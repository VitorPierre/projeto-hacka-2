require 'fileutils'

files = Dir.glob("app/views/**/*.html.erb")

files.each do |file|
  content = File.read(file)
  
  # Replace backgrounds
  content.gsub!(/bg-slate-50/, "bg-surface-bg dark:bg-slate-900")
  content.gsub!(/bg-white/, "bg-surface-bg dark:bg-slate-800")
  content.gsub!(/bg-blue-600/, "bg-brand dark:bg-[#25D35C]")
  content.gsub!(/bg-blue-700/, "bg-brand-hover dark:bg-[#1DB84E]")
  content.gsub!(/bg-blue-50/, "bg-[#e8f7ec] dark:bg-slate-700")
  content.gsub!(/bg-slate-100/, "bg-surface-sec dark:bg-slate-700")
  
  # Replace texts
  content.gsub!(/text-white/, "text-[#F4FBF6]")
  content.gsub!(/text-slate-900/, "text-slate-900 dark:text-[#F4FBF6]")
  content.gsub!(/text-slate-800/, "text-slate-800 dark:text-[#e8f7ec]")
  content.gsub!(/text-slate-700/, "text-slate-700 dark:text-[#C2E8CF]")
  content.gsub!(/text-slate-600/, "text-slate-600 dark:text-slate-300")
  content.gsub!(/text-slate-500/, "text-slate-500 dark:text-slate-400")
  content.gsub!(/text-blue-600/, "text-brand dark:text-[#25D35C]")
  content.gsub!(/text-blue-700/, "text-brand-hover dark:text-[#1DB84E]")
  
  # Replace borders
  content.gsub!(/border-slate-200/, "border-surface-sec dark:border-slate-700")
  content.gsub!(/border-slate-300/, "border-surface-sec dark:border-slate-600")
  content.gsub!(/border-blue-600/, "border-brand dark:border-[#25D35C]")
  content.gsub!(/border-blue-200/, "border-surface-sec dark:border-slate-700")
  
  # Replace rings
  content.gsub!(/focus:ring-blue-500/, "focus:ring-brand dark:focus:ring-[#25D35C]")
  
  File.write(file, content)
end

puts "Replacements done!"
