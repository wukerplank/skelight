// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .

var map;

var resizeMap = function() {
  var targetHeight = $(window).height() - $('#nav').height();
  
  map.height(targetHeight);
}

$(function(){
  map = $('#map');
  
  resizeMap();
  
  $(window).resize(function(){
    resizeMap();
  });
});

//------------------------------------------------------------------------------------------------

var plotTweet = function(tweet) {
  var position;
  if (tweet.place) {
    var coords = tweet.place.bounding_box.coordinates[0][0];
    position = new google.maps.LatLng(coords[1], coords[0]);
  }
  else if (tweet.geo) {
    var coords = tweet.geo.coordinates;
    position = new google.maps.LatLng(coords[0], coords[1]);
  }
  
  var marker = new google.maps.Marker({
    map: gmap,
    position: position
  });
}

var fetchTweets = function(after, limit) {
  if (typeof after == "undefined"){
    after = null;
  }
  
  if (typeof limit == "undefined"){
    limit = 100;
  }
  
  $.ajax("/twitter", {
    method: 'get',
    data: {after: after, limit: limit},
    success: function(data) {
      data.forEach(function(e){
        console.log(e.raw_tweet);
        plotTweet(e.raw_tweet);
      });
    }
  });
}

//------------------------------------------------------------------------------------------------
