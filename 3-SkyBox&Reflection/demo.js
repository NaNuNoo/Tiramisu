/*
 * SkyBox - demo.js
 * Author: NaNuNo
 * Date: 2016-12-27
 */

(function(){

const VS_CODE = `
uniform mat4 u_mvpMat;
uniform mat4 u_mMat;
attribute vec3 a_objPosM;
varying vec3 a_objTex;
varying vec3 v_objPosW;
void main() {
  v_objPosW = (u_mMat * vec4(a_objPosM, 1.0)).xyz;
  gl_Position = u_mvpMat * vec4(a_objPosM, 1.0);
}`;

const FS_CODE = `
precision mediump float;
uniform samplerCube u_envSam;
varying vec3 v_objPosW;
void main() {
  gl_FragColor = textureCube(u_envSam, v_objPosW);
}`;

let canvas = document.getElementById("gl-canvas");
let glw = createWebGLWrap(canvas);

Promise.all([
  glw.createShader(VS_CODE, FS_CODE),
  glw.createBufferMesh_Obj("../_res/sky-box.obj"),
  glw.createTextureCube_Image([
    "../_res/px.jpg",
    "../_res/nx.jpg",
    "../_res/py.jpg",
    "../_res/ny.jpg",
    "../_res/pz.jpg",
    "../_res/nz.jpg"
  ])
]).then(function(resArray){
  let [skyBoxShad, skyBoxObj, skyBoxTex] = resArray;

  const clearParam = {
    clearColorRed: 0.92,
    clearColorGreen: 0.92,
    clearColorBlue: 0.92,
    clearColorAlpha: 1.0,
    clearDepth: 1.0
  };

  let projMat = mat4.ortho(mat4.create(), -512, 512, -288, 288, -1000, 1000);
  let modelMat = mat4.fromScaling(mat4.create(), [600 ,600 ,600]);
  let mvpMat = mat4.multiply(mat4.create(), projMat, modelMat);

  const drawParam = {
    cullEnable: false,
    shader: skyBoxShad,
    uniformArray: [
      {name: "u_mvpMat", data: mvpMat},
      {name: "u_mMat", data: modelMat},
      {name: "u_envSam", data: skyBoxTex}
    ],
    attributeArray: [
      {name: "a_objPosM", size: 3, stride: 8, offset: 0, data: skyBoxObj}
    ],
    drawIndex: skyBoxObj,
    drawMode: glw.DrawMode.TRIANGLES,
    drawCount: skyBoxObj.getIndexLength()
  };

  util.updateAnime(function(){
    glw.clearFrame(clearParam);
    glw.drawCall(drawParam);
  });

}).catch(function(err){
  console.log(err);
})

})();
