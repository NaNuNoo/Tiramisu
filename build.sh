rm ./lib.js
echo "function createWebGLWrap(argCanvas, argParam){" >> ./lib.js
cat\
  ./_lib/basic.coffee\
  ./_lib/shader.coffee\
  ./_lib/obj_file.coffee\
  ./_lib/buffer.coffee\
  ./_lib/texture.coffee\
  ./_lib/state.coffee\
  ./_lib/wrap.coffee\
| coffee -c -s -b >> ./lib.js
echo "};" >> ./lib.js
