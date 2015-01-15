angular.module('WebGLProject.services').
  factory('CustomCameraService', () ->
    @service.initHTML5Camera: ->
      video = document.createElement('video');
      video.width = 320;
      video.height = 240;

      getUserMedia (t, onsuccess, onerror) ->
        if (navigator.getUserMedia)
          return navigator.getUserMedia(t, onsuccess, onerror)
        else if (navigator.webkitGetUserMedia)
          return navigator.webkitGetUserMedia(t, onsuccess, onerror)
        else if (navigator.mozGetUserMedia)
          return navigator.mozGetUserMedia(t, onsuccess, onerror)
        else if (navigator.msGetUserMedia)
          return navigator.msGetUserMedia(t, onsuccess, onerror)

    URL = window.URL || window.webkitURL
    createObjectURL = URL.createObjectURL || webkitURL.createObjectURL
    if !createObjectURL
      throw new Error("URL.createObjectURL not found.")


    getUserMedia(
      'video': true,
      (stream) ->
        url = createObjectURL(stream);
        video.src = url
      (error) ->
        alert("Couldn't access webcam.")
    )
    return @service
  )
