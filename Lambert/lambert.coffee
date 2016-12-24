VS_CODE = '''
uniform mat4 u_worldMat;
attribute vec3 a_modelPos;
attribute vec3 a_modelNorm;
varying vec3 v_modelNorm;
void main() {
  gl_Position = u_worldMat * vec4(a_modelPos, 1.0);
  v_modelNorm = a_modelNorm;
}
'''

FS_CODE = '''
precision mediump float;
uniform vec3 u_modelDiff;
uniform vec3 u_envCol;
uniform vec3 u_paraDir;
uniform vec3 u_paraDiff;
varying vec3 v_modelNorm;
vec3 paraDiffuse() {
  float dirDotNorm = dot(-u_paraDir, v_modelNorm);
  dirDotNorm = clamp(dirDotNorm, 0.0, 1.0);
  return dirDotNorm * u_paraDiff * u_modelDiff;
}
void main(){
  vec3 diffCol = paraDiffuse();
  gl_FragColor = vec4(diffCol + u_envCol, 1.0);
}
'''

canvas = document.getElementById("gl-canvas")
glw = createWebGLWrap(canvas)

Promise.all([
  glw.createShader(VS_CODE, FS_CODE)
  glw.createBufferMesh_Obj("./special.obj")
])
.then (resArray) ->
  shader = resArray[0]
  mesh = resArray[1]
  projMat = mat4.ortho(mat4.create(), -512, 512, -288, 288, -500, 500)
  modelMat = mat4.create()
  mat4.translate(modelMat, modelMat, [0, 0, -100])
  mat4.scale(modelMat, modelMat, [100, 100, 100])
  #mat4.rotateY(modelMat, modelMat, -Math.PI/6)
  worldMat = mat4.multiply(mat4.create(), projMat, modelMat)
  objDiff = vec3.fromValues(1, 1, 1)
  envCol = vec3.fromValues(0.6, 0.6, 0.6)
  paraDir = vec3.fromValues(Math.sqrt(2)/2, -Math.sqrt(2)/2, 0)
  paraDiff = vec3.fromValues(0.4, 0.4, 0.4)

  glw.clearFrame({
    clearColorRed: 0.92
    clearColorGreen: 0.92
    clearColorBlue: 0.92
    clearColorAlpha: 1.0
    clearDepth: 1.0
  })

  glw.drawCall({
    shader: shader
    uniformArray: [
      {name: "u_worldMat", data: worldMat}
      {name: "u_modelDiff", data: objDiff}
      {name: "u_envCol", data: envCol}
      {name: "u_paraDir", data: paraDir}
      {name: "u_paraDiff", data: paraDiff}
    ]
    attributeArray: [
      {name: "a_modelPos", size: 3, stride: 6, offset: 0, data: mesh}
      {name: "a_modelNorm", size: 3, stride: 6, offset: 3, data: mesh}
    ]
    drawIndex: mesh
    drawMode: glw.DrawMode.TRIANGLES
    drawCount: mesh.getIndexLength()
  })
.catch (err) ->
  console.log(err)
