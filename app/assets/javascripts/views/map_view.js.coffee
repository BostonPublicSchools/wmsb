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

  points: []

  mapCenter: ->
    current = @collection.current()
    if current? then current.get('Lnglat') else new mapboxgl.LngLat(-71.0603, 42.3583)


  initialize: (options) ->
    _.bindAll this

    @busView    = @$('#bus-view')
    @container  = 'map-canvas'

    @listenTo @collection, 'reset', @render

  render: ->
    @renderMap() unless @map?

    @renderHeader()
    @renderMarker()


    @intervalID ||= setInterval @refreshAssignments, $('#map-interval').data('map-timeout')
    console.log($('#map-interval').data('map-timeout'))

  renderMap: ->
    mapboxgl.accessToken = window.mapbox_token
    @map = new mapboxgl.Map {
      container: @container
      style: 'mapbox://styles/mapbox/streets-v11'
      center: @mapCenter()
      dragRotate: false,
      touchZoomRotate: true,
      zoom: 14
    }

    #Add zoom and rotation controls to the map.
    @map.addControl(new mapboxgl.NavigationControl());

  renderHeader: ->
    markup = assignmentList
      current: @collection.current()
      collection: @collection
    @busView.html markup

  renderMarker: ->
    @marker?.remove()

    if @points.length != 0
      _.each @points, (point) ->
        point?.remove()
      @points.length = 0

    _.each @collection.current().get('history'), (point) =>
      Lnglat = new mapboxgl.LngLat(point.lng, point.lat)
      el = document.createElement('div');
      el.className = 'marker-dots';

      point = new mapboxgl.Marker(el)
        .setLngLat(Lnglat)
        .addTo(@map)
      @points.push point

    center = @collection.current().get 'Lnglat'
    popup = new mapboxgl.Popup()
      .setHTML(@collection.current().get 'student_name');

    ell = document.createElement('div');
    ell.className = 'marker';
    @marker = new mapboxgl.Marker(ell)
      .setLngLat(center)
      .setPopup(popup)
      .addTo(@map)

    @map.flyTo({center: center});


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

