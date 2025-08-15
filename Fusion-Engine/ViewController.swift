//
//  ViewController.swift
//  Fusion-Engine
//
//  Created by Kelvin Reid on 8/15/25.
//

import Cocoa
import MetalKit

final class MetalViewController: NSViewController, MTKViewDelegate {
    private var mtkView: MTKView!
    private var commandQueue: MTLCommandQueue?
    private var engineHandle: FEEngineHandle?
    private var lastFrameTime: CFTimeInterval?

    override func loadView() {
        // Create an MTKView backed by the system default device. This view will
        // drive the display loop and provide a CAMetalLayer for presentation.
        self.view = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let view = self.view as? MTKView, let device = view.device else { return }
        self.mtkView = view
        // Command queue is no longer needed on the Swift side since rendering
        // is handled inside the Objective-C++ bridge.
        self.commandQueue = nil
        // Basic swapchain / depth configuration and a pleasant clear color.
        view.clearColor = MTLClearColor(red: 0.1, green: 0.12, blue: 0.15, alpha: 1.0)
        view.colorPixelFormat = .bgra8Unorm
        view.depthStencilPixelFormat = .depth32Float
        view.sampleCount = 1
        view.delegate = self
        view.enableSetNeedsDisplay = false
        view.isPaused = false
        view.preferredFramesPerSecond = 60

        // Create the C++ engine through the bridge. We pass the MTKView pointer
        // as an opaque value for now; the bridge keeps a weak reference.
        self.engineHandle = FEEngineCreate(Unmanaged.passUnretained(view).toOpaque())
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // No-op for now. Later we will forward this to the C++ engine so it can
        // recreate size-dependent GPU resources (depth/stencil, uniform rings).
        FEEngineResize(self.engineHandle, Int32(size.width), Int32(size.height))
    }

    func draw(in view: MTKView) {
        // Minimal frame: end the encoder immediately and present. This validates
        // that the swapchain is wired correctly and the render loop is running.
        let now = CACurrentMediaTime()
        let dt: CFTimeInterval
        if let last = lastFrameTime {
            dt = now - last
        } else {
            dt = 1.0 / 60.0
        }
        lastFrameTime = now
        FEEngineTick(self.engineHandle, dt)

        // Rendering and presentation are performed in the engine bridge to
        // avoid double-presenting the drawable.
        return
    }
}



