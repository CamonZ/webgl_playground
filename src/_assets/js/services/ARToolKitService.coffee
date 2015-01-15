angular.module('WebGLProject.services').
  factory('ARToolKitService', (CustomCameraService) ->
    @service = {}

    @service.initToolkit = =>
      @canvas = $("canvas#video_camera")
      @canvas.width = 320
      @canvas.height = 240
      @canvas.style.display = 'block'

      ctx = canvas.getContext('2d')
      ctx.font = "24px URW Gothic L, Arial, Sans-serif"

      raster = new NyARRgbRaster_Canvas2D(@canvas)
      param = new FLARParam(320, 240)
      detector = new FLARMultiIdMarkerDetector(param, 120)
      detector.setContinueMode(true)

      setInterval(() ->
        detected = detector.detectMarkerLite(raster, 50)
        console.log('detected: ' + detected)
      ,15)


    return @service
  )
