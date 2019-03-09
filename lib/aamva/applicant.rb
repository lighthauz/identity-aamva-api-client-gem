require 'date'
require 'hashie/mash'

module Aamva
  class Applicant < Hashie::Mash
    def self.from_proofer_applicant(applicant)
      new(
        uuid: applicant[:uuid],
        first_name: applicant[:first_name],
        middle_name: applicant[:middle_name],
        last_name: applicant[:last_name],
        name_suffix: applicant[:name_suffix],
        issued_at: format_date(applicant[:issued_at]),
        expires_at: format_date(applicant[:expires_at]),
        dob: format_date(applicant[:dob]),
        state_id_data: format_state_id_data(applicant),
        sex: applicant[:sex],
        eye_color: applicant[:eye_color],
        height: applicant[:height],
        weight: applicant[:weight],
        address1: applicant[:address1],
        address2: applicant[:address2],
        city: applicant[:city],
        state: applicant[:state],
        zipcode: applicant[:zipcode],
      )
    end

    private_class_method def self.format_date(dob)
      return dob if dob =~ /\A\d{4}-\d{2}-\d{2}\z/
      return nil if dob.nil? || dob == ''

      date = date_from_string(dob)

      return nil if date.nil?
      date.strftime('%Y-%m-%d')
    end

    private_class_method def self.date_from_string(dob_string)
      if dob_string =~ /\A\d{8}\z/
        Date.strptime(dob_string, '%Y%m%d')
      elsif dob_string =~ %r{\A\d{2}/\d{2}/\d{4}\z}
        Date.strptime(dob_string, '%m/%d/%Y')
      end
    end

    private_class_method def self.format_state_id_data(applicant)
      {
        state_id_number: applicant[:state_id_number],
        state_id_jurisdiction: applicant[:state_id_jurisdiction],
        state_id_type: applicant[:state_id_type],
      }
    end
  end
end
