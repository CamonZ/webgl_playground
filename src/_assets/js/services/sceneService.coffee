angular.module('WebGLProject.services').
  factory('SceneService', (CanvasService, ShadersService, CameraService, ObjectCreationService, MuseumService) ->
    glContext = CanvasService.glContext()

    ARRAY_BUFFER = glContext.ARRAY_BUFFER
    STATIC_DRAW = glContext.STATIC_DRAW
    DEPTH_TEST = glContext.DEPTH_TEST
    COLOR_BUFFER_BIT = glContext.COLOR_BUFFER_BIT
    DEPTH_BUFFER_BIT = glContext.DEPTH_BUFFER_BIT
    FLOAT = glContext.FLOAT

    @mvMatrix = mat4.create()
    @pMatrix = mat4.create()
    @nMatrix = mat4.create()

    @mvMatrixStack = []

    @drawables = {}

    @xAngle = 75
    @zAngle = -180

    @service = {}

    mvPushMatrix = () =>
      copy = mat4.create()
      mat4.copy(copy, @mvMatrix)
      @mvMatrixStack.push(copy)
      @

    mvPopMatrix = () =>
      return if @mvMatrixStack.length == 0
      @mvMatrix = @mvMatrixStack.pop()
      @

    radToDeg = (radians) =>
      return radians * 180 / Math.PI
    degToRad = (degrees) =>
      return degrees * Math.PI / 180

    @service.initScene = () =>
      glContext.enable(DEPTH_TEST)
      glContext.depthFunc(glContext.LEQUAL)
      glContext.clearColor(0, 0, 0, 1)

      CameraService.initialize(@pMatrix)
      CameraService.perspective()
      @museum = MuseumService.museum(@.service)

      @
    @service.draw = () =>
      glContext.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT)

      obs = [0, 0, -200]

      mat4.identity(@mvMatrix)
      mat4.translate(@mvMatrix, @mvMatrix, obs)

      mat4.rotateX(@mvMatrix, @mvMatrix, -degToRad(@xAngle))
      mat4.rotateZ(@mvMatrix, @mvMatrix, -degToRad(@zAngle))

      for id, drawable of @drawables
        console.log('Drawing: ' + drawable.n)
        mvPushMatrix()
        drawable.draw({mv: @mvMatrix, p: @pMatrix, n: @nMatrix})
        mvPopMatrix()
      @
    @service.updateRotationAngles = (xDiff, yDiff) =>
      @zAngle += CanvasService.xAngleFromDrag(xDiff)
      @zAngle %= 360

      @xAngle += CanvasService.zAngleFromDrag(yDiff)
      @xAngle %= 360

      @service.draw()
      @
    @service.addDrawable = (object) =>
      @drawables[object.id] = object
      @service.draw()
      @
    @service.removeDrawable = (id) =>
      delete @drawables[id]
      @service.draw()
      @
    @service.setCamera = (type) =>
      CameraService[type]()
      @service.draw()
      @
    @service.getDrawable = (id) =>
      @drawables[id].serialize()
    @service.updateDrawable = (obj) =>
      @drawables[obj.id].deserialize(obj)
      @service.draw()
      @
    @service.zoomCamera = (step) =>
      CameraService.zoom(step)
      @service.draw()


    @service.modelView = @mvMatrix
    @service.projection = @pMatrix

    return @service
  )
