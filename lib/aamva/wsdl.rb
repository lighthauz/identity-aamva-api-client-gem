module AAMVA
  class WSDL
    WSDL_DIRECTORY = File.expand_path('wsdl', File.dirname(__FILE__))

    def self.batch
      File.join(WSDL_DIRECTORY, 'aamva.vs.dldv21.batch.wsdl')
    end

    def self.online
      File.join(WSDL_DIRECTORY, 'aamva.vs.dldv21.online.wsdl')
    end

    def self.valuefree
      File.join(WSDL_DIRECTORY, 'aamva.vs.dldv21.valuefree.wsdl')
    end

    def self.valuepaid
      File.join(WSDL_DIRECTORY, 'aamva.vs.dldv21.valuepaid.wsdl')
    end

    def self.authentication
      File.join(WSDL_DIRECTORY, 'Authenticate-Service.wsdl')
    end
  end
end
