angular.module('app').controller('HomeCtrl',
function($scope, $rootScope, $location, $cookies) {
  $scope.save_name = function(name) {
    if(name && name.trim().length > 0) {
      $cookies.put("name", name);
      $rootScope.name = name;
      $location.path('/games');
    } else {
      $scope.errors = {name: true};
    }
  };
});
