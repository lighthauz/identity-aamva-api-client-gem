require 'dotenv'

Dotenv.load(File.expand_path('../.env', File.dirname(__FILE__)))

$:.unshift File.expand_path('../lib', File.dirname(__FILE__))

public_pem_path = File.expand_path(ENV['PUBLIC_PEM_PATH'])
private_pem_path = File.expand_path(ENV['PRIVATE_PEM_PATH'])
cert_password = ENV['CERT_PASSWORD']

require 'savon'
require 'logger'
require 'aamva'

auth_client = Savon.client(
  wsdl: AAMVA::WSDL.authentication,
  ssl_cert_file: public_pem_path,
  ssl_cert_key_file: private_pem_path,
  ssl_cert_key_password: cert_password,

  # want these off in prod for sure
  logger: Logger.new(STDOUT),
  log_level: :debug,
  log: true,
)

begin
  x = auth_client.call(:authenticate, message: {})
rescue => e
  require 'pry-byebug'
  binding.pry
end

puts 'x'
