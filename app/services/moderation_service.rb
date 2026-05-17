require 'yaml'

class ModerationService
  # Mapa de caracteres comuns usados para burlar a moderação (leetspeak e homóglifos Unicode)
  CHAR_MAP = {
    'a' => '[aáàâãä4@аα]',
    'b' => '[b8вβ]',
    'c' => '[cç¢сκ]',
    'd' => '[dⅾ]',
    'e' => '[eéèêë3еεη]',
    'f' => '[fƒ]',
    'g' => '[g9]',
    'h' => '[hн]',
    'i' => '[iíìîï1!|lі]',
    'j' => '[j]',
    'k' => '[kκ]',
    'l' => '[l1!|]',
    'm' => '[mмμ]',
    'n' => '[nν]',
    'o' => '[oóòôõö0оο]',
    'p' => '[pр]',
    'q' => '[q]',
    'r' => '[rρ]',
    's' => '[s5$с]',
    't' => '[t7+τ]',
    'u' => '[uúùûüμυ]',
    'v' => '[vν]',
    'w' => '[w]',
    'x' => '[xхχ]',
    'y' => '[yуυ]',
    'z' => '[z2]'
  }.freeze

  # Mapa reverso para normalização direta de string (substitui caracteres exóticos por equivalentes normais)
  NORMALIZATION_MAP = {
    # Números e leetspeak comuns
    '0' => 'o', '1' => 'i', '3' => 'e', '4' => 'a', '5' => 's', '7' => 't', '8' => 'b', '9' => 'g',
    '@' => 'a', '$' => 's', '!' => 'i', '|' => 'i', '+' => 't',
    # Homóglifos cirílicos comuns
    'а' => 'a', 'е' => 'e', 'о' => 'o', 'р' => 'r', 'с' => 's', 'у' => 'y', 'х' => 'x', 'і' => 'i', 'н' => 'h', 'т' => 't', 'м' => 'm', 'к' => 'k', 'в' => 'v',
    # Homóglifos gregos comuns
    'α' => 'a', 'ε' => 'e', 'ο' => 'o', 'ρ' => 'r', 'τ' => 't', 'υ' => 'y', 'χ' => 'x', 'κ' => 'k', 'η' => 'e', 'ν' => 'n', 'μ' => 'm'
  }.freeze

  # Retorna a lista de termos bloqueados configurados no arquivo YAML
  def self.blacklist
    @blacklist ||= begin
      file_path = Rails.root.join('config', 'moderation_blacklist.yml')
      if File.exist?(file_path)
        data = YAML.load_file(file_path)
        data['blocked_terms'] || []
      else
        []
      end
    rescue => e
      Rails.logger.error "Erro ao carregar lista de bloqueio de moderação: #{e.message}"
      []
    end
  end

  # Limpa o cache da blacklist (útil se o arquivo mudar durante execução ou testes)
  def self.clear_cache!
    @blacklist = nil
    @regex_cache = {}
  end

  # Constrói ou obtém uma expressão regular otimizada para detectar o termo com variações de espaçamento, símbolos e repetições
  def self.regex_for(term)
    @regex_cache ||= {}
    @regex_cache[term] ||= begin
      # Translitera acentos básicos
      clean_term = ActiveSupport::Inflector.transliterate(term.to_s.downcase.strip)
      
      parts = []
      clean_term.each_char do |char|
        if char =~ /\s/
          # Para espaços no termo bloqueado, casa qualquer sequência de espaços ou caracteres não-alfanuméricos
          parts << '[^\p{Alnum}]+'
        elsif CHAR_MAP[char]
          # Casa a classe de equivalentes do caractere (com repetição opcional de 1 ou mais vezes)
          parts << "#{CHAR_MAP[char]}+"
        else
          # Fallback para outros caracteres
          parts << "#{Regexp.escape(char)}+"
        end
      end

      # Une as partes permitindo opcionalmente símbolos não-alfanuméricos entre as letras
      pattern_str = ""
      parts.each_with_index do |part, idx|
        pattern_str << part
        if idx < parts.size - 1
          # Evita duplicar separadores se um deles já for delimitador de espaço
          unless parts[idx] == '[^\p{Alnum}]+' || parts[idx + 1] == '[^\p{Alnum}]+'
            pattern_str << '[^\p{Alnum}]*'
          end
        end
      end

      # Exige limites de palavra nas pontas para evitar falsos positivos em substrings curtas
      # Exemplo: não deve casar "cu" dentro de "Marcus" ou "culinária"
      # Usamos (?:[^a-zA-Z0-9]|\A) no início e (?:[^a-zA-Z0-9]|\z) no final
      Regexp.new("(?:[^a-zA-Z0-9]|\\A)#{pattern_str}(?:[^a-zA-Z0-9]|\\z)", Regexp::IGNORECASE)
    end
  end

  # Normaliza um texto para um formato simplificado (sem acentos, leetspeak, homóglifos, letras repetidas)
  def self.normalize_text(text)
    return "" if text.blank?

    # 1. Converte para minúsculas e translitera acentos
    normalized = text.to_s.downcase.strip
    normalized = ActiveSupport::Inflector.transliterate(normalized)

    # 2. Substitui homóglifos e leetspeak usando o mapa de normalização direta
    normalized = normalized.chars.map { |c| NORMALIZATION_MAP[c] || c }.join

    # 3. Comprime letras repetidas consecutivas (ex: "booooboooo" -> "bobo")
    # Mantém no máximo uma repetição (para preservar palavras legítimas com letras duplas como ss/rr se houver)
    # Mas para moderação, reduzir tudo a apenas letras simples é super eficaz.
    normalized = normalized.gsub(/(.)\1+/, '\1')

    normalized
  end

  # Verifica se o texto contém conteúdo impróprio ou ofensivo
  def self.inappropriate?(text)
    return false if text.blank?

    # 1. Checagem direta usando as expressões regulares dinâmicas baseadas na blacklist
    blacklist.each do |term|
      regex = regex_for(term)
      if text =~ regex
        log_blocked_attempt(text, term, "Regex Match")
        return true
      end
    end

    # 2. Checagem complementar normalizando totalmente o texto e termos
    # Isso ajuda a pegar casos extremos onde o espaçamento ou repetição tenta quebrar limites normais.
    normalized_text = normalize_text(text)

    blacklist.each do |term|
      normalized_term = normalize_text(term)
      next if normalized_term.blank?

      # Se o termo for longo (>= 5 caracteres), verificamos se ele existe como substring no texto sem espaços
      if normalized_term.length >= 5
        squashed_text = normalized_text.gsub(/\s+/, '')
        squashed_term = normalized_term.gsub(/\s+/, '')
        if squashed_text.include?(squashed_term)
          log_blocked_attempt(text, term, "Squashed Substring Match")
          return true
        end
      else
        # Para termos curtos (< 5 caracteres), dividimos o texto em tokens para evitar falsos positivos
        tokens = normalized_text.split(/[^\p{Alnum}]+/)
        tokens.each do |token|
          # Bloqueia se o token for idêntico ao termo ou se o token começar com o termo (ex: "bobos" começa com "bobo")
          if token == normalized_term || (normalized_term.length >= 4 && token.start_with?(normalized_term))
            log_blocked_attempt(text, term, "Token Match")
            return true
          end
        end
      end
    end

    false
  end

  private

  # Registra no log do Rails a tentativa imprópria para auditoria
  def self.log_blocked_attempt(text, matched_term, strategy)
    Rails.logger.warn "[AUDIT MODERAÇÃO] Tentativa de cadastro/salvamento bloqueada! Texto: '#{text}' | Termo detectado: '#{matched_term}' | Estratégia: #{strategy}"
  end
end
