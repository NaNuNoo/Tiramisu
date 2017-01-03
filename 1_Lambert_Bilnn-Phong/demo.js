(function(){

const VS_CODE = `
uniform mat4 u_worldMat;
attribute vec3 a_modelPos;
attribute vec3 a_modelNorm;
varying vec3 v_modelNorm;
void main() {
  gl_Position = u_worldMat * vec4(a_modelPos, 1.0);
  v_modelNorm = a_modelNorm;
}`;

const FS_CODE = `
precision mediump float;
uniform vec3 u_envLight;
uniform vec3 u_paraDir;
uniform vec3 u_paraDiff;
uniform vec3 u_modelDiff;
varying vec3 v_modelNorm;

vec3 lightDiffuse(
  in vec3 lightDir,
  in vec3 lightDiff,
  in vec3 modelNorm,
  in vec3 modelDiff
) {
  float dirDotNorm = dot(-lightDir, modelNorm);
  dirDotNorm = clamp(dirDotNorm, 0.0, 1.0);
  return dirDotNorm * modelDiff * lightDiff;
}

void main(){
  vec3 diffCol = lightDiffuse(u_paraDir, u_paraDiff, v_modelNorm, u_modelDiff);
  gl_FragColor = vec4(diffCol + u_envLight, 1.0);
}`

Promise.all([
  ti.StaticShader.create_VsFs(VS_CODE, FS_CODE),
  ti.StaticMesh.create_ObjFile("../_res/special.obj"),
])
.then((resArray) => {
  let [shader, mesh] = resArray;

  let projMat = mat4.ortho(mat4.create(), -512, 512, -288, 288, -500, 500);
  let modelMat = mat4.create();
  mat4.translate(modelMat, modelMat, [0, 0, -100]);
  mat4.scale(modelMat, modelMat, [100, 100, 100]);
  //mat4.rotateY(modelMat, modelMat, -Math.PI/6);
  let worldMat = mat4.multiply(mat4.create(), projMat, modelMat);
  let objDiff = vec3.fromValues(1, 1, 1);
  let envCol = vec3.fromValues(0.6, 0.6, 0.6);
  let paraDir = vec3.fromValues(Math.sqrt(2)/2, -Math.sqrt(2)/2, 0);
  let paraDiff = vec3.fromValues(0.4, 0.4, 0.4);

  ti.clearFrame({
    clearColorRed: 0.92,
    clearColorGreen: 0.92,
    clearColorBlue: 0.92,
    clearColorAlpha: 1.0,
    clearDepth: 1.0,
  });

  ti.drawCall({
    shader: shader,
    uniformArray: [
      {name: "u_worldMat", data: worldMat},
      {name: "u_modelDiff", data: objDiff},
      {name: "u_envLight", data: envCol},
      {name: "u_paraDir", data: paraDir},
      {name: "u_paraDiff", data: paraDiff},
    ],
    attributeArray: [
      {name: "a_modelPos", size: 3, stride: 6, offset: 0, data: mesh},
      {name: "a_modelNorm", size: 3, stride: 6, offset: 3, data: mesh},
    ],
    drawIndex: mesh,
    drawMode: ti.DrawMode.TRIANGLES,
    drawCount: mesh.getIndexLength(),
  });
})
.catch((err) => {
  console.log(err);
});

})();
