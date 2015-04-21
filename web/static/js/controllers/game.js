// jshint esnext:true
import { Socket } from 'phoenix';

angular.module('app').controller('GameCtrl',
function($scope, $routeParams, $location) {
  var game_id = $scope.game_id = $routeParams.game_id;
  if(!$scope.name) $location.url('/?game_id='+encodeURIComponent(game_id));

  var socket = new Socket("/ws");
  var channel;

  socket.connect();

  socket.onClose(function(e) {
    console.log("CLOSE", e);
  });
  socket.join("tictactoe:" + game_id, {name: $scope.name})
  .receive("ok", function(chan) {
    channel = chan;
    console.log("Connected...");
    channel.onError(function(e) {
      console.log("something went wrong", e);
    });
    channel.onClose(function(e) {
      console.log("channel closed", e);
    });
    channel.on("state", function(state) {
      $scope.state = state;
      $scope.$digest();
      console.log(state);
    });
    channel.on("user:joined", function(evt) {
      if(evt.position == 'o') $scope.state.o = evt.user;
      $scope.$digest();
      console.log(evt);
    });
  });

  $scope.play = function(x, y) {
    channel.push("play", [x,y]).receive("error", function(errors) {
      console.log(errors);
    });
  };

  $scope.ping = function() {
    console.log(new Date().valueOf());
    channel.push("ping", {})
    .receive("ok", function(resp){
      console.log(new Date().valueOf());
      console.log(resp);
    })
    .receive("error", function(error) {
      console.log(error);
    });
  };

  $scope.restart = function() {
    channel.push("restart").receive("error", function(errors) {
      console.log(errors);
    });
  };
});
