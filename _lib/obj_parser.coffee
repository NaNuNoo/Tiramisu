# # # # # # # # # # # # # # # # # # # #
# buffer
# # # # # # # # # # # # # # # # # # # #

CHAR_INT = 0x1
CHAR_FLOAT = 0x2

CHAR_SIZE = 128
CHAR_TABLE = new Uint32Array(CHAR_SIZE)
CHAR_TABLE[48] = CHAR_INT | CHAR_FLOAT # -
CHAR_TABLE[46] = CHAR_FLOAT # .
CHAR_TABLE[48] = CHAR_INT | CHAR_FLOAT # 0
CHAR_TABLE[49] = CHAR_INT | CHAR_FLOAT # 1
CHAR_TABLE[50] = CHAR_INT | CHAR_FLOAT # 2
CHAR_TABLE[51] = CHAR_INT | CHAR_FLOAT # 3
CHAR_TABLE[52] = CHAR_INT | CHAR_FLOAT # 4
CHAR_TABLE[53] = CHAR_INT | CHAR_FLOAT # 5
CHAR_TABLE[54] = CHAR_INT | CHAR_FLOAT # 6
CHAR_TABLE[55] = CHAR_INT | CHAR_FLOAT # 7
CHAR_TABLE[56] = CHAR_INT | CHAR_FLOAT # 8
CHAR_TABLE[57] = CHAR_INT | CHAR_FLOAT # 9
CHAR_TABLE[69] = CHAR_FLOAT # E
CHAR_TABLE[101] = CHAR_FLOAT # e

VERTEX_REGEXP = /^v\s+([\d\.\+-eE]+)\s+([\d\.\+-eE]+)\s+([\d\.\+-eE]+)\s+$/

ignoreSpace = (text, ptr) ->
  if ' ' != text[ptr] and '\t' != text[ptr]
    throw new Error()
  ptr = ptr + 1
  while ' ' == text[ptr] or '\t' == text[ptr]
    ptr = ptr + 1
  return ptr

ignoreLine = (text, ptr) ->
  while true
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

parseIntx = do ->
  result =
    ptr: 0
    num: 0
  return (text, ptr) ->
    start = ptr
    charCode = text.charCodeAt(ptr)
    if charCode >= CHAR_SIZE or 0 == CHAR_INT | CHAR_TABLE[charCode]
      throw new Error()
    ptr = ptr + 1
    while true
      charCode = text.charCodeAt(ptr)
      if charCode >= CHAR_SIZE or 0 == CHAR_INT | CHAR_TABLE[charCode]
        break
      ptr = ptr + 1
    result.ptr = ptr
    result.num = parseInt(text[start...ptr])
    return result

parseFloatx = do ->
  result =
    ptr: 0
    num: 0
  return (text, ptr) ->
    start = ptr
    charCode = text.charCodeAt(ptr)
    if charCode >= CHAR_SIZE or 0 == CHAR_FLOAT | CHAR_TABLE[charCode]
      throw new Error()
    ptr = ptr + 1
    while true
      charCode = text.charCodeAt(ptr)
      if charCode >= CHAR_SIZE or 0 == CHAR_FLOAT | CHAR_TABLE[charCode]
        break
      ptr = ptr + 1
    result.ptr = ptr
    result.num = parseInt(text[start...ptr])
    return result

parseVertex = do ->
  result =
    ptr: 0
    vx: 0, vy: 0, vz: 0
  (text, ptr) ->
    ptr = ignoreSpace(text, ptr)
    {num: result.vx, ptr} = parseFloatx(text, ptr)
    ptr = ignoreSpace(text, ptr)
    {num: result.vy, ptr} = parseFloatx(text, ptr)
    ptr = ignoreSpace(text, ptr)
    {num: result.vz, ptr} = parseFloatx(text, ptr)
    result.ptr = ignoreLine(text, ptr)
    return result

parseTexture = do ->
  result =
    ptr: 0
    tx: 0, ty: 0
  (text, ptr) ->
    ptr = ignoreSpace(text, ptr)
    {num: result.tx, ptr} = parseFloatx(text, ptr)
    ptr = ignoreSpace(text, ptr)
    {num: result.ty, ptr} = parseFloatx(text, ptr)
    result.ptr = ignoreLine(text, ptr)
    return result

parseVertex = do ->
  result =
    ptr: 0
    nx: 0, ny: 0, nz: 0
  (text, ptr) ->
    ptr = ignoreSpace(text, ptr)
    {num: result.nx, ptr} = parseFloatx(text, ptr)
    ptr = ignoreSpace(text, ptr)
    {num: result.ny, ptr} = parseFloatx(text, ptr)
    ptr = ignoreSpace(text, ptr)
    {num: result.nz, ptr} = parseFloatx(text, ptr)
    result.ptr = ignoreLine(text, ptr)
    return result

parseThird = do ->
  result =
    ptr: 0
    vi: 0, ti: 0, ni: 0
  return (text, ptr) ->
    result.vi = null
    result.ti = null
    result.ni = null
    # vi
    {ptr: ptr, num: result.vi} = parseIntx(text, ptr)
    # ti
    if '/' != text[ptr]
      result.ptr = ptr
      return result
    ptr = ptr + 1
    if '/' != text[ptr]
      {ptr: ptr, num: result.ti} = parseIntx(text, ptr)
    # ni
    if '/' != text[ptr]
      result.ptr = ptr
      return result
    ptr = ptr + 1
    {ptr: ptr, num: result.ni} = parseIntx(text, ptr)
    result.ptr = ptr
    return result

parseFace = do ->
  result =
    ptr: 0
    vi1: 0, ti1: 0, ni1: 0
    vi2: 0, ti2: 0, ni2: 0
    vi3: 0, ti3: 0, ni3: 0
  return (text, ptr) ->
    {ptr, vi: result.vi1, ti: result.ti1, ni: result.ni1} = parseThird(text, ptr)
    ptr = ignoreSpace(text, ptr)
    {ptr, vi: result.vi2, ti: result.ti2, ni: result.ni2} = parseThird(text, ptr)
    ptr = ignoreSpace(text, ptr)
    {ptr, vi: result.vi3, ti: result.ti3, ni: result.ni3} = parseThird(text, ptr)
    ptr = ignoreLine(text, ptr)
    result.ptr = ptr
    return result

parseObj = (text) ->
  vertex = new Array(512 * 3)
  vertexLen = 0
  texture = new Array(512 * 2)
  textureLen = 0
  normal = new Array(512 * 3)
  normalLen = 0

  initBufFormat = false
  vertexFlag = false
  textureFlag = false
  normalFlag = false

  vtxBuf = null
  vtxBufLen = 0
  vtxBufPtr = 0
  vtxStride = 0
  idxBuf = null
  idxBufLen = 0
  idxMap = Object.create(null)

  ptr = 0
  switch text[ptr]
    when 'v'
      ptr = ptr + 1
      if 't' == text[ptr]
        ptr = ptr + 1
        ptr = ignoreSpace(text, ptr)
        {ptr, tx, ty} = parseTexture(text, ptr)
        texture[textureLen++] = tx
        texture[textureLen++] = ty
      else if 'n' == text[ptr]
        ptr = ptr + 1
        ptr = ignoreSpace(text, ptr)
        {ptr, nx, ny, nz} = parseVertex(text, ptr)
        normal[normalLen++] = nx
        normal[normalLen++] = ny
        normal[normalLen++] = nz
      else
        ptr = ignoreSpace(text, ptr)
        {ptr, vx, vy, vz} = parseVertex(text, ptr)
        vertex[vertexLen++] = vx
        vertex[vertexLen++] = vy
        vertex[vertexLen++] = vz
    when 'f'
      ptr = ptr + 1
      ptr = ignoreSpace(text, ptr)
      {ptr, vi1, ti1, ni1, vi2, ti2, ni2, vi3, ti3, ni3} = parseFace(text, ptr)
      
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
