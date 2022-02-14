import Foundation
import MetalKit

class Renderer: NSObject, MTKViewDelegate {

    var device: MTLDevice!
    var queue: MTLCommandQueue!
    var pipeline: MTLRenderPipelineState!

    static let MaxBuffers = 3
    private let inflightSemaphore = DispatchSemaphore(value: MaxBuffers)

    init(device: MTLDevice) {
        self.device = device
        queue = device.makeCommandQueue()

    }

    func setShader(source: String) {

        do {
            let library = try device.makeLibrary(source: source, options: nil)

            let rpd = MTLRenderPipelineDescriptor()
            rpd.vertexFunction = library.makeFunction(name: "__vertex__")
            rpd.fragmentFunction = library.makeFunction(name: "main")
            rpd.colorAttachments[0].pixelFormat = .rgba8Unorm

            pipeline = try device.makeRenderPipelineState(descriptor: rpd)

        } catch let error {
            print("Error: \(error)")
        }
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

    }

    func draw(in view: MTKView) {

        let size = view.frame.size
        let w = Float(size.width)
        let h = Float(size.height)
        // let scale = Float(view.contentScaleFactor)

        if w == 0 || h == 0 {
            return
        }

        // use semaphore to encode 3 frames ahead
        _ = inflightSemaphore.wait(timeout: DispatchTime.distantFuture)

        let commandBuffer = queue.makeCommandBuffer()!

        let semaphore = inflightSemaphore
        commandBuffer.addCompletedHandler { _ in
            semaphore.signal()
        }


        if let renderPassDescriptor = view.currentRenderPassDescriptor, let currentDrawable = view.currentDrawable {

            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)


            commandBuffer.present(currentDrawable)
        }
        commandBuffer.commit()

    }
}
