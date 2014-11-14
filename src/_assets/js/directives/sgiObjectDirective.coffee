angular.module('WebGLProject.directives').
  directive('sgiObjectDirective', (SceneService, ObjectCreationService, $compile) ->
    return {
      restrict: 'EA',
      transclude: true,
      replace: true,
      template: "<li class='object_navigation'><button type='button' class='close'><span aria-hidden='true'>&times;</span><span class='sr-only'>Close</span></button><p><ng-transclude></ng-transclude></p></li>",
      link: (scope, element, attributes) ->

        toggleObjectControl = ->
          if scope.drawable? and scope.status.isObjectControlCollapsed
            scope.status.isObjectControlCollapsed = !scope.status.isObjectControlCollapsed
          else unless scope.drawable?
            scope.status.isObjectControlCollapsed = true


        $(element).click (eventData) ->
          $(element).siblings().removeClass('active')
          $(element).toggleClass('active')
          drawable = if $(element).hasClass('active') then SceneService.getDrawable(element[0].id.trim()) else null
          scope.drawable = drawable
          
          toggleObjectControl()
          
          scope.$apply()
          @
        
        $(element).find("button.close").click (eventData) ->
          eventData.preventDefault()
          eventData.stopPropagation()
          SceneService.removeDrawable(element[0].id.trim())
          
          if $(element).hasClass('active')
            scope.drawable = null

          $(element).remove()

          toggleObjectControl()
          
          scope.$apply()
          @
        @
    }
  )