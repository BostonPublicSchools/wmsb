require 'terminal-table'
desc 'Track the status of buses by importing the list'
# file = File.open('buses_list.text', "w")
# old_out = $stdout
# $stdout = file
puts "\nTASK: Track the status of all buses by importing the list"
puts "\nProcess started at = #{Time.now}"
  task track_bus_status: :environment do
    default_params = {
                          username: ENV['ZONAR_USERNAME'],
                          password: ENV['ZONAR_PASSWORD'],
                      }
    Zonar.connection.params.merge!(default_params)
    success_rows = []
    failed_rows = []
    success_count = 0
    failed_count = 0
    puts "\nImporting the list of all buses from model....."
    BusesList::BUSES_LIST.uniq.each do |bus_id|
      current_time = Time.zone.now
      @zonar_response = Zonar.bus_location(bus_id, buses_rake_task = "true")
      response_attributes = Hash.from_xml(@zonar_response)
      if response_attributes.try(:[],'currentlocations').nil?
        failed_rows << [failed_count +=1, bus_id, "CurrentLocation is missing inside Response attributes"]
        next
      elsif response_attributes.try(:[],'currentlocations').try(:[], 'asset').nil?
        failed_rows << [failed_count +=1, bus_id, "Asset is missing inside Response attributes"]
        next
      elsif response_attributes.try(:[], 'currentlocations').try(:[],'asset').try(:[],'time').nil?
        failed_rows << [failed_count+= 1, bus_id, "Time is missing inside Response attributes"]
        next
      else
        zonar_time = response_attributes['currentlocations']['asset']['time'].to_datetime.in_time_zone("Eastern Time (US & Canada)")
        latitude = response_attributes['currentlocations']['asset']['lat']
        longitude = response_attributes['currentlocations']['asset']['long']
        success_rows << [success_count += 1, bus_id, current_time, zonar_time,  (current_time - zonar_time).round(2) > ENV['BUSES_THRESHOLD_TIME']? 'YES' : 'NO', latitude, longitude]
        sleep 2
      end
    end
    success_table = Terminal::Table.new :title => "Success", :headings => ['No', 'Bus', 'Current', 'Zonar', 'Delayed > 20 mins', 'Latitude', 'Longitude'], :rows => success_rows
    puts "\n#{success_table}"
    failed_table = Terminal::Table.new :title => "Failed", :headings => ['No', 'Bus', 'Error'], :rows => failed_rows
    puts "\n#{failed_table}"
    puts "\n\nCompleted process at #{Time.zone.now}"
    # file.close
    # $stdout = old_out
end

