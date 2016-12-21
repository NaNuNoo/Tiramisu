# # # # # # # # # # # # # # # # # # # #
# buffer
# # # # # # # # # # # # # # # # # # # #

CHAR_INT = 0x1
CHAR_INDEX = 0x2
CHAR_FLOAT = 0x4

CHAR_SIZE = 128
CHAR_TABLE = new Uint32Array(CHAR_SIZE)
CHAR_TABLE[45] = CHAR_FLOAT # -
CHAR_TABLE[46] = CHAR_FLOAT # .
CHAR_TABLE[47] = CHAR_INDEX # /
CHAR_TABLE[48] = CHAR_INT | CHAR_FLOAT | CHAR_INDEX # 0
CHAR_TABLE[49] = CHAR_INT | CHAR_FLOAT | CHAR_INDEX # 1
CHAR_TABLE[50] = CHAR_INT | CHAR_FLOAT | CHAR_INDEX # 2
CHAR_TABLE[51] = CHAR_INT | CHAR_FLOAT | CHAR_INDEX # 3
CHAR_TABLE[52] = CHAR_INT | CHAR_FLOAT | CHAR_INDEX # 4
CHAR_TABLE[53] = CHAR_INT | CHAR_FLOAT | CHAR_INDEX # 5
CHAR_TABLE[54] = CHAR_INT | CHAR_FLOAT | CHAR_INDEX # 6
CHAR_TABLE[55] = CHAR_INT | CHAR_FLOAT | CHAR_INDEX # 7
CHAR_TABLE[56] = CHAR_INT | CHAR_FLOAT | CHAR_INDEX # 8
CHAR_TABLE[57] = CHAR_INT | CHAR_FLOAT | CHAR_INDEX # 9
CHAR_TABLE[69] = CHAR_FLOAT # E
CHAR_TABLE[101] = CHAR_FLOAT # e

VERTEX_STRIDE = 3
TEXTURE_STRIDE = 2
NORMAL_STRIDE = 3

createContext = () ->
  return {
    vertex: new Array(512 * VERTEX_STRIDE)
    vertexLen: 0
    texture: new Array(512 * TEXTURE_STRIDE)
    textureLen: 0
    normal: new Array(512 * NORMAL_STRIDE)
    normalLen: 0

    initFlag: false
    vertexStride: 0
    textureStride: 0
    normalStride: 0
    totalStride: 0

    vtxBuf: null
    vtxBufLen: 0
    idxBuf: null
    idxBufLen: 0
    idxMap: Object.create(null)
  }

ignoreSpace = (text, ptr) ->
  if ' ' != text[ptr] and '\t' != text[ptr]
    throw new Error()
  ptr = ptr + 1
  while ' ' == text[ptr] or '\t' == text[ptr]
    ptr = ptr + 1
  return ptr

ignoreLine = (text, ptr) ->
  while undefined != text[ptr]
    if '\r' == text[ptr]
      if '\r' != text[ptr + 1]
        ptr = ptr + 1
      else
        ptr = ptr + 2
      break
    if '\n' == text[ptr]
      if '\r' != text[ptr + 1]
        ptr = ptr + 1
      else
        ptr = ptr + 2
      break
    ptr = ptr + 1
  return ptr

parseIntEx = do ->
  result =
    ptr: 0
    num: 0
  return (text, ptr) ->
    start = ptr
    charCode = text.charCodeAt(ptr)
    if (charCode >= CHAR_SIZE) or (0 == (CHAR_INT & CHAR_TABLE[charCode]))
      throw new Error()
    ptr = ptr + 1
    while true
      charCode = text.charCodeAt(ptr)
      if (charCode >= CHAR_SIZE) or (0 == (CHAR_INT & CHAR_TABLE[charCode]))
        break
      ptr = ptr + 1
    result.ptr = ptr
    result.num = parseInt(text[start...ptr])
    return result

parseFloatEx = do ->
  result =
    ptr: 0
    num: 0
  return (text, ptr) ->
    start = ptr
    charCode = text.charCodeAt(ptr)
    if (charCode >= CHAR_SIZE) or (0 == (CHAR_FLOAT & CHAR_TABLE[charCode]))
      throw new Error()
    ptr = ptr + 1
    while true
      charCode = text.charCodeAt(ptr)
      if (charCode >= CHAR_SIZE) or (0 == (CHAR_FLOAT & CHAR_TABLE[charCode]))
        break
      ptr = ptr + 1
    result.ptr = ptr
    result.num = parseFloat(text[start...ptr])
    return result

parseVertex = do ->
  result =
    ptr: 0
    vx: 0, vy: 0, vz: 0
  (text, ptr) ->
    ptr = ignoreSpace(text, ptr)
    {num: result.vx, ptr} = parseFloatEx(text, ptr)
    ptr = ignoreSpace(text, ptr)
    {num: result.vy, ptr} = parseFloatEx(text, ptr)
    ptr = ignoreSpace(text, ptr)
    {num: result.vz, ptr} = parseFloatEx(text, ptr)
    result.ptr = ignoreLine(text, ptr)
    return result

parseTexture = do ->
  result =
    ptr: 0
    tx: 0, ty: 0
  (text, ptr) ->
    ptr = ignoreSpace(text, ptr)
    {num: result.tx, ptr} = parseFloatEx(text, ptr)
    ptr = ignoreSpace(text, ptr)
    {num: result.ty, ptr} = parseFloatEx(text, ptr)
    result.ptr = ignoreLine(text, ptr)
    return result

parseNormal = do ->
  result =
    ptr: 0
    nx: 0, ny: 0, nz: 0
  (text, ptr) ->
    ptr = ignoreSpace(text, ptr)
    {num: result.nx, ptr} = parseFloatEx(text, ptr)
    ptr = ignoreSpace(text, ptr)
    {num: result.ny, ptr} = parseFloatEx(text, ptr)
    ptr = ignoreSpace(text, ptr)
    {num: result.nz, ptr} = parseFloatEx(text, ptr)
    result.ptr = ignoreLine(text, ptr)
    return result

parseThird = do ->
  result =
    ptr: 0
    idxText: ""
  (text, ptr) ->
    start = ptr
    while true
      charCode = text.charCodeAt(ptr)
      if 0 == (CHAR_INDEX & CHAR_TABLE[charCode])
        break
      ptr = ptr + 1
    result.ptr = ptr
    result.idxText = text[start...ptr]
    if '' == result.idxText
      throw new Error()
    return result

writeIndex = (ctx, idxText) ->
  numArray = idxText.split('/')
  # init once
  if not ctx.initFlag
    ctx.initFlag = true
    ctx.totalStride = 0
    if '' != numArray[0]
      ctx.vertexStride = VERTEX_STRIDE
      ctx.totalStride = ctx.totalStride + VERTEX_STRIDE
    if '' != numArray[1]
      ctx.textureStride = TEXTURE_STRIDE
      ctx.totalStride = ctx.totalStride + TEXTURE_STRIDE
    if '' != numArray[2]
      ctx.normalStride = NORMAL_STRIDE
      ctx.totalStride = ctx.totalStride + NORMAL_STRIDE
    ctx.vtxBuf = new Array(ctx.totalStride * 512)
    ctx.idxBuf = new Array(4 * 512)
  # 重复的idx不再写入
  idx = ctx.idxMap[idxText]
  if 'number' == typeof(idx)
    ctx.idxBuf[ctx.idxBufLen++] = idx
    return
  # 解析新的idx
  ptr = 0
  offset = 0
  # 填充vertex
  if ctx.vertexStride
    {ptr: ptr, num: vi} = parseIntEx(idxText, ptr)
    vi = vi - 1
    if vi > ctx.vertexLen
      throw new Error()
    ctx.vtxBuf[ctx.totalStride * ctx.vtxBufLen + offset++] = ctx.vertex[VERTEX_STRIDE * vi + 0]
    ctx.vtxBuf[ctx.totalStride * ctx.vtxBufLen + offset++] = ctx.vertex[VERTEX_STRIDE * vi + 1]
    ctx.vtxBuf[ctx.totalStride * ctx.vtxBufLen + offset++] = ctx.vertex[VERTEX_STRIDE * vi + 2]
  # 填充texture
  if ctx.textureStride
    if '/' != idxText[ptr]
      throw new Error()
    ptr = ptr + 1
    {ptr: ptr, num: ti} = parseIntEx(idxText, ptr)
    ti = ti - 1
    if ti > ctx.textureLen
      throw new Error()
    ctx.vtxBuf[ctx.totalStride * ctx.vtxBufLen + offset++] = ctx.texture[TEXTURE_STRIDE * ti + 0]
    ctx.vtxBuf[ctx.totalStride * ctx.vtxBufLen + offset++] = ctx.texture[TEXTURE_STRIDE * ti + 1]
  # 填充normal
  if ctx.normalStride
    if '/' != idxText[ptr]
      throw new Error()
    ptr = ptr + 1
    if '/' == idxText[ptr]
      ptr = ptr + 1
    {ptr: ptr, num: ni} = parseIntEx(idxText, ptr)
    ni = ni - 1
    if ni > ctx.normalLen
      throw new Error()
    ctx.vtxBuf[ctx.totalStride * ctx.vtxBufLen + offset++] = ctx.vertex[NORMAL_STRIDE * ni + 0]
    ctx.vtxBuf[ctx.totalStride * ctx.vtxBufLen + offset++] = ctx.vertex[NORMAL_STRIDE * ni + 1]
    ctx.vtxBuf[ctx.totalStride * ctx.vtxBufLen + offset++] = ctx.vertex[NORMAL_STRIDE * ni + 2]
  # 填充index
  if ptr != idxText.length
    throw new Error()
  ctx.idxBuf[ctx.idxBufLen++] = ctx.vtxBufLen
  ctx.idxMap[idxText] = ctx.vtxBufLen
  ctx.vtxBufLen = ctx.vtxBufLen + 1
  return

parseObj = (text) ->
  ctx = createContext()
  ptr = 0
  textLen = text.length
  while ptr < textLen
    switch text[ptr]
      when 'v'
        ptr = ptr + 1
        if 't' == text[ptr]
          ptr = ptr + 1
          {ptr, tx, ty} = parseTexture(text, ptr)
          ctx.texture[TEXTURE_STRIDE * ctx.textureLen + 0] = tx
          ctx.texture[TEXTURE_STRIDE * ctx.textureLen + 1] = ty
          ctx.textureLen = ctx.textureLen + 1
        else if 'n' == text[ptr]
          ptr = ptr + 1
          {ptr, nx, ny, nz} = parseNormal(text, ptr)
          ctx.normal[NORMAL_STRIDE * ctx.normalLen + 0] = nx
          ctx.normal[NORMAL_STRIDE * ctx.normalLen + 1] = ny
          ctx.normal[NORMAL_STRIDE * ctx.normalLen + 2] = nz
          ctx.normalLen = ctx.normalLen + 1
        else
          {ptr, vx, vy, vz} = parseVertex(text, ptr)
          ctx.vertex[VERTEX_STRIDE * ctx.vertexLen + 0] = vx
          ctx.vertex[VERTEX_STRIDE * ctx.vertexLen + 1] = vy
          ctx.vertex[VERTEX_STRIDE * ctx.vertexLen + 2] = vz
          ctx.vertexLen = ctx.vertexLen + 1
      when 'f'
        ptr = ptr + 1
        ptr = ignoreSpace(text, ptr)
        {ptr, idxText} = parseThird(text, ptr)
        writeIndex(ctx, idxText)
        ptr = ignoreSpace(text, ptr)
        {ptr, idxText} = parseThird(text, ptr)
        writeIndex(ctx, idxText)
        ptr = ignoreSpace(text, ptr)
        {ptr, idxText} = parseThird(text, ptr)
        writeIndex(ctx, idxText)
        ptr = ignoreLine(text, ptr)
      when '#'
        ptr = ignoreLine(text, ptr)
      when 'o'
        ptr = ptr + 1
        ptr = ignoreSpace(text, ptr)
        ptr = ignoreLine(text, ptr)
      when 's'
        ptr = ptr + 1
        ptr = ignoreSpace(text, ptr)
        ptr = ignoreLine(text, ptr)
      when 'm'
        if 'mtllib' != text[ptr...(ptr+6)]
          throw new Error()
        ptr = ptr + 6
        ptr = ignoreSpace(text, ptr)
        ptr = ignoreLine(text, ptr)
      when 'u'
        if 'usemtl' != text[ptr...(ptr+6)]
          throw new Error()
        ptr = ptr + 6
        ptr = ignoreSpace(text, ptr)
        ptr = ignoreLine(text, ptr)
      when '\r', '\n'
        ptr = ignoreLine(text, ptr)
      when ' ', '\t'
        ptr = ignoreSpace(text, ptr)
        ptr = ignoreLine(text, ptr)
      else
        throw new Error()
  ctx.vtxBuf.length = ctx.vtxBufLen * ctx.totalStride
  ctx.idxBuf.length = ctx.idxBufLen
  return {
    vtxBuf: new Float32Array(ctx.vtxBuf)
    idxBuf: new Uint32Array(ctx.idxBuf)
    vertexStride: ctx.vertexStride
    textureStride: ctx.textureStride
    normalStride: ctx.normalStride
  }

objFile = """
# ......

v  -0.5000 0.0000 0.5000
v  -0.5000 0.0000 0.3750
v  -0.3750 0.0000 0.3750
v  -0.3750 0.0000 0.5000

vn 0.0000 -1.0000 -0.0000
vn 0.0000 -1.0000 -0.0000
vn 0.0000 -1.0000 -0.0000
vn 0.0000 -1.0000 -0.0000

vt 1.0000 0.0000 0.0000
vt 1.0000 0.1250 0.0000
vt 0.8750 0.1250 0.0000
vt 0.8750 0.0000 0.0000

f 1/1/1 2/2/1 3/3/1
f 3/3/1 4/4/1 1/1/1
"""

debugger
res = parseObj(objFile)
console.log(res)
