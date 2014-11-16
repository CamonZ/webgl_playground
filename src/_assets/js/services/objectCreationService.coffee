angular.module('WebGLProject.services').
  factory('ObjectCreationService', (CanvasService, ShadersService) ->
    @service = {}
    glContext = CanvasService.glContext()
    
    ARRAY_BUFFER = glContext.ARRAY_BUFFER
    STATIC_DRAW = glContext.STATIC_DRAW
    ELEMENT_ARRAY_BUFFER = glContext.ELEMENT_ARRAY_BUFFER
    FLOAT = glContext.FLOAT
    UNSIGNED_SHORT = glContext.UNSIGNED_SHORT
    TRIANGLES = glContext.TRIANGLES

    
    
    degToRad = (degrees) =>
      return degrees * Math.PI / 180

    class Drawable
      constructor: (objId) ->
        @id = Date.now()
        @context = CanvasService.glContext()
        @shader = ShadersService.defaultShader()
        @vertexPositionBuffer = null
        @vertexNormalsBuffer = null
        @vertexIndexBuffer = null
        @xPos = 0
        @yPos = 1
        @zPos = 0
        @xRot = 0
        @yRot = 0
        @zRot = 0
        @scaleF = 1
        
        #params for goraud-lambert shader
        @color = [1, 1, 1, 1]
        @lightDirection = [0.0, -1.0, -1.0]
        @lightDiffuse = [1.0,1.0,1.0,1.0]

        #params for the stripe shader
        @firstColor = [1, 0, 0, 1]
        @secondColor = [0, 0, 1, 1]
        @horizontalStripes = true
        @gapSize = 50.0
        @stripeWidth = 25.0

        mesh = OBJ.Mesh($(objId).text())

        @vertices = mesh.vertices
        @faces = mesh.indices
        @normals = mesh.vertexNormals
        @setBuffers()
      draw: (matrices) ->
        @context.useProgram(@shader.program)

        translationVector = [-@xPos, @zPos, @yPos]
        mat4.translate(matrices.mv, matrices.mv, translationVector)

        mat4.rotateX(matrices.mv, matrices.mv, degToRad(@xRot))
        mat4.rotateY(matrices.mv, matrices.mv, degToRad(@yRot))
        mat4.rotateZ(matrices.mv, matrices.mv, degToRad(@zRot))
        
        mat4.scale(matrices.mv, matrices.mv, [@scaleF, @scaleF, @scaleF])
        
        @shader.setMatrixUniforms(matrices)
        
        @shader.setDrawableUniforms(this)
        
        if @shader.hasNormals
          @shader.setLightValues()

          mat4.copy(matrices.n, matrices.mv)
          mat4.invert(matrices.n, matrices.n)
          mat4.transpose(matrices.n, matrices.n)

          glContext.uniformMatrix4fv(
            @shader.program.nMatrixUniform, 
            false, 
            matrices.n)

        @context.bindBuffer(ARRAY_BUFFER, @vertexPositionBuffer)
        @context.vertexAttribPointer(@shader.vertexPosition(), 3, FLOAT, false, 0, 0)

        if @shader.hasNormals
          @context.bindBuffer(ARRAY_BUFFER, @vertexNormalsBuffer)
          @context.vertexAttribPointer(@shader.vertexNormal(), 3, FLOAT, false, 0, 0)
          
        @context.bindBuffer(ELEMENT_ARRAY_BUFFER, @vertexIndexBuffer)
        @context.drawElements(TRIANGLES, @faces.length, UNSIGNED_SHORT, 0)

        @context.bindBuffer(ARRAY_BUFFER, null)
        @context.bindBuffer(ELEMENT_ARRAY_BUFFER, null)
      setBuffers: ->
        if not @vertexPositionBuffer?
          @vertexPositionBuffer = @context.createBuffer() 
        @context.bindBuffer(ARRAY_BUFFER, @vertexPositionBuffer)
        @context.bufferData(ARRAY_BUFFER, new Float32Array(@vertices), STATIC_DRAW)

        if @shader.hasNormals
          @vertexNormalsBuffer = @context.createBuffer() if not @vertexNormalsBuffer?
          @context.bindBuffer(ARRAY_BUFFER, @vertexNormalsBuffer)
          @context.bufferData(ARRAY_BUFFER, new Float32Array(@normals), STATIC_DRAW)

        if not @vertexIndexBuffer?
          @vertexIndexBuffer = @context.createBuffer() 
        @context.bindBuffer(ELEMENT_ARRAY_BUFFER, @vertexIndexBuffer)
        @context.bufferData(ELEMENT_ARRAY_BUFFER, new Uint16Array(@faces), STATIC_DRAW)
        @context.bindBuffer(ARRAY_BUFFER, null)
        @context.bindBuffer(ELEMENT_ARRAY_BUFFER, null)
      serialize: ->
        return { 
          id: @id,
          xPos: @xPos,
          yPos: @yPos,
          zPos: @zPos,
          xRot: @xRot,
          yRot: @yRot,
          zRot: @zRot,
          scaleF: @scaleF,
          n: @n,
          color: @serializeColor(@color),
          firstColor: @serializeColor(@firstColor),
          secondColor: @serializeColor(@secondColor),
          horizontalStripes: @horizontalStripes,
          gapSize: @gapSize,
          stripeWidth: @stripeWidth,
          shaderName: @shader.name,
          shaderType: @shader.type 
        }
      deserialize: (obj) ->
        for colorAttribute in ['color', 'firstColor', 'secondColor']
          @[colorAttribute] = @deserializeColor(obj[colorAttribute])
        for attribute in [ 'xPos', 'yPos', 'zPos', 
                           'xRot', 'yRot', 'zRot', 
                           'scaleF', 'n', 'horizontalStripes',
                           'gapSize', 'stripeWidth'
                         ]
          @[attribute] = obj[attribute]
        @shader = ShadersService.getShader(obj.shaderType)
        @
      serializeColor: (color) ->
        str = ""
        for idx in [0..color.length-2]
          str += parseInt(color[idx]*255).toString() + ","
        str += color[3].toString()
        return "rgba("+str+")"
      deserializeColor: (str) ->
        parse = (values) ->
          `var i;
           for(i=0; i< values.length; i++)
             values[i] = parseFloat(values[i]);
          `
          values
        normalize = (values) ->
          rgbValues = values.slice(values.length - 1) 
          `var i;
           for(i=0; i< values.length-1; i++)
            values[i] = values[i] / 255
          `
          values
        matches = /rgba\((\d+),(\d+),(\d+),(\d*\.?\d+)\)/.exec(str).slice(1)
        return normalize(parse(matches))
    class Plane extends Drawable
      constructor: ->
        super('#plane_object')
        @xRot = 90
        @scaleF = 10
        @n = "Plane"
        @color = [0.1419, 0.3101, 0.0953, 1.0]
        @
    class Cube extends Drawable
      constructor: ->
        super('#cube_object')
        @n = "Cube"
        @color = [0.9495, 0.3552, 0.0417, 1.0]
    class Pyramid extends Drawable
      constructor: ->
        super('#pyramid_object')
        @xRot = 90
        @n = 'Piramid'
        @color = [0.0000, 0.2107, 0.9495, 1.0]
    class Sphere extends Drawable
      constructor: ->
        super('#sphere_object')
        @n = 'Sphere'
        @color = [0.3477, 0.2305, 0.1192, 1.0]
    class Cone extends Drawable
      constructor: ->
        super('#cone_object')
        @n = 'Cone'
        @color = [0.3477, 0.2305, 0.1192, 1.0]
    class IcoSphere extends Drawable
      constructor: ->
        super('#icosphere_object')
        @n = 'IcoSphere'
        @color = [0.3477, 0.2305, 0.1192, 1.0]
    class Cylinder extends Drawable
      constructor: ->
        super('#cylinder_object')
        @n = 'Cylinder'
        @color = [0.3477, 0.2305, 0.1192, 1.0]
    class Torus extends Drawable
      constructor: ->
        super('#torus_object')
        @n = 'Torus'
        @color = [0.3477, 0.2305, 0.1192, 1.0]

    @Drawables = {
      'cube': Cube,
      'pyramid': Pyramid,
      'sphere': Sphere,
      'plane': Plane,
      'cone': Cone,
      'icosphere': IcoSphere,
      'cylinder': Cylinder,
      'torus': Torus
    }

    @service.createObject = (type, program) =>
      return new @Drawables[type](program)
    @service.getPrimitiveTypes = ->
      return [
        'plane',
        'cube',
        'pyramid',
        'sphere',
        'cone',
        'icosphere',
        'cylinder',
        'torus'
      ]
    return @service
  )