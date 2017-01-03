rm ./_lib/tiramisu.js

cat \
  ./_Tiramisu/math.coffee \
  ./_Tiramisu/init.coffee \
  ./_Tiramisu/enum.coffee \
  ./_Tiramisu/util.coffee \
  ./_Tiramisu/shader.coffee \
  ./_Tiramisu/texture.coffee \
  ./_Tiramisu/obj_file.coffee \
  ./_Tiramisu/buffer.coffee \
  ./_Tiramisu/state.coffee \
| coffee -c -s >> ./_lib/tiramisu.js

if [[ $1 ]]; then
  coffee -c ./$1
fi
