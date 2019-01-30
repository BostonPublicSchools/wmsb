Wmsb.Models.BusAssignment = Backbone.Model.extend
  initialize: (attributes) ->
    initialize: (attributes) ->
      (mapboxgl.Marker).setLngLat([this.longitude, this.latitude])
      (new (mapboxgl.Marker).getLngLat([this.longitude, this.latitude]))

#    @set 'latLng', new google.maps.LatLng(@get('latitude'), @get('longitude'))

