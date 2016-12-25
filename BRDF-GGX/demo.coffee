VS_CODE = '''
uniform mat4 u_mvpMat;      // MVP矩阵（模型空间=>设备空间）
uniform mat4 u_mvMat;       // MV矩阵（模型空间=>世界空间）

attribute vec3 a_objPosM;   // 模型位置（模型空间）
attribute vec3 a_objNormM;  // 模型法线（模型空间）

varying vec3 v_objPosW;     // 模型位置（世界空间）
varying vec3 v_objNormW;    // 模型法线（世界空间）

void main() {
  gl_Position = u_mvpMat * vec4(a_objPosM, 1.0);
  v_objPosW = (u_mvMat * vec4(a_objPosM, 1.0)).xyz;
  v_objNormW = a_objNormM;
}
'''

FS_CODE = '''
precision mediump float;

const float C_0 = 0.0;
const float C_1 = 1.0;
const float C_PI = 3.141592653589793;
const float C_2xPI = 2.0 * C_PI;
const float C_1_PI = 1.0 / C_PI;
const float C_EPSILON = 1e-6;

float saturate(const in float a) { return clamp(a, C_0, C_1); }
vec2 saturate(const in vec2 a) { return clamp(a, C_0, C_1); }
vec3 saturate(const in vec3 a) { return clamp(a, C_0, C_1); }
vec4 saturate(const in vec4 a) { return clamp(a, C_0, C_1); }

float pow2(const in float a) { return a * a; }
float pow3(const in float a) { return a * a * a; }
float pow4(const in float a) { float b = a * a; return b * b; }

uniform vec3 u_envCol;        // 环境光颜色

uniform vec3 u_paraDirW;      // 平行光源方向
uniform vec3 u_paraCol;       // 平行光源颜色

uniform vec3 u_viewPosW;      // 摄像机位置（世界空间）

uniform vec3 u_objAlbedo;     // 物体反照率（颜色）
uniform float u_objMetalness; // 物体金属度
uniform float u_objRoughness; // 物体粗糙度

varying vec3 v_objPosW;       // 模型位置（世界空间）
varying vec3 v_objNormW;      // 模型法线（世界空间）

// 计算物体材质的diffuse
vec3 ComputeDiffuse(
  const in vec3 objAlbedo,
  const in float objMetalness
) {
  return objAlbedo * (C_1 - objMetalness);
}

// 计算物体材质的specular
vec3 ComputeSpecular(
  const in vec3 objAlbedo,
  const in float objMetalness
) {
  return mix(vec3(0.04), objAlbedo, vec3(objMetalness));
}

// 光照方程 漫反射项
vec3 DiffuseTerm(
  const in vec3 objDiff
) {
  return C_1_PI * objDiff;
}

// BRDF F项 菲涅尔项
vec3 FresnelTerm(
  const in float lightDotHalf,
  const in vec3 objSpec
) {
  float fresnel = pow(C_1 - lightDotHalf, 5.0);
  return objSpec + (C_1 - objSpec) * fresnel;
}

// BRDF G项 几何项
float GeometryTerm(
  const in float normDotLightW,
  const in float normDotViewW,
  const in float objRoughness
) {
  float alphaPow2 = pow4(objRoughness);
  float gl = normDotLightW + sqrt(alphaPow2 + (C_1 - alphaPow2) * pow2(normDotViewW));
  float gv = normDotViewW + sqrt(alphaPow2 + (C_1 - alphaPow2) * pow2(normDotLightW));
  return 0.5 / max(gl + gv, C_EPSILON);
}

// BRDF D项 分布项
float DistributionTerm(
  const in float normDotHalfW,
  const in float objRoughness
) {
  float alphaPow2 = pow4(objRoughness);
  float denom = pow2(normDotHalfW) * (alphaPow2 - C_1) + 1.0;
  return C_1_PI * alphaPow2 / pow2(denom);
}

// 光照方程 镜面反射项
vec3 SpecularTerm(
  const in float normDotLightW,
  const in float normDotViewW,
  const in float normDotHalfW,
  const in float lightDotHalfW,
  const in vec3 objSpec,
  const in float objRoughness
) {
  vec3 fresnelTerm = FresnelTerm(lightDotHalfW, objSpec);
  float geometryTerm = GeometryTerm(normDotLightW, normDotViewW, objRoughness);
  float distributionTerm = DistributionTerm(normDotHalfW, objRoughness);
  return fresnelTerm * (distributionTerm * geometryTerm);
}

// 光照方程
vec3 LightEquation(
  const in vec3 lightVecW,
  const in vec3 viewVecW,
  const in vec3 objNormW,
  const in vec3 lightCol,
  const in vec3 objDiff,
  const in vec3 objSpec,
  const in float objRoughness
) {
  vec3 halfVecW = normalize(lightVecW + viewVecW);

  float normDotLightW = saturate(dot(objNormW, lightVecW));
  float normDotViewW = saturate(dot(objNormW, viewVecW));
  float normDotHalfW = saturate(dot(objNormW, halfVecW));
  float lightDotHalfW = saturate(dot(lightVecW, halfVecW));

  vec3 diffuseTerm = DiffuseTerm(objDiff);
  vec3 specularTerm = SpecularTerm(
    normDotLightW, normDotViewW, normDotHalfW, lightDotHalfW,
    objSpec, objRoughness
  );
  return C_PI * (diffuseTerm + specularTerm) * (lightCol * normDotLightW);
}

void main() {
  vec3 objDiff = ComputeDiffuse(u_objAlbedo, u_objMetalness);
  vec3 objSpec = ComputeSpecular(u_objAlbedo, u_objMetalness);

  vec3 viewVecW = normalize(u_viewPosW - v_objPosW);

  vec3 envCol = u_objAlbedo * u_envCol;

  vec3 paraLightVecW = -u_paraDirW;
  vec3 paraCol = LightEquation(
    paraLightVecW, viewVecW, v_objNormW,
    u_paraCol, objDiff, objSpec, u_objRoughness
  );

  gl_FragColor = vec4(envCol + paraCol, 1.0);
}
'''

canvas = document.getElementById("gl-canvas")
glw = createWebGLWrap(canvas)

Promise.all([
  glw.createShader(VS_CODE, FS_CODE)
  glw.createBufferMesh_Obj("../_res/sphere-2.obj")
])
.then (resArray) ->
  shader = resArray[0]
  mesh = resArray[1]

  #modelMat = mat4.fromRotationTranslationScale(mat4.create(), [1,0,0,0], [100,100,0], [100,100,100])
  modelMat = mat4.fromScaling(mat4.create(), [50,50,50])
  projMat = mat4.ortho(mat4.create(), -512, 512, -288, 288, -500, 500)
  mvMat = mat4.copy(mat4.create(), modelMat)
  mvpMat = mat4.multiply(mat4.create(), projMat, modelMat)

  lightEnv = vec3.fromValues(0.5, 0.5, 0.5)

  paraDir = vec3.fromValues(-M.SQRT3_3, -M.SQRT3_3, -M.SQRT3_3)
  paraCol = vec3.fromValues(0.5, 0.5, 0.5)

  viewPos = vec3.fromValues(0, 0, 200)

  objAlbedo = vec3.fromValues(0.7, 0.45, 0.4)
  objMetalness = 0.1
  objRoughness = 0.2

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
      {name: "u_mvpMat", data: mvpMat}
      {name: "u_mvMat", data: mvMat}
      {name: "u_envCol", data: lightEnv}
      {name: "u_paraDirW", data: paraDir}
      {name: "u_paraCol", data: paraCol}
      {name: "u_viewPosW", data: viewPos}
      {name: "u_objAlbedo", data: objAlbedo}
      {name: "u_objMetalness", data: objMetalness}
      {name: "u_objRoughness", data: objRoughness}
    ]
    attributeArray: [
      {name: "a_objPosM", size: 3, stride: 6, offset: 0, data: mesh}
      {name: "a_objNormM", size: 3, stride: 6, offset: 3, data: mesh}
    ]
    drawIndex: mesh
    drawMode: glw.DrawMode.TRIANGLES
    drawCount: mesh.getIndexLength()
  }

  animeTick = () ->
    glw.clearFrame(clearParam)
    glw.drawCall(drawParam)
  util.updateAnime(animeTick)
.catch (err) ->
  console.log(err)
