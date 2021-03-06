module Aamva
  module Response
    class AuthenticationTokenResponse
      attr_reader :auth_token

      def initialize(http_response)
        @http_response = http_response
        handle_timeout_error
        handle_soap_error
        handle_http_error
        parse_response
      end

      private

      attr_reader :http_response
      attr_writer :auth_token

      def handle_timeout_error
        TimeoutErrorHandler.new(
          http_response: http_response, context: 'authentication token'
        ).call
      end

      def handle_http_error
        status = http_response.code
        return if status == 200
        raise AuthenticationError, "Unexpected status code in response: #{status}"
      end

      def handle_soap_error
        error_handler = SoapErrorHandler.new(http_response)
        return unless error_handler.error_present?
        raise AuthenticationError, error_handler.error_message
      end

      def handle_missing_token_error(token_node)
        return unless token_node.nil?
        raise AuthenticationError, 'The authentication response is missing a token'
      end

      def parse_response
        document = REXML::Document.new(http_response.body)
        token_node = REXML::XPath.first(document, '//Token')
        handle_missing_token_error(token_node)
        self.auth_token = token_node.text
      end
    end
  end
end
