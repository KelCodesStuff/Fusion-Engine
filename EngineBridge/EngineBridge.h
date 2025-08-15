#pragma once

#ifdef __cplusplus
extern "C" {
#endif

// Handle to the opaque engine instance used across the C ABI boundary.
typedef void* FEEngineHandle;

// Create a new engine instance. The pointer must be an `MTKView*` cast to
// `void*`. We keep a weak reference on the Objective‑C++ side.
FEEngineHandle FEEngineCreate(void* mtkView /* MTKView* */);

// Notify the engine that the drawable size changed (pixel dimensions).
void FEEngineResize(FEEngineHandle engine, int width, int height);

// Advance simulation / rendering by `deltaSeconds`.
void FEEngineTick(FEEngineHandle engine, double deltaSeconds);

// Destroy the engine and release resources. Safe to pass NULL.
void FEEngineDestroy(FEEngineHandle engine);

// Optional: attach CAMetalLayer to the C++ core for metal-cpp migration
void FEEngineAttachLayer(FEEngineHandle engine, void* caMetalLayer /* CAMetalLayer* */);

#ifdef __cplusplus
}
#endif


