# # # # # # # # # # # # # # # # # # # #
# File: Tiramisu/_TiramisuGL/init.coffee
# Author: NaNuNo
# Project: https://github.com/NaNuNoo/Tiramisu
# WebSite: http://FenQi.IO
# # # # # # # # # # # # # # # # # # # #

window.tiGL = tiGL = {}

canvasArray = document.getElementsByTagName('canvas')
canvasArray = canvasArray.filter (item) ->
  return 'TiramisuGL' in item
if canvasArray.length < 1
  throw new Error('Element not dound. <canvas TiramisuGL></canvas>')
else if canvasArray.length > 1
  throw new Error('More than one elements. <canvas TiramisuGL></canvas>')
canvas = canvasArray[0]
if not canvas
  return null

pramaGL =
  alpha: canvas.alpha ? true
  depth: canvas.depth ? true
  stencil: canvas.stencil ? false
  antialias: canvas.antialias ? true
  premultipliedAlpha: canvas.premultipliedAlpha ? true
  preserveDrawingBuffer: canvas.preserveDrawingBuffer ? false
webGL = canvas.getContext('webgl', pramaGL) or
  canvas.getContext('experimental-webgl', pramaGL) or
  canvas.getContext('webkit-3d', pramaGL) or
  canvas.getContext('moz-webgl', pramaGL) or
  canvas.getContext('webkit-webgl', pramaGL) or
  canvas.getContext('ms-webgl', pramaGL) or
  canvas.getContext('o-webgl', pramaGL)
if not webGL
  throw new Error("Create webGL context failed.")

tiGL.canvas = canvas
tiGL.webGL = webGL
