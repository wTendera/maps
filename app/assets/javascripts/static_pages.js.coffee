ready = () ->
  map = new OpenLayers.Map('map',
    projection: new OpenLayers.Projection("EPSG:4326")
    displayProjection: new OpenLayers.Projection("EPSG:4326")
  )
  window.map = map
  road = new OpenLayers.Layer.OSM()
  map.addLayer(road);
   
  map.zoomToMaxExtent();
  $("#dupa").click ->
    $.ajax
      type: "GET"
      url: "/static_pages/resp"
      data: { 
        "from": $("#from").val(),
        "to": $("#to").val(),
      }
      success: (data) ->
        $("#dyst").text(data.distance)
        $("#time").text(data.traveltime)
        $("#desc").text(data.description)
        $("#coor").text(data.coordinates)
        drawRoute(data.coordinates)
        drawMarkers(data.coordinates[0], data.coordinates[data.coordinates.length - 1])
      

$(document).ready(ready);
style =
  strokeColor: "#00ff00"
  strokeOpacity: 0.5
  strokeWidth: 5

drawRoute = (coordinates) ->
  lineLayer = new OpenLayers.Layer.Vector("Line Layer")
  window.map.addLayer lineLayer
  window.map.addControl new OpenLayers.Control.DrawFeature(lineLayer, OpenLayers.Handler.Path)
  len = coordinates.length
  for i in [0..len - 2] by 1
    points = new Array(new OpenLayers.Geometry.Point(coordinates[i][0], coordinates[i][1]).transform(new OpenLayers.Projection("EPSG:4326"), map.getProjectionObject()), new OpenLayers.Geometry.Point(coordinates[i + 1][0], coordinates[i + 1][1]).transform(new OpenLayers.Projection("EPSG:4326"), map.getProjectionObject()))
    line = new OpenLayers.Geometry.LineString(points)
    lineFeature = new OpenLayers.Feature.Vector(line, null, style)
    lineLayer.addFeatures [lineFeature]

  map.zoomToExtent(lineLayer.getDataExtent())

drawMarkers = (start, end) ->
  markers = new OpenLayers.Layer.Markers("Markers")
  window.map.addLayer markers
  size = new OpenLayers.Size(21, 25)
  offset = new OpenLayers.Pixel(-(size.w / 2), -size.h)
  icon = new OpenLayers.Icon('http://simpleicon.com/wp-content/uploads/map-marker-13.png', size, offset)
  posStart = new OpenLayers.LonLat(start[0], start[1]) .transform(
        new OpenLayers.Projection("EPSG:4326"),
        map.getProjectionObject()
      )
  posEnd = new OpenLayers.LonLat(end[0], end[1]) .transform(
        new OpenLayers.Projection("EPSG:4326"),
        map.getProjectionObject()
      )

  marker1 = new OpenLayers.Marker(posStart, icon)
  markers.addMarker marker1
  markers.addMarker new OpenLayers.Marker(posEnd, icon.clone())
###
  myLocation = new OpenLayers.Geometry.Point(start[0], start[1]).transform('EPSG:4326', 'EPSG:3857');
  marker1.events.register( 'click', markers, clickMarker(myLocation) );


  
  

clickMarker = (myLocation) ->
  popup = new OpenLayers.Popup.FramedCloud("Popup", myLocation.getBounds().getCenterLonLat(), null, "<a target=\"_blank\" href=\"http://openlayers.org/\">We</a> " + "could be here.<br>Or elsewhere.", null, true) # <-- true if we want a close (X) button, false otherwise
  window.map.addPopup popup
  ###

     



