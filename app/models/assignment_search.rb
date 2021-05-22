class AssignmentSearch
  include ActiveModel::Model
  
  ENV['BPS_API'] = 'https://stageapi.mybps.org/'
  ENV['BPS_PASSWORD'] = 'F1D0K9$'
  ENV['BPS_USERNAME'] = 'BPSTrans'
  ENV['BUSES_THRESHOLD_TIME'] = '1200.00'
  ENV['DATABASE_URL'] = 'postgres://mjdbiofabgaopb:3cf7f68f2913cc5b0e91774881c93dee8305455713eadf02c6ae7c03c4aab4be@ec2-23-23-225-116.compute-1.amazonaws.com:5432/d5s6rp52aue8ge'
  ENV['GOOGLE_ANALYTICS'] = 'UA-40446355-2'
  ENV['HEROKU_POSTGRESQL_BLUE_URL'] = 'postgres://mqqqobgyjcxwai:cbc90ded324141fa227b7549f91c9bf8bca43d89e13d74ad6c57c6c5f3ae7628@ec2-54-221-236-144.compute-1.amazonaws.com:5432/de1kb9r5uebs6u'
  ENV['HEROKU_POSTGRESQL_YELLOW_URL'] = 'postgres://mjdbiofabgaopb:3cf7f68f2913cc5b0e91774881c93dee8305455713eadf02c6ae7c03c4aab4be@ec2-23-23-225-116.compute-1.amazonaws.com:5432/d5s6rp52aue8ge'
  ENV['HTTP_BASIC_AUTH_NAME'] = 'bps'
  ENV['HTTP_BASIC_AUTH_PASSWORD'] = 'bpswmsb'
  ENV['LANG'] = 'en_US.UTF-8'
  ENV['MAPBOX_TOKEN'] = 'pk.eyJ1IjoiZWhhbmt3aXR6IiwiYSI6ImNqdTh0MXpnYzBrNDM0M256NzJzd2psNHcifQ.5a2-uY_MlC6OkEMpI9V9-g'
  ENV['MAP_INTERVAL'] = '45000'
  ENV['MEMCACHIER_PASSWORD'] = 'a058b30ea84467fea7d8'
  ENV['MEMCACHIER_PUCE_PASSWORD'] = 'a058b30ea84467fea7d8'
  ENV['MEMCACHIER_PUCE_SERVERS'] = 'mc4.dev.ec2.memcachier.com:11211'
  ENV['MEMCACHIER_PUCE_USERNAME'] = '829fc1'
  ENV['MEMCACHIER_SERVERS'] = 'mc2.dev.ec2.memcachier.com:11211'
  ENV['MEMCACHIER_USERNAME'] = '829fc1'
  ENV['NEW_RELIC_APP_NAME'] = 'wmsb'
  ENV['NEW_RELIC_LICENSE_KEY'] = '4699c35f2b1c02538c17f75a94cd983b2b7073b1'
  ENV['NEW_RELIC_LOG'] = 'stdout'
  ENV['RACK_ENV'] = 'production'
  ENV['RAILS_AUTOSCALE_URL'] = 'https://api.railsautoscale.com/api/ssO427f8vaZ1ZA'
  ENV['RAILS_ENV'] = 'production'
  ENV['SECRET_TOKEN'] = 'd0596e3388caa314313eafe512640950f4161e5f58a17a36677ae433e4e4fbdcb05d9f7b31fb5f4e69f979c3cc4f9ef2d1da2993150bede3a88f535db83ddda9'
  ENV['SERVICE_HEADER_KEY'] = '4cwYs4b5STa8ww7uOaxwr+7zPkKgAw3I0B5Jfe8CON0='
  ENV['ZONAR_ALERT_TIME'] = '300.0'
  ENV['ZONAR_API'] = 'http://bos0501.zonarsystems.net'
  ENV['ZONAR_PASSWORD'] = '8!vgH6CRYpdw'
  ENV['ZONAR_USERNAME'] = 'code4america'

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
      response = connection.post(
          '/BPSRegistrationService/api/Transportation/BusAssignments',
          clientcode: CLIENT_CODE,
          studentNo: @aspen_contact_id,
          tripFlag: tripflag
      )
      response.success? ? response.body : nil
    end

    if response_body.present?
      response_assignments = []
      response_array = []
      assignments = JSON.parse(response_body)
      assignments.map do |assignment|
        if assignment[1].is_a? Array
          assignment[1].each do |a|
            response_assignments << a
          end
        else
          response_assignments << assignment[1]
        end
      end
      response_array << response_assignments.inject({}) { |aggregate, hash| aggregate.merge hash }
      @assignments = response_array.map do |assignment|
        BusAssignment.new(assignment, trip_flag)
      end
    else
      @errors.add(:assignments, :missing)
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
