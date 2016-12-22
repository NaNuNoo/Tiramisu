VS_CODE = '''
uniform mat4 u_mvp;
attribute vec3 a_pos;
attribute vec3 a_norm;
varying vec3 v_norm;
void main() {
  gl_Position = u_mvp * vec4(a_pos, 1.0);
  v_norm = a_norm;
}
'''

FS_CODE = '''
precision mediump float;
uniform vec3 u_paraDir;
uniform vec3 u_paraDiffuse;
uniform vec3 u_diffuse;
varying vec3 v_norm;
void main(){
  vec3 diffuseCol = dot(-u_paraDir, v_norm) * u_paraDiffuse * u_diffuse;
  gl_FragColor = vec4(diffuseCol, 1.0);
}
'''

canvas = document.getElementById("gl-canvas")
glw = createWebGLWrap(canvas)

Promise.all([
  glw.createShader(VS_CODE, FS_CODE)
  glw.createBufferMesh_Obj("./rect.obj")
])
.then (resArray) ->
  shader = resArray[0]
  mesh = resArray[1]
  glw.clearFrame({
    clearColorRed: 0.0
    clearColorGreen: 0.0
    clearColorBlue: 0.0
    clearColorAlpha: 1.0
    clearDepth: 1.0
  })
  return
  glw.drawCall({
    shader: shader
    name: {"a_pos", size: 3, stride: 8, offset: 0, data: mesh}
    name: {"a_norm", size: 3, stride: 8, offset: 5, data: mesh}
    drawIndex: mesh
    drawMode: glw.drawMode.TRIANGLES
  })
.catch (err) ->
  console.log(err)
