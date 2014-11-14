angular.module('WebGLProject.services').
  factory('SceneService', (CanvasService, ShadersService, CameraService, ObjectCreationService) ->
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
      @floor = ObjectCreationService.createObject('plane')
      @floor.yPos = 0

      @
    @service.draw = () =>
      glContext.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT)

      obs = [0, 0, -20]

      mat4.identity(@mvMatrix)
      mat4.translate(@mvMatrix, @mvMatrix, obs)

      mat4.rotateX(@mvMatrix, @mvMatrix, -degToRad(@xAngle))
      mat4.rotateZ(@mvMatrix, @mvMatrix, -degToRad(@zAngle))
      
      mvPushMatrix()
      @floor.draw({mv: @mvMatrix, p: @pMatrix, n: @nMatrix})
      mvPopMatrix()
      
      for id, drawable of @drawables
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
      d = @drawables[id]
      str = ""
      
      for idx in [0..d.color.length-2]
        str += parseInt(d.color[idx]*255).toString() + ","
      
      str += d.color[3].toString()
      
      r = {
        id: d.id
        xPos: d.xPos, 
        yPos: d.yPos, 
        zPos: d.zPos,
        xRot: d.xRot, 
        yRot: d.yRot, 
        zRot: d.zRot,
        scaleF: d.scaleF, 
        n: d.n,
        color: "rgba("+str+")"
        shaderName: d.shader.name,
        shaderType: d.shader.type
      }
      return r
    @service.updateDrawable = (obj) =>
      parseValues = (values) ->
        `var i;
         for(i=0; i< values.length; i++)
           values[i] = parseFloat(values[i]);
        `
        values
      normalizeValues = (values) ->
        rgbValues = values.slice(values.length - 1) 
        `var i;
         for(i=0; i< values.length-1; i++)
          values[i] = values[i] / 255
        `
        values

      for attribute in ['xPos', 'yPos', 'zPos', 'xRot', 'yRot', 'zRot', 'scaleF', 'n', 'color']
        if attribute is 'color' and obj['color'].split isnt undefined
          color = obj['color']
          matches = /rgba\((\d+),(\d+),(\d+),(\d*\.?\d+)\)/.exec(color).slice(1)
          obj['color'] = normalizeValues(parseValues(matches))
          console.log(obj['color'])
        @drawables[obj.id][attribute] = obj[attribute]
      @drawables[obj.id].shader = ShadersService.getShader(obj.shaderType)
      @service.draw()
      @
    @service.zoomCamera = (step) =>
      CameraService.zoom(step)
      @service.draw()


    @service.modelView = @mvMatrix
    @service.projection = @pMatrix

    return @service
  )