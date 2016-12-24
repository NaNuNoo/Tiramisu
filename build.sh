rm ./_src/lib.js

echo "" >> ./_src/lib.js
coffee -c -p ./_lib/math.coffee >> ./_src/lib.js

echo "" >> ./_src/lib.js
coffee -c -p ./_lib/util.coffee >> ./_src/lib.js

echo "function createWebGLWrap(argCanvas, argParam){" >> ./_src/lib.js
cat\
  ./_lib/basic.coffee\
  ./_lib/shader.coffee\
  ./_lib/obj_file.coffee\
  ./_lib/buffer.coffee\
  ./_lib/texture.coffee\
  ./_lib/state.coffee\
  ./_lib/wrap.coffee\
| coffee -c -s -b >> ./_src/lib.js
echo "};" >> ./_src/lib.js

if [[ $1 ]]; then
  coffee -c ./$1
fi
