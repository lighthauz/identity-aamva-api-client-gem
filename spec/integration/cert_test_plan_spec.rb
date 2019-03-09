
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

      expect(response.verification_results).to eq(expected(
        state_id_number: true,
        state_id_type: true,
        first_name: true,
        last_name: true,
        dob: true,
      ))
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

      expect(response.verification_results).to eq(expected(
        state_id_number: true,
        state_id_type: true,
        first_name: true,
        last_name: true,
        dob: true,
        sex: true,
        eye_color: true,
      ))
    end
  end

  def expected(values)
    {
      state_id_number: nil,
      first_name: nil,
      last_name: nil,
      dob: nil,
      state_id_type: nil,
      sex: nil,
      eye_color: nil,
    }.merge(values)
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
