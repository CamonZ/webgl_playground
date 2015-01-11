angular.module('WebGLProject.services').
  factory('MuseumService', (ObjectCreationService) ->
    @service = {}

    class Museum
      constructor: (scene) ->
        @scene = scene
        @drawables = []

        floor = ObjectCreationService.createObject('plane')
        floor.yPos = 0
        floor.color = [0.1373, 0.1373, 0.1373, 1]
        @scene.addDrawable(floor)
        @.createWalls()
        @.createPodiums()
        @
      createWalls: ->
        wall2 = ObjectCreationService.createObject('cube')
        wall2.n = 'wall2'
        wall2.color = [0.7569, 0.7569, 0.7569, 1]
        wall2.scaleFX = 100
        wall2.scaleFY = 5
        wall2.scaleFZ = 10
        wall2.xPos = 0
        wall2.yPos = 10
        wall2.zPos = -100
        @scene.addDrawable(wall2)

        for xCoord in [-100, 100]
          wall = ObjectCreationService.createObject('cube')
          wall.color = [0.7569, 0.7569, 0.7569, 1]
          wall.scaleFX = 5
          wall.scaleFY = 100
          wall.scaleFZ = 10
          wall.xPos = xCoord
          wall.yPos = 10
          wall.zPos = 0
          @scene.addDrawable(wall)

        for xCoord in [-75, 75]
          wall = ObjectCreationService.createObject('cube')
          wall.color = [0.7569, 0.7569, 0.7569, 1]
          wall.scaleFX = 25
          wall.scaleFY = 25
          wall.scaleFZ = 10
          wall.xPos = xCoord
          wall.yPos = 10
          wall.zPos = 0
          @scene.addDrawable(wall)

      createPodiums: ->
        for xCoord in [-75, 75]
          for zCoord in [-85, -55, 55, 85]
            podium = ObjectCreationService.createObject('cube')
            podium.color = [0.7569, 0.7569, 0.7569, 1]
            podium.scaleFX = 10
            podium.scaleFY = 10
            podium.scaleFZ = 5
            podium.xPos = xCoord
            podium.yPos = 5
            podium.zPos = zCoord
            @scene.addDrawable(podium)
    @service.museum = (scene) =>
      return new Museum(scene)
    return @service
  )
