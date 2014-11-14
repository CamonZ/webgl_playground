(function() {
  angular.module('WebGLProject.services', []).factory('CanvasService', function() {
    var aspectF, degToRad, initContext, radToDeg;
    this.context = null;
    initContext = (function(_this) {
      return function() {
        var h, w;
        _this.canvas = $("canvas");
        try {
          _this.context = _this.canvas[0].getContext('experimental-webgl');
          w = parseInt(_this.canvas.css('width'));
          h = parseInt(_this.canvas.css('height'));
          _this.canvas[0].width = w;
          _this.canvas[0].height = h;
          return _this.context.viewport(0, 0, w, h);
        } catch (_error) {
          if (!_this.context) {
            return console.error("couldn't get the webgl context");
          }
        }
      };
    })(this);
    radToDeg = function(radians) {
      return radians * 180 / Math.PI;
    };
    degToRad = function(degrees) {
      return degrees * Math.PI / 180;
    };
    aspectF = (function(_this) {
      return function() {
        return _this.canvas[0].width / _this.canvas[0].height;
      };
    })(this);
    return {
      glContext: (function(_this) {
        return function() {
          if (_this.context !== null) {
            return _this.context;
          }
          initContext();
          return _this.context;
        };
      })(this),
      aspect: aspectF,
      xAngleFromDrag: (function(_this) {
        return function(diff) {
          var halfHeight;
          halfHeight = _this.canvas[0].height / 2;
          return ((diff * 180) / halfHeight) * 0.5;
        };
      })(this),
      zAngleFromDrag: (function(_this) {
        return function(diff) {
          var halfWidth;
          halfWidth = _this.canvas[0].width / 2;
          return ((diff * 180) / halfWidth) * 0.5;
        };
      })(this),
      updateAspect: (function(_this) {
        return function(width, height) {
          _this.canvas[0].width = width;
          _this.canvas[0].height = height;
          return _this.context.viewport(0, 0, w, h);
        };
      })(this)
    };
  });

}).call(this);

(function() {
  angular.module('WebGLProject.services').factory('CameraService', function(CanvasService) {
    var degToRad, glContext, radToDeg;
    this.pMatrix = null;
    glContext = CanvasService.glContext();
    this.service = {};
    this.type = '';
    this.fovYInitial = 60;
    this.fovYDiff = 0;
    this.orthoZoomFactor = 1;
    radToDeg = function(radians) {
      return radians * 180 / Math.PI;
    };
    degToRad = function(degrees) {
      return degrees * Math.PI / 180;
    };
    this.service.initialize = (function(_this) {
      return function(pMatrix) {
        return _this.pMatrix = pMatrix;
      };
    })(this);
    this.service.perspective = (function(_this) {
      return function() {
        _this.type = 'perspective';
        mat4.identity(_this.pMatrix);
        return mat4.perspective(_this.pMatrix, degToRad(_this.fovYInitial + _this.fovYDiff), CanvasService.aspect(), 0.1, 100);
      };
    })(this);
    this.service.orthographic = (function(_this) {
      return function() {
        _this.type = 'orthographic';
        mat4.identity(_this.pMatrix);
        return mat4.ortho(_this.pMatrix, -15 * _this.orthoZoomFactor, 15 * _this.orthoZoomFactor, -15 * _this.orthoZoomFactor, 15 * _this.orthoZoomFactor, 0.1, 100);
      };
    })(this);
    this.service.zoom = (function(_this) {
      return function(step) {
        if (_this.type === 'perspective') {
          _this.fovYDiff -= step;
          if (_this.fovYDiff < -59) {
            _this.fovYDiff = -59;
          }
          if (_this.fovYDiff > 119) {
            _this.fovYDiff = 119;
          }
          return _this.service.perspective();
        } else {
          _this.orthoZoomFactor -= step * 0.01;
          return _this.service.orthographic();
        }
      };
    })(this);
    return this.service;
  });

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  angular.module('WebGLProject.services').factory('ShadersService', function(CanvasService) {
    var BasicShader, GoraudLambertian, Shaders, StripesShader, compileShaders, glContext, shaderInstances, shaderSources, shaderTypes;
    this.service = {};
    glContext = CanvasService.glContext();
    shaderTypes = {
      'fragment': glContext.FRAGMENT_SHADER,
      'vertex': glContext.VERTEX_SHADER
    };
    shaderSources = {
      'vertex': {},
      'fragment': {}
    };
    compileShaders = (function(_this) {
      return function() {
        var script, shader, type, _i, _len, _ref;
        _ref = $("script[type*='x-shader']");
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          script = _ref[_i];
          type = /x-shader\/x-(.+)/.exec(script.type)[1];
          shader = glContext.createShader(shaderTypes[type]);
          glContext.shaderSource(shader, script.text);
          glContext.compileShader(shader);
          if (glContext.getShaderParameter(shader, glContext.COMPILE_STATUS)) {
            shaderSources[type][script.id] = shader;
          } else {
            console.log('Error when compiling shader: ' + glContext.getShaderInfoLog(shader));
          }
        }
        return _this;
      };
    })(this);
    BasicShader = (function() {
      function BasicShader(vertexShaderId, fragmentShaderId) {
        this.hasNormals = false;
        this.color = [1, 1, 1, 1];
        this.linkShaders(vertexShaderId, fragmentShaderId);
        this.setAttributeLocations();
        this.setUniformLocations();
        this.name = "Basic Shader";
        this.type = "basic";
      }

      BasicShader.prototype.linkShaders = function(vertexId, fragmentId) {
        this.program = glContext.createProgram();
        glContext.attachShader(this.program, shaderSources['vertex'][vertexId]);
        glContext.attachShader(this.program, shaderSources['fragment'][fragmentId]);
        glContext.linkProgram(this.program);
        if (!(glContext.getProgramParameter(this.program, glContext.LINK_STATUS))) {
          return console.log('Error when linking shaders: ' + glContext.getProgramInfoLog(this.program));
        }
      };

      BasicShader.prototype.setAttributeLocations = function() {
        return this.program.vertexPosition = glContext.getAttribLocation(this.program, 'aVertexPosition');
      };

      BasicShader.prototype.setUniformLocations = function() {
        this.program.pMatrixUniform = glContext.getUniformLocation(this.program, "uPMatrix");
        this.program.mvMatrixUniform = glContext.getUniformLocation(this.program, "uMVMatrix");
        this.program.uColor = glContext.getUniformLocation(this.program, "uColor");
        return this;
      };

      BasicShader.prototype.setMatrixUniforms = function(matrices) {
        glContext.enableVertexAttribArray(this.program.vertexPosition);
        glContext.uniformMatrix4fv(this.program.pMatrixUniform, false, matrices.p);
        return glContext.uniformMatrix4fv(this.program.mvMatrixUniform, false, matrices.mv);
      };

      BasicShader.prototype.vertexPosition = function() {
        return this.program.vertexPosition;
      };

      BasicShader.prototype.setDrawableUniforms = function(drawable) {
        this.color = drawable.color;
        return glContext.uniform4fv(this.program.uColor, this.color);
      };

      return BasicShader;

    })();
    GoraudLambertian = (function(_super) {
      __extends(GoraudLambertian, _super);

      function GoraudLambertian(vertexShaderId, fragmentShaderId) {
        GoraudLambertian.__super__.constructor.call(this, vertexShaderId, fragmentShaderId);
        this.hasNormals = true;
        this.setAttributeLocations();
        this.setUniformLocations();
        this.name = "Goraud–Lambert";
        this.type = "goraud-lambertian";
      }

      GoraudLambertian.prototype.setLightValues = function() {
        glContext.uniform3fv(this.program.lightDirection, this.lightDirection);
        glContext.uniform4fv(this.program.lightDiffuse, this.lightDiffuse);
        glContext.uniform4fv(this.program.materialDiffuse, this.materialDiffuse);
        return this;
      };

      GoraudLambertian.prototype.setAttributeLocations = function() {
        GoraudLambertian.__super__.setAttributeLocations.call(this);
        this.program.vertexNormal = glContext.getAttribLocation(this.program, 'aVertexNormal');
        glContext.enableVertexAttribArray(this.program.vertexNormal);
        return this;
      };

      GoraudLambertian.prototype.setUniformLocations = function() {
        GoraudLambertian.__super__.setUniformLocations.call(this);
        this.program.nMatrixUniform = glContext.getUniformLocation(this.program, "uNMatrix");
        this.program.materialDiffuse = glContext.getUniformLocation(this.program, "uMaterialDiffuse");
        this.program.lightDiffuse = glContext.getUniformLocation(this.program, "uLightDiffuse");
        this.program.lightDirection = glContext.getUniformLocation(this.program, "uLightDirection");
        return this;
      };

      GoraudLambertian.prototype.setDrawableUniforms = function(drawable) {
        this.setMaterialDiffuse(drawable.color);
        this.setLightDirection(drawable.lightDirection);
        this.setLightDiffuse(drawable.lightDiffuse);
        return this;
      };

      GoraudLambertian.prototype.setMaterialDiffuse = function(diffuse) {
        this.materialDiffuse = diffuse;
        glContext.uniform4fv(this.program.materialDiffuse, this.materialDiffuse);
        return this;
      };

      GoraudLambertian.prototype.setLightDirection = function(direction) {
        this.lightDirection = direction;
        glContext.uniform3fv(this.program.lightDirection, this.lightDirection);
        return this;
      };

      GoraudLambertian.prototype.setLightDiffuse = function(diffuse) {
        this.lightDiffuse = diffuse;
        glContext.uniform4fv(this.program.lightDiffuse, this.lightDiffuse);
        return this;
      };

      GoraudLambertian.prototype.vertexNormal = function() {
        return this.program.vertexNormal;
      };

      return GoraudLambertian;

    })(BasicShader);
    StripesShader = (function(_super) {
      __extends(StripesShader, _super);

      function StripesShader(vertexShaderId, fragmentShaderId) {
        StripesShader.__super__.constructor.call(this, vertexShaderId, fragmentShaderId);
        this.setAttributeLocations();
        this.setUniformLocations();
        this.name = "Stripes Shader";
        this.type = "stripes";
      }

      StripesShader.prototype.setUniformLocations = function() {
        StripesShader.__super__.setUniformLocations.call(this);
        this.program.uFirstColor = glContext.getUniformLocation(this.program, "uFirstColor");
        this.program.uSecondColor = glContext.getUniformLocation(this.program, "uSecondColor");
        this.program.uHorizontalStripes = glContext.getUniformLocation(this.program, "uHorizontalStripes");
        this.program.uGapSize = glContext.getUniformLocation(this.program, "uGapSize");
        this.program.uStripeWidth = glContext.getUniformLocation(this.program, "uStripeWidth");
        return this;
      };

      StripesShader.prototype.setDrawableUniforms = function(drawable) {
        glContext.uniform4fv(this.program.uFirstColor, drawable.firstColor);
        glContext.uniform4fv(this.program.uSecondColor, drawable.secondColor);
        glContext.uniform1i(this.program.uHorizontalStripes, drawable.horizontalStripes);
        glContext.uniform2fv(this.program.uGapSize, drawable.gapSize);
        glContext.uniform1f(this.program.uStripeWidth, drawable.stripeWidth);
        return this;
      };

      return StripesShader;

    })(BasicShader);
    compileShaders();
    Shaders = {
      'basic': [BasicShader, 'shader-vs', 'solidGrey-fs', "Basic Shader"],
      'stripes': [StripesShader, 'shader-vs', 'stripes-fs', "Stripes Shader"],
      'goraud-lambertian': [GoraudLambertian, "goraudLambertian-vs", "goraudLambertian-fs", "Goraud–Lambert"]
    };
    shaderInstances = {};
    this.service.getShader = (function(_this) {
      return function(name) {
        var Klass, s;
        s = Shaders[name];
        Klass = s[0];
        if (shaderInstances[name] != null) {
          return shaderInstances[name];
        }
        shaderInstances[name] = new Klass(s[1], s[2]);
        return shaderInstances[name];
      };
    })(this);
    this.service.defaultShader = (function(_this) {
      return function() {
        return _this.service.getShader('goraud-lambertian');
      };
    })(this);
    this.service.getShaderNames = (function(_this) {
      return function() {
        var key, res, values;
        res = {};
        for (key in Shaders) {
          values = Shaders[key];
          res[key] = values[3];
        }
        return res;
      };
    })(this);
    return this.service;
  });

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  angular.module('WebGLProject.services').factory('ObjectCreationService', function(CanvasService, ShadersService) {
    var ARRAY_BUFFER, Cone, Cube, Cylinder, Drawable, ELEMENT_ARRAY_BUFFER, FLOAT, IcoSphere, Plane, Pyramid, STATIC_DRAW, Sphere, TRIANGLES, Torus, UNSIGNED_SHORT, degToRad, glContext;
    this.service = {};
    glContext = CanvasService.glContext();
    ARRAY_BUFFER = glContext.ARRAY_BUFFER;
    STATIC_DRAW = glContext.STATIC_DRAW;
    ELEMENT_ARRAY_BUFFER = glContext.ELEMENT_ARRAY_BUFFER;
    FLOAT = glContext.FLOAT;
    UNSIGNED_SHORT = glContext.UNSIGNED_SHORT;
    TRIANGLES = glContext.TRIANGLES;
    degToRad = (function(_this) {
      return function(degrees) {
        return degrees * Math.PI / 180;
      };
    })(this);
    Drawable = (function() {
      function Drawable(objId) {
        var mesh;
        this.id = Date.now();
        this.context = CanvasService.glContext();
        this.shader = ShadersService.defaultShader();
        this.vertexPositionBuffer = null;
        this.vertexNormalsBuffer = null;
        this.vertexIndexBuffer = null;
        this.xPos = 0;
        this.yPos = 0;
        this.zPos = 0;
        this.xRot = 0;
        this.yRot = 0;
        this.zRot = 0;
        this.scaleF = 1;
        this.color = [1, 1, 1, 1];
        this.lightDirection = [0.0, -1.0, -1.0];
        this.lightDiffuse = [1.0, 1.0, 1.0, 1.0];
        this.firstColor = [1, 0, 0, 1];
        this.secondColor = [0, 0, 1, 1];
        this.horizontalStripes = true;
        this.gapSize = [50, 50];
        this.stripeWidth = 25.0;
        mesh = OBJ.Mesh($(objId).text());
        this.vertices = mesh.vertices;
        this.faces = mesh.indices;
        this.normals = mesh.vertexNormals;
        this.setBuffers();
      }

      Drawable.prototype.draw = function(matrices) {
        var translationVector;
        this.context.useProgram(this.shader.program);
        translationVector = [this.xPos, this.yPos, this.zPos];
        mat4.translate(matrices.mv, matrices.mv, translationVector);
        mat4.rotateX(matrices.mv, matrices.mv, degToRad(this.xRot));
        mat4.rotateY(matrices.mv, matrices.mv, degToRad(this.yRot));
        mat4.rotateZ(matrices.mv, matrices.mv, degToRad(this.zRot));
        mat4.scale(matrices.mv, matrices.mv, [this.scaleF, this.scaleF, this.scaleF]);
        this.shader.setMatrixUniforms(matrices);
        this.shader.setDrawableUniforms(this);
        if (this.shader.hasNormals) {
          this.shader.setLightValues();
          mat4.copy(matrices.n, matrices.mv);
          mat4.invert(matrices.n, matrices.n);
          mat4.transpose(matrices.n, matrices.n);
          glContext.uniformMatrix4fv(this.shader.program.nMatrixUniform, false, matrices.n);
        }
        this.context.bindBuffer(ARRAY_BUFFER, this.vertexPositionBuffer);
        this.context.vertexAttribPointer(this.shader.vertexPosition(), 3, FLOAT, false, 0, 0);
        if (this.shader.hasNormals) {
          this.context.bindBuffer(ARRAY_BUFFER, this.vertexNormalsBuffer);
          this.context.vertexAttribPointer(this.shader.vertexNormal(), 3, FLOAT, false, 0, 0);
        }
        this.context.bindBuffer(ELEMENT_ARRAY_BUFFER, this.vertexIndexBuffer);
        this.context.drawElements(TRIANGLES, this.faces.length, UNSIGNED_SHORT, 0);
        this.context.bindBuffer(ARRAY_BUFFER, null);
        return this.context.bindBuffer(ELEMENT_ARRAY_BUFFER, null);
      };

      Drawable.prototype.setBuffers = function() {
        if (this.vertexPositionBuffer == null) {
          this.vertexPositionBuffer = this.context.createBuffer();
        }
        this.context.bindBuffer(ARRAY_BUFFER, this.vertexPositionBuffer);
        this.context.bufferData(ARRAY_BUFFER, new Float32Array(this.vertices), STATIC_DRAW);
        if (this.shader.hasNormals) {
          if (this.vertexNormalsBuffer == null) {
            this.vertexNormalsBuffer = this.context.createBuffer();
          }
          this.context.bindBuffer(ARRAY_BUFFER, this.vertexNormalsBuffer);
          this.context.bufferData(ARRAY_BUFFER, new Float32Array(this.normals), STATIC_DRAW);
        }
        if (this.vertexIndexBuffer == null) {
          this.vertexIndexBuffer = this.context.createBuffer();
        }
        this.context.bindBuffer(ELEMENT_ARRAY_BUFFER, this.vertexIndexBuffer);
        this.context.bufferData(ELEMENT_ARRAY_BUFFER, new Uint16Array(this.faces), STATIC_DRAW);
        this.context.bindBuffer(ARRAY_BUFFER, null);
        return this.context.bindBuffer(ELEMENT_ARRAY_BUFFER, null);
      };

      Drawable.prototype.serialize = function() {
        return this;
      };

      return Drawable;

    })();
    Plane = (function(_super) {
      __extends(Plane, _super);

      function Plane() {
        Plane.__super__.constructor.call(this, '#plane_object');
        this.xRot = 90;
        this.scaleF = 10;
        this.n = "Plane";
        this.color = [0.1419, 0.3101, 0.0953, 1.0];
        this;
      }

      return Plane;

    })(Drawable);
    Cube = (function(_super) {
      __extends(Cube, _super);

      function Cube() {
        Cube.__super__.constructor.call(this, '#cube_object');
        this.zPos = 1;
        this.n = "Cube";
        this.color = [0.9495, 0.3552, 0.0417, 1.0];
      }

      return Cube;

    })(Drawable);
    Pyramid = (function(_super) {
      __extends(Pyramid, _super);

      function Pyramid() {
        Pyramid.__super__.constructor.call(this, '#pyramid_object');
        this.zPos = 1;
        this.xRot = 90;
        this.n = 'Piramid';
        this.color = [0.0000, 0.2107, 0.9495, 1.0];
      }

      return Pyramid;

    })(Drawable);
    Sphere = (function(_super) {
      __extends(Sphere, _super);

      function Sphere() {
        Sphere.__super__.constructor.call(this, '#sphere_object');
        this.zPos = 1;
        this.n = 'Sphere';
        this.color = [0.3477, 0.2305, 0.1192, 1.0];
      }

      return Sphere;

    })(Drawable);
    Cone = (function(_super) {
      __extends(Cone, _super);

      function Cone() {
        Cone.__super__.constructor.call(this, '#cone_object');
        this.zPos = 1;
        this.n = 'Cone';
        this.color = [0.3477, 0.2305, 0.1192, 1.0];
      }

      return Cone;

    })(Drawable);
    IcoSphere = (function(_super) {
      __extends(IcoSphere, _super);

      function IcoSphere() {
        IcoSphere.__super__.constructor.call(this, '#icosphere_object');
        this.zPos = 1;
        this.n = 'IcoSphere';
        this.color = [0.3477, 0.2305, 0.1192, 1.0];
      }

      return IcoSphere;

    })(Drawable);
    Cylinder = (function(_super) {
      __extends(Cylinder, _super);

      function Cylinder() {
        Cylinder.__super__.constructor.call(this, '#cylinder_object');
        this.zPos = 1;
        this.n = 'Cylinder';
        this.color = [0.3477, 0.2305, 0.1192, 1.0];
      }

      return Cylinder;

    })(Drawable);
    Torus = (function(_super) {
      __extends(Torus, _super);

      function Torus() {
        Torus.__super__.constructor.call(this, '#torus_object');
        this.zPos = 1;
        this.n = 'Torus';
        this.color = [0.3477, 0.2305, 0.1192, 1.0];
      }

      return Torus;

    })(Drawable);
    this.Drawables = {
      'cube': Cube,
      'pyramid': Pyramid,
      'sphere': Sphere,
      'plane': Plane,
      'cone': Cone,
      'icosphere': IcoSphere,
      'cylinder': Cylinder,
      'torus': Torus
    };
    this.service.createObject = (function(_this) {
      return function(type, program) {
        return new _this.Drawables[type](program);
      };
    })(this);
    return this.service;
  });

}).call(this);

(function() {
  angular.module('WebGLProject.services').factory('SceneService', function(CanvasService, ShadersService, CameraService, ObjectCreationService) {
    var ARRAY_BUFFER, COLOR_BUFFER_BIT, DEPTH_BUFFER_BIT, DEPTH_TEST, FLOAT, STATIC_DRAW, degToRad, glContext, mvPopMatrix, mvPushMatrix, radToDeg;
    glContext = CanvasService.glContext();
    ARRAY_BUFFER = glContext.ARRAY_BUFFER;
    STATIC_DRAW = glContext.STATIC_DRAW;
    DEPTH_TEST = glContext.DEPTH_TEST;
    COLOR_BUFFER_BIT = glContext.COLOR_BUFFER_BIT;
    DEPTH_BUFFER_BIT = glContext.DEPTH_BUFFER_BIT;
    FLOAT = glContext.FLOAT;
    this.mvMatrix = mat4.create();
    this.pMatrix = mat4.create();
    this.nMatrix = mat4.create();
    this.mvMatrixStack = [];
    this.drawables = {};
    this.xAngle = 75;
    this.zAngle = -180;
    this.service = {};
    mvPushMatrix = (function(_this) {
      return function() {
        var copy;
        copy = mat4.create();
        mat4.copy(copy, _this.mvMatrix);
        _this.mvMatrixStack.push(copy);
        return _this;
      };
    })(this);
    mvPopMatrix = (function(_this) {
      return function() {
        if (_this.mvMatrixStack.length === 0) {
          return;
        }
        _this.mvMatrix = _this.mvMatrixStack.pop();
        return _this;
      };
    })(this);
    radToDeg = (function(_this) {
      return function(radians) {
        return radians * 180 / Math.PI;
      };
    })(this);
    degToRad = (function(_this) {
      return function(degrees) {
        return degrees * Math.PI / 180;
      };
    })(this);
    this.service.initScene = (function(_this) {
      return function() {
        glContext.enable(DEPTH_TEST);
        glContext.depthFunc(glContext.LEQUAL);
        glContext.clearColor(0, 0, 0, 1);
        CameraService.initialize(_this.pMatrix);
        CameraService.perspective();
        _this.floor = ObjectCreationService.createObject('plane');
        return _this;
      };
    })(this);
    this.service.draw = (function(_this) {
      return function() {
        var drawable, id, obs, _ref;
        glContext.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);
        obs = [0, 0, -20];
        mat4.identity(_this.mvMatrix);
        mat4.translate(_this.mvMatrix, _this.mvMatrix, obs);
        mat4.rotateX(_this.mvMatrix, _this.mvMatrix, -degToRad(_this.xAngle));
        mat4.rotateZ(_this.mvMatrix, _this.mvMatrix, -degToRad(_this.zAngle));
        mvPushMatrix();
        _this.floor.draw({
          mv: _this.mvMatrix,
          p: _this.pMatrix,
          n: _this.nMatrix
        });
        mvPopMatrix();
        _ref = _this.drawables;
        for (id in _ref) {
          drawable = _ref[id];
          mvPushMatrix();
          drawable.draw({
            mv: _this.mvMatrix,
            p: _this.pMatrix,
            n: _this.nMatrix
          });
          mvPopMatrix();
        }
        return _this;
      };
    })(this);
    this.service.updateRotationAngles = (function(_this) {
      return function(xDiff, yDiff) {
        _this.zAngle += CanvasService.xAngleFromDrag(xDiff);
        _this.zAngle %= 360;
        _this.xAngle += CanvasService.zAngleFromDrag(yDiff);
        _this.xAngle %= 360;
        _this.service.draw();
        return _this;
      };
    })(this);
    this.service.addDrawable = (function(_this) {
      return function(object) {
        _this.drawables[object.id] = object;
        _this.service.draw();
        return _this;
      };
    })(this);
    this.service.removeDrawable = (function(_this) {
      return function(id) {
        delete _this.drawables[id];
        _this.service.draw();
        return _this;
      };
    })(this);
    this.service.setCamera = (function(_this) {
      return function(type) {
        CameraService[type]();
        _this.service.draw();
        return _this;
      };
    })(this);
    this.service.getDrawable = (function(_this) {
      return function(id) {
        var d, idx, r, str, _i, _ref;
        d = _this.drawables[id];
        str = "";
        for (idx = _i = 0, _ref = d.color.length - 2; 0 <= _ref ? _i <= _ref : _i >= _ref; idx = 0 <= _ref ? ++_i : --_i) {
          str += parseInt(d.color[idx] * 255).toString() + ",";
        }
        str += d.color[3].toString();
        r = {
          id: d.id,
          xPos: d.xPos,
          yPos: d.yPos,
          zPos: d.zPos,
          xRot: d.xRot,
          yRot: d.yRot,
          zRot: d.zRot,
          scaleF: d.scaleF,
          n: d.n,
          color: "rgba(" + str + ")",
          shaderName: d.shader.name,
          shaderType: d.shader.type
        };
        return r;
      };
    })(this);
    this.service.updateDrawable = (function(_this) {
      return function(obj) {
        var attribute, color, matches, normalizeValues, parseValues, _i, _len, _ref;
        parseValues = function(values) {
          var i;
         for(i=0; i< values.length; i++)
           values[i] = parseFloat(values[i]);
        ;
          return values;
        };
        normalizeValues = function(values) {
          var rgbValues;
          rgbValues = values.slice(values.length - 1);
          var i;
         for(i=0; i< values.length-1; i++)
          values[i] = values[i] / 255
        ;
          return values;
        };
        _ref = ['xPos', 'yPos', 'zPos', 'xRot', 'yRot', 'zRot', 'scaleF', 'n', 'color'];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          attribute = _ref[_i];
          if (attribute === 'color' && obj['color'].split !== void 0) {
            color = obj['color'];
            matches = /rgba\((\d+),(\d+),(\d+),(\d*\.?\d+)\)/.exec(color).slice(1);
            obj['color'] = normalizeValues(parseValues(matches));
            console.log(obj['color']);
          }
          _this.drawables[obj.id][attribute] = obj[attribute];
        }
        _this.drawables[obj.id].shader = ShadersService.getShader(obj.shaderType);
        _this.service.draw();
        return _this;
      };
    })(this);
    this.service.zoomCamera = (function(_this) {
      return function(step) {
        CameraService.zoom(step);
        return _this.service.draw();
      };
    })(this);
    this.service.modelView = this.mvMatrix;
    this.service.projection = this.pMatrix;
    return this.service;
  });

}).call(this);

(function() {
  angular.module('WebGLProject.directives', []).directive('sgiCanvasDirective', function(SceneService) {
    return {
      restrict: 'A',
      scope: {},
      replace: false,
      link: function(scope, element, attributes) {
        $(element).mousedown((function(_this) {
          return function(eventData) {
            _this.clicked = true;
            _this.startX = eventData.offsetX;
            return _this.startY = eventData.offsetY;
          };
        })(this));
        $(element).mousemove((function(_this) {
          return function(eventData) {
            var diffX, diffY;
            if (_this.clicked) {
              diffX = eventData.offsetX - _this.startX;
              _this.startX = eventData.offsetX;
              diffY = eventData.offsetY - _this.startY;
              _this.startY = eventData.offsetY;
              return SceneService.updateRotationAngles(diffX, diffY);
            }
          };
        })(this));
        $(element).mouseup((function(_this) {
          return function(eventData) {
            return _this.clicked = false;
          };
        })(this));
        return Hamster(element[0]).wheel((function(_this) {
          return function(event, delta, deltaX, deltaY) {
            console.log('delta:' + delta);
            return SceneService.zoomCamera(delta);
          };
        })(this));
      }
    };
  });

}).call(this);

(function() {
  angular.module('WebGLProject.directives').directive('sgiAddObjectToCanvasDirective', function(SceneService, ObjectCreationService, $compile) {
    return {
      restrict: 'A',
      scope: {},
      replace: false,
      link: function(scope, element, attributes) {
        return $(element).find("li.button").click(function(eventData) {
          var object, objectTag, printable, type;
          type = /add_(\w+)/.exec(this.id)[1];
          object = ObjectCreationService.createObject(type);
          SceneService.addDrawable(object);
          printable = SceneService.getDrawable(object.id);
          scope.$parent.printable = printable;
          objectTag = '<sgi-object-directive id="' + object.id + '" n="' + object.n + '">' + object.n + '</sgi-object-directive>';
          return $("#scene_navigation ul.objects_in_scene").append($compile(objectTag)(scope.$parent));
        });
      }
    };
  });

}).call(this);

(function() {
  angular.module('WebGLProject.directives').directive('sgiObjectDirective', function(SceneService, ObjectCreationService, $compile) {
    return {
      restrict: 'EA',
      transclude: true,
      replace: true,
      template: "<li class='object_navigation'><button type='button' class='close'><span aria-hidden='true'>&times;</span><span class='sr-only'>Close</span></button><p><ng-transclude></ng-transclude></p></li>",
      link: function(scope, element, attributes) {
        var toggleObjectControl;
        toggleObjectControl = function() {
          if ((scope.drawable != null) && scope.status.isObjectControlCollapsed) {
            return scope.status.isObjectControlCollapsed = !scope.status.isObjectControlCollapsed;
          } else if (scope.drawable == null) {
            return scope.status.isObjectControlCollapsed = true;
          }
        };
        $(element).click(function(eventData) {
          var drawable;
          $(element).siblings().removeClass('active');
          $(element).toggleClass('active');
          drawable = $(element).hasClass('active') ? SceneService.getDrawable(element[0].id.trim()) : null;
          scope.drawable = drawable;
          toggleObjectControl();
          scope.$apply();
          return this;
        });
        $(element).find("button.close").click(function(eventData) {
          eventData.preventDefault();
          eventData.stopPropagation();
          SceneService.removeDrawable(element[0].id.trim());
          if ($(element).hasClass('active')) {
            scope.drawable = null;
          }
          $(element).remove();
          toggleObjectControl();
          scope.$apply();
          return this;
        });
        return this;
      }
    };
  });

}).call(this);

(function() {
  angular.module('WebGLProject.controllers', []).controller('ApplicationController', [
    '$scope', '$rootScope', 'SceneService', 'ShadersService', function($scope, $rootScope, SceneService, ShadersService) {
      var watchFunc;
      SceneService.initScene();
      SceneService.draw();
      $scope.cameraTypes = ['perspective', 'orthographic'];
      $scope.activeCameraType = $scope.cameraTypes[0];
      $scope.drawable = null;
      $scope.shaderTypes = ShadersService.getShaderNames();
      $scope.status = {};
      $scope.status.isObjectControlCollapsed = true;
      $scope.status.isShaderDropdownOpen = false;
      $scope.setCameraType = function(type) {
        if (!$scope.isActiveCamera(type)) {
          $scope.activeCameraType = type;
          SceneService.setCamera($scope.activeCameraType);
        }
        return this;
      };
      $scope.isActiveCamera = (function(_this) {
        return function(type) {
          return $scope.activeCameraType === type;
        };
      })(this);
      $scope.shaderSwitch = (function(_this) {
        return function($event) {
          $scope.drawable.shaderType = $event.target.id;
          $scope.drawable.shaderName = $event.target.text;
          SceneService.updateDrawable($scope.drawable);
          return _this;
        };
      })(this);
      watchFunc = function(newVal, oldVal) {
        if (newVal != null) {
          $("li#" + newVal.id).find("p span").text(newVal.n);
          SceneService.updateDrawable(newVal);
        }
        return this;
      };
      $scope.$watch('drawable', watchFunc, true);
      return this;
    }
  ]);

}).call(this);

(function() {
  angular.element(document).ready(function() {
    if (window.location.hash === '#_=_') {
      return window.location.hash = '#!';
    }
  });

  this.myApp = angular.module('WebGLProject', ['ui.bootstrap', 'colorpicker.module', 'WebGLProject.services', 'WebGLProject.directives', 'WebGLProject.controllers']);

  this.myApp.config([
    '$interpolateProvider', function($interpolateProvider) {
      return $interpolateProvider.startSymbol('{(').endSymbol(')}');
    }
  ]);

  this.myApp.run();

}).call(this);
