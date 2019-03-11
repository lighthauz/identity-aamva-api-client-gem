require 'rexml/document'
require 'rexml/xpath'

module Aamva
  class SoapErrorHandler
    attr_reader :error_message

    def initialize(http_response)
      @document = REXML::Document.new(http_response.body)
      @errors = []

      parse_errors
    end

    def error_present?
      @error_present
    end

    def errors
      @errors
    end

    private

    attr_reader :document

    def add_program_exception_messages
      return if program_exception_nodes.empty?
      @error_message += ' - ' + raw_errors.map do |raw_error|
        program_exception_message_for_exception_node(raw_error)
      end.join(' ; ')
    end

    def parse_errors
      @error_present = !soap_fault_node.nil?
      return unless error_present?

      @errors = raw_errors.map { |raw_error| map_error(raw_error) }
      @error_message = soap_error_reason_text_node&.text || 'A SOAP error occurred'
      add_program_exception_messages
    end

    def map_error(raw_error)
      {
        id: raw_error['ExceptionId'],
        text: raw_error['ExceptionText'],
        type: raw_error['ExceptionTypeCode'],
        fatal: raw_error['ExceptionFatalIndicatorCode'].nil? ? nil : 'true' == raw_error['ExceptionFatalIndicatorCode'],
        actor: raw_error['ExceptionActorText'],
      }
    end

    def raw_errors
      @raw_errors ||= program_exception_nodes.map do |raw_error|
        parse_raw_error(raw_error)
      end
    end

    def parse_raw_error(exception_node)
      exception_node.children.map do |child|
        next unless child.node_type == :element
        [child.name, child.text]
      end.compact.to_h
    end

    def program_exception_message_for_exception_node(raw_error)
      raw_error.map do |name, text|
        "#{name}: #{text}"
      end.join(', ')
    end

    def program_exception_nodes
      @nodes ||= REXML::XPath.match(document, '//ProgramExceptions/ProgramException')
    end

    def soap_error_reason_text_node
      REXML::XPath.first(
        document,
        '//soap-envelope:Reason/soap-envelope:Text',
        'soap-envelope' => 'http://www.w3.org/2003/05/soap-envelope'
      )
    end

    def soap_fault_node
      REXML::XPath.first(
        document,
        '//soap-envelope:Fault',
        'soap-envelope' => 'http://www.w3.org/2003/05/soap-envelope'
      )
    end
  end
end
