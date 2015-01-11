angular.module('WebGLProject.services').
  factory('CameraService', (CanvasService) ->
    @pMatrix = null
    glContext = CanvasService.glContext()
    @service = {}
    @type = ''
    @fovYInitial = 60
    @fovYDiff = 0
    @orthoZoomFactor = 1

    radToDeg = (radians) ->
      return radians * 180 / Math.PI
    degToRad = (degrees) ->
      return degrees * Math.PI / 180

    @service.initialize = (pMatrix) =>
      @pMatrix = pMatrix
    @service.perspective = () =>
      @type = 'perspective'
      mat4.identity(@pMatrix)
      mat4.perspective(@pMatrix, degToRad(@fovYInitial + @fovYDiff), CanvasService.aspect(), 0.1, 1000)
    @service.orthographic = () =>
      @type = 'orthographic'
      mat4.identity(@pMatrix)
      mat4.ortho(@pMatrix, -15*@orthoZoomFactor, 15*@orthoZoomFactor, -15*@orthoZoomFactor, 15*@orthoZoomFactor, 0.1, 1000)
    @service.zoom = (step) =>
      if @type is 'perspective'
        @fovYDiff -= step

        if @fovYDiff < -59
          @fovYDiff = -59
        if @fovYDiff > 119
          @fovYDiff = 119
        @service.perspective()
      else
        @orthoZoomFactor -= step*0.01
        @service.orthographic()
    return @service
  )



