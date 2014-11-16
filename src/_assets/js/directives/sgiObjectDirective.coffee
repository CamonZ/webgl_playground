angular.module('WebGLProject.directives').
  directive('sgiObjectDirective', (SceneService, ObjectCreationService, $compile) ->
    return {
      restrict: 'EA',
      transclude: true,
      replace: true,
      template: "<button class='btn btn-default btn-sm btn-block' type='button'><span class='glyphicon glyphicon-remove-sign pull-left'></span><ng-transclude></ng-transclude></button>",
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
          scope.$parent.drawable = drawable
          toggleObjectControl()
          scope.$apply()
          @
        
        $(element).find("span.glyphicon-remove-sign").click (eventData) ->
          eventData.preventDefault()
          eventData.stopPropagation()
          SceneService.removeDrawable(element[0].id.trim())
          
          if $(element).hasClass('active')
            scope.$parent.drawable = null

          $(element).remove()

          toggleObjectControl()
          
          scope.$apply()
          @
        @
    }
  )