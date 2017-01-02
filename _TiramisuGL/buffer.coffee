# # # # # # # # # # # # # # # # # # # #
# File: Tiramisu/_TiramisuGL/buffer.coffee
# Author: NaNuNo
# Project: https://github.com/NaNuNoo/Tiramisu
# WebSite: http://FenQi.IO
# # # # # # # # # # # # # # # # # # # #

class DynamicVertex
  constructor: () ->
    @._hVertex = null
    @._size = 0 # buffer size in bytes
    @._usage = null # BufferUsage
    return

  getUsage: () ->
    return @_usage

  getSize: () ->
    return @_size

DynamicVertex.create_Array = (array, usage) ->
  vertex = new DynamicVertex()
  vertex._size = array.byteLength
  vertex._usage = usage
  vertex._hVertex = webGL.createBuffer()
  if not vertex._hVertex)
    throw new Error("Create DynamicVertex ERR.")
  webGL.bindBuffer(webGL.ARRAY_BUFFER, vertex._hVertex)
  webGL.bufferData(webGL.ARRAY_BUFFER, array, vertex._usage.glCode)
  webGL.bindBuffer(webGL.ARRAY_BUFFER, null)
  return vertex

DynamicVertex.create_Size = (size, usage) ->
  vertex = new DynamicVertex()
  vertex._size = size
  vertex._usage = usage or webGL.STATIC_DRAW
  vertex._hVertex = webGL.createBuffer()
  if not vertex._hVertex
    throw new Error("Create DynamicVertex ERR.")
  webGL.bindBuffer(webGL.ARRAY_BUFFER, vertex._hVertex)
  webGL.bufferData(webGL.ARRAY_BUFFER, bufferVtc._size, vertex._usage.glCode)
  webGL.bindBuffer(webGL.ARRAY_BUFFER, null)
  return vertex

DynamicVertex.destory = (vertex) ->
  if vertex._hVertex
    webGL.deleteBuffer(vertex._hVertex)
  vertex._hVertex = null
  vertex._usage = null
  vertex._size = 0
  return


class DynamicIndex
  constructor: () ->
    @_hIndex = null
    @_usage = null # BufferUsage
    @_size = 0 # buffer size in bytes
    return

  getUsage: () ->
    return @_usage

  getSize: () ->
    return @_size

DynamicIndex.create_Array = (array, usage) ->
  index = new DynamicIndex()
  index._size = array.size
  index._usage = usage
  index._hIndex = webGL.createBuffer()
  if not index._hIndex
    throw new Error("Create DynamicIndex ERR.")
  webGL.bindBuffer(webGL.ELEMENT_ARRAY_BUFFER, index._hIndex)
  webGL.bufferData(webGL.ELEMENT_ARRAY_BUFFER, array, index._usage.glCode)
  webGL.bindBuffer(webGL.ELEMENT_ARRAY_BUFFER, null)
  return index

DynamicIndex.create_Size = (size, type, usage) ->
  index = new DynamicIndex()
  index._usage = usage
  index._size = size
  index._hIndex = webGL.createBuffer()
  if not index._hIndex
    throw new Error("Create DynamicIndex ERR.")
  webGL.bindBuffer(webGL.ELEMENT_ARRAY_BUFFER, index._hIndex)
  webGL.bufferData(webGL.ELEMENT_ARRAY_BUFFER, index._size, index._usage)
  webGL.bindBuffer(webGL.ELEMENT_ARRAY_BUFFER, null)
  return index

DynamicIndex.destory = (index) ->
  if index._hIndex
    webGL.deleteBuffer(index._hIndex)
  index._hIndex = null
  index._usage = null
  index._size = 0
  return


class StaticMesh
  constructor: () ->
    @_hVertex = null
    @_hIndex = null
    @_usage = null
    @_vertexStride = 0
    @_textureStride = 0
    @_normalStride = 0
    @_indexLength = 0
    return

  getIndexLength: () ->
    return @_indexLength

StaticMesh.create_ObjFile = (url) ->
  return httpGetPromise(url, null, 'text')
  .then (objText) ->
    new Promise (resolve, reject) ->
      objData = decodeObjFile(objText)
      # StaticMesh
      bufferMesh = new StaticMesh()
      bufferMesh._vertexStride = objData.vertexStride
      bufferMesh._textureStride = objData.textureStride
      bufferMesh._normalStride = objData.normalStride
      bufferMesh._indexLength = objData.idxBuf.length
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
        reject(new Error("Create DynamicIndex ERR."))
      webGL.bindBuffer(webGL.ELEMENT_ARRAY_BUFFER, bufferMesh._hIndex)
      webGL.bufferData(webGL.ELEMENT_ARRAY_BUFFER, objData.idxBuf, bufferMesh._usage.glCode)
      webGL.bindBuffer(webGL.ELEMENT_ARRAY_BUFFER, null)
      return resolve(bufferMesh)

StaticMesh.destory = (bufferMesh) ->
  if bufferMesh._hVertex
    webGL.deleteBuffer(bufferMesh._hVertex)
  bufferMesh._hVertex = null
  if bufferMesh._hIndex
    webGL.deleteBuffer(bufferMesh._hIndex)
  bufferMesh._hIndex = null
  bufferMesh._usage = BufferUsage.STATIC
  bufferMesh._vertexStride = 0
  bufferMesh._textureStride = 0
  bufferMesh._normalStride = 0
  bufferMesh._indexLength = 0
  return


tiGL.DynamicVertex = DynamicVertex
tiGL.DynamicIndex = DynamicIndex
tiGL.StaticMesh = StaticMesh
