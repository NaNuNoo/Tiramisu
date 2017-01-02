# # # # # # # # # # # # # # # # # # # #
# shader
# # # # # # # # # # # # # # # # # # # #

Shader = () ->
  @_hShader = null
  @_uniformNum = 0
  @_uniformMap = Object.create(null)
  @_attributeNum = 0
  @_attributeMap = Object.create(null)
  return

Shader::getUniformNum = () ->
  return @_uniformNum

Shader::getUniformName = (name) ->
  return @_uniformMap[name]

Shader::getAttributeNum = () ->
  return @_attributeNum

Shader::getAttributeName = (name) ->
  return @_attributeMap[name]

createShader = (vsCode, fsCode) ->
  return new Promise (resolve, reject) ->
    isOk = false
    loop # only run once
      hVertex = webGL.createShader(webGL.VERTEX_SHADER)
      if not hVertex
        console.error("Create shader ERR.")
        break
      webGL.shaderSource(hVertex, vsCode)
      webGL.compileShader(hVertex)
      if not webGL.getShaderParameter(hVertex, webGL.COMPILE_STATUS)
        infoLog = webGL.getShaderInfoLog(hVertex)
        console.error("Vertex Shader ERR." + infoLog)
        break

      hFragment = webGL.createShader(webGL.FRAGMENT_SHADER)
      if not hFragment
        console.error("Create shader ERR.")
        break
      webGL.shaderSource(hFragment, fsCode)
      webGL.compileShader(hFragment)
      if not webGL.getShaderParameter(hFragment, webGL.COMPILE_STATUS)
        infoLog = webGL.getShaderInfoLog(hFragment)
        console.error("Fragment Shader ERR." + infoLog)
        break

      hShader = webGL.createProgram()
      if not hShader
        console.error("Create Program ERR.")
        break
      webGL.attachShader(hShader, hVertex)
      webGL.attachShader(hShader, hFragment)
      webGL.linkProgram(hShader)
      if not webGL.getProgramParameter(hShader, webGL.LINK_STATUS)
        infoLog = webGL.getProgramInfoLog(hShader)
        console.error("Shader Link ERR.\n" + infoLog)
        break

      isOk = true
      break

    if hVertex
      webGL.deleteShader(hVertex)
    if hFragment
      webGL.deleteShader(hFragment)
    if not isOk
      if hShader
        webGL.deleteProgram(hShader)
      return reject(new Error("createShader() ERR."))

    shader = new Shader()
    shader._hShader = hShader

    shader._uniformNum = webGL.getProgramParameter(hShader, webGL.ACTIVE_UNIFORMS)
    for idx in [0...shader._uniformNum] by 1
      info = webGL.getActiveUniform(hShader, idx)
      location = webGL.getUniformLocation(hShader, info.name)
      shader._uniformMap[info.name] = new GLSLVar(info, location)

    shader._attributeNum = webGL.getProgramParameter(hShader, webGL.ACTIVE_ATTRIBUTES)
    for idx in [0...shader._attributeNum] by 1
      info = webGL.getActiveAttrib(hShader, idx)
      location = webGL.getAttribLocation(hShader, info.name)
      shader._attributeMap[info.name] = new GLSLVar(info, location)

    return resolve(shader)

destoryShader = (shader) ->
  if shader._hShader
    webGL.deleteProgram(shader._hShader)
  shader._hShader = null
  shader._uniformNum = 0
  shader._uniformMap = null
  shader._attributeNum = 0
  shader._attributeMap = null
  return
