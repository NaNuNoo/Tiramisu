# # # # # # # # # # # # # # # # # # # #
# File: Tiramisu/_helper/camera.coffee
# Author: NaNuNo
# Project: https://github.com/NaNuNoo/Tiramisu
# WebSite: http://FenQi.IO
# # # # # # # # # # # # # # # # # # # #

PHI_MIN = 0
PHI_MAX = Math.PI * 2
THETA_MIN = 0
THETA_MAX = Math.PI

class SphereView
  constructor: () ->
    @_phi = 0
    @_theta = Math.PI / 2
    @_radius = 200
    @_viewPos = vec3.create()
    @_viewMat = mat4.create()
    return

  getViewPos: () ->
    return @_viewPos

  getViewMat: () ->
    return @_viewMat

  update: () ->
    x = @_radius * Math.sin(@_theta) * Math.cos(@_phi)
    z = @_radius * Math.sin(@_theta) * Math.sin(@_phi)
    y = @_radius * Math.cos(@_theta)
    vec3.set(@_viewPos, x, y, z)
    upx = @_radius * Math.sin(@_theta + Math.PI / 2) * Math.cos(@_phi)
    upz = @_radius * Math.sin(@_theta + Math.PI / 2) * Math.sin(@_phi)
    upy = @_radius * Math.cos(@_theta + Math.PI / 2)
    mat4.lookAt(@_viewMat, [0,0,0], [upx,upy,upz])
    return

  incPhi: () ->

  decPhi: () ->

  incTheta: () ->

  decTheta: () ->
