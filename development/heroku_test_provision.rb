api_key = ENV['CINE_IO_API_KEY']

if api_key != ''
  puts "I got cine.io api key #{api_key}"
else
  abort "Failed to get api key"
end
