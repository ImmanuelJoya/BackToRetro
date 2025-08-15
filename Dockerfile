# -------- Stage 1: build Chocolate Doom (WASM) -------- 
#start with the Emscripten SDK image (version 3.1.51), which is a compiler that can build C/C++ code into WebAssembly (.wasm) so it can run in a browser.
#This is necessary because Doom is originally C code.
FROM emscripten/emsdk:3.1.51 AS builder
 
# Basic build tools (autotools/cmake/unzip/curl) that the build script may use.
#Installs basic Linux build tools inside the container.
#These are needed for compiling Dooms source code.
RUN apt-get update && apt-get install -y \
    git curl unzip python3 make cmake autoconf automake libtool pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /src

# Clone Cloudflare's WebAssembly port of Chocolate Doom
#Clones Cloudflare’s doom-wasm repository (a WebAssembly port of Chocolate Doom).
#This repo already has all the JavaScript glue code and HTML needed to run Doom in a browser.
RUN git clone --depth=1 https://github.com/cloudflare/doom-wasm.git
WORKDIR /src/doom-wasm

# Fetch Freedoom Phase 1 and provide it as doom1.wad expected by the project

#Downloads the Freedoom WAD file (open-source game data).
#Doom needs a .wad file for levels, textures, etc.
#Copies it into the correct location (src/doom1.wad) so the build can bundle it.
RUN curl -L -o /tmp/freedoom.zip https://github.com/freedoom/freedoom/releases/download/v0.12.1/freedoom-0.12.1.zip \
    && unzip /tmp/freedoom.zip -d /tmp/freedoom \
    && cp /tmp/freedoom/freedoom-0.12.1/freedoom1.wad ./src/doom1.wad

# Build to WebAssembly

#Runs the build script included in the doom-wasm repo.

#Compiles Doom’s C source code to WebAssembly (doom.wasm).
#Generates JavaScript loader code (doom.js) and HTML (index.html) that loads the game.
#Outputs everything into /src/doom-wasm/src/.
RUN chmod +x ./scripts/build.sh && ./scripts/build.sh

# -------- Stage 2: static web server --------

#Creates a tiny Nginx web server container.
#Copies the compiled WebAssembly game files (index.html, .js, .wasm, .wad) into Nginx’s default web root.
FROM nginx:alpine
# Copy the built site (Cloudflare repo serves from ./src/)
COPY --from=builder /src/doom-wasm/src/ /usr/share/nginx/html/
# Ensure correct MIME for .wasm

#Makes sure .wasm files are served with the correct MIME type.
#Opens port 80 so you can access the game via http://localhost.
RUN printf "types { application/wasm wasm; }\n" > /etc/nginx/conf.d/wasm.conf
EXPOSE 80
