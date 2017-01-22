# # # # # # # # # # # # # # # # # # # #
# File: Tiramisu/_Tiramisu/math.coffee
# Author: NaNuNo
# Project: https://github.com/NaNuNoo/Tiramisu
# WebSite: http://FenQi.IO
# # # # # # # # # # # # # # # # # # # #

m = {}

for name, func in Math
  if 'function' == typeof(name)
    m[name] = func

m.fract = (num) ->
  return num - Math.floor(num)

m.clamp = (num, small, big) ->
  if num < small
    return small
  if num > big
    return big
  return num

m.saturate = (num) ->
  if num < 0
    return 0
  if num > 1
    return 1
  return num

m.lerp = (step, start, finish) ->
  if step < 0
    step = 0
  else if step > 1
    step = 1
  return step * start + (1 - start) * finish

m.$PI = Math.PI
m.$PIx2 = Math.PI * 2
m.$PI_2 = Math.PI / 2
m.$PI_3 = Math.PI / 3
m.$PI_4 = Math.PI / 4
m.$PI_6 = Math.PI / 6
m.$1_PI = 1 / Math.PI
m.$2_PI = 2 / Math.PI

m.$E = Math.E
m.$Ex2 = Math.E * 2
m.$E_2 = Math.E / 2
m.$1_E = 1 / Math.E
m.$LN2 = Math.LN2
m.$LN10 = Math.LN10
m.$LOG2E = Math.LOG2E
m.$LOG10E = Math.LOG10E

m.$SQRT2 = Math.sqrt(2)
m.$SQRT3 = Math.sqrt(3)
m.$SQRT5 = Math.sqrt(5)
m.$SQRT2_2 = Math.sqrt(2)/2
m.$SQRT3_2 = Math.sqrt(3)/2
m.$SQRT5_2 = Math.sqrt(5)/2
m.$SQRT3_3 = Math.sqrt(3)/3
m.$1_SQRT2 = 1 / Math.sqrt(2)
m.$1_SQRT3 = 1 / Math.sqrt(3)
m.$1_SQRT5 = 1 / Math.sqrt(5)
