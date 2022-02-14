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
        var renderer: Renderer<T>

        init(constants: T) {
            renderer = Renderer<T>(device: MTLCreateSystemDefaultDevice()!, constants: constants)
        }
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(constants: constants)
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
        var renderer: Renderer<T>

        init(constants: T) {
            renderer = Renderer<T>(device: MTLCreateSystemDefaultDevice()!, constants: constants)
        }
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(constants: constants)
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

struct TestConstants {
    var r: Float
}

struct TestView: View {

    static let shader = """
        struct Constants {
            float r;
        };
        fragment float4 shader(FragmentIn input [[stage_in]], constant Constants& c) { return float4(c.r,1,1,1); }
        """

    @State var constants = TestConstants(r: 0.0)

    var body: some View {
        VStack {
            MSLView(shader: TestView.shader, constants: constants)
            Slider(value: $constants.r)
        }
    }
}

struct MSLView_Previews: PreviewProvider {

    static var previews: some View {
        TestView()
    }
}
