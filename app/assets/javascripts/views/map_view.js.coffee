assignmentList = _.template """
<div class="header-info student">
  <h4 class="small-text">Student:</h4>
  <div class="<%= collection.length > 1 ? 'select-students' : '' %> selected-student">
    <div class="name"><%= current.escape("student_name") %></div>
    <% if ( collection.length > 1 ) { %>
      <span class="icon-down-dir"></span>
    <% } %>
  </div>
  <ul class="student-names closed">
    <% collection.each(function(assignment) { %>
      <li class="student-name"><%= assignment.get("student_name") %></li>
    <% }) %>
  </ul>
</div>
<div class="header-details">
  <div class="header-info time">
    <h4 class="small-text">Last updated:</h4>
    <h2 class="<%= current.escape("time_difference") == "true" ? 'last_updated_content' : '' %>"> <%= current.escape("last_updated_at") %></h2>
    <%= current.escape("time_difference") == "true" ? "<div class='last_updated_content'>Your bus's GPS tracker is experiencing delays. We apologize for any inconvenience.</div>" : '' %>
  </div>
  <div class="header-info bus-number">
    <h4 class="small-text">Bus number:</h4>
    <h2><%= current.escape("bus_number") %></h2>
  </div>
  <div class="header-info bus-destination">
    <h4 class="small-text">Destination:</h4>
    <h2><%= current.escape("destination") %></h2>
  </div>
</div>
  """

Wmsb.Views.MapView = Backbone.View.extend
  events:
    'click .select-students': 'toggleAssignmentList'
    'click .student-name': 'changeSelectedAssignment'

#  styles: [
#    stylers: [
#      { "saturation": -30 }
#      { "lightness": 31 }
#      { "weight": 0.4 }
#      { "gamma": 0.78 }
#      { "hue": "#3b97d3" }
#    ]
#  ]

  points: []

  mapboxgl.accessToken = 'pk.eyJ1Ijoid21zYiIsImEiOiJjanI3emJ2d2YwMHZ3NDNuMGk2MHIxdnUzIn0.jHizbQD5eE9GmnP0y1w2Ng'

#  styledMap: ->
#    new google.maps.StyledMapType @styles, name: 'Boston Public Schools'

  mapCenter: ->
    current = @collection.current()
    if current? then current.get('latLng') else new mapboxgl.Marker().setLngLat([42.3583, -71.0603])

  initialize: (options) ->
    _.bindAll this

    @busView    = @$('#bus-view')
    @container      ='map-canvas'

    @listenTo @collection, 'reset', @render

  render: ->
    @renderMap() unless @map?

    @renderHeader()
    @renderMarker()


    @intervalID ||= setInterval @refreshAssignments, $('#map-interval').data('map-timeout')
    console.log($('#map-interval').data('map-timeout'))

  renderMap: ->
    @map = new mapboxgl.Map {
      container: @container
      style: 'mapbox://styles/mapbox/streets-v11'
      center: @mapCenter()
      zoom: 13
      disableDefaultUI: true
      panControl: !Modernizr.touch
      zoomControl: true
    }
    @map.mapTypes.set 'wmsb' #@styledMap()

  renderHeader: ->
    markup = assignmentList
      current: @collection.current()
      collection: @collection
    @busView.html markup

  renderMarker: ->
    @marker?.setMap null

    if @points.length != 0
      _.each @points, (point) ->
        point.setMap null

      @points.length = 0

    _.each @collection.current().get('history'), (point) =>
      latLng = new mapboxgl.Marker().setLngLat([42.3583, -71.0603])


    center = @collection.current().getLngLat('latLng')
#    @marker = new google.maps.Marker
#      position: center
#      map: @map
#      title: @collection.current().get 'student_name'
#      icon: '/assets/bus-marker.svg'
#      zIndex: google.maps.Marker.MAX_ZINDEX

    @popup = new mapboxgl.Popup()
    .setHTML('<h3>Reykjavik Roasters</h3><p>A good coffee shop</p>');

    marker = (new (mapboxgl.Marker)).setLngLat([
      -21.92661562
      64.14356426
    ]).setPopup(popup).addTo(@map)

    @map.setCenter center

  toggleAssignmentList: ->
    @$('.student-names').toggleClass 'closed'
    @$('.icon-down-dir').toggleClass 'rotate'

  refreshAssignments: ->
    @collection.fetch
      reset: true
      cache: false
      error: (collection, response, options) ->
        if response.status == 401
          Wmsb.notice 'Your session has expired. You will be signed out shortly.'
          setTimeout (-> window.location.pathname = ''), 5000
        else if response.status != 0 # 0 is from a user-generated page refresh
          Wmsb.notice 'There was a problem updating the bus location. Refresh the page or sign in again.'

  changeSelectedAssignment: (event) ->
    assignment = @collection.find (assignment) ->
      assignment.get('student_name') is event.target.innerHTML

    window.location.hash = assignment.get('token')

    @render()
