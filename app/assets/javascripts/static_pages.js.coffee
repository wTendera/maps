ready = -> 
  map = new OpenLayers.Map('map',
    projection: new OpenLayers.Projection("EPSG:4326")
    displayProjection: new OpenLayers.Projection("EPSG:4326")
  )
  road = new OpenLayers.Layer.OSM()
  map.addLayer(road);

  markers = new OpenLayers.Layer.Markers("Markers")
  map.addLayer markers
   
  map.zoomToMaxExtent();
  $("#show_route").click ->
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
        drawRoute(data.coordinates, map, markers)
 


style =
  strokeColor: "#00ff00"
  strokeOpacity: 0.5
  strokeWidth: 5

selectedStyle = 
  strokeColor: "#0000ff"
  strokeOpacity: 0.5
  strokeWidth: 5

markerStyle = 
  externalGraphic: 'http://simpleicon.com/wp-content/uploads/map-marker-13.png' 
  graphicHeight: 25
  graphicWidth: 21 
  graphicXOffset:-12
  graphicYOffset:-25

colorRoute = (layer) ->
  for feature in layer.features
    if feature.style == style
      feature.style = selectedStyle
    else if feature.style == selectedStyle
      feature.style = style

  layer.redraw()

getPos = (coordinates, map) ->
  new OpenLayers.LonLat(coordinates[0], coordinates[1]) .transform(
    new OpenLayers.Projection("EPSG:4326"),
    map.getProjectionObject()
  )

addMarker = (pos, markers, layer, map) ->
  size = new OpenLayers.Size(21, 25)
  offset = new OpenLayers.Pixel(-(size.w / 2), -size.h)
  icon = new OpenLayers.Icon('http://simpleicon.com/wp-content/uploads/map-marker-13.png', size, offset)
  marker = new OpenLayers.Marker(pos, icon)
  markers.addMarker marker
  marker.events.register( 'click', marker, ->
    popup = new OpenLayers.Popup.FramedCloud("Popup", pos, null, "Start", null, true)
    map.addPopup popup
    colorRoute(layer)
  );

listeners =
  featureclick: (evt) ->
    for feature in this.features
      if feature.style == style
        feature.style = selectedStyle
      else if feature.style == selectedStyle
        feature.style = style


    this.redraw()

drawRoute = (coordinates, map, markers) ->
  lineLayer = new OpenLayers.Layer.Vector("Line Layer", eventListeners: OpenLayers.Util.extend({scope: lineLayer}, listeners))
  map.addLayer lineLayer
  map.addControl new OpenLayers.Control.DrawFeature(lineLayer, OpenLayers.Handler.Path)
  points = []
  for i in [0..coordinates.length - 2] by 1
    points.push(new OpenLayers.Geometry.Point(coordinates[i][0], coordinates[i][1]).transform(new OpenLayers.Projection("EPSG:4326"), map.getProjectionObject()))
  
  line = new OpenLayers.Geometry.LineString(points)
  lineFeature = new OpenLayers.Feature.Vector(line, null, style)
  lineLayer.addFeatures [lineFeature]

  drawMarkers(coordinates[0], coordinates[coordinates.length - 1], lineLayer, map, markers)

  map.zoomToExtent(lineLayer.getDataExtent())

drawMarkers = (start, end, layer, map, markers) ->
  posStart = getPos(start, map)
  posEnd = getPos(end, map)
  addMarker(posStart, markers, layer, map)
  addMarker(posEnd, markers, layer, map)
  map.raiseLayer(markers, map.layers.length);


     
$(document).ready(ready);

