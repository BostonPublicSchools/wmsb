Wmsb.Models.BusAssignment = Backbone.Model.extend
  initialize: (attributes) ->
    mapboxgl.accessToken = window.mapbox_token
    @set 'Lnglat', new mapboxgl.LngLat(@get('longitude'), @get('latitude'))