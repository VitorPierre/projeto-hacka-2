# Este arquivo é dedicado exclusivamente ao catálogo estrutural do sistema (dados de referência).
# NÃO utilize este arquivo para criar dados mockados (usuários falsos, propostas fakes).
# O uso deste seed garante que o sistema possua os domínios básicos para funcionar.

puts "Iniciando carga de catálogos estruturais..."

# 1. Áreas de Ensino / Interesse (Subjects)
# Estas são as áreas que conectam Alunos a Professores.
puts "-> Cadastrando Áreas de Ensino..."
areas = [
  "Matemática",
  "Álgebra",
  "Geometria",
  "Cálculo",
  "Estatística",
  "Física",
  "Química",
  "Biologia",
  "Ecologia",
  "Anatomia",
  "Genética",
  "História",
  "Geografia",
  "Filosofia",
  "Sociologia",
  "Psicologia",
  "Pedagogia",
  "Economia",
  "Língua Portuguesa",
  "Literatura",
  "Redação",
  "Inglês",
  "Espanhol",
  "Francês",
  "Alemão",
  "Italiano",
  "Libras",
  "Programação",
  "Python",
  "JavaScript",
  "Ruby",
  "Java",
  "Inteligência Artificial",
  "Data Science",
  "Segurança da Informação",
  "UX/UI Design",
  "Banco de Dados",
  "Design",
  "Música",
  "Artes",
  "Educação Financeira",
  "Contabilidade",
  "Administração",
  "Marketing",
  "Empreendedorismo",
  "Pacote Office",
  "Google Workspace",
  "Nutrição",
  "Empreendedorismo",
  "Redação para ENEM",
  "Redação para Concursos",
  "Redação para Vestibulares",
  "Preparatóroio para OAB",
  "Preparatório ENEM",
  "Preparatório Concursos",
  "Preparatório Residecia Médica"
]

areas.each do |area|
  # find_or_create_by! garante que não haverá duplicação se o seed rodar mais de uma vez.
  Subject.find_or_create_by!(name: area)
end
puts "   #{Subject.count} áreas cadastradas/verificadas."

# 2. Escolaridades (Education Levels)
# Nota: No aprendeAI, os níveis de escolaridade (básico, técnico, superior)
# foram modelados como um Enum no Active Record (User.education_levels).
# Por isso, não precisam de tabela própria no banco nem de inserção via seed.
# Eles já estão disponíveis estruturalmente no código.

puts "Carga de catálogos concluída com sucesso!"
