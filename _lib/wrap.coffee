# # # # # # # # # # # # # # # # # # # #
# wrap
# # # # # # # # # # # # # # # # # # # #

return {
  canvas: canvas
  webGL: webGL

  TextureFormat: TextureFormat
  TextureWrap: TextureWrap
  TextureFilter: TextureFilter
  SurfaceFormat: SurfaceFormat
  BufferUsage: BufferUsage
  IndexType: IndexType
  DrawMode: DrawMode

  createShader: createShader
  destoryShader: destoryShader

  createBufferVtx_Array: createBufferVtx_Array
  createBufferVtx_Size: createBufferVtx_Size
  destoryBufferVtx: destoryBufferVtx
  createBufferIdx_Array: createBufferIdx_Array
  createBufferIdx_Size: createBufferIdx_Size
  destoryBufferIdx: destoryBufferIdx
  createBufferMesh_Obj: createBufferMesh_Obj
  destoryBufferMesh: destoryBufferMesh

  createTexture2D_Image: createTexture2D_Image
  createTexture2D_Data: createTexture2D_Data
  createTexture2D_Size: createTexture2D_Size
  destoryTexture2D: destoryTexture2D
  createTextureCube_Image: createTextureCube_Image
  createTextureCube_Size: createTextureCube_Size
  destoryTextureCube: destoryTextureCube

  clearFrame: clearFrame
  drawCall: drawCall
}
