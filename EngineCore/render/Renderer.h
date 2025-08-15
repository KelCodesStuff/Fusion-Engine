// Renderer stub (C++)
//
// This is a placeholder for a metal-cpp based renderer. For now it contains
// no Metal code so the project compiles without the metal-cpp headers. We'll
// replace the internals with `MTL::Device`, `MTL::CommandQueue`, etc., once
// the headers are vendored and a CAMetalLayer is passed from the bridge.
#pragma once

namespace fe {

class Renderer {
public:
	Renderer();
	~Renderer();

	// Notify the renderer about drawable size changes (pixels)
	void resize(int width, int height);

	// Record commands for one frame (stub for now)
	void draw();

private:
	int drawableWidth = 0;
	int drawableHeight = 0;
};

} // namespace fe


