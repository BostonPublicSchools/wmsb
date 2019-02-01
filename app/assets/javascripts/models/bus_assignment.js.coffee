Wmsb.Models.BusAssignment = Backbone.Model.extend
  initialize: (attributes) ->
    mapboxgl.accessToken = 'pk.eyJ1IjoieW9yaWNrdmFuZGVydmlzIiwiYSI6ImNqazN4bmpoeTE0Y2Izd28yZXI0Ym9kb24ifQ.MHqgRPF-2NjKPI2d9z91yg'
    @set 'latLng', new (mapboxgl.LngLat)(@get('longitude'), @get('latitude'))
#    @set 'latLng', new google.maps.LatLng(@get('latitude'), @get('longitude'))