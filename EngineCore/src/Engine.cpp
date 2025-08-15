#include "EngineCore/Engine.h"
#include "../render/Renderer.h"

namespace fe {

// Construct all engine state to valid defaults. Keep heavy allocations out of
// the constructor so creation is cheap; prefer lazy initialization during the
// first `resize` / `tick` when the required sizes are known.
Engine::Engine() {}

// Tear down; order matters later (GPU → CPU). Using RAII on members will keep
// this destructor trivial even as the engine grows in complexity.
Engine::~Engine() {}

// Cache the new drawable size and (later) recreate size‑dependent resources like
// depth buffers and swapchain attachments.
void Engine::resize(int /*width*/, int /*height*/) {}

// Main per‑frame entry point. Later this will:
// 1) Step physics at a fixed timestep (accumulator)
// 2) Update view/projection, gather visible objects
// 3) Encode GPU command buffers and submit
void Engine::tick(double /*deltaSeconds*/) {}

void Engine::attachCAMetalLayer(void* /*caMetalLayer*/) {
    // Placeholder; once metal-cpp is integrated, store CAMetalLayer* here and
    // create MTL::Device/CommandQueue/Drawable handling in C++.
}

} // namespace fe


