FROM emscripten/emsdk:3.1.28

RUN apt update && \
    apt install -y autotools-dev automake libtool

ENV OUT_DIR=/out
ENV ROOT=/src

ENV VERSION=10.03.0
ENV VERSION_NODOTS=10030
ENV DIRECTORY=ghostscript-${VERSION}

WORKDIR /src

COPY arch_wasm.h .
ADD https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs${VERSION_NODOTS}/${DIRECTORY}.tar.gz .
RUN tar -xzf ${DIRECTORY}.tar.gz

WORKDIR /src/${DIRECTORY}

RUN mkdir -p $OUT_DIR

ENV EMCC_FLAGS_RELEASE=""
ENV CFLAGS=${EMCC_FLAGS_RELEASE}
ENV CXXFLAGS=${CFLAGS}

RUN emconfigure ./autogen.sh \
    CCAUX=gcc CFLAGSAUX= CPPFLAGSAUX= \
    --host="wasm32-unknown-linux" \
    --prefix="$OUT_DIR" \
    --disable-threading \
    --disable-cups \
    --disable-dbus \
    --disable-gtk \
    --without-tesseract \
    --with-arch_h="${ROOT}/arch_wasm.h"

COPY js ./js

ENV GS_LDFLAGS="\
    -lnodefs.js -lworkerfs.js -lidbfs.js\
    --closure 1 \
    --pre-js "./js/pre.js" \
    --post-js "./js/post.js" \
    -s WASM_BIGINT=1 \
    -s ALLOW_MEMORY_GROWTH=1 \
    -s EXPORTED_RUNTIME_METHODS='[\"callMain\",\"FS\",\"NODEFS\",\"WORKERFS\",\"ENV\",\"IDBFS\"]' \
    -s INCOMING_MODULE_JS_API='[\"noInitialRun\",\"noFSInit\",\"locateFile\",\"preRun\",\"instantiateWasm\"]' \
    -s NO_DISABLE_EXCEPTION_CATCHING=1 \
    -s MODULARIZE=1 \
    -s INITIAL_MEMORY=18743296 \
    -s EMULATE_FUNCTION_POINTER_CASTS=1 \
    -s BINARYEN_EXTRA_PASSES=\"--pass-arg=max-func-params@39\" \
"

RUN emmake make \
    XE=".js" \
    LDFLAGS="$GS_LDFLAGS" \
    -j install

RUN mkdir -p /dist
RUN cp ${ROOT}/${DIRECTORY}/bin/* /dist
