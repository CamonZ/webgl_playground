angular.module('WebGLProject.directives', []).
  directive('sgiCanvasDirective', (SceneService) ->
    return {
      restrict: 'A',
      scope: {},
      replace: false,
      link: (scope, element, attributes) ->
        
        $(element).mousedown( (eventData) =>
          @clicked = true
          @startX = eventData.offsetX
          @startY = eventData.offsetY
        )

        $(element).mousemove( (eventData) =>
          if @clicked
            diffX = eventData.offsetX - @startX
            @startX = eventData.offsetX

            diffY = eventData.offsetY - @startY
            @startY = eventData.offsetY

            SceneService.updateRotationAngles(diffX, diffY)
        )

        $(element).mouseup( (eventData) =>
          @clicked = false
        )


        Hamster(element[0]).wheel(
          (event, delta, deltaX, deltaY) =>
            console.log('delta:' + delta)
            SceneService.zoomCamera(delta)
        )
        
    }
  )