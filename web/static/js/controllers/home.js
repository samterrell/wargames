angular.module('app').controller('HomeCtrl',
function($scope, $rootScope, $location, $cookies, $routeParams) {
  $scope.save_name = function(name) {
    if(name && name.trim().length > 0) {
      $cookies.put("name", name);
      $rootScope.name = name;
      if($routeParams.game_id)
        $location.url('/games/'+encodeURIComponent($routeParams.game_id));
      else
        $location.path('/games');
    } else {
      $scope.errors = {name: true};
    }
  };
});
