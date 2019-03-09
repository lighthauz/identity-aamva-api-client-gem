
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
        name_suffix: 'JR',
        dob: '1980-01-01',
        eye_color: 'BRO',
        sex: '1',
        address1: '4301 Wilson Blvd',
        address2: '1234',
        city: 'Arlington',
        state: 'VA',
        zipcode: '22203',
        height: '510',
        weight: '200',
        expires_at: '20231010',
        issued_at: '20111010',
      }))

      response = Aamva::VerificationClient.new.send_verification_request(applicant: aamva_applicant)

      expect(response.verification_results).to eq(expected(
        state_id_number: true,
        state_id_type: true,
        first_name: true,
        last_name: true,
        middle_name: true,
        name_suffix: true,
        dob: true,
        sex: true,
        eye_color: true,
        expires_at: true,
        issued_at: true,
        height: true,
        weight: true,
        address1: true,
        address2: true,
        city: true,
        state: true,
        zipcode: true,
      ))
    end
  end

  def expected(values)
    {
      state_id_number: nil,
      first_name: nil,
      first_name_fuzzy: nil,
      first_name_fuzzy_alternate: nil,
      last_name: nil,
      last_name_fuzzy: nil,
      last_name_fuzzy_alternate: nil,
      middle_name: nil,
      middle_name_fuzzy: nil,
      name_suffix: nil,
      dob: nil,
      state_id_type: nil,
      sex: nil,
      eye_color: nil,
      expires_at: nil,
      issued_at: nil,
      height: nil,
      weight: nil,
      address1: nil,
      address2: nil,
      city: nil,
      state: nil,
      zipcode: nil,
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
