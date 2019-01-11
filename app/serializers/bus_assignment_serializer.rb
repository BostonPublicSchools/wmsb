class BusAssignmentSerializer < ActiveModel::Serializer
  TRIP_DIRECTIONS = {
    'arrival'   => 'School',
    'departure' => 'Home'
  }.freeze

  attributes :token,
             :student_name,
             :bus_number,
             :latitude,
             :longitude,
             :last_updated_at,
             :destination,
             :time_difference,
             :history

  def token
    Digest::SHA512.hexdigest(object.student_number).first(20)
  end

  def last_updated_at
    object.last_updated_at.strftime('%b %e, %l:%M %P')
  end

  def time_difference
    current_time = Time.zone.now
    (current_time - object.last_updated_at).round(2) > ENV['ZONAR_ALERT_TIME'].to_f ? 'true' : 'false'
  end

  def destination
    TRIP_DIRECTIONS[object.trip_flag]
  end

  def history
    @history ||= object.history.any? ? object.history[1..-1] : []
  end
end
