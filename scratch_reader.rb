# scratch_reader.rb
content = File.read("test_output.txt", encoding: "UTF-16LE:UTF-8", invalid: :replace, undef: :replace)
if idx = content.index("Erro ao adicionar")
  puts "FOUND ALERT MESSAGE:"
  puts content[idx, 200]
else
  puts "Alert not found in HTML output."
end
