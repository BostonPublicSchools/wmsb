Wmsb.Models.BusAssignment = Backbone.Model.extend
  initialize: (attributes) ->
    @set 'Lnglat', new mapboxgl.LngLat(@get('longitude'), @get('latitude'))