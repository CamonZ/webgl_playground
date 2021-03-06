angular.module('WebGLProject.services').
  factory('CustomCameraService', ->
    @service = {}

    @service.initHTML5Camera = ->
      video = document.createElement('video')
      video.width = 320
      video.height = 240

      URL = window.URL || window.webkitURL
      createObjectURL = URL.createObjectURL || webkitURL.createObjectURL

      streamFunc = (stream) ->
          url = createObjectURL(stream)
          video.src = url
          @
      errorFunc = (error) ->
          alert("Couldn't access webcam.")
          @

      navigator.webkitGetUserMedia( 'video': true, streamFunc, errorFunc)

      return @
    return @service
  )
