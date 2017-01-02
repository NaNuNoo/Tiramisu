# # # # # # # # # # # # # # # # # # # #
# texture_2d
# # # # # # # # # # # # # # # # # # # #

imagePromise = (url) ->
  return new Promise (resolve, reject) ->
    image = new Image()
    image.onload = () -> resolve(image)
    image.onerror = () -> reject(new Error("Load Image ERR."))
    image.src = url


Texture2D = () ->
  @_hTexture = null
  @_width = 0
  @_height = 0
  @_format = null
  @_wrapS = null
  @_wrapT = null
  @_magFilter = null
  @_minFilter = null
  @_mipMap = false
  return

createTexture2DHelper = (isImageObj) ->
  if isImageObj
    image = arguments[1]
    param = arguments[2] or {}
  else
    width = arguments[1]
    height = arguments[2]
    param = arguments[3] or {}
  texture2D = new Texture2D()
  texture2D._format = param.format ? TextureFormat.R8G8B8A8
  texture2D._wrapS = param.wrapS ? TextureWrap.EDGE
  texture2D._wrapT = param.wrapT ? TextureWrap.EDGE
  texture2D._magFilter = param.magFilter ? TextureFilter.LINEAR
  texture2D._minFilter = param.minFilter ? TextureFilter.LINEAR
  texture2D._hTexture = webGL.createTexture()
  if not texture._hTexture
      return null
  webGL.bindTexture(webGL.TEXTURE_2D, texture2D._hTexture)
  {glMemory, glFormat} = texture2D._format
  if isImageObj
    webGL.texImage2D(webGL.TEXTURE_2D, 0, glFormat, glFormat, glMemory, image)
  else
    webGL.texImage2D(webGL.TEXTURE_2D, 0, width, height, 0, glFormat, glFormat, glMemory, null)
  webGL.texParameteri(webGL.TEXTURE_2D, webGL.TEXTURE_WRAP_S, texture2D._wrapS.glCode)
  webGL.texParameteri(webGL.TEXTURE_2D, webGL.TEXTURE_WRAP_T, texture2D._wrapT.glCode)
  webGL.texParameteri(webGL.TEXTURE_2D, webGL.TEXTURE_MAG_FILTER, texture2D._magFilter.glCode)
  webGL.texParameteri(webGL.TEXTURE_2D, webGL.TEXTURE_MIN_FILTER, texture2D._minFilter.glCode)
  webGL.bindTexture(webGL.TEXTURE_2D, null)
  return texture2D

createTexture2D_Image = (url, param) ->
  return imagePromise(url)
  .then (image) ->
    return new Promise (resolve, reject) ->
      param = param or {}
      texture2D = createTexture2DHelper(true, image, param)
      if not texture2D
        return reject(new Error("Create Texture2D ERR."))
      return resolve(texture2D)

createTexture2D_Data = (data, param) ->
  texture2D = createTexture2DHelper(true, data, param)
  if not texture2D
    throw new Error("Create Texture2D ERR.")
  return texture2D

createTexture2D_Size = (width, height, param) ->
  texture2D = createTexture2DHelper(false, width, height, param)
  if not texture2D
    throw new Error("Create Texture2D ERR.")
  return texture2D

destoryTexture2D = (texture2D) ->
  if texture2D._hTexture
    webGL.deleteTexture(texture2D._hTexture)
  texture2D._hTexture = null
  texture2D._width = 0
  texture2D._height = 0
  texture2D._format = null
  texture2D._wrapS = null
  texture2D._wrapT = null
  texture2D._magFilter = null
  texture2D._minFilter = null
  texture2D._mipMap = false
  return


TextureCube = () ->
  @_hTexture = null
  @_width = 0
  @_height = 0
  @_format = null
  @_wrapS = null
  @_wrapT = null
  @_magFilter = null
  @_minFilter = null
  @_mipMap = false
  return

createTextureCubeHelper = (isImageObj) ->
  if isImageObj
    imageArray = arguments[1]
    param = arguments[2] or {}
  else
    width = arguments[1]
    height = arguments[2]
    param = arguments[3] or {}
  textureCube = new TextureCube()
  textureCube._format = param.format ? TextureFormat.R8G8B8
  textureCube._wrapS = param.wrapS ? TextureWrap.EDGE
  textureCube._wrapT = param.wrapT ? TextureWrap.EDGE
  textureCube._magFilter = param.magFilter ? TextureFilter.LINEAR
  textureCube._minFilter = param.minFilter ? TextureFilter.LINEAR
  textureCube._hTexture = webGL.createTexture()
  if not textureCube._hTexture
      return reject(new Error("Create textureCube ERR."))
  webGL.bindTexture(webGL.TEXTURE_CUBE_MAP, textureCube._hTexture)
  {glMemory, glFormat} = textureCube._format
  if isImageObj
    webGL.texImage2D(webGL.TEXTURE_CUBE_MAP_POSITIVE_X, 0, glFormat, glFormat, glMemory, imageArray[0])
    webGL.texImage2D(webGL.TEXTURE_CUBE_MAP_NEGATIVE_X, 0, glFormat, glFormat, glMemory, imageArray[1])
    webGL.texImage2D(webGL.TEXTURE_CUBE_MAP_POSITIVE_Y, 0, glFormat, glFormat, glMemory, imageArray[2])
    webGL.texImage2D(webGL.TEXTURE_CUBE_MAP_NEGATIVE_Y, 0, glFormat, glFormat, glMemory, imageArray[3])
    webGL.texImage2D(webGL.TEXTURE_CUBE_MAP_POSITIVE_Z, 0, glFormat, glFormat, glMemory, imageArray[4])
    webGL.texImage2D(webGL.TEXTURE_CUBE_MAP_NEGATIVE_Z, 0, glFormat, glFormat, glMemory, imageArray[5])
  else
    webGL.texImage2D(webGL.TEXTURE_CUBE_MAP_POSITIVE_X, 0, width, height, 0, glFormat, glFormat, glMemory, null)
    webGL.texImage2D(webGL.TEXTURE_CUBE_MAP_NEGATIVE_X, 0, width, height, 0, glFormat, glFormat, glMemory, null)
    webGL.texImage2D(webGL.TEXTURE_CUBE_MAP_POSITIVE_Y, 0, width, height, 0, glFormat, glFormat, glMemory, null)
    webGL.texImage2D(webGL.TEXTURE_CUBE_MAP_NEGATIVE_Y, 0, width, height, 0, glFormat, glFormat, glMemory, null)
    webGL.texImage2D(webGL.TEXTURE_CUBE_MAP_POSITIVE_Z, 0, width, height, 0, glFormat, glFormat, glMemory, null)
    webGL.texImage2D(webGL.TEXTURE_CUBE_MAP_NEGATIVE_Z, 0, width, height, 0, glFormat, glFormat, glMemory, null)
  webGL.texParameteri(webGL.TEXTURE_CUBE_MAP, webGL.TEXTURE_WRAP_S, textureCube._wrapS.glCode)
  webGL.texParameteri(webGL.TEXTURE_CUBE_MAP, webGL.TEXTURE_WRAP_T, textureCube._wrapT.glCode)
  webGL.texParameteri(webGL.TEXTURE_CUBE_MAP, webGL.TEXTURE_MAG_FILTER, textureCube._magFilter.glCode)
  webGL.texParameteri(webGL.TEXTURE_CUBE_MAP, webGL.TEXTURE_MIN_FILTER, textureCube._minFilter.glCode)
  webGL.bindTexture(webGL.TEXTURE_CUBE_MAP, null)
  return textureCube

createTextureCube_Image = (urlsArray, param) ->
  return Promise.all([
    imagePromise(urlsArray[0])
    imagePromise(urlsArray[1])
    imagePromise(urlsArray[2])
    imagePromise(urlsArray[3])
    imagePromise(urlsArray[4])
    imagePromise(urlsArray[5])
  ]).then (imageArray) ->
    return new Promise (resolve, reject) ->
      param = param or {}
      texture2D = createTextureCubeHelper(true, imageArray, param)
      if not texture2D
        return reject(new Error("Create Texture2D ERR."))
      return resolve(texture2D)

createTextureCube_Data = (dataArray, param) ->
  textureCube = createTextureCubeHelper(true, dataArray, param)
  if not textureCube
    throw new Error("Create Texture2D ERR.")
  return textureCube

createTextureCube_Size = (width, height, param) ->
  textureCube = createTextureCubeHelper(false, width, height, param)
  if not textureCube
    throw new Error("Create Texture2D ERR.")
  return textureCube

destoryTextureCube = () ->
  if textureCube._hTexture
    webGL.deleteTexture(textureCube._hTexture)
  textureCube._hTexture = null
  textureCube._width = 0
  textureCube._height = 0
  textureCube._format = null
  textureCube._wrapS = null
  textureCube._wrapT = null
  textureCube._magFilter = null
  textureCube._minFilter = null
  textureCube._mipMap = false
  return
