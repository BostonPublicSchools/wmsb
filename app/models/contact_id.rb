class ContactId
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  CLIENT_CODE = "wmsb".freeze

  class_attribute :connection, instance_writer: false
  self.connection = Faraday.new ENV['BPS_API'], ssl: {
      ca_file: Rails.root.join('lib', 'certs', 'SVRIntlG3.crt').to_s
  }
  attr_reader :contact_id, :errors, :parentLastName, :studentNo

  validates :parentLastName, :studentNo, :studentDob, presence: true

  def initialize(attributes = {})
    @attributes = attributes

    @parentLastName    = @attributes['parentLastName']
    @studentNo = @attributes['studentNo']
    @month = @attributes['studentDob(2i)']
    @date = @attributes['studentDob(3i)']
    @year = @attributes['studentDob(1i)']

    @errors = ActiveModel::Errors.new(self)
  end

  def authenticate!
    connection.headers = {BpsToken: ENV['SERVICE_HEADER_KEY']}
    response = connection.post(
        '/BPSRegistrationService/api/Transportation/ValidStudent',
        clientcode: CLIENT_CODE,
        parentLastName: parentLastName,
        studentNo: studentNo,
        studentDob: formatted_date_of_birth,
        )

    @contact_id = response.body.gsub('"', '')
    if @contact_id.include?("true") && response.success?
      # The response is not a proper JSON object so JSON.parse('"000"') will
      # choke. Remove the quotes.
      @contact_id = @contact_id
    else
      @errors.add(:aspen_contact_id, "could not be retreived (#{response.status})")
      @contact_id = ''
    end

    @contact_id.present?
  end

  def studentDob
    @studentDob ||= Time.zone.local(
        @attributes['studentDob(1i)'].to_i,
        @attributes['studentDob(2i)'].to_i,
        @attributes['studentDob(3i)'].to_i
    )
  rescue
    nil
  end

  def formatted_date_of_birth
    studentDob.strftime('%m/%d/%Y')
  end

  def persisted?
    false
  end

  private

  def username
    ENV['BPS_USERNAME']
  end

  def password
    ENV['BPS_PASSWORD']
  end
end
