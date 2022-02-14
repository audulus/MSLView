import Foundation
import MetalKit

class Renderer: NSObject, MTKViewDelegate {

    var device: MTLDevice!
    var queue: MTLCommandQueue!
    var pipeline: MTLRenderPipelineState!
    var source = ""

    static let MaxBuffers = 3
    private let inflightSemaphore = DispatchSemaphore(value: MaxBuffers)

    init(device: MTLDevice) {
        self.device = device
        queue = device.makeCommandQueue()

    }

    func setShader(source: String) {

        if source == self.source {
            return
        }

        self.source = source

        let vertex = """
#include <metal_stdlib>

struct FragmentIn {
    float4 position [[ position ]];
};

constant float2 pos[4] = { {-1,-1}, {1,-1}, {-1,1}, {1,1 } };

vertex FragmentIn __vertex__(uint id [[ vertex_id ]]) {
    FragmentIn out;
    out.position = float4(pos[id], 0, 1);
    return out;
}

"""

        do {
            let library = try device.makeLibrary(source: vertex + source, options: nil)

            let rpd = MTLRenderPipelineDescriptor()
            rpd.vertexFunction = library.makeFunction(name: "__vertex__")
            rpd.fragmentFunction = library.makeFunction(name: "shader")
            rpd.colorAttachments[0].pixelFormat = .bgra8Unorm

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

            let enc = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
            enc.setRenderPipelineState(pipeline)
            enc.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            enc.endEncoding()

            commandBuffer.present(currentDrawable)
        }
        commandBuffer.commit()

    }
}
