import SwiftUI
import MetalKit

#if os(macOS)
public struct MSLView : NSViewRepresentable {

    var shader: String
    var constants: [Any]

    public class Coordinator {
        var renderer = Renderer(device: MTLCreateSystemDefaultDevice()!)
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    public func makeNSView(context: Context) -> some NSView {
        let metalView = MTKView(frame: CGRect(x: 0, y: 0, width: 1024, height: 768),
                                device: MTLCreateSystemDefaultDevice()!)
        metalView.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        metalView.delegate = context.coordinator.renderer
        return metalView
    }

    public func updateNSView(_ nsView: NSViewType, context: Context) {
    }
}
#else
public struct MSLView : UIViewRepresentable {

    var shader: String
    var constants: [Any]

    public class Coordinator {
        var renderer = Renderer(device: MTLCreateSystemDefaultDevice()!)
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    public func makeUIView(context: Context) -> some UIView {
        let metalView = MTKView(frame: CGRect(x: 0, y: 0, width: 1024, height: 768),
                                device: MTLCreateSystemDefaultDevice()!)
        metalView.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        metalView.delegate = context.coordinator.renderer
        return metalView
    }

    public func updateUIView(_ nsView: UIViewType, context: Context) {

    }

}
#endif

struct MSLView_Previews: PreviewProvider {

    static let shader = """
        fragment float4 main(FragmentIn input [[stage_in]]) { return float4(0,1,1,1); }
        """

    static var previews: some View {
        MSLView(shader: shader, constants: [])
    }
}
