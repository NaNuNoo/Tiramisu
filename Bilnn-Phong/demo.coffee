VS_CODE = '''
uniform mat4 u_mvpMat;      // MVP矩阵（设备空间）
uniform mat4 u_mvMat;       // MV矩阵（世界空间）

attribute vec3 a_modelPos;  // 模型位置（模型空间）
attribute vec3 a_modelNorm; // 模型法线（模型空间）

varying vec3 v_modelPos;    // 模型位置（世界空间）
varying vec3 v_modelNorm;   // 模型法线（世界空间）

void main() {
  gl_Position = u_mvpMat * vec4(a_modelPos, 1.0);
  v_modelPos = (u_mvpMat * vec4(a_modelPos, 1.0)).xyz;
  v_modelNorm = a_modelNorm;
}
'''

FS_CODE = '''
precision mediump float;

uniform vec3 u_lightEnv;    // 环境光颜色

uniform vec3 u_paraDir;     // 平行光源方向
uniform vec3 u_paraDiff;    // 平行光源漫反射颜色
uniform vec3 u_paraSpec;    // 平行光源镜面反射颜色

uniform float u_eyePos;     // 摄像机位置（世界空间）

uniform vec3 u_modelDiff;   // 模型漫反射颜色
uniform vec3 u_modelSpec;   // 模型镜面反射颜色
uniform float u_modelGloss; // 模型光滑度

varying vec3 v_modelPos;    // 模型位置（世界空间）
varying vec3 v_modelNorm;   // 模型法线（世界空间）

vec3 lightDiffuse(
  in vec3 lightDir,
  in vec3 lightDiff,
  in vec3 modelNorm,
  in vec3 modelDiff
) {
  float dirDotNorm = clamp(dot(-lightDir, modelNorm), 0.0, 1.0);
  return dirDotNorm * lightDir * lightDiff;
}

vec3 lightSpecular(
  in vec3 lightDir,
  in vec3 lightSpec,
  in vec3 eyePos,
  in vec3 modelPos,
  in vec3 modelNorm,
  in vec3 modelSpec,
  int float modelGloss
) {
  vec3 eyeVec = eyePos - modelPos;
  vec3 halfVec = normalize(lightDir + eyeVec);
  vec3 halfDotNorm = clamp(dot(halfVec, modelNorm), 0.0, 1.0);
  return halfDotNorm * lightDir * lightDiff;
}

void main(){
  vec3 diffCol = lightDiffuse(
    u_paraDir, u_paraDiff,
    v_modelNorm, u_modelDiff
  );
  vec3 specCol = lightSpecular(
    u_paraDir, u_paraSpec,
    u_eyePos, v_modelPos, v_modelNorm,
    u_modelSpec, u_modelGloss
  );
  gl_FragColor = vec4(diffCol + u_lightEnv, 1.0);
}
'''

canvas = document.getElementById("gl-canvas")
glw = createWebGLWrap(canvas)

Promise.all([
  glw.createShader(VS_CODE, FS_CODE)
  glw.createBufferMesh_Obj("./_res/special.obj")
])
.then (resArray) ->
  shader = resArray[0]
  mesh = resArray[1]

  modelMat = modelMat.fromRotationTranslationScale(mat4.create(), [1,0,0,0], [0,0,0], [100,100,100])
  projMat = mat4.ortho(mat4.create(), -512, 512, -288, 288, -500, 500)
  mvMat = mat4.copy(mat4.create(), modelMat)
  mvpMat = mat4.multiply(mat4.create(), projMat, modelMat)

  lightEnv = vec3.fromValues(0.6, 0.6, 0.6)

  paraDir = vec3.fromValues(M.SQRT2_2, -M.SQRT2_2, 0)
  paraDiff = vec3.fromValues(0.3, 0.3, 0.3)
  paraSpec = vec3.fromValues(0.3, 0.3, 0.3)

  modelDiff = vec3.fromValues(1, 1, 1)
  modelSpec = vec3.fromValues(1, 1, 1)
  model

  clearParam = {
    clearColorRed: 0.92
    clearColorGreen: 0.92
    clearColorBlue: 0.92
    clearColorAlpha: 1.0
    clearDepth: 1.0
  }

  drawParam = {
    shader: shader
    uniformArray: [
      {name: "u_mvpMat", data: worldMat}
      {name: "u_modelDiff", data: modelDiff}
      {name: "u_lightEnv", data: envCol}
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
  }

  glw.clearFrame(clearParam)
  glw.drawCall(drawParam)
.catch (err) ->
  console.log(err)
