# kensa run ruby development/heroku_test_provision.rb
api_values = {
  api_key: ENV['CINE_IO_API_KEY'],
  api_secret: ENV['CINE_IO_API_SECRET']
}

if api_values.fetch(:api_key) != '' && api_values.fetch(:api_secret) != ''
  puts "I got cine.io public key and secret: #{api_values.inspect}"
else
  abort "Failed to get public key #{api_values.inspect}"
end
