# list_simple.rb
require 'net/http'
require 'json'

api_key = ENV['GEMINI_API_KEY']
uri = URI("https://generativelanguage.googleapis.com/v1beta/models?key=#{api_key}")
response = Net::HTTP.get(uri)
json = JSON.parse(response)
json['models'].each do |m|
  puts m['name'] if m['supportedGenerationMethods'].include?('generateContent')
end
