class BusLocation
  attr_accessor :fleet,
                :long,
                :lat,
                :heading,
                :speed,
                :time,
                :current_time

  alias :bus_id :fleet
  alias :longitude :long
  alias :latitude :lat

  def initialize(attributes)
    attributes.each do |attr, value|
      send("#{attr}=", value) if respond_to?(attr)
    end
  end

  def last_updated_at
    @last_updated_at ||= Time.zone.parse(time)
  end

  def current_time
    @current_time ||= Time.zone.now
  end
end
