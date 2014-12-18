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
  id_num = 0
  $("#show_route").click ->
    tmp = []
    tmp.push($("#from").val())
    if id_num > 0
      for i in [0..id_num - 1]
        tmp.push($("#" + i).val())
    tmp.push($("#to").val())
    $.ajax
      type: "GET"
      url: "/static_pages/resp"
      data: { 
        "from": $("#from").val(),
        "to": $("#to").val(),
        "tmp": tmp
      }
      success: (data) ->
        if data[0].error
          alert(data[0].error)
          return
        $("#dyst").text(data[0].distance)
        $("#time").text(data[0].traveltime)
        drawRoute(data[0].coordinates, data[0].markers, map, markers)
  wrapper = $(".input_wrapper")
  add_button = $("#add_point")
  $("#add_point").click ->
    $(wrapper).append('<div><input type="text" name="mytext[]" id="' + id_num + '"/><a href="#" class="remove_field">Remove</a></div>')
    id_num++
  $(wrapper).on("click",".remove_field", (e) ->
    e.preventDefault()
    $(this).parent('div').remove()
  )
 


style =
  strokeColor: "#00ff00"
  strokeOpacity: 0.5
  strokeWidth: 5

selectedStyle = 
  strokeColor: "#0000ff"
  strokeOpacity: 0.5
  strokeWidth: 5


colorRoute = (layer) ->
  for feature in layer.features
    if feature.style == style
      feature.style = selectedStyle
    else if feature.style == selectedStyle
      feature.style = style

  layer.redraw()

getPos = (coordinates, map) ->
  new OpenLayers.LonLat(coordinates[1], coordinates[0]).transform(
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

drawRoute = (coordinates, markersPos, map, markers) ->
  lineLayer = new OpenLayers.Layer.Vector("Line Layer", eventListeners: OpenLayers.Util.extend({scope: lineLayer}, listeners))
  map.addLayer lineLayer
  map.addControl new OpenLayers.Control.DrawFeature(lineLayer, OpenLayers.Handler.Path)
  points = []
  for i in [0..coordinates.length - 2] by 1
    points.push(new OpenLayers.Geometry.Point(coordinates[i][0], coordinates[i][1]).transform(new OpenLayers.Projection("EPSG:4326"), map.getProjectionObject()))
  
  line = new OpenLayers.Geometry.LineString(points)
  lineFeature = new OpenLayers.Feature.Vector(line, null, style)
  lineLayer.addFeatures [lineFeature]

  drawMarkers(markersPos, lineLayer, map, markers)

  map.zoomToExtent(lineLayer.getDataExtent())

drawMarkers = (markersPos, layer, map, markers) ->
  console.log(markersPos)
  for el in markersPos
    pos = getPos(el, map)
    addMarker(pos, markers, layer, map)
  map.raiseLayer(markers, map.layers.length)

     
$(document).ready(ready);

