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

    override func loadView() {
        // Create an MTKView backed by the system default device. This view will
        // drive the display loop and provide a CAMetalLayer for presentation.
        self.view = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let view = self.view as? MTKView, let device = view.device else { return }
        self.mtkView = view
        self.commandQueue = device.makeCommandQueue()
        // Basic swapchain / depth configuration and a pleasant clear color.
        view.clearColor = MTLClearColor(red: 0.1, green: 0.12, blue: 0.15, alpha: 1.0)
        view.colorPixelFormat = .bgra8Unorm
        view.depthStencilPixelFormat = .depth32Float
        view.sampleCount = 1
        view.delegate = self
        view.enableSetNeedsDisplay = false
        view.isPaused = false
        view.preferredFramesPerSecond = 60
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // No-op for now. Later we will forward this to the C++ engine so it can
        // recreate size-dependent GPU resources (depth/stencil, uniform rings).
    }

    func draw(in view: MTKView) {
        // Minimal frame: end the encoder immediately and present. This validates
        // that the swapchain is wired correctly and the render loop is running.
        guard let renderPassDescriptor = view.currentRenderPassDescriptor,
              let drawable = view.currentDrawable,
              let commandQueue = self.commandQueue,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }

        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}


