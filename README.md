## Fusion-Engine (macOS)

Game Engine built with Metal graphics + Jolt physics.

### Status
- App builds and runs on macOS (Intel and Apple Silicon).
- Window activation/restoration fixed; stable render loop.
- Objective‑C++ bridge renders a colored triangle with Metal.
- Compiled Metal shader (`Shaders/triangle.metal`) packaged as `default.metallib`.
- C++ scaffolding (`EngineCore`) and bridge (`EngineBridge`) in place.
- Jolt submodule present (not yet compiled/linked).

### Architecture
- **Swift app (UI, windowing)**: hosts `MTKView`, lifecycle, menus
- **Objective‑C++ bridge (`EngineBridge`)**: C ABI for Swift ↔ C++ calls; encodes a minimal Metal pass; loads `default.metallib`
- **C++ core (`EngineCore`)**: engine loop stubs; prepared to accept a `CAMetalLayer*` and move rendering into C++

### Requirements
- Xcode 16 (macOS 14+ recommended)
- Architectures: `arm64` and `x86_64`

### First‑time setup
```bash
git clone <this repo>
cd Fusion-Engine
git submodule update --init --recursive
```

### Build and run (Xcode)
1) Open `Fusion-Engine.xcodeproj` in Xcode
2) Select scheme `Fusion-Engine` → Run

### Universal hardware support
- Build architectures: `arm64` and `x86_64`.
- Jolt flags (to be applied when integrating):
  - `x86_64`: `-DJPH_USE_SSE4_1=1 -msse4.1`
  - `arm64`: `-DJPH_USE_NEON=1`

### metal-cpp migration (planned)
- Vendor Apple’s `metal-cpp` headers (headers-only)
- Pass `CAMetalLayer*` from the bridge via `FEEngineAttachLayer` → `fe::Engine::attachCAMetalLayer(void*)`
- Implement `EngineCore/render/MetalRenderer` in C++ and move pipeline/encoding out of ObjC++

### Roadmap (next milestones)
1) Vendor `metal-cpp` and implement `MetalRenderer` in C++ using the passed `CAMetalLayer*`
2) Replace bridge’s draw path with calls into `EngineCore` (single source of truth)
3) Integrate Jolt (minimal compile, per‑arch flags, fixed‑timestep step in `tick()`)
4) Render physics bodies (cube instances), add camera controls and depth
5) Expand to materials, instancing, and then shadows/PBR


