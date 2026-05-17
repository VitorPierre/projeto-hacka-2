# list_models.rb
require 'net/http'
require 'json'

api_key = ENV['GEMINI_API_KEY']
uri = URI("https://generativelanguage.googleapis.com/v1beta/models?key=#{api_key}")

response = Net::HTTP.get_response(uri)
puts "Status: #{response.code}"
puts "Body: #{response.body}"
