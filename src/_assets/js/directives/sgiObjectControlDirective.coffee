angular.module('WebGLProject.directives').
  directive('sgiObjectControlDirective', (SceneService) ->
    return {
      restrict: 'A',
      replace: false,
      link: (scope, element, attributes) ->
        
    }
  )