class AssignmentSearch
  extend ActiveModel::Translation
  CLIENT_CODE = "wmsb".freeze

  class_attribute :connection, instance_writer: false
  self.connection = Faraday.new ENV['BPS_API'], ssl: {
    ca_file: Rails.root.join('lib', 'certs', 'SVRIntlG3.crt').to_s
  }

  attr_reader :assignments, :errors

  def self.find(aspen_contact_id)
    new(aspen_contact_id).find
  end

  def initialize(aspen_contact_id)
    @aspen_contact_id = aspen_contact_id
    @errors           = ActiveModel::Errors.new(self)
  end

  def find
    response_body =  Rails.cache.fetch(cache_key, expires_in: 12.hours) do
      connection.headers = {BpsToken: ENV['SERVICE_HEADER_KEY']}
      if trip_flag == "departure"
        tripflag = "outbound"
      elsif trip_flag == "arrival"
        tripflag = "inbound"
      end
      binding.pry
      response = connection.get(
          '/BPSRegistrationService/api/Transportation/BusAssignments',
          clientcode: CLIENT_CODE,
          studentNo: @aspen_contact_id,
          tripFlag: tripflag
      )

      if !response.success?
        @errors.add(:assignments, :missing)
      end
      response.success? ? response.body : nil
    end

    if response_body.present?
      assignments = JSON.parse(response_body)
      @assignments = assignments.map do |assignment|
        BusAssignment.new(assignment, trip_flag)
      end
    else
      @assignments = []
    end

    return self
  end

  def assignments_with_gps_data
    assignments.select(&:gps_available?)
  end

  def assignments_without_gps_data
    assignments.reject(&:gps_available?)
  end

  alias :read_attribute_for_validation :send

  private

  def cache_key
    "bps.assignments.#{@aspen_contact_id}.#{trip_flag}"
  end

  def trip_flag
    time_of_request.hour >= 11 ? 'departure' : 'arrival'
  end

  def current_date
    time_of_request.strftime('%D')
  end

  def time_of_request
    @time_of_request ||= Time.zone.now
  end

  def username
    ENV['BPS_USERNAME']
  end

  def password
    ENV['BPS_PASSWORD']
  end
end
