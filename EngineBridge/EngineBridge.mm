#import <MetalKit/MetalKit.h>

#import "EngineBridge.h"

#include <memory>
#include "EngineCore/Engine.h"

// Small wrapper that owns the C++ engine and keeps a weak reference to the MTKView
// provided by Swift. Keeping the view weak avoids retain cycles.
struct FEEngineWrapper {
	std::unique_ptr<fe::Engine> engine;
	__weak MTKView* view = nil;
	id<MTLDevice> device = nil;
	id<MTLCommandQueue> queue = nil;
	id<MTLRenderPipelineState> pipeline = nil;
	MTLPixelFormat colorFormat = MTLPixelFormatBGRA8Unorm;
};

// Create a new engine and bind it to the MTKView. The MTKView is only stored
// for future use when we move command encoding into C++.
FEEngineHandle FEEngineCreate(void* mtkView) {
	FEEngineWrapper* wrapper = new FEEngineWrapper();
	wrapper->view = (__bridge MTKView*)mtkView;
	wrapper->engine = std::make_unique<fe::Engine>();

	// Initialize minimal Metal state in ObjC++ so we can render a triangle
	// without depending on metal-cpp yet. We compile a tiny shader from source
	// at runtime to avoid adding a Metal build phase.
	wrapper->device = wrapper->view.device;
	wrapper->queue = [wrapper->device newCommandQueue];
	wrapper->colorFormat = wrapper->view.colorPixelFormat;

	static NSString* const kShaderSrc = @"\n"
	"using namespace metal;\n"
	"struct VSOut { float4 position [[position]]; float4 color; };\n"
	"vertex VSOut v_main(uint vid [[vertex_id]]) {\n"
	"    float2 pos[3] = { float2(-0.8,-0.8), float2(0.0,0.8), float2(0.8,-0.8) };\n"
	"    float4 col[3] = { float4(1,0,0,1), float4(0,1,0,1), float4(0,0.5,1,1) };\n"
	"    VSOut o; o.position = float4(pos[vid], 0, 1); o.color = col[vid]; return o;\n"
	"}\n"
	"fragment float4 f_main(VSOut in [[stage_in]]) { return in.color; }\n";

	NSError* err = nil;
	id<MTLLibrary> lib = [wrapper->device newDefaultLibrary];
	if (!lib) {
		// Fallback to runtime source compilation if default library is not available
		lib = [wrapper->device newLibraryWithSource:kShaderSrc options:nil error:&err];
	}
	if (!lib || err) {
		NSLog(@"Metal shader compile error: %@", err);
	} else {
		id<MTLFunction> vs = [lib newFunctionWithName:@"v_main"];
		id<MTLFunction> fs = [lib newFunctionWithName:@"f_main"];
		MTLRenderPipelineDescriptor* pdesc = [MTLRenderPipelineDescriptor new];
		pdesc.label = @"TrianglePipeline";
		pdesc.vertexFunction = vs;
		pdesc.fragmentFunction = fs;
		pdesc.colorAttachments[0].pixelFormat = wrapper->colorFormat;
		pdesc.depthAttachmentPixelFormat = wrapper->view.depthStencilPixelFormat;
		pdesc.stencilAttachmentPixelFormat = MTLPixelFormatInvalid;
		pdesc.sampleCount = wrapper->view.sampleCount;
		err = nil;
		wrapper->pipeline = [wrapper->device newRenderPipelineStateWithDescriptor:pdesc error:&err];
		if (!wrapper->pipeline || err) {
			NSLog(@"Pipeline creation failed: %@", err);
		}
	}
	return (FEEngineHandle)wrapper;
}

// Forward resize to the C++ engine.
void FEEngineResize(FEEngineHandle handle, int width, int height) {
	FEEngineWrapper* wrapper = (FEEngineWrapper*)handle;
	if (!wrapper) return;
	wrapper->engine->resize(width, height);
	// Rebuild pipeline if formats/sample count changed (e.g., after Resize/Zoom)
	id<MTLDevice> dev = wrapper->device ?: wrapper->view.device;
	if (!dev) return;
	MTLPixelFormat newColor = wrapper->view.colorPixelFormat;
	bool needRebuild = (wrapper->pipeline == nil) ||
		(wrapper->colorFormat != newColor) ||
		(wrapper->view.sampleCount != 1);
	if (needRebuild) {
		wrapper->colorFormat = newColor;
		NSError* err = nil;
		static NSString* const kShaderSrc = @"\n"
		"using namespace metal;\n"
		"struct VSOut { float4 position [[position]]; float4 color; };\n"
		"vertex VSOut v_main(uint vid [[vertex_id]]) {\n"
		"    float2 pos[3] = { float2(-0.8,-0.8), float2(0.0,0.8), float2(0.8,-0.8) };\n"
		"    float4 col[3] = { float4(1,0,0,1), float4(0,1,0,1), float4(0,0.5,1,1) };\n"
		"    VSOut o; o.position = float4(pos[vid], 0, 1); o.color = col[vid]; return o;\n"
		"}\n"
		"fragment float4 f_main(VSOut in [[stage_in]]) { return in.color; }\n";
		id<MTLLibrary> lib = [dev newLibraryWithSource:kShaderSrc options:nil error:&err];
		if (!lib || err) return;
		id<MTLFunction> vs = [lib newFunctionWithName:@"v_main"];
		id<MTLFunction> fs = [lib newFunctionWithName:@"f_main"];
		MTLRenderPipelineDescriptor* pdesc = [MTLRenderPipelineDescriptor new];
		pdesc.label = @"TrianglePipeline";
		pdesc.vertexFunction = vs;
		pdesc.fragmentFunction = fs;
		pdesc.colorAttachments[0].pixelFormat = wrapper->colorFormat;
		pdesc.depthAttachmentPixelFormat = wrapper->view.depthStencilPixelFormat;
		pdesc.stencilAttachmentPixelFormat = MTLPixelFormatInvalid;
		pdesc.sampleCount = wrapper->view.sampleCount;
		wrapper->pipeline = [dev newRenderPipelineStateWithDescriptor:pdesc error:&err];
	}
}

// Per-frame call from Swift. Will later read drawable size from the view,
// step physics at fixed timestep, and record Metal command buffers in C++.
void FEEngineTick(FEEngineHandle handle, double deltaSeconds) {
	FEEngineWrapper* wrapper = (FEEngineWrapper*)handle;
	if (!wrapper) return;
	// For now, do nothing but forward tick; renderer will come later.
	wrapper->engine->tick(deltaSeconds);

	MTKView* v = wrapper->view;
	if (!v) return;
	MTLRenderPassDescriptor* rpd = v.currentRenderPassDescriptor;
	id<CAMetalDrawable> drawable = v.currentDrawable;
	if (!rpd || !drawable || !wrapper->pipeline || !wrapper->queue) return;

	id<MTLCommandBuffer> cb = [wrapper->queue commandBuffer];
	id<MTLRenderCommandEncoder> enc = [cb renderCommandEncoderWithDescriptor:rpd];
	[enc setRenderPipelineState:wrapper->pipeline];
	[enc drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
	[enc endEncoding];
	[cb presentDrawable:drawable];
	[cb commit];
}

// Destroy and free the wrapper/engine pair.
void FEEngineDestroy(FEEngineHandle handle) {
	FEEngineWrapper* wrapper = (FEEngineWrapper*)handle;
	if (!wrapper) return;
	delete wrapper;
}

void FEEngineAttachLayer(FEEngineHandle handle, void* caMetalLayer) {
	FEEngineWrapper* wrapper = (FEEngineWrapper*)handle;
	if (!wrapper) return;
	// Forward to C++ for future metal-cpp migration
	wrapper->engine->attachCAMetalLayer(caMetalLayer);
}


