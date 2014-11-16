angular.module('WebGLProject.directives').
  directive('sgiAddObjectToCanvasDirective', (SceneService, ObjectCreationService, $compile) ->
    return {
      restrict: 'A',
      scope: {},
      replace: false,
      link: (scope, element, attributes) ->
        $(element).click( (eventData) ->
          type = /add_(\w+)/.exec(@id)[1]
          
          object = ObjectCreationService.createObject(type)
          SceneService.addDrawable(object)

          objectTag = '<sgi-object-directive id="'+object.id+'" n="'+object.n+'"> '+object.n+'</sgi-object-directive>'
          $("#scene_navigation .objectsContainer").append($compile(objectTag)(scope.$parent))
          
          #delete scope.$parent.printable
        )
    }
  )