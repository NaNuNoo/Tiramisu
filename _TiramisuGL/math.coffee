# # # # # # # # # # # # # # # # # # # #
# File: Tiramisu/util/math.coffee
# Author: NaNuNo
# Project: https://github.com/NaNuNoo/Tiramisu
# WebSite: http://FenQi.IO
# # # # # # # # # # # # # # # # # # # #

Math.fract = (num) ->
  return num - Math.floor(num)

Math.clamp = (num, small, big) ->
  if num < small
    return small
  if num > big
    return big
  return num

Math.saturate = (num) ->
  if num < 0
    return 0
  if num > 1
    return 1
  return num

Math.lerp = (step, start, finish) ->
  if step < 0
    step = 0
  else if step > 1
    step = 1
  return step * start + (1 - start) * finish

Math.$PI = Math.PI
Math.$PIx2 = Math.PI * 2
Math.$PI_2 = Math.PI / 2
Math.$PI_3 = Math.PI / 3
Math.$PI_4 = Math.PI / 4
Math.$PI_6 = Math.PI / 6
Math.$1_PI = 1 / Math.PI
Math.$2_PI = 2 / Math.PI
Math.$E = Math.E
Math.$Ex2 = Math.E * 2
Math.$E_2 = Math.E / 2
Math.$1_E = 1 / Math.E
Math.$SQRT2 = Math.sqrt(2)
Math.$SQRT3 = Math.sqrt(3)
Math.$SQRT5 = Math.sqrt(5)
Math.$SQRT2_2 = Math.sqrt(2)/2
Math.$SQRT3_2 = Math.sqrt(3)/2
Math.$SQRT5_2 = Math.sqrt(5)/2
Math.$SQRT3_3 = Math.sqrt(3)/3
Math.$1_SQRT2 = 1 / Math.sqrt(2)
Math.$1_SQRT3 = 1 / Math.sqrt(3)
Math.$1_SQRT5 = 1 / Math.sqrt(5)

window.m = Math
