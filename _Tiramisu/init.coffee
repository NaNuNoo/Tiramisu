# # # # # # # # # # # # # # # # # # # #
# File: Tiramisu/_Tiramisu/init.coffee
# Author: NaNuNo
# Project: https://github.com/NaNuNoo/Tiramisu
# WebSite: http://FenQi.IO
# # # # # # # # # # # # # # # # # # # #

window.ti = ti = {}

canvasArray = document.getElementsByTagName('canvas')
if not canvasArray
  throw new Error('Element not dound. <canvas Tiramisu></canvas>')
canvasArray = Array::filter.call canvasArray, (item) ->
  return 'string' == typeof(item.getAttribute('Tiramisu'))
if canvasArray.length < 1
  throw new Error('Element not dound. <canvas Tiramisu></canvas>')
else if canvasArray.length > 1
  throw new Error('More than one elements. <canvas Tiramisu></canvas>')
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

ti.canvas = canvas
ti.webGL = webGL
