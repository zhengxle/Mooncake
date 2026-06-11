export OUTPUT_DIR=dist
export MACA_PATH=/opt/maca
export LIBRARY_PATH=${MACA_PATH}/lib:${MACA_PATH}/lib64:${MACA_PATH}/mxgpu_llvm/lib:$LIBRARY_PATH
export LD_LIBRARY_PATH=${MACA_PATH}/lib:${MACA_PATH}/lib64:${MACA_PATH}/mxgpu_llvm/lib:$LD_LIBRARY_PATH
export CUCC_CMAKE_ENTRY=2
export CUCC_CUDA_VERSION=12090
export PATH=/opt/maca/tools/cu-bridge/bin:$PATH

[[ "$1" == "-f" ]] && rm -rf build
mkdir -p build && cd build
cmake -G Ninja .. -DBUILD_UNIT_TESTS=OFF \
        -DUSE_HTTP=ON \
        -DUSE_ETCD=ON \
        -DUSE_MACA=ON \
        -DUSE_CUDA=ON \
        -DWITH_EP=ON \
        -DWITH_STORE=ON \
        -DWITH_P2P_STORE=ON \
        -DSTORE_USE_ETCD=ON \
        -DCMAKE_PREFIX_PATH="/opt/maca;/opt/maca/mxgpu_llvm;/opt/maca/tools/cu-bridge" \
        -DCMAKE_CXX_FLAGS="-I/opt/maca/include/mcr -I/opt/maca/tools/cu-bridge/include -L/opt/maca/lib -L/opt/maca/lib64 -L /opt/maca/tools/cu-bridge/lib" \
        -DMACA_RUNTIME_LIBS="mcruntime;mxc-runtime64;runtime_cu"  \
        -DPython3_EXECUTABLE=/usr/bin/python3.10 -DCMAKE_BUILD_TYPE=Release
cmake --build ./ -v && \
cd -
mkdir -p build/mooncake-transfer-engine/nvlink-allocator && \
    cd mooncake-transfer-engine/nvlink-allocator && \
    bash build.sh --use-maca ../../build/mooncake-transfer-engine/nvlink-allocator/ && \
cd - 
OUTPUT_DIR=dist && ./scripts/build_wheel.sh
