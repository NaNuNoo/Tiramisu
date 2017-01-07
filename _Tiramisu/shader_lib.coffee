# # # # # # # # # # # # # # # # # # # #
# File: Tiramisu/_Tiramisu/shader_lib.coffee
# Author: NaNuNo
# Project: https://github.com/NaNuNoo/Tiramisu
# WebSite: http://FenQi.IO
# # # # # # # # # # # # # # # # # # # #

SHADER_PUBLIC_LIB = '''
const float C_0 = 0.0;
const float C_1 = 1.0;
const float C_PI = 3.141592653589793;
const float C_2xPI = 2.0 * C_PI;
const float C_1_PI = 1.0 / C_PI;
const float C_EPSILON = 1e-6;

float saturate(const in float a) { return clamp(a, C_0, C_1); }
vec2 saturate(const in vec2 a) { return clamp(a, C_0, C_1); }
vec3 saturate(const in vec3 a) { return clamp(a, C_0, C_1); }
vec4 saturate(const in vec4 a) { return clamp(a, C_0, C_1); }

float pow2(const in float a) { return a * a; }
float pow3(const in float a) { return a * a * a; }
float pow4(const in float a) { float b = a * a; return b * b; }
'''

SHADER_VERTEX_LIB = '''
'''

SHADER_FRAGMENT_LIB = '''
const float GAMMA_IN = 2.2;
vec3 gammaIn(const in vec3 c) { return pow(c, vec3(GAMMA_IN)); }
vec4 gammaIn(const in vec4 c) { return pow(c, vec4(GAMMA_IN)); }
const float GAMMA_OUT = 1.0 / GAMMA_IN;
vec3 gammaOut(const in vec3 c) { return pow(c, vec3(GAMMA_OUT)); }
vec4 gammaOut(const in vec4 c) { return pow(c, vec4(GAMMA_OUT)); }
'''

joinVsCode = (vsCode) ->
  return """
  //////////////// SHADER_PUBLIC_LIB ////////////////
  #{SHADER_PUBLIC_LIB}

  //////////////// SHADER_VERTEX_LIB ////////////////
  #{SHADER_VERTEX_LIB}

  //////////////// User VS Code ////////////////
  #{vsCode}
  """

joinFsCode = (fsCode) ->
  return """
  precision mediump float;

  //////////////// SHADER_PUBLIC_LIB ////////////////
  #{SHADER_PUBLIC_LIB}

  //////////////// SHADER_FRAGMENT_LIB ////////////////
  #{SHADER_VERTEX_LIB}

  //////////////// User FS Code ////////////////
  #{fsCode}
  """
