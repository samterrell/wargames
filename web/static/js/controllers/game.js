/*jshint esnext:true */
import {Socket, LongPoller} from "phoenix";

angular.module('app').controller('GameCtrl',
['$scope', '$routeParams', '$location', '$window',
function($scope, $routeParams, $location, $window) {
  var game_id = $scope.game_id = $routeParams.game_id;
  if(!$scope.name) $location.url('/?game_id='+encodeURIComponent(game_id));

  $scope.full_url = $window.location.href;

  var socket = new Socket("/ws", {});
  socket.connect();
  var channel;

  socket.connect();
  $scope.state = {};
  channel = socket.channel("tictactoe:" + game_id, {name: $scope.name});
  channel.on("state", function(state) {
    $scope.state = state;
    $scope.$digest();
  });
  channel.on("user:joined", function(evt) {
    if(evt.position == 'o') $scope.state.o = evt.user;
    $scope.$digest();
  });
  channel.join();

  $scope.play = function(x, y) {
    channel.push("play", [x,y]);
  };

  $scope.ping = function() {
    channel.push("ping", {});
  };

  $scope.restart = function() {
    channel.push("restart");
  };
}]);
