# Este arquivo é dedicado exclusivamente ao catálogo estrutural do sistema (dados de referência).
# NÃO utilize este arquivo para criar dados mockados (usuários falsos, propostas fakes).
# O uso deste seed garante que o sistema possua os domínios básicos para funcionar.

puts "Iniciando carga de catálogos estruturais..."

# 1. Áreas de Ensino / Interesse (Subjects)
# Estas são as áreas que conectam Alunos a Professores.
puts "-> Cadastrando Áreas de Ensino..."
areas = [
  "Matemática",
  "Física",
  "Química",
  "Biologia",
  "História",
  "Geografia",
  "Língua Portuguesa",
  "Literatura",
  "Redação",
  "Inglês",
  "Espanhol",
  "Programação",
  "Design",
  "Música",
  "Artes",
  "Educação Financeira",
  "Preparatório ENEM",
  "Preparatório Concursos"
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
