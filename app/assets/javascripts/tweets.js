var maxMarkers = 50;
var heatMapData = [];
var activeMarkers = [];
var heatmap;

var redrawHeatMap = function(){
  heatmap = new google.maps.visualization.HeatmapLayer({
    data: heatMapData
  });
  heatmap.setMap(gmap);
}

var pushMarker = function(position, score) {
  var marker = new google.maps.Marker({
    map: gmap,
    position: position
  });
  
  if (score < 0) {
    marker.setIcon('http://maps.google.com/mapfiles/ms/icons/red-dot.png');
  }
  else if (score > 0) {
    marker.setIcon('http://maps.google.com/mapfiles/ms/icons/green-dot.png');
  }
  else {
    marker.setIcon(grey_marker);
  }
  
  // heatMapData.push({location: position, weight: score});
  
  activeMarkers.push(marker);
}

var drawMarker = function(full_tweet) {
  var tweet = full_tweet.raw_tweet;
  
  var position;
  if (tweet.place) {
    var coords = tweet.place.bounding_box.coordinates[0][0];
    position = new google.maps.LatLng(coords[1], coords[0]);
    pushMarker(position, full_tweet.score);
  }
  else if (tweet.geo) {
    var coords = tweet.geo.coordinates;
    position = new google.maps.LatLng(coords[0], coords[1]);
    pushMarker(position, full_tweet.score);
  }
}

var drawCard = function(full_tweet) {
  var tweet = full_tweet.raw_tweet;
  var happyClass = "happiness_";
  
  if (full_tweet.score < 0) {
    happyClass += 'bad';
  }
  else if (full_tweet.score > 0) {
    happyClass += 'good';
  }
  else {
    happyClass += 'neutral';
  }
  
  var tweet_card = $('<div/>').addClass('tweet_card '+happyClass)
    .append($('<p />').html(tweet.text))
    .append($('<span />')
      .append($('<img />').attr('src', tweet.user.profile_image_url))
      .append(' ')
      .append($('<a />').attr('href', "http://twitter.com/"+tweet.user.screen_name).html('@'+tweet.user.screen_name))
    )
    .appendTo('#stream');
}

var plotTweet = function(tweet) {
  drawMarker(tweet);
  drawCard(tweet);
}

var plotTweets = function(data) {
  // console.log(data);
  
  var tweet = data.pop();
  
  plotTweet(tweet);
  
  cleanupTweets();
  cleanupMarkers();
  
  if (data.length > 0) {
    window.setTimeout(function(){
      plotTweets(data);
    }, 50);
  }
  else {
    fetchTweets(tweet.id);
  }
  
}

var cleanupTweets = function() {
  var contentHeight = $('#stream')[0].scrollHeight;
  var containerHeight = $('#stream').height();
  
  if(contentHeight > containerHeight) {
    var child = $('#stream').children('div:first');
    child.slideUp({
      duration: 200,
      complete: function(){
        child.remove();
      }
    });
  }
}

var cleanupMarkers = function() {
  while(activeMarkers.length > maxMarkers) {
    var marker = activeMarkers.shift();
    marker.setMap(null);
  }
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
    success: plotTweets
  });
}
