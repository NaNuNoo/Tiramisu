# # # # # # # # # # # # # # # # # # # #
# buffer
# # # # # # # # # # # # # # # # # # # #

BufferVtx = () ->
  @_hVertex = null
  @_size = 0 # buffer size in bytes
  @_usage = null # BufferUsage
  return

BufferVtx::getUsage = () ->
  return @_usage

BufferVtx::getSize = () ->
  return @_size

createBufferVtx_Array = (array, usage) ->
  bufferVtx = new BufferVtx()
  bufferVtx._size = array.byteLength
  bufferVtx._usage = usage
  bufferVtx._hVertex = webGL.createBuffer()
  if not bufferVtx._hVertex
    throw new Error("Create BufferVtx ERR.")
  webGL.bindBuffer(webGL.ARRAY_BUFFER, bufferVtx._hVertex)
  webGL.bufferData(webGL.ARRAY_BUFFER, array, bufferVtx._usage.glCode)
  webGL.bindBuffer(webGL.ARRAY_BUFFER, null)
  return bufferVtx

createBufferVtx_Size = (size, usage) ->
  bufferVtx = new BufferVtx()
  bufferVtx._size = size
  bufferVtx._usage = usage or webGL.STATIC_DRAW
  bufferVtx._hVertex = webGL.createBuffer()
  if not bufferVtx._hVertex
    throw new Error("Create BufferVtx ERR.")
  webGL.bindBuffer(webGL.ARRAY_BUFFER, bufferVtx._hVertex)
  webGL.bufferData(webGL.ARRAY_BUFFER, bufferVtc._size, bufferVtx._usage.glCode)
  webGL.bindBuffer(webGL.ARRAY_BUFFER, null)
  return bufferVtx

destoryBufferVtx = (bufferVtx) ->
  if bufferVtx._hVertex
    webGL.deleteBuffer(bufferVtx._hVertex)
  bufferVtx._hVertex = null
  bufferVtx._usage = null
  bufferVtx._size = 0
  return


BufferIdx = () ->
  @_hIndex = null
  @_usage = null # BufferUsage
  @_size = 0 # buffer size in bytes
  @_type = null # IndexType
  return

BufferIdx::getUsage = () ->
  return @_usage

BufferIdx::getSize = () ->
  return @_size

BufferIdx::getType = () ->
  return @_type

createBufferIdx_Array = (array, usage) ->
  bufferIdx = new BufferIdx()
  bufferIdx._size = array.size
  bufferIdx._usage = usage
  if array.constructor == Uint8Array
    bufferIdx._type = IndexType.BYTE
  else if array.constructor == Uint16Array
    bufferIdx._type = IndexType.SHORT
  else
    throw new Error("Create BufferIdx ERR.")
  bufferIdx._hIndex = webGL.createBuffer()
  if not bufferIdx._hIndex
    throw new Error("Create BufferIdx ERR.")
  webGL.bindBuffer(webGL.ELEMENT_ARRAY_BUFFER, bufferIdx._hIndex)
  webGL.bufferData(webGL.ELEMENT_ARRAY_BUFFER, array, bufferIdx._usage.glCode)
  webGL.bindBuffer(webGL.ELEMENT_ARRAY_BUFFER, null)
  return bufferIdx

createBufferIdx_Size = (size, type, usage) ->
  bufferIdx = new BufferIdx()
  bufferIdx._usage = usage
  bufferIdx._size = size
  bufferIdx._type = type
  bufferIdx._hIndex = webGL.createBuffer()
  if not bufferIdx._hIndex
    throw new Error("Create BufferIdx ERR.")
  webGL.bindBuffer(webGL.ELEMENT_ARRAY_BUFFER, bufferIdx._hIndex)
  webGL.bufferData(webGL.ELEMENT_ARRAY_BUFFER, bufferIdx._size, bufferIdx._usage)
  webGL.bindBuffer(webGL.ELEMENT_ARRAY_BUFFER, null)
  return bufferIdx

destoryBufferIdx = (bufferIdx) ->
  if bufferIdx._hIndex
    webGL.deleteBuffer(bufferIdx._hIndex)
  bufferIdx._hIndex = null
  bufferIdx._usage = null
  bufferIdx._size = 0
  bufferIdx._type = null
  return


parseObjFile = do ->
  createContext = () ->
    return {
      vertex: new Array(512 * 3)
      vertexLen: 0
      texture: new Array(512 * 2)
      textureLen: 0
      normal: new Array(512 * 3)
      normalLen: 0

      initBufFormat: false
      vertexFlag: false
      textureFlag: false
      normalFlag: false

      vtxBuf: null
      vtxBufLen: 0
      vtxBufPtr: 0
      vtxStride: 0
      idxBuf: null
      idxBufLen: 0
      idxMap: Object.create(null)
    }

  parseVertex = (ctx, wordArray, lineNo) ->
    if 4 != wordArray.length
      throw new Error("ERR obj file line #{lineNo}")
    ctx.vertex[ctx.vertexLen * 3 + 0] = parseFloat(wordArray[1])
    ctx.vertex[ctx.vertexLen * 3 + 1] = parseFloat(wordArray[2])
    ctx.vertex[ctx.vertexLen * 3 + 2] = parseFloat(wordArray[3])
    vertexLen = vertexLen + 1
    return

  parseTexture = (ctx, wordArray, lineNo) ->
    if 3 != wordArray.length
      throw new Error("ERR obj file line #{lineNo}")
    ctx.texture[ctx.textureLen * 2 + 0] = parseFloat(wordArray[1])
    ctx.texture[ctx.textureLen * 2 + 1] = parseFloat(wordArray[2])
    textureLen = textureLen + 1
    return

  parseNormal = (ctx, wordArray, lineNo) ->
    if 4 != wordArray.length
      throw new Error("ERR obj file line #{lineNo}")
    ctx.normal[ctx.normalLen * 3 + 0] = parseFloat(wordArray[1])
    ctx.normal[ctx.normalLen * 3 + 1] = parseFloat(wordArray[2])
    ctx.normal[ctx.normalLen * 3 + 2] = parseFloat(wordArray[3])
    normalLen = normalLen + 1
    return

  initBufFormat = (ctx, numArray) ->
    if not ctx.initBufFormat
      ctx.initBufFormat = true
      # vertex
      ctx.vertexFlag = true
      ctx.vtxStride += 3
      # texture
      if numArray[1]
        ctx.textureFlag = true
        ctx.vtxStride += 2
      # normal
      if numArray[2]
        ctx.normalFlag = true
        ctx.vtxStride += 3
    ctx.vtxBuf = new Array(512 * ctx.vtxStride)
    ctx.idxBuf = new Array(1024)
    return

  copyToVtxBuf = (ctx, array, start, count) ->
    for idx in [0...count] by 1
      ctx.vtxBuf[ctx.vtxBufPtr + idx] = array[start + idx]
    ctx.vtxBufPtr = ctx.vtxBufPtr + count
    return

  parseFace = (ctx, wordArray, lineNo) ->
    if 4 != wordArray.length
      throw new Error("ERR obj file line #{lineNo}")
    for idx in [1...4] by 1
      numText = wordArray[idx]
      vtxIdx = ctx.idxMap[numText]
      if vtxIdx
        ctx.idxBuf[ctx.idxBufLen] = vtxIdx
        ctx.idxBufLen = ctx.idxBufLen + 1
      else
        numArray = numText.split('/')
        initBufFormat(ctx, numArray)
        if ctx.vertexFlag
          if not numArray[0]
            throw new Error("ERR obj file line #{lineNo}")
          index = parseInt(numArray[0]) - 1
          copyToVtxBuf(ctx, ctx.vertex, index, index * 3, 3)
        if ctx.textureFlag
          if not numArray[1]
            throw new Error("ERR obj file line #{lineNo}")
          index = parseInt(numArray[1]) - 1
          copyToVtxBuf(ctx, ctx.texture, index, index * 2, 2)
        if ctx.normalFlag
          if not numArray[2]
            throw new Error("ERR obj file line #{lineNo}")
          index = parseInt(numArray[2]) - 1
          copyToVtxBuf(ctx, ctx.normal, index, index * 3, 3)
        ctx.vtxBufLen = ctx.vtxBufLen + 1
      ctx.idxBuf[ctx.idxBufLen] = ctx.vtxBufLen - 1
      ctx.idxBufLen = ctx.idxBufLen + 1
      ctx.idxMap[numText] = ctx.vtxBufLen - 1
    return

  return (objText) ->
    lineArray = objText.split(/\r\n|\n\r|\n/)
    for line, lineNo in lineArray
      lineNo = lineNo + 1
      if 0 == line.length
        continue
      if '#' == line[0]
        continue
      if ' ' == line[0]
        continue
      wordArray = line.split(/\s+/)
      switch wordArray[0]
        when 'v' then parseVertex(ctx, wordArray, lineNo)
        when 'vn' then parseNormal(ctx, wordArray, lineNo)
        when 'vt' then parseTexture(ctx, wordArray, lineNo)
        when 'f' then parseFace(ctx, wordArray, lineNo)
        when 'g' then # ignore
        when 'o' then # ignore
        when 's' then # ignore
        when 'mtllib' then # ignore
        when 'usemtl' then # ignore
        else throw new Error("ERR obj file line #{lineNo}")
    ctx.vtxBuf.length = ctx.vtxBufLen * ctx.vtxStride
    ctx.idxBuf.length = ctx.idxBufLen
    return {
      vtxBuf: new Float32Array(ctx.vtxBuf)
      idxBuf: new Float32Array(ctx.idxBuf)
      isVertex: ctx.vertexFlag
      isTexture: ctx.textureFlag
      isNormal: ctx.normalFlag
    }

BufferMesh = () ->
  @_hVertex = null
  @_hIndex = null
  @_usage = BufferUsage.STATIC
  @_isVertex = false
  @_isTexture = false
  @_isNormal = false
  return

xhrPromise = (url) ->
  return new Promise (resolve, reject) ->
    xhr = new XMLHttpRequest()
    xhr.onload = () -> resolve(xhr.responseText)
    xhr.onerror = () -> reject(new Error("HTTP #{xhr.status}."))
    xhr.ontimeout = () -> reject(new Error("HTTP time out."))
    xhr.timeout = 5000
    xhr.open("GET", url)
    xhr.send(null)

createBufferMesh_Obj = (url) ->
  return xhrPromise(url)
  .then (objText) ->
    new Promise (resolve, reject) ->
      objData = parseObjFile(objText)
      # BufferMesh
      bufferMesh = new BufferMesh()
      bufferMesh._isVertex = objData.vertexFlag
      bufferMesh._isTexture = objData.textureFlag
      bufferMesh._isNormal = objData.normalFlag
      # vertex buffer
      bufferMesh._hVertex = webGL.createBuffer()
      if not bufferMesh._hVertex
        reject(new Error("Create BufferVtx ERR."))
      webGL.bindBuffer(webGL.ARRAY_BUFFER, bufferMesh._hVertex)
      webGL.bufferData(webGL.ARRAY_BUFFER, objData.vtxBuf, bufferMesh._usage.glCode)
      webGL.bindBuffer(webGL.ARRAY_BUFFER, null)
      # index buffer
      bufferMesh._hIndex = webGL.createBuffer()
      if not bufferMesh._hIndex
        reject(new Error("Create BufferIdx ERR."))
      webGL.bindBuffer(webGL.ELEMENT_ARRAY_BUFFER, bufferMesh._hIndex)
      webGL.bufferData(webGL.ELEMENT_ARRAY_BUFFER, objData.idxBuf, bufferMesh._usage.glCode)
      webGL.bindBuffer(webGL.ELEMENT_ARRAY_BUFFER, null)
      return resolve(bufferMesh)

destoryBufferMesh = (bufferMesh) ->
  if bufferMesh._hVertex
    webGL.deleteBuffer(bufferMesh._hVertex)
  bufferMesh._hVertex = null
  if bufferMesh._hIndex
    webGL.deleteBuffer(bufferMesh._hIndex)
  bufferMesh._hIndex = null
  bufferMesh._usage = BufferUsage.STATIC
  bufferMesh._isVertex = false
  bufferMesh._isTexture = false
  bufferMesh._isNormal = false
