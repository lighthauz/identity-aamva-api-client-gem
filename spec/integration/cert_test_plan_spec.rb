
describe 'Cert Structured Test Plan' do
  before do
    Dotenv.load.each do |key, value|
      ENV[key] = value
    end
    WebMock.allow_net_connect!
  end

  after do
    EnvOverrides.set_test_environment_variables
    WebMock.disable_net_connect!
  end

  context 'Test Case #1' do
    it 'should pass' do
      aamva_applicant = Aamva::Applicant.from_proofer_applicant(OpenStruct.new({
        uuid: SecureRandom.uuid,
        state_id_number: 'DLDVSTRUCTUREDTEST11',
        state_id_jurisdiction: '22203',
        state_id_type: state_id_type_from_category('1'),
        first_name: 'STEVEN',
        last_name: 'BROWN',
        dob: '1980-01-01',
      }))

      response = Aamva::VerificationClient.new.send_verification_request(applicant: aamva_applicant)

      expected_fields = [
        :state_id_number,
        :first_name,
        :last_name,
        :dob,
        :state_id_type
      ]

      expect_fields_present(response, expected_fields)
      expect_fields_matched(response, expected_fields)
    end
  end

  context 'Test Case #2' do
    it 'should pass' do
      aamva_applicant = Aamva::Applicant.from_proofer_applicant(OpenStruct.new({
        uuid: SecureRandom.uuid,
        state_id_number: 'DLDVSTRUCTUREDTEST12',
        state_id_jurisdiction: '22203',
        state_id_type: state_id_type_from_category('1'),
        first_name: 'STEVEN',
        last_name: 'BROWN',
        middle_name: 'DANIEL',
        suffix: 'JR',
        dob: '1980-01-01',
        eye_color: 'BRO',
        sex: '1',
        address_line_1: '4301 Wilson Blvd',
        address_line_2: '1234',
        city: 'Arlington',
        state: 'VA',
        height: '510',
        weight: '200',
        expires_at: '20231010',
        issued_at: '20111010'
      }))

      response = Aamva::VerificationClient.new.send_verification_request(applicant: aamva_applicant)

      expected_fields = [
        :state_id_number,
        :state_id_type,
        :first_name,
        :last_name,
        :dob,
        # :eye_color,
        # :sex,
        # :address_line_1,
        # :address_line_2,
        # :city,
        # :state,
        # :height,
        # :weight,
        # :expires_at,
        # :issued_at,
      ]

      expect_fields_present(response, expected_fields)
      expect_fields_matched(response, expected_fields)
    end
  end


  def expect_fields_present(response, fields)
    expect(response.verification_results.keys.sort).to eq(fields.sort)
  end

  def expect_fields_matched(response, fields)
    fields.each { |field| expect(response.verification_results[field]).to eq(true) }
  end

  def state_id_type_from_category(category)
    case category
    when '1'
      'drivers_license'
    when '2'
      'drivers_permit'
    when '3'
      'state_id_card'
    end
  end
end
