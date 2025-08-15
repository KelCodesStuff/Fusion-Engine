// EngineCore public interface (C++)
//
// This header declares the minimal C++ engine surface used by the Objective‑C++
// bridge. Keep this API small and stable so Swift can call into it via a C ABI
// without needing C++ name mangling.
#pragma once

#include <cstdint>

namespace fe {

/// Engine is the long‑lived core owner of rendering and physics subsystems.
///
/// Lifecycle
/// - Construct once when the host `MTKView` is created
/// - Call `resize` whenever the drawable size changes
/// - Call `tick` once per frame from the display loop
///
/// Threading
/// - Public methods are expected to be invoked from the main thread for now
/// - Internals may use worker threads later (job systems, command encoding)
class Engine {
public:
	/// Create an uninitialized engine. Subsystems are brought up lazily.
	Engine();

	/// Release subsystems and GPU/CPU resources in a safe order.
	~Engine();

	/// Notify the engine that the drawable/backing size changed.
	/// width/height are in pixels (not points) and must be non‑negative.
	void resize(int width, int height);

	/// Advance simulation and record GPU commands for one frame.
	/// deltaSeconds is wall‑clock time since the previous call (seconds).
	void tick(double deltaSeconds);

	/// Optional: Attach the platform surface. For Metal this will be a
	/// `CAMetalLayer*` provided as an opaque pointer from the bridge. Kept here
	/// to enable future metal-cpp integration without Objective‑C includes.
	void attachCAMetalLayer(void* caMetalLayer);
};

} // namespace fe


