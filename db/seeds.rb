puts "-> Cadastrando Usuário Administrador..."
admin = User.find_or_initialize_by(email: "admin@aprendeai.com") do |u|
  u.name = "Administrador do Sistema"
  u.password = "123456"
  u.role = :teacher
  u.education_level = :higher
  u.phone = "11999999999"
  u.cpf = "11122233344"
  u.certified = true
end
admin.admin = true
admin.save!(validate: false)
puts "   Administrador cadastrado: #{admin.email}"

puts "Carga de catálogos concluída com sucesso!"
