angular.module('WebGLProject.controllers', []).controller(
  'ApplicationController', ['$scope', '$rootScope', 'SceneService', 'ShadersService', 'ObjectCreationService', ($scope, $rootScope, SceneService, ShadersService, ObjectCreationService) ->
    
    SceneService.initScene()
    SceneService.draw()

    $scope.cameraTypes = ['perspective', 'orthographic']
    $scope.activeCameraType = $scope.cameraTypes[0]
    $scope.primitiveTypes = ObjectCreationService.getPrimitiveTypes()


    $scope.drawable = null
    $scope.shaderTypes = ShadersService.getShaderNames()
    $scope.status = {}
    $scope.status.isObjectControlCollapsed = true
    $scope.status.isShaderDropdownOpen = false
    
    $scope.setCameraType = (type) ->
      unless $scope.isActiveCamera(type)
        $scope.activeCameraType = type
        SceneService.setCamera($scope.activeCameraType)
      @
    $scope.isActiveCamera = (type) =>
      $scope.activeCameraType is type
    $scope.shaderSwitch = ($event) =>
      $scope.drawable.shaderType = $event.target.id
      $scope.drawable.shaderName = $event.target.text
      SceneService.updateDrawable($scope.drawable)
      @
    watchFunc = (newVal, oldVal) -> 
      if newVal?
        $("li##{(newVal.id)}").find("p span").text(newVal.n)
        SceneService.updateDrawable(newVal)
      @

    $scope.$watch 'drawable', watchFunc, true
    @
])