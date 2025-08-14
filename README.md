# Freedoom Web (Chocolate Doom in WebAssembly)

This project runs **Freedoom** (a free, open-source Doom-compatible game) in your browser using [Chocolate Doom](https://www.chocolate-doom.org/) compiled to **WebAssembly**.  
It is based on Cloudflare’s [doom-wasm](https://github.com/cloudflare/doom-wasm) port and served through a lightweight **Nginx** container.

---

## 🚀 Features

- **WebAssembly** build of Chocolate Doom
- Bundled with **Freedoom Phase 1** WAD file (free, legal replacement for DOOM 1)
- Runs entirely in the browser, no plugins required
- Served via an ultra-lightweight Nginx container

---

## 📂 Project Structure

Dockerfile # Multi-stage build: compiles Doom to WASM, serves via Nginx

The build process happens in **two stages**:

1. **Builder Stage** (`emscripten/emsdk`)

   - Installs required build tools
   - Clones Cloudflare’s `doom-wasm` repo
   - Downloads Freedoom WAD and renames it to `doom1.wad`
   - Builds Chocolate Doom to WebAssembly

2. **Serving Stage** (`nginx:alpine`)
   - Copies compiled files to Nginx web root
   - Configures MIME type for `.wasm`
   - Exposes port `80`

---

## 🛠 Requirements

- [Docker](https://docs.docker.com/get-docker/) installed and running

---

## 📦 Build & Run

1. **Clone this repository**

```bash
git clone https://github.com/<your-username>/freedoom-web.git
cd freedoom-web
```

2. **Build the Docker image**

```bash
docker build -t freedoom-web .
```

**Run the container**

```bash
docker run -it --rm -p 8080:80 freedoom-web
```

**Enjoy the game in your browser**

```bash
http://localhost:8080
```

🎮 Controls

Arrow keys / WASD — Move around

Ctrl / Space — Fire / Action

Esc — Game menu

📜 License

Freedoom WAD — BSD 3-Clause License

Chocolate Doom — GPL-2.0 License

This repository’s Docker setup — MIT License

🙌 Acknowledgements

Freedoom Project for the free WAD files

Chocolate Doom for the Doom source port

Cloudflare Doom-WASM for the WebAssembly build
