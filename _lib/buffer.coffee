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


BufferMesh = () ->
  @_hVertex = null
  @_hIndex = null
  @_usage = BufferUsage.STATIC
  @_vertexStride = 0
  @_textureStride = 0
  @_normalStride = 0
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
      objData = objFile(objText)
      # BufferMesh
      bufferMesh = new BufferMesh()
      bufferMesh._vertexStride = objData.vertexStride
      bufferMesh._textureStride = objData.textureStride
      bufferMesh._normalStride = objData.normalStride
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
  bufferMesh._vertexStride = false
  bufferMesh._textureStride = false
  bufferMesh._normalStride = false
