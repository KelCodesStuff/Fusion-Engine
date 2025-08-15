## Fusion-Engine (macOS)

Metal Graphics + Jolt Physics, with a C++ engine core.

### Status
- App builds and runs on macOS (Intel and Apple Silicon).
- Renders with a Swift `MTKView` that clears the screen at 60 FPS.
- C++ scaffolding (`EngineCore`) and Objective‑C++ bridge (`EngineBridge`) are in place.
- Jolt Physics is added as a submodule but not yet compiled or linked.

### Architecture
- **Swift App (UI, windowing)**: hosts the `MTKView`, activation, menus
- **Objective‑C++ Bridge (`EngineBridge`)**: C ABI for Swift ↔ C++ calls
- **C++ Core (`EngineCore`)**: rendering + physics (to be expanded)

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

You should see a window with a dark slate clear color (no content yet).

### Important Xcode notes
- File System Sync can auto-add `third_party/JoltPhysics` into your target’s build phases. This causes "Multiple commands produce…" errors and slow builds.
  - Fix: In the app target → Build Phases → Copy Bundle Resources and Compile Sources, remove all entries under `third_party/`.
  - In the Project Navigator, select the root synced group → File Inspector → File System Sync: add an exclusion for `third_party/**` (or uncheck target membership for the `third_party` group).

### Bridging header and headers
- Bridging header: `Fusion-Engine/EngineBridge-Bridging-Header.h` with:
  ```objc
  #import "EngineBridge.h"
  ```
- Header search paths (already set): `$(SRCROOT)/EngineBridge`, `$(SRCROOT)/EngineCore/include`.

### Universal hardware support
- Build architectures: `arm64` and `x86_64`.
- Jolt flags (to be applied when integrating):
  - `x86_64`: `-DJPH_USE_SSE4_1=1 -msse4.1`
  - `arm64`: `-DJPH_USE_NEON=1`

### metal-cpp (planned)
Rendering will move from Swift to C++ using `metal-cpp` (Apple’s C++ headers). Until then, Swift drives the `MTKView` and issues a simple clear.

### Roadmap (next milestones)
1) Vendor `metal-cpp` headers and move renderer into C++ (`EngineCore`) via the bridge.
2) Compile a minimal Jolt subset, initialize physics, and run a fixed‑timestep step in `EngineCore`.
3) Sync transforms from Jolt bodies to a simple cube instance buffer; render cubes in Metal.
4) Add camera controls, depth, a basic material, and instancing. Later: shadows and PBR.


