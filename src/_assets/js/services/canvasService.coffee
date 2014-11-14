angular.module('WebGLProject.services', []).
  factory('CanvasService', () ->
    @context = null
    initContext = () =>
      @canvas = $("canvas")
      try
        @context = @canvas[0].getContext('experimental-webgl')

        w = parseInt(@canvas.css('width'))
        h = parseInt(@canvas.css('height'))

        @canvas[0].width = w
        @canvas[0].height = h

        @context.viewport(0, 0, w, h)
      catch
        console.error("couldn't get the webgl context") unless @context
  
    radToDeg = (radians) ->
      return radians * 180 / Math.PI
    degToRad = (degrees) ->
      return degrees * Math.PI / 180
    aspectF = () =>
      return @canvas[0].width / @canvas[0].height
    
    return {
      glContext: () =>
        return @context if @context isnt null
        initContext()
        return @context
      aspect: aspectF
      xAngleFromDrag: (diff) =>
        halfHeight = @canvas[0].height / 2
        return ((diff * 180) / halfHeight) * 0.5
      zAngleFromDrag: (diff) =>
        halfWidth = @canvas[0].width / 2
        return ((diff * 180) / halfWidth) * 0.5
      
      updateAspect: (width, height) =>
        @canvas[0].width = width
        @canvas[0].height = height
        @context.viewport(0, 0, w, h)
    }
  )