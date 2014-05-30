# kensa run ruby development/heroku_test_provision.rb
api_values = {
  public_key: ENV['CINE_IO_PUBLIC_KEY'],
  secret_key: ENV['CINE_IO_SECRET_KEY']
}

if api_values.fetch(:public_key) && api_values.fetch(:secret_key)
  puts "I got cine.io public key and secret: #{api_values.inspect}"
else
  abort "Failed to get public key #{api_values.inspect}"
end
