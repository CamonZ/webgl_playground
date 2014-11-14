angular.module('WebGLProject.directives').
  directive('sgiAddObjectToCanvasDirective', (SceneService, ObjectCreationService, $compile) ->
    return {
      restrict: 'A',
      scope: {},
      replace: false,
      link: (scope, element, attributes) ->
        $(element).find("li.button").click( (eventData) ->
          type = /add_(\w+)/.exec(@id)[1]
          
          object = ObjectCreationService.createObject(type)
          SceneService.addDrawable(object)
          
          printable = SceneService.getDrawable(object.id)
          scope.$parent.printable = printable

          objectTag = '<sgi-object-directive id="'+object.id+'" n="'+object.n+'">'+object.n+'</sgi-object-directive>'

          $("#scene_navigation ul.objects_in_scene").append($compile(objectTag)(scope.$parent))
          
          #delete scope.$parent.printable
        )
    }
  )