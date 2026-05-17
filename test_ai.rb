# test_ai.rb
user = User.find_by(role: "student") || User.first
question = "O que é fotossíntese?"
puts "Testando AiService com pergunta: #{question}"
puts "User Role: #{user&.role}"
puts "API Key present: #{ENV['GEMINI_API_KEY'].present?}"

response = AiService.call(user, question)
puts "--- RESPOSTA ---"
puts response
puts "--- FIM ---"
