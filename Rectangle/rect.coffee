VS_CODE = '''
attribute vec3 a_pos;
void main() {
  gl_Position = vec4(a_pos, 0.0);
}
'''

FS_CODE = '''
precision mediump float;
uniform vec4 u_col;
void main(){
  gl_FragColor = u_col;
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
  setInterval () ->
    glw.clearFrame({
      clearColorRed: 0.0
      clearColorGreen: 0.0
      clearColorBlue: 0.0
      clearColorAlpha: 1.0
      clearDepth: 1.0
    })
    glw.drawCall({
      shader: shader
      attributeArray: [
        {name:"a_pos", size: 3, stride: 0, offset: 0, data: mesh}
      ]
      uniformArray: [
        {name: "u_col", data: new Float32Array([1.0, 1.0, 1.0, 1.0])}
      ]
      #drawIndex: mesh
      drawMode: glw.DrawMode.TRIANGLES
      drawCount: 3
    })
  , 0.1
.catch (err) ->
  console.log(err)
