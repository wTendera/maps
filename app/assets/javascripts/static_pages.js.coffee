ready = () ->
  map = new OpenLayers.Map('map');
  road = new OpenLayers.Layer.OSM("OpenCycleMap", ["http://a.tile.opencyclemap.org/cycle/${z}/${x}/${y}.png", "http://b.tile.opencyclemap.org/cycle/${z}/${x}/${y}.png", "http://c.tile.opencyclemap.org/cycle/${z}/${x}/${y}.png"]);
  map.addLayer(road);
  map.zoomToMaxExtent();
  $("#dupa").click ->
    $.ajax
      type: "GET"
      url: "/static_pages/resp"
      data: { 
        "fromx": $("#startx").val(), 
        "fromy": $("#starty").val(), 
        "tox": $("#endx").val(),
        "toy": $("#endy").val()
      }
      success: (data) ->
        $("#dyst").text(data.distance)
        $("#time").text(data.traveltime)
        $("#desc").text(data.description)
        $("#coor").text(data.coordinates)
      

$(document).ready(ready);
