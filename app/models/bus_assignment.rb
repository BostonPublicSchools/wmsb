class BusAssignment
  include ActiveModel::SerializerSupport

  FAKE_ASSIGNMENT_REGEX = /^9\d{3}$/

  attr_accessor :BusNo,
                :StudentNo,
                :ParentFirstName,
                :ParentLastName,
                :StudentFirstName,
                :StudentLastName,
                :days,
                :trip_flag

  alias :bus_number :BusNo
  alias :student_number :StudentNo
  alias :parent_first_name :ParentFirstName
  alias :parent_last_name :ParentLastName
  alias :student_first_name :StudentFirstName
  alias :student_last_name :StudentLastName

  attr_reader :location, :history

  delegate :longitude, :latitude, :last_updated_at, to: :location

  def initialize(attributes, trip_flag)
    attributes.each do |attr, value|
      send("#{attr}=", value) if respond_to?(attr)
    end
    self.trip_flag = trip_flag

    if real_assignment?
      @history = Zonar.bus_history(bus_number)
      @location = @history.last || Zonar.bus_location(bus_number)
    end
  end

  def student_name
    "#{student_first_name} #{student_last_name}"
  end

  def real_assignment?
    !FAKE_ASSIGNMENT_REGEX.match(bus_number)
  end

  def gps_available?
    @location.present?
  end
end
