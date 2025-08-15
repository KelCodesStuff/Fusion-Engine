#include "Renderer.h"

namespace fe {

Renderer::Renderer() = default;
Renderer::~Renderer() = default;

void Renderer::resize(int width, int height) {
	drawableWidth = width;
	drawableHeight = height;
}

void Renderer::draw() {
	// Stub: will encode Metal commands once metal-cpp is integrated.
}

} // namespace fe


