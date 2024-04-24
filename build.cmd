docker build -t gs-wasm-image .
docker create --name gs-wasm gs-wasm-image
docker cp gs-wasm:/dist .
docker rm gs-wasm