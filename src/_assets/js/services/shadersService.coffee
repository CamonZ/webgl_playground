angular.module('WebGLProject.services').
  factory('ShadersService', (CanvasService) ->
    @service = {}
    glContext = CanvasService.glContext()
    shaderTypes = 
      'fragment': glContext.FRAGMENT_SHADER,
      'vertex': glContext.VERTEX_SHADER
    shaderSources = 
      'vertex': {}
      'fragment': {}

    compileShaders = () =>
      for script in $("script[type*='x-shader']")
        type = /x-shader\/x-(.+)/.exec(script.type)[1]
        
        shader = glContext.createShader(shaderTypes[type])
        glContext.shaderSource(shader, script.text)
        glContext.compileShader(shader)

        if(glContext.getShaderParameter(shader, glContext.COMPILE_STATUS))
          shaderSources[type][script.id] = shader
        else
          console.log('Error when compiling shader: ' + glContext.getShaderInfoLog(shader))
      @

    class BasicShader
      constructor: (vertexShaderId, fragmentShaderId) ->
        @hasNormals = false
        @color = [1, 1, 1, 1]
        @linkShaders(vertexShaderId, fragmentShaderId)
        @setAttributeLocations()
        @setUniformLocations()
        @name = "Basic Shader"
        @type = "basic"
      linkShaders: (vertexId, fragmentId) ->
        @program = glContext.createProgram()

        glContext.attachShader(@program, shaderSources['vertex'][vertexId])
        glContext.attachShader(@program, shaderSources['fragment'][fragmentId])
        glContext.linkProgram(@program)

        unless(glContext.getProgramParameter(@program, glContext.LINK_STATUS))
          console.log('Error when linking shaders: ' + glContext.getProgramInfoLog(@program))
      setAttributeLocations: ->
        @program.vertexPosition = glContext.getAttribLocation(@program, 'aVertexPosition')
      setUniformLocations: ->
        @program.pMatrixUniform = glContext.getUniformLocation(@program, "uPMatrix")
        @program.mvMatrixUniform = glContext.getUniformLocation(@program, "uMVMatrix")
        @program.uColor = glContext.getUniformLocation(@program, "uColor")
        @
      setMatrixUniforms: (matrices) ->
        glContext.enableVertexAttribArray(@program.vertexPosition)
        glContext.uniformMatrix4fv(@program.pMatrixUniform, false, matrices.p)
        glContext.uniformMatrix4fv(@program.mvMatrixUniform, false, matrices.mv)
      vertexPosition: ->
        return @program.vertexPosition
      setDrawableUniforms: (drawable) ->
        @color = drawable.color
        glContext.uniform4fv(@program.uColor, @color)
    class GoraudLambertian extends BasicShader
      constructor: (vertexShaderId, fragmentShaderId) ->
        super(vertexShaderId, fragmentShaderId)
        @hasNormals = true
        @setAttributeLocations()
        @setUniformLocations()
        @name = "Goraud–Lambert"
        @type = "goraud-lambertian"
      setLightValues: ->
        glContext.uniform3fv(@program.lightDirection, @lightDirection)
        glContext.uniform4fv(@program.lightDiffuse, @lightDiffuse)
        glContext.uniform4fv(@program.materialDiffuse, @materialDiffuse)
        @
      setAttributeLocations: ->
        super()
        @program.vertexNormal = glContext.getAttribLocation(@program, 'aVertexNormal')
        glContext.enableVertexAttribArray(@program.vertexNormal)
        @
      setUniformLocations: ->
        super()
        @program.nMatrixUniform = glContext.getUniformLocation(@program, "uNMatrix")
        @program.materialDiffuse = glContext.getUniformLocation(@program, "uMaterialDiffuse")
        @program.lightDiffuse = glContext.getUniformLocation(@program, "uLightDiffuse")
        @program.lightDirection = glContext.getUniformLocation(@program, "uLightDirection")
        @
      setDrawableUniforms: (drawable) ->
        @setMaterialDiffuse(drawable.color)
        @setLightDirection(drawable.lightDirection)
        @setLightDiffuse(drawable.lightDiffuse)
        @
      setMaterialDiffuse: (diffuse) ->
        @materialDiffuse = diffuse
        glContext.uniform4fv(@program.materialDiffuse, @materialDiffuse)
        @
      setLightDirection: (direction) ->
        @lightDirection = direction
        glContext.uniform3fv(@program.lightDirection, @lightDirection)
        @
      setLightDiffuse: (diffuse) ->
        @lightDiffuse = diffuse
        glContext.uniform4fv(@program.lightDiffuse, @lightDiffuse)
        @
      vertexNormal: ->
        return @program.vertexNormal
    class StripesShader extends BasicShader
      constructor: (vertexShaderId, fragmentShaderId) ->
        super(vertexShaderId, fragmentShaderId)
        @setAttributeLocations()
        @setUniformLocations()
        @name = "Stripes Shader"
        @type = "stripes"
      setUniformLocations: ->
        super()
        @program.uFirstColor = glContext.getUniformLocation(@program, "uFirstColor")
        @program.uSecondColor = glContext.getUniformLocation(@program, "uSecondColor")
        @program.uHorizontalStripes = glContext.getUniformLocation(@program, "uHorizontalStripes")
        @program.uGapSize = glContext.getUniformLocation(@program, "uGapSize")
        @program.uStripeWidth = glContext.getUniformLocation(@program, "uStripeWidth")
        @
      setDrawableUniforms: (drawable) ->
        glContext.uniform4fv(@program.uFirstColor, drawable.firstColor)
        glContext.uniform4fv(@program.uSecondColor, drawable.secondColor)
        glContext.uniform1i(@program.uHorizontalStripes, drawable.horizontalStripes)
        glContext.uniform2fv(@program.uGapSize, drawable.gapSize)
        glContext.uniform1f(@program.uStripeWidth, drawable.stripeWidth)
        @
    compileShaders()

    Shaders = {
      'basic': [BasicShader, 'shader-vs', 'solidGrey-fs', "Basic Shader"],
      'stripes': [StripesShader, 'shader-vs', 'stripes-fs', "Stripes Shader"],
      'goraud-lambertian': [GoraudLambertian, "goraudLambertian-vs", "goraudLambertian-fs", "Goraud–Lambert"]
    }

    shaderInstances = {

    }
    @service.getShader = (name) =>
      s = Shaders[name]
      Klass = s[0]
      if shaderInstances[name]?
        return shaderInstances[name]
      shaderInstances[name] = new Klass(s[1], s[2])
      return shaderInstances[name]
    @service.defaultShader = () =>
      return @service.getShader('goraud-lambertian')
    @service.getShaderNames = =>
      res = {}
      for key, values of Shaders
        res[key] = values[3]
      res
    return @service
  )