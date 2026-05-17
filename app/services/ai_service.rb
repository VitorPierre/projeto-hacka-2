require "net/http"
require "json"

class AiService
  GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"

  def self.call(user, question)
    new(user, question).execute
  end

  def initialize(user, question)
    @user = user
    @question = question
    @api_key = ENV["GEMINI_API_KEY"]
  end

  def execute
    return "Por favor, faça uma pergunta sobre educação." if @question.blank?

    # Proactive off-topic check to save resources
    unless education_related?(@question)
      return "Como assistente do aprendeAI, meu foco é exclusivamente em educação e apoio pedagógico. Como posso te ajudar nos seus estudos?"
    end

    prompt = build_prompt
    
    if @api_key.present?
      response = call_api(prompt)
      return response if response.present?
    end

    # Fallback response if API key is missing or call fails
    generate_fallback_response
  end

  private

  def build_prompt
    role_context = if @user.teacher?
      "Você é um assistente pedagógico para professores. Sua missão é ajudar na criação de planos de aula, sugestões de atividades e organização de ensino. Fale estritamente sobre educação."
    else
      "Você é um assistente de estudos para alunos. Responda de forma curta, clara e objetiva. Se o tema for complexo, sugira que o aluno procure um professor especializado na plataforma aprendeAI. Fale estritamente sobre educação."
    end

    "Contexto: #{role_context}\n\nPergunta do usuário: #{@question}\n\nImportante: Se a pergunta não for sobre educação ou temas acadêmicos, responda educadamente que você só pode falar sobre educação."
  end

  def call_api(prompt)
    uri = URI("#{GEMINI_API_URL}?key=#{@api_key}")
    header = { "Content-Type": "application/json" }
    body = {
      contents: [
        { parts: [ { text: prompt } ] }
      ]
    }.to_json

    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = body
      
      response = http.request(request)
      
      if response.code == "200"
        json = JSON.parse(response.body)
        answer = json.dig("candidates", 0, "content", "parts", 0, "text")
        if answer.present?
          return answer
        else
          Rails.logger.error "Resposta da IA veio vazia: #{response.body}"
          nil
        end
      else
        # Log the error code and body (redacting key just in case it appears in logs)
        Rails.logger.error "Erro na API Gemini (Status #{response.code}): #{response.body.gsub(@api_key, '[REDACTED]')}"
        nil
      end
    rescue => e
      # We log the error but avoid exposing the URI/API Key by not logging the exception object directly
      Rails.logger.error "Exceção na chamada da API de IA: #{e.class} - #{e.message.gsub(@api_key, '[REDACTED]')}"
      nil
    end
  end

  def education_related?(text)
    text.downcase.match?(/aula|estudo|escola|aprender|ensinar|materia|matematica|portugues|ciencia|historia|geografia|plano|pedagogia|como|que|porque|expliqu|ajud|quem|onde|quando|qual/)
  end

  def generate_fallback_response
    if @user.teacher?
      "Ótima iniciativa! Para o tema '#{@question}', recomendo estruturar seu plano de aula com: 1. Objetivos de aprendizagem; 2. Conteúdo programático; 3. Metodologia ativa; 4. Avaliação formativa. Deseja que eu detalhe algum desses pontos para sua aula?"
    else
      "Sobre '#{@question}': É um tema fundamental. Recomendo focar nos conceitos base e praticar exercícios. Caso sinta dificuldade, não hesite em buscar um dos nossos professores especializados aqui no aprendeAI para uma mentoria personalizada!"
    end
  end
end
