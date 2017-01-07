/* * * * * * * * * * * * * * * * * * * *
 * File: Tiramisu/1_Lambert_Bilnn-Phong/demo.js
 * Author: NaNuNo
 * Project: https://github.com/NaNuNoo/Tiramisu
 * WebSite: http://FenQi.IO
 */

(function(){

const VS_CODE = `
uniform mat4 u_matPosM2D; // 模型空间 => 设备空间
uniform mat4 u_matPosM2W; // 模型空间 => 世界空间
uniform mat3 u_matNormM2W; // 法线变换 模型空间 => 世界空间

attribute vec3 a_modelPosM; // 物体位置（模型）
attribute vec3 a_modelNormM; // 物体法线（模型）

varying vec3 v_modelPosW; // 物体位置（世界）
varying vec3 v_modelNormW; // 物体法线（世界）

void main() {
  gl_Position = u_matPosM2D * vec4(a_modelPosM, 1.0);
  v_modelPosW = (u_matPosM2W * vec4(a_modelPosM, 1.0)).xyz;
  v_modelNormW = u_matNormM2W * a_modelNormM;
}`;

const FS_CODE = `
uniform vec3 u_envCol; // 环境光颜色

uniform vec3 u_paraDirW; // 平行光方向（世界）
uniform vec3 u_paraCol; // 平行光颜色

uniform vec3 u_pointPosW; // 点光位置（世界）
uniform vec3 u_pointCol; // 点光颜色

uniform vec3 u_eyePosW; // 视点位置（世界）

uniform vec3 u_modelDiffCol; // 物体漫反射颜色
uniform vec3 u_modelSpecCol; // 物体镜面反射颜色
uniform float u_modelSpecPow; // 物体镜面反射系数

varying vec3 v_modelPosW; // 物体位置（世界）
varying vec3 v_modelNormW; // 物体法线（世界）

vec3 computeEnvLight() {
  return u_envCol * u_modelDiffCol;
}

vec3 lightLambert(
  in vec3 lightW,
  in vec3 normW,
  in vec3 lightCol,
  in vec3 modelDiff
) {
  float lightDotNorm = saturate(dot(lightW, normW));
  return lightDotNorm * lightCol * modelDiff;
}

vec3 lightBilnnPhong(
  in vec3 normW,
  in vec3 halfW,
  in vec3 lightCol,
  in vec3 modelSpec,
  in float modelSpecPow
) {
  float normDotHalf = saturate(dot(normW, halfW));
  return pow(normDotHalf, modelSpecPow) * lightCol * modelSpec;
}

vec3 computeLight(
  in vec3 lightW,
  in vec3 normW,
  in vec3 halfW,
  in vec3 lightCol,
  in vec3 modelDiff,
  in vec3 modelSpec,
  in float modelSpecPow
) {
  vec3 diffCol = lightLambert(lightW, normW, lightCol, modelDiff);
  vec3 specCol = lightBilnnPhong(normW, halfW, lightCol, modelSpec, modelSpecPow);
  return diffCol + specCol;
}

vec3 computeParaLight() {
  vec3 lightW = normalize(-u_paraDirW);
  vec3 viewW = normalize(u_eyePosW - v_modelPosW);
  vec3 halfW = normalize(lightW + viewW);
  return computeLight(
    lightW, v_modelNormW, halfW,
    u_paraCol, u_modelDiffCol, u_modelSpecCol, u_modelSpecPow
  );
}

vec3 computePointLight() {
  vec3 lightW = normalize(u_pointPosW - v_modelPosW);
  vec3 viewW = normalize(u_eyePosW - v_modelPosW);
  vec3 halfW = normalize(lightW + viewW);
  return computeLight(
    lightW, v_modelNormW, halfW,
    u_pointCol, u_modelDiffCol, u_modelSpecCol, u_modelSpecPow
  );
}

void main() {
  vec3 envCol = computeEnvLight();
  vec3 paraCol = computeParaLight();
  vec3 pointCol = computePointLight();
  gl_FragColor.rgb = paraCol;
  gl_FragColor.a = 1.0;
}`

Promise.all([
  ti.StaticShader.create_VsFs(VS_CODE, FS_CODE),
  ti.StaticMesh.create_ObjFile("../_res/special.obj"),
])
.then((resArray) => {
  const [shader, mesh] = resArray;
  const matPosV2D = mat4.create();
  const matPosW2V = mat4.create();
  const matPosW2D = mat4.create();

  const drawShape = () => {
    const matPosM2W = mat4.fromRotationTranslationScale(mat4.create(), [0,0,0,1], [0,0,0], [100,100,100]);
    const matNormM2W = mat3.fromQuat(mat3.create(), [0,0,0,1]);
    const matPosM2D = mat4.multiply(mat4.create(), matPosW2D, matPosM2W);
    const drawParam = {
      shader: shader,
      uniformArray: [
        {name: "u_matPosM2D", data: matPosM2D},
        {name: "u_matPosM2W", data: matPosM2W},
        {name: "u_matNormM2W", data: matNormM2W},
        {name: "u_envCol", data: vec3.fromValues(0.6, 0.6, 0.6)},
        {name: "u_paraDirW", data: vec3.fromValues(1, -1, 0)},
        {name: "u_paraCol", data: vec3.fromValues(0.4, 0.4, 0.4)},
        {name: "u_pointPosW", data: vec3.fromValues(0, 0, 0)},
        {name: "u_pointCol", data: vec3.fromValues(0, 0, 0)},
        {name: "u_eyePosW", data: vec3.fromValues(0, 0, 0)},
        {name: "u_modelDiffCol", data: vec3.fromValues(1, 1, 1)},
        {name: "u_modelSpecCol", data: vec3.fromValues(1, 1, 1)},
        {name: "u_modelSpecPow", data: 20},
      ],
      attributeArray: [
        {name: "a_modelPosM", size: 3, stride: 6, offset: 0, data: mesh},
        {name: "a_modelNormM", size: 3, stride: 6, offset: 3, data: mesh},
      ],
      drawIndex: mesh,
      drawMode: ti.DrawMode.TRIANGLES,
      drawCount: mesh.getIndexLength(),
    };
    ti.drawCall(drawParam);
  };

  ti.updateAnime(() => {
    ti.cleatFrame({
      clearColorRed: 0.92,
      clearColorGreen: 0.92,
      clearColorBlue: 0.92,
      clearColorAlpha: 1.0,
      clearDepth: 1.0,
    });
    mat4.ortho(matPosV2D, -512, 512, -288, 288, -500, 500);
    mat4.lookAt(matPosW2V, [0,0,200], [0,0,0], [0,1,0]);
    mat4.multiply(matPosW2D, matPosV2D, matPosW2V);
    drawShape();
  });
})
.catch((err) => {
  console.log(err);
});

})();
