import SwiftUI
import MetalKit

#if os(macOS)
public struct MSLView<T> : NSViewRepresentable {

    var shader: String
    var constants: T

    public init(shader: String, constants: T) {
        self.shader = shader
        self.constants = constants
    }

    public class Coordinator {
        var renderer = Renderer<T>(device: MTLCreateSystemDefaultDevice()!)
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    public func makeNSView(context: Context) -> some NSView {
        let metalView = MTKView(frame: CGRect(x: 0, y: 0, width: 1024, height: 768),
                                device: MTLCreateSystemDefaultDevice()!)
        metalView.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        metalView.delegate = context.coordinator.renderer
        context.coordinator.renderer.setShader(source: shader)
        return metalView
    }

    public func updateNSView(_ nsView: NSViewType, context: Context) {
        context.coordinator.renderer.setShader(source: shader)
    }
}
#else
public struct MSLView<T> : UIViewRepresentable {

    var shader: String
    var constants: T

    public init(shader: String, constants: T) {
        self.shader = shader
        self.constants = constants
    }

    public class Coordinator {
        var renderer = Renderer<T>(device: MTLCreateSystemDefaultDevice()!)
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    public func makeUIView(context: Context) -> some UIView {
        let metalView = MTKView(frame: CGRect(x: 0, y: 0, width: 1024, height: 768),
                                device: MTLCreateSystemDefaultDevice()!)
        metalView.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        metalView.delegate = context.coordinator.renderer
        context.coordinator.renderer.setShader(source: shader)
        return metalView
    }

    public func updateUIView(_ nsView: UIViewType, context: Context) {
        context.coordinator.renderer.setShader(source: shader)
    }

}
#endif

struct MSLView_Previews: PreviewProvider {

    static let shader = """
        fragment float4 shader(FragmentIn input [[stage_in]]) { return float4(0,1,1,1); }
        """

    static var previews: some View {
        MSLView(shader: shader, constants: [])
    }
}
