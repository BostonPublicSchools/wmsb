Wmsb.Models.BusAssignment = Backbone.Model.extend
  initialize: (attributes) ->
    mapboxgl.accessToken = ENV['MAPBOX_TOKEN']
    @set 'Lnglat', new mapboxgl.LngLat(@get('longitude'), @get('latitude'))