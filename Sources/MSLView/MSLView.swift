import SwiftUI
import MetalKit

#if os(macOS)
/// Shadertoy-style view. Specify a fragment shader (must be named "mainImage") and a struct of constants
/// to pass to the shader. In order to ensure the constants struct is consistent with the MSL version, it's
/// best to include it in a Swift briding header. Constants are bound at position 0, and a uint2 for the view size
/// is bound at position 1.
public struct MSLView<T> : NSViewRepresentable {

    var shader: String?
    var constants: T

    public init(shader: String, constants: T) {
        self.shader = shader
        self.constants = constants
    }
    
    public init(constants: T) {
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
        metalView.enableSetNeedsDisplay = true
        metalView.isPaused = true
        metalView.delegate = context.coordinator.renderer
        if let shader = shader {
            context.coordinator.renderer.setShader(source: shader)
        } else {
            context.coordinator.renderer.setDefaultShader()
        }
        return metalView
    }

    public func updateNSView(_ nsView: NSViewType, context: Context) {
        if let shader = shader {
            context.coordinator.renderer.setShader(source: shader)
        }
        context.coordinator.renderer.constants = constants
        nsView.setNeedsDisplay(nsView.bounds)
    }
}
#else
/// Shadertoy-style view. Specify a fragment shader (must be named "mainImage") and a struct of constants
/// to pass to the shader. In order to ensure the constants struct is consistent with the MSL version, it's
/// best to include it in a Swift briding header. Constants are bound at position 0, and a uint2 for the view size
/// is bound at position 1.
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
        metalView.enableSetNeedsDisplay = true
        metalView.isPaused = true
        metalView.delegate = context.coordinator.renderer
        context.coordinator.renderer.setShader(source: shader)
        return metalView
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {
        context.coordinator.renderer.setShader(source: shader)
        context.coordinator.renderer.constants = constants
        uiView.setNeedsDisplay()
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
        fragment float4 mainImage(FragmentIn input [[stage_in]],
                               constant Constants& c,
                               constant uint2& viewSize) {
            return float4(c.r,
                          input.position.x/viewSize.x,
                          input.position.y/viewSize.y,1);
        }
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
