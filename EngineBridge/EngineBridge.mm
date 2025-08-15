#import <MetalKit/MetalKit.h>

#import "EngineBridge.h"

#include <memory>
#include "EngineCore/Engine.h"

// Small wrapper that owns the C++ engine and keeps a weak reference to the MTKView
// provided by Swift. Keeping the view weak avoids retain cycles.
struct FEEngineWrapper {
	std::unique_ptr<fe::Engine> engine;
	__weak MTKView* view = nil;
};

// Create a new engine and bind it to the MTKView. The MTKView is only stored
// for future use when we move command encoding into C++.
FEEngineHandle FEEngineCreate(void* mtkView) {
	FEEngineWrapper* wrapper = new FEEngineWrapper();
	wrapper->view = (__bridge MTKView*)mtkView;
	wrapper->engine = std::make_unique<fe::Engine>();
	return (FEEngineHandle)wrapper;
}

// Forward resize to the C++ engine.
void FEEngineResize(FEEngineHandle handle, int width, int height) {
	FEEngineWrapper* wrapper = (FEEngineWrapper*)handle;
	if (!wrapper) return;
	wrapper->engine->resize(width, height);
}

// Per-frame call from Swift. Will later read drawable size from the view,
// step physics at fixed timestep, and record Metal command buffers in C++.
void FEEngineTick(FEEngineHandle handle, double deltaSeconds) {
	FEEngineWrapper* wrapper = (FEEngineWrapper*)handle;
	if (!wrapper) return;
	// For now, do nothing but forward tick; renderer will come later.
	wrapper->engine->tick(deltaSeconds);
}

// Destroy and free the wrapper/engine pair.
void FEEngineDestroy(FEEngineHandle handle) {
	FEEngineWrapper* wrapper = (FEEngineWrapper*)handle;
	if (!wrapper) return;
	delete wrapper;
}


