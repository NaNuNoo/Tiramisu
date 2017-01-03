# # # # # # # # # # # # # # # # # # # #
# File: Tiramisu/_Tiramisu/state.coffee
# Author: NaNuNo
# Project: https://github.com/NaNuNoo/Tiramisu
# WebSite: http://FenQi.IO
# # # # # # # # # # # # # # # # # # # #

glState = {
  clearColorRed: undefined # float
  clearColorGreen: undefined # float
  clearColorBlue: undefined # float
  clearColorAlpha: undefined # float
  clearDepth: undefined # float
  clearStencil: undefined # int

  viewPortOx: undefined # float
  viewPortOy: undefined # float
  viewPortWidth: undefined # float
  viewPortHeight: undefined # float
  viewPortNear: undefined # float
  viewPortFar: undefined # float

  lineWidth: undefined # float

  cullEnable: undefined # bool
  cullFront: undefined # enum
  cullFace: undefined # enum

  polygonOffsetEnable: undefined # bool
  polygonOffsetSlope: undefined # float
  polygonOffsetUnit: undefined # float

  scissorEnable: undefined # bool
  scissorOx: undefined # float
  scissorOy: undefined # float
  scissorWidth: undefined # float
  scissorHeight: undefined # float

  stencilEnable: undefined # bool
  stencilFrontWriteMask: undefined # int
  stencilFrontReadMask: undefined # int
  stencilFrontRefValue: undefined # int
  stencilFrontFunc: undefined # enum
  stencilFrontOptFail: undefined # enum
  stencilFrontOptZFail: undefined # enum
  stencilFrontOptPass: undefined # enum
  stencilBackWriteMask: undefined # int
  stencilBackReadMask: undefined # int
  stencilBackRefValue: undefined # int
  stencilBackFunc: undefined # enum
  stencilBackOptFail: undefined # enum
  stencilBackOptZFail: undefined # enum
  stencilBackOptPass: undefined # enum

  depthEnable: undefined # bool
  depthMask: undefined # bool
  depthFunc: undefined # enum

  blendEnable: undefined # bool
  blendRefRed: undefined # float
  blendRefGreen: undefined # float
  blendRefBlue: undefined # float
  blendRefAlpha: undefined # float
  blendSrcRGBFunc: undefined # enum
  blendSrcAlphaFunc: undefined # enum
  blendDstRGBFunc: undefined # enum
  blendDstAlphaFunc: undefined # enum
  blendRGBOpt: undefined # enum
  blendAlphaOpt: undefined # enum

  colorMaskRed: undefined # bool
  colorMaskGreen: undefined # bool
  colorMaskBlue: undefined # bool
  colorMaskAlpha: undefined # bool

  ditherEnable: undefined # bool

  nowFrame: null
  nowShader: null
  nowTexture: 0
}

ti.clearFrame = (param) ->
  clearColorRed = param.clearColorRed ? 0
  clearColorGreen = param.clearColorGreen ? 0
  clearColorBlue = param.clearColorBlue ? 0
  clearColorAlpha = param.clearColorAlpha ? 0
  updateFlag =
    glState.clearColorRed != param.clearColorRed or
    glState.clearColorGreen != param.clearColorGreen or
    glState.clearColorBlue != param.clearColorBlue or
    glState.clearColorAlpha != param.clearColorAlpha
  if updateFlag
    glState.clearColorRed = param.clearColorRed
    glState.clearColorGreen = param.clearColorGreen
    glState.clearColorBlue = param.clearColorBlue
    glState.clearColorAlpha = param.clearColorAlpha
    webGL.clearColor(glState.clearColorRed, glState.clearColorGreen, glState.clearColorBlue, glState.clearColorAlpha)

  clearDepth = param.clearDepth ? 1.0
  if glState.clearDepth != clearDepth
    glState.clearDepth = clearDepth
    webGL.clearDepth(clearDepth)

  clearStencil = param.clearStencil ? 0x00000000
  if glState.clearStencil != clearStencil
    glState.clearStencil = clearStencil
    webGL.clearStencil(clearStencil)

  clearFlag = 0
  updateFlag =
    "number" == typeof(param.clearColorRed) or
    "number" == typeof(param.clearColorGreen) or
    "number" == typeof(param.clearColorBlue) or
    "number" == typeof(param.clearColorAlpha)
  if updateFlag
    clearFlag |= webGL.COLOR_BUFFER_BIT
  if "number" == typeof(param.clearDepth)
    clearFlag |= webGL.DEPTH_BUFFER_BIT
  if "number" == typeof(param.clearStencil)
    clearFlag |= webGL.STENCIL_BUFFER_BIT

  webGL.clear(clearFlag)
  return

bindAttributeBuffer = (name, size, stride, offset, data) ->
  # size - type包含的unit个数 针对传入的Buffer
  # stride - 以byte数为单位的数据块
  # offset - 以byte数为单位的数据偏移
  varInfo = glState.nowShader._attributeMap[name]
  if not varInfo
    console.error("Attribute not found <#{name}>.")
    return
  webGL.enableVertexAttribArray(varInfo.location)
  webGL.bindBuffer(webGL.ARRAY_BUFFER, data._hVertex)
  webGL.vertexAttribPointer(
    varInfo.location,
    size,
    varInfo.typeInfo.typeCode,
    false,
    stride * varInfo.typeInfo.unitBytes,
    offset * varInfo.typeInfo.unitBytes
  )
  webGL.bindBuffer(webGL.ARRAY_BUFFER, null)
  return

bindAttributeConst = (name, data) ->
  varInfo = glState.nowShader._attributeMap[name]
  if not varInfo
    console.error("Attribute not found <#{name}>.")
    return
  webGL.enableVertexAttribArray(varInfo.location)
  webGL.disableVertexAttribArray(pos)
  switch varInfo.typeInfo.typeIndex
    when 8 # float
      webGL.vertexAttrib1f(data)
    when 9 # vec2
      webGL.vertexAttrib2fv(data)
    when 10 # vec3
      webGL.vertexAttrib3fv(data)
    when 11 # vec4
      webGL.vertexAttrib4fv(data)
    else
      console.error("Unknow attribute type.")
  webGL.bindBuffer(webGL.ARRAY_BUFFER, null)
  return

bindUniform = (name, data) ->
  varInfo = glState.nowShader._uniformMap[name]
  if not varInfo
    console.error("Uniform not found <#{name}>.")
    return
  switch varInfo.typeInfo.typeIndex
    when 0 # bool
      if 1 == varInfo.arraySize
        webGL.uniform1i(varInfo.location, data)
      else
        webGL.uniform1iv(varInfo.location, data)
    when 1 # bvec2
      webGL.uniform2iv(varInfo.location, data)
    when 2 # bvec3
      webGL.uniform3iv(varInfo.location, data)
    when 3 # bvec4
      webGL.uniform4iv(varInfo.location, data)
    when 4 # int
      if 1 == varInfo.arraySize
        webGL.uniform1i(varInfo.location, data)
      else
        webGL.uniform1iv(varInfo.location, data)
    when 5 # ivec2
      webGL.uniform2iv(varInfo.location, data)
    when 6 # ivec3
      webGL.uniform3iv(varInfo.location, data)
    when 7 # ivec4
      webGL.uniform4iv(varInfo.location, data)
    when 8 # float
      if 1 == varInfo.arraySize
        webGL.uniform1f(varInfo.location, data)
      else
        webGL.uniform1fv(varInfo.location, data)
    when 9 # vec2
      webGL.uniform2fv(varInfo.location, data)
    when 10 # vec3
      webGL.uniform3fv(varInfo.location, data)
    when 11 # vec4
      webGL.uniform4fv(varInfo.location, data)
    when 12 # mat2
      webGL.uniformMatrix2fv(varInfo.location, false, data)
    when 13 # mat3
      webGL.uniformMatrix3fv(varInfo.location, false, data)
    when 14 # mat4
      webGL.uniformMatrix4fv(varInfo.location, false, data)
    when 15 # sampler2d
      webGL.activeTexture(webGL.TEXTURE0 + glState.nowTexture)
      webGL.bindTexture(webGL.TEXTURE_2D, data._hTexture)
      webGL.uniform1i(varInfo.location, glState.nowTexture)
      glState.nowTexture = glState.nowTexture + 1
    when 16 # samplerCube
      webGL.activeTexture(webGL.TEXTURE0 + glState.nowTexture)
      webGL.bindTexture(webGL.TEXTURE_CUBE_MAP, data._hTexture)
      webGL.uniform1i(varInfo.location, glState.nowTexture)
      glState.nowTexture = glState.nowTexture + 1
    else
      console.error("Unknow uniform type.")
  return

ti.drawCall = (param) ->
  viewPortOx = param.viewPortOx ? 0
  viewPortOy = param.viewPortOy ? 0
  viewPortWidth = param.viewPortWidth ? webGL.drawingBufferWidth
  viewPortHeight = param.viewPortHeight ? webGL.drawingBufferHeight
  updateFlag =
    glState.viewPortOx != viewPortOx or
    glState.viewPortOy != viewPortOy or
    glState.viewPortWidth != viewPortWidth or
    glState.viewPortHeight != viewPortHeight
  if updateFlag
    glState.viewPortOx = viewPortOx
    glState.viewPortOy = viewPortOy
    glState.viewPortWidth = viewPortWidth
    glState.viewPortHeight = viewPortHeight
    webGL.viewport(glState.viewPortOx, glState.viewPortOy, glState.viewPortWidth, glState.viewPortHeight)

  viewPortNear = param.viewPortNear ? -1
  viewPortFar = param.viewPortFar ? 1
  updateFlag =
    glState.viewPortNear != viewPortNear or
    glState.viewPortFar != viewPortFar
  if updateFlag
    glState.viewPortNear = viewPortNear
    glState.viewPortFar = viewPortFar
    webGL.depthRange(glState.viewPortNear, glState.viewPortFar)

  lineWidth = param.lineWidth ? 1
  if glState.lineWidth != lineWidth
    glState.lineWidth = lineWidth
    webGL.lineWidth(glState.lineWidth)

  cullEnable = param.cullEnable ? true
  if glState.cullEnable != cullEnable
    glState.cullEnable = cullEnable
    if glState.cullEnable
      webGL.enable(webGL.CULL_FACE)
    else
      webGL.disable(webGL.CULL_FACE)

  cullFront = param.cullFront ? webGL.CCW
  if glState.cullFront != cullFront
    glState.cullFront = cullFront
    webGL.frontFace(glState.cullFront)

  cullFace = param.cullFace ? webGL.BACK
  if glState.cullFace != cullFace
    glState.cullFace = cullFace
    webGL.cullFace(glState.cullFace)

  polygonOffsetEnable = glState.polygonOffsetEnable ? false
  if glState.polygonOffsetEnable != polygonOffsetEnable
    glState.polygonOffsetEnable = polygonOffsetEnable
    if glState.polygonOffsetEnable
      webGL.enable(webGL.POLYGON_OFFSET_FILL)
    else
      webGL.disable(webGL.POLYGON_OFFSET_FILL)

  polygonOffsetSlope = glState.polygonOffsetSlope ? 0
  polygonOffsetUnit = glState.polygonOffsetUnit ? 0
  updateFlag =
    glState.polygonOffsetSlope != polygonOffsetSlope or
    glState.polygonOffsetUnit != polygonOffsetUnit
  if updateFlag
    glState.polygonOffsetSlope = polygonOffsetSlope
    glState.polygonOffsetUnit = polygonOffsetUnit
    webGL.polygonOffset(glState.polygonOffsetSlope, glState.polygonOffsetUnit)

  ###
  scissorEnable = glState.scissorEnable ? false
  if glState.scissorEnable != scissorEnable
    glState.scissorEnable = scissorEnable
    if glState.scissorEnable
      webGL.enable(webGL.SCISSOR_TEST)
    else
      webGL.disable(webGL.SCISSOR_TEST)

  scissorOx = param.scissorOx ? 0
  scissorOy = param.scissorOy ? 0
  scissorWidth = param.scissorWidth ? 0
  scissorHeight = param.scissorHeight ? 0
  updateFlag =
    glState.scissorOx != scissorOx or
    glState.scissorOy != scissorOy or
    glState.scissorWidth != scissorWidth or
    glState.scissorHeight != scissorHeight
  if updateFlag
    glState.scissorOx = scissorOx
    glState.scissorOy = scissorOy
    glState.scissorWidth = scissorWidth
    glState.scissorHeight = scissorHeight
    webGL.scissor(glState.scissorOx, glState.scissorOy, glState.scissorWidth, glState.scissorHeight)
  ###

  stencilEnable = glState.stencilEnable ? false
  if glState.stencilEnable != stencilEnable
    glState.stencilEnable = stencilEnable
    if glState.stencilEnable
      webGL.enable(webGL.STENCIL_TEST)
    else
      webGL.disable(webGL.STENCIL_TEST)

  stencilFrontWriteMask = param.stencilFrontWriteMask ? 0xFFFFFFFF
  if glState.stencilMaskSeparate != stencilFrontWriteMask
    glState.stencilMaskSeparate = stencilFrontWriteMask
    webGL.stencilMaskSeparate(webGL.FRONT, glState.stencilMaskSeparate)

  stencilFrontReadMask = glState.stencilFrontReadMask ? 0xFFFFFFFF
  stencilFrontRefValue = glState.stencilFrontRefValue ? 0
  stencilFrontFunc = glState.stencilFrontFunc or webGL.EQUAL
  updateFlag =
    glState.stencilFrontReadMask != stencilFrontReadMask or
    glState.stencilFrontRefValue != stencilFrontRefValue or
    glState.stencilFrontFunc != stencilFrontFunc
  if updateFlag
    glState.stencilFrontReadMask = stencilFrontReadMask
    glState.stencilFrontRefValue = stencilFrontRefValue
    glState.stencilFrontFunc = stencilFrontFunc
    webGL.stencilFuncSeparate(webGL.FRONT, glState.stencilFrontFunc, glState.stencilFrontRefValue, glState.stencilFrontReadMask)

  stencilFrontOpFail = glState.stencilFrontOpFail ? webGL.KEEP
  stencilFrontOpZFail = glState.stencilFrontOpZFail ? webGL.KEEP
  stencilFrontOpPass = glState.stencilFrontOpPass ? webGL.KEEP
  updateFlag =
    glState.stencilFrontOpFail != stencilFrontOpFail or
    glState.stencilFrontOpZFail != stencilFrontOpZFail or
    glState.stencilFrontOpPass != stencilFrontOpPass
  if updateFlag
    glState.stencilFrontOpFail = stencilFrontOpFail
    glState.stencilFrontOpZFail = stencilFrontOpZFail
    glState.stencilFrontOpPass = stencilFrontOpPass
    webGL.stencilOpSeparate(webGL.FRONT, glState.stencilFrontOpFail, glState.stencilFrontOpZFail, glState.stencilFrontOpPass)

  stencilBackWriteMask = param.stencilBackWriteMask ? 0xFFFFFFFF
  if glState.stencilMaskSeparate != stencilBackWriteMask
    glState.stencilMaskSeparate = stencilBackWriteMask
    webGL.stencilMaskSeparate(webGL.BACK, glState.stencilMaskSeparate)

  stencilBackReadMask = glState.stencilBackReadMask ? 0xFFFFFFFF
  stencilBackRefValue = glState.stencilBackRefValue ? 0
  stencilBackFunc = glState.stencilBackFunc or webGL.EQUAL
  updateFlag =
    glState.stencilBackReadMask != stencilBackReadMask or
    glState.stencilBackRefValue != stencilBackRefValue or
    glState.stencilBackFunc != stencilBackFunc
  if updateFlag
    glState.stencilBackReadMask = stencilBackReadMask
    glState.stencilBackRefValue = stencilBackRefValue
    glState.stencilBackFunc = stencilBackFunc
    webGL.stencilFuncSeparate(webGL.BACK, glState.stencilBackFunc, glState.stencilBackRefValue, glState.stencilBackReadMask)

  stencilBackOptFail = glState.stencilBackOptFail ? webGL.KEEP
  stencilBackOptZFail = glState.stencilBackOptZFail ? webGL.KEEP
  stencilBackOptPass = glState.stencilBackOptPass ? webGL.KEEP
  updateFlag =
    glState.stencilBackOptFail != stencilBackOptFail or
    glState.stencilBackOptZFail != stencilBackOptZFail or
    glState.stencilBackOptPass != stencilBackOptPass
  if updateFlag
    glState.stencilBackOptFail = stencilBackOptFail
    glState.stencilBackOptZFail = stencilBackOptZFail
    glState.stencilBackOptPass = stencilBackOptPass
    webGL.stencilOpSeparate(webGL.BACK, glState.stencilBackOptFail, glState.stencilBackOptZFail, glState.stencilBackOptPass)

  depthEnable = glState.depthEnable ? true
  if glState.depthEnable != depthEnable
    glState.depthEnable = depthEnable
    if glState.depthEnable
      webGL.enable(webGL.DEPTH_TEST)
    else
      webGL.disable(webGL.DEPTH_TEST)

  depthMask = glState.depthMask ? true
  if glState.depthMask != depthMask
    glState.depthMask = depthMask
    webGL.depthMask(glState.depthMask)

  depthFunc = glState.depthFunc ? webGL.LESS
  if glState.depthFunc != depthFunc
    glState.depthFunc = depthFunc
    webGL.depthFunc(glState.depthFunc)
  ###
  blendEnable = glState.blendEnable ? false
  if glState.blendEnable != blendEnable
    glState.blendEnable = blendEnable
    if glState.blendEnable
      webGL.enable(webGL.BLEND)
    else
      webGL.disable(webGL.BLEND)

  blendRefRed = glState.blendRefRed ? 0
  blendRefGreen = glState.blendRefGreen ? 0
  blendRefBlue = glState.blendRefBlue ? 0
  blendRefAlpha = glState.blendRefAlpha ? 0
  updateFlag =
    glState.blendRefRed != blendRefRed or
    glState.blendRefGreen != blendRefGreen or
    glState.blendRefBlue != blendRefBlue or
    glState.blendRefAlpha != blendRefAlpha
  if updateFlag
    glState.blendRefRed = blendRefRed
    glState.blendRefGreen = blendRefGreen
    glState.blendRefBlue = blendRefBlue
    glState.blendRefAlpha = blendRefAlpha
    webGL.blendColor(glState.blendRefRed, glState.blendRefGreen, glState.blendRefBlue, glState.blendRefAlpha)

  blendSrcRGBFunc = glState.blendSrcRGBFunc ? webGL.SRC_ALPHA
  blendSrcAlphaFunc = glState.blendSrcAlphaFunc ? webGL.SRC_ALPHA
  blendDstRGBFunc = glState.blendDstRGBFunc ? webGL.ONE_MINUS_SRC_ALPHA
  blendDstAlphaFunc = glState.blendDstAlphaFunc ? webGL.ONE_MINUS_SRC_ALPHA
  updateFlag =
    glState.blendSrcRGBFunc != blendSrcRGBFunc or
    glState.blendSrcAlphaFunc != blendSrcAlphaFunc or
    glState.blendDstRGBFunc != blendDstRGBFunc or
    glState.blendDstAlphaFunc != blendDstAlphaFunc
  if updateFlag
    glState.blendSrcRGBFunc = blendSrcRGBFunc
    glState.blendSrcAlphaFunc = blendSrcAlphaFunc
    glState.blendDstRGBFunc = blendDstRGBFunc
    glState.blendDstAlphaFunc = blendDstAlphaFunc
    webGL.blendFuncSeparate(glState.blendSrcRGBFunc, glState.blendSrcAlphaFunc, glState.blendDstRGBFunc, glState.blendDstAlphaFunc)

  blendRGBOpt = glState.blendRGBOpt ? webGL.FUNC_ADD
  blendAlphaOpt = glState.blendAlphaOpt ? webGL.FUNC_ADD
  updateFlag =
    glState.blendRGBOpt != blendRGBOpt or
    glState.blendAlphaOpt != blendAlphaOpt
  if updateFlag
    glState.blendRGBOpt = blendRGBOpt
    glState.blendAlphaOpt = blendAlphaOpt
    webGL.blendEquationSeparate(glState.blendRGBOpt, glState.blendAlphaOpt)

  colorMaskRed = glState.colorMaskRed ? true
  colorMaskGreen = glState.colorMaskGreen ? true
  colorMaskBlue = glState.colorMaskBlue ? true
  colorMaskAlpha = glState.colorMaskAlpha ? true
  updateFlag =
    glState.colorMaskRed != colorMaskRed or
    glState.colorMaskGreen != colorMaskGreen or
    glState.colorMaskBlue != colorMaskBlue or
    glState.colorMaskAlpha != colorMaskAlpha
  if updateFlag
    glState.colorMaskRed = colorMaskRed
    glState.colorMaskGreen = colorMaskGreen
    glState.colorMaskBlue = colorMaskBlue
    glState.colorMaskAlpha = colorMaskAlpha
    webGL.colorMask(glState.colorMaskRed, glState.colorMaskGreen, glState.colorMaskBlue, glState.colorMaskAlpha)

  ditherEnable = glState.ditherEnable ? false
  if glState.ditherEnable != ditherEnable
    glState.ditherEnable = ditherEnable
    if glState.ditherEnable
      webGL.enable(webGL.DITHER)
    else
      webGL.disable(webGL.DITHER)
  ###

  {shader} = param
  if not shader
    throw new Error("drawCall() Need a shader.")
  webGL.useProgram(shader._hShader)
  glState.nowShader = shader

  {uniformArray} = param
  if not uniformArray
    throw new Error("drawCall() Need a uniformArray.")
  for {name, data} in uniformArray
    bindUniform(name, data)

  {attributeArray} = param
  if not attributeArray
    throw new Error("drawCall() Need a attributeArray.")
  for {name, size, stride, offset, data} in attributeArray
    bindAttributeBuffer(name, size, stride, offset, data)

  {drawIndex, drawMode} = param
  if not drawIndex
    webGL.drawArrays(drawMode.glCode, 0, param.drawCount)
  else
    webGL.bindBuffer(webGL.ELEMENT_ARRAY_BUFFER, drawIndex._hIndex)
    webGL.drawElements(drawMode.glCode, param.drawCount, webGL.UNSIGNED_SHORT, 0)
    webGL.bindBuffer(webGL.ELEMENT_ARRAY_BUFFER, null)

  for idx in [0...glState.nowTexture] by 1
    webGL.activeTexture(webGL.TEXTURE0 + idx)
    webGL.bindTexture(webGL.TEXTURE_2D, null)
    webGL.bindTexture(webGL.TEXTURE_CUBE_MAP, null)
  glState.nowTexture = 0

  webGL.useProgram(null)
  return
