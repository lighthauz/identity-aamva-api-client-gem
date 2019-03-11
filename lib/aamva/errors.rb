module Aamva
  class AuthenticationError < StandardError; end

  class VerificationError < StandardError; end

  class VerificationSoapFault < VerificationError
    attr_reader :errors

    def initialize(message, errors)
      super(message)
      @errors = errors
    end
  end
end
