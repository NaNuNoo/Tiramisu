# # # # # # # # # # # # # # # # # # # #
# const
# # # # # # # # # # # # # # # # # # # #

canvas = document.createElement("canvas")
webGL = canvas.getContext("webgl") or
  canvas.getContext("experimental-webgl") or
  canvas.getContext("webkit-3d") or
  canvas.getContext("moz-webgl") or
  canvas.getContext("webkit-webgl") or
  canvas.getContext("ms-webgl") or
  canvas.getContext("o-webgl")
if not webGL
  return null


TextureFormat = (name, glFormat, glMemeory) ->
  @name = name
  @glFormat = glFormat
  @glMemeory = glMemeory
  Object.freeze(this)
  return

TextureFormat::toString = () ->
  return @name

TextureFormat.R4G4B4A4 = new TextureFormat("R4G4B4A4", webGL.RGBA, webGL.UNSIGNED_SHORT_4_4_4_4)
TextureFormat.R5G5B5A1 = new TextureFormat("R5G5B5A1", webGL.RGBA, webGL.UNSIGNED_SHORT_5_5_5_1)
TextureFormat.R5G6B5 = new TextureFormat("R5G6B5", webGL.RGB, webGL.UNSIGNED_SHORT_5_6_5)
TextureFormat.L8 = new TextureFormat("L8", webGL.LUMINANCE, webGL.UNSIGNED_BYTE)
TextureFormat.A8 = new TextureFormat("A8", webGL.ALPHA, webGL.UNSIGNED_BYTE)
TextureFormat.L8A8 = new TextureFormat("L8A8", webGL.LUMINANCE_ALPHA, webGL.UNSIGNED_BYTE)
TextureFormat.R8G8B8 = new TextureFormat("R8G8B8", webGL.RGB, webGL.UNSIGNED_BYTE)
TextureFormat.R8G8B8A8 = new TextureFormat("R8G8B8A8", webGL.RGBA, webGL.UNSIGNED_BYTE)


TextureWrap = (name, glCode) ->
  @name = name
  @glCode = glCode
  Object.freeze(this)
  return

TextureWrap::toString = () ->
  return @name

TextureWrap.REPEAT = new TextureWrap("REPEAT", webGL.REPEAT)
TextureWrap.EDGE = new TextureWrap("EDGE", webGL.CLAMP_TO_EDGE)
TextureWrap.MIRROR = new TextureWrap("MIRROR", webGL.MIRRORED_REPEAT)


TextureFilter = (name, glCode) ->
  @name = name
  @glCode = glCode
  Object.freeze(this)
  return

TextureFilter::toString = () ->
  return @name

TextureFilter.NEAREST = new TextureFilter("NEAREST", webGL.NEAREST)
TextureFilter.LINEAR = new TextureFilter("LINEAR", webGL.LINEAR)
TextureFilter.NEAREST_NEAREST = new TextureFilter("NEAREST_NEAREST", webGL.NEAREST_MIPMAP_NEARESTA)
TextureFilter.NEAREST_LINEAR = new TextureFilter("NEAREST_LINEAR", webGL.NEAREST_MIPMAP_LINEAR)
TextureFilter.LINEAR_NEAREST = new TextureFilter("LINEAR_NEAREST", webGL.LINEAR_MIPMAP_NEAREST)
TextureFilter.LINEAR_LINEAR = new TextureFilter("LINEAR_LINEAR", webGL.LINEAR_MIPMAP_LINEAR)


SurfaceFormat = (name, glCode) ->
  @name = name
  @glCode = glCode
  Object.freeze(this)
  return

SurfaceFormat::toString = () ->
  return @name


BufferUsage = (name, glCode) ->
  @name = name
  @glCode = glCode
  Object.freeze(this)
  return

BufferUsage::toString = () ->
  return @name

BufferUsage.STATIC = new BufferUsage("STATIC", webGL.STATIC_DRAW)
BufferUsage.DYNAMIC = new BufferUsage("DYNAMIC", webGL.DYNAMIC_DRAW)
BufferUsage.STREAM = new BufferUsage("STREAM", webGL.STREAM_DRAW)


IndexType = (name, glCode) ->
  @name = name
  @glCode = glCode
  Object.freeze(this)
  return

IndexType::toString = () ->
  return @name

IndexType.BYTE = new IndexType("BYTE", webGL.BYTE)
IndexType.SHORT = new IndexType("SHORT", webGL.SHORT)


DrawMode = (name, glCode) ->
  @name = name
  @glCode = glCode
  Object.freeze(this)
  return

DrawMode::toString = () ->
  return @name

DrawMode.POINTS = new DrawMode("POINTS", webGL.POINTS)
DrawMode.LINE_STRIP = new DrawMode("LINE_STRIP", webGL.LINE_STRIP)
DrawMode.LINE_LOOP = new DrawMode("LINE_LOOP", webGL.LINE_LOOP)
DrawMode.LINES = new DrawMode("LINES", webGL.LINES)
DrawMode.TRIANGLE_STRIP = new DrawMode("TRIANGLE_STRIP", webGL.TRIANGLE_STRIP)
DrawMode.TRIANGLE_FAN = new DrawMode("TRIANGLE_FAN", webGL.TRIANGLE_FAN)
DrawMode.TRIANGLES = new DrawMode("TRIANGLES", webGL.TRIANGLES)


GLSLType = (typeIndex, typeName, typeCode, unitBytes, unitCount) ->
  # type类型:
  #   float的类型是float
  #   vec2的类型是vec2
  #   vec2[2]的类型是vec2
  # unit基元:
  #   float的基元是float
  #   vec2的基元是float
  #   vec2[2]的基元是float
  @typeIndex = typeIndex # <int> 便于switch的类型索引
  @typeName = typeName # <string> 类型名称
  @typeCode = typeCode # <int> 类型的WebGL名称
  @unitBytes = unitBytes # <int> 基元的包含字节数
  @unitCount = unitCount # <int> 类型包含的基元个数
  Object.freeze(this)
  return

GLSLType.fromGLType = (webGLType) ->
  return switch webGLType
    when webGL.BOOL then GLSLType.BOOL
    when webGL.BOOL_VEC2 then GLSLType.BVEC2
    when webGL.BOOL_VEC3 then GLSLType.BVEC3
    when webGL.BOOL_VEC4 then GLSLType.BVEC4
    when webGL.INT then GLSLType.INT
    when webGL.INT_VEC2 then GLSLType.IVEC2
    when webGL.INT_VEC3 then GLSLType.IVEC3
    when webGL.INT_VEC4 then GLSLType.IVEC4
    when webGL.FLOAT then GLSLType.FLOAT
    when webGL.FLOAT_VEC2 then GLSLType.VEC2
    when webGL.FLOAT_VEC3 then GLSLType.VEC3
    when webGL.FLOAT_VEC4 then GLSLType.VEC4
    when webGL.FLOAT_MAT2 then GLSLType.MAT2
    when webGL.FLOAT_MAT3 then GLSLType.MAT3
    when webGL.FLOAT_MAT4 then GLSLType.MAT4
    when webGL.SAMPLER_2D then GLSLType.SAMPLER_2D
    when webGL.SAMPLER_CUBE then GLSLType.SAMPLER_Cube
    else null

GLSLType.BOOL = new GLSLType(0, "bool", webGL.BOOL, 1, 1)
GLSLType.BVEC2 = new GLSLType(1, "bvec2", webGL.BOOL_VEC2, 1, 2)
GLSLType.BVEC3 = new GLSLType(2, "bvec3", webGL.BOOL_VEC3, 1, 3)
GLSLType.BVEC4 = new GLSLType(3, "bvec4", webGL.BOOL_VEC4, 1, 4)
GLSLType.INT = new GLSLType(4, "int", webGL.INT, 4, 1)
GLSLType.IVEC2 = new GLSLType(5, "ivec2", webGL.INT_VEC2, 4, 2)
GLSLType.IVEC3 = new GLSLType(6, "ivec3", webGL.INT_VEC3, 4, 3)
GLSLType.IVEC4 = new GLSLType(7, "ivec4", webGL.INT_VEC4, 4, 4)
GLSLType.FLOAT = new GLSLType(8, "float", webGL.FLOAT, 4, 1)
GLSLType.VEC2 = new GLSLType(9, "vec2", webGL.FLOAT_VEC2, 4, 2)
GLSLType.VEC3 = new GLSLType(10, "vec3", webGL.FLOAT_VEC3, 4, 3)
GLSLType.VEC4 = new GLSLType(11, "vec4", webGL.FLOAT_VEC4, 4, 4)
GLSLType.MAT2 = new GLSLType(12, "mat2", webGL.FLOAT_MAT2, 4, 4)
GLSLType.MAT3 = new GLSLType(13, "mat3", webGL.FLOAT_MAT3, 4, 9)
GLSLType.MAT4 = new GLSLType(14, "mat4", webGL.FLOAT_MAT4, 4, 16)
GLSLType.SAMPLER_2D = new GLSLType(15, "sampler2d", webGL.SAMPLER_2D, 4, 1)
GLSLType.SAMPLER_CUBE = new GLSLType(16, "samplerCube", webGL.SAMPLER_CUBE, 4, 1)


GLSLVar = (info, location) ->
  @varName = info.name
  @location = location
  @typeInfo = GLSLType.fromGLType(info.type)
  @arraySize = info.size
  return

GLSLVar::toString = () ->
  return "#{@typeInfo} #{@varName}"
