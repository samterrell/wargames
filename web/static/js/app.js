(function(){
  angular.module('app',['ngRoute', 'ngAnimate', 'ngCookies']).
  config(function($routeProvider) {
    $routeProvider.
    when('/', {
      templateUrl: 'web/static/templates/home.html',
      controller: 'HomeCtrl'
    }).
    when('/games', {
      templateUrl: 'web/static/templates/games.html'
    }).
    when('/games/:game_id', {
      templateUrl: 'web/static/templates/game.html',
      controller: 'GameCtrl'
    });
  }).
  run(function($location, $rootScope, $cookies) {
    $rootScope.$location = $location;
    $rootScope.name = $cookies.get("name");
  });
})();