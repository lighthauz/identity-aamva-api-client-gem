require 'rexml/document'
require 'rexml/xpath'

module Aamva
  module Response
    class VerificationResponse
      VERIFICATION_ATTRIBUTES_MAP = {
        'DriverLicenseNumberMatchIndicator' => :state_id_number,
        'PersonBirthDateMatchIndicator' => :dob,
        'PersonLastNameExactMatchIndicator' => :last_name,
        'PersonLastNameFuzzyPrimaryMatchIndicator' => :last_name_fuzzy,
        'PersonLastNameFuzzyAlternateMatchIndicator' => :last_name_fuzzy_alternate,
        'PersonFirstNameExactMatchIndicator' => :first_name,
        'PersonFirstNameFuzzyPrimaryMatchIndicator' => :first_name_fuzzy,
        'PersonFirstNameFuzzyAlternateMatchIndicator' => :first_name_fuzzy_alternate,
        'PersonMiddleNameExactMatchIndicator' => :middle_name,
        'PersonMiddleNameFuzzyPrimaryMatchIndicator' => :middle_name_fuzzy,
        'PersonMiddleNameFuzzyAlternateMatchIndicator' => :middle_name_fuzzy_alternate,
        'PersonMiddleInitialMatchIndicator' => :middle_initial,
        'PersonNameSuffixMatchIndicator' => :name_suffix,
        'DocumentCategoryMatchIndicator' => :state_id_type,
        'DriverLicenseIssueDateMatchIndicator' => :issued_at,
        'DriverLicenseExpirationDateMatchIndicator' => :expires_at,
        'PersonSexCodeMatchIndicator' => :sex,
        'PersonHeightMatchIndicator' => :height,
        'PersonWeightMatchIndicator' => :weight,
        'PersonEyeColorMatchIndicator' => :eye_color,
        'AddressLine1MatchIndicator' => :address1,
        'AddressLine2MatchIndicator' => :address2,
        'AddressCityMatchIndicator' => :city,
        'AddressStateCodeMatchIndicator' => :state,
        'AddressZIP5MatchIndicator' => :zipcode,
        'AddressZIP4MatchIndicator' => :zipcode4
      }.freeze

      REQUIRED_VERIFICATION_ATTRIBUTES = %i[
        state_id_number
        dob
        last_name
        first_name
      ].freeze

      attr_reader :verification_results

      def initialize(http_response)
        @missing_attributes = []
        @verification_results = {}
        @http_response = http_response
        handle_timeout_error
        handle_soap_error
        handle_http_error
        parse_response
      end

      def reasons
        REQUIRED_VERIFICATION_ATTRIBUTES.map do |verification_attribute|
          verification_result = verification_results[verification_attribute]
          case verification_result
          when false
            "Failed to verify #{verification_attribute}"
          when nil
            "Response was missing #{verification_attribute}"
          end
        end.compact
      end

      def success?
        REQUIRED_VERIFICATION_ATTRIBUTES.each do |verification_attribute|
          return false unless verification_results[verification_attribute]
        end
        true
      end

      private

      attr_reader :http_response, :missing_attributes

      def handle_timeout_error
        TimeoutErrorHandler.new(
          http_response: http_response, context: :verification
        ).call
      end

      def handle_http_error
        status = http_response.code
        return if status == 200
        raise VerificationError, "Unexpected status code in response: #{status}"
      end

      def handle_missing_attribute(attribute_name)
        missing_attributes.push(attribute_name)
        verification_results[attribute_name] = nil
      end

      def handle_soap_error
        error_handler = SoapErrorHandler.new(http_response)
        return unless error_handler.error_present?

        if error_handler.errors.empty?
          raise VerificationError, error_handler.error_message
        else
          raise VerificationSoapFault.new(error_handler.error_message, error_handler.errors)
        end
      end

      def node_for_match_indicator(match_indicator_name)
        REXML::XPath.first(rexml_document, "//#{match_indicator_name}")
      end

      def parse_response
        VERIFICATION_ATTRIBUTES_MAP.each_pair do |match_indicator_name, attribute_name|
          attribute_node = node_for_match_indicator(match_indicator_name)
          if attribute_node.nil?
            handle_missing_attribute(attribute_name)
          elsif attribute_node.text == 'true'
            verification_results[attribute_name] = true
          else
            verification_results[attribute_name] = false
          end
        end
      end

      def rexml_document
        @rexml_document ||= REXML::Document.new(http_response.body)
      end
    end
  end
end
