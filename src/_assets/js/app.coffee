
angular.element(document).ready () ->
  window.location.hash = '#!' if (window.location.hash is '#_=_')

@myApp = angular.module('WebGLProject', [
  'ui.bootstrap',
  'colorpicker.module',
  'WebGLProject.services',
  'WebGLProject.directives',
  'WebGLProject.controllers'
])

@myApp.config ['$interpolateProvider', ($interpolateProvider)->
  $interpolateProvider.startSymbol('{(').endSymbol(')}')
]


@myApp.run()
