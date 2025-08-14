# -------- Stage 1: build Chocolate Doom (WASM) --------
FROM emscripten/emsdk:3.1.51 AS builder

# Basic build tools (autotools/cmake/unzip/curl) that the build script may use
RUN apt-get update && apt-get install -y \
    git curl unzip python3 make cmake autoconf automake libtool pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

# Clone Cloudflare's WebAssembly port of Chocolate Doom
RUN git clone --depth=1 https://github.com/cloudflare/doom-wasm.git
WORKDIR /src/doom-wasm

# Fetch Freedoom Phase 1 and provide it as doom1.wad expected by the project
RUN curl -L -o /tmp/freedoom.zip https://github.com/freedoom/freedoom/releases/download/v0.12.1/freedoom-0.12.1.zip \
 && unzip /tmp/freedoom.zip -d /tmp/freedoom \
 && cp /tmp/freedoom/freedoom-0.12.1/freedoom1.wad ./src/doom1.wad

# Build to WebAssembly
RUN chmod +x ./scripts/build.sh && ./scripts/build.sh

# -------- Stage 2: static web server --------
FROM nginx:alpine
# Copy the built site (Cloudflare repo serves from ./src/)
COPY --from=builder /src/doom-wasm/src/ /usr/share/nginx/html/
# Ensure correct MIME for .wasm
RUN printf "types { application/wasm wasm; }\n" > /etc/nginx/conf.d/wasm.conf
EXPOSE 80
