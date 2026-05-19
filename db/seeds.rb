# Este arquivo é dedicado exclusivamente ao catálogo estrutural do sistema (dados de referência).
# NÃO utilize este arquivo para criar dados mockados (usuários falsos, propostas fakes).
# O uso deste seed garante que o sistema possua os domínios básicos para funcionar.

puts "Iniciando carga de catálogos estruturais..."

# 1. Áreas de Ensino / Interesse (Subjects)
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
  Subject.find_or_create_by!(name: area)
end
puts "   #{Subject.count} áreas cadastradas/verificadas."
