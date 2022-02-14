# MSLView
SwiftUI view for Shadertoy-style MSL shaders

```Swift
struct Constants {
    var r: Float
}

struct ContentView: View {

    @State var constants = Constants(r: 0)
    let shader = """
        struct Constants {
            float r;
        };
        fragment float4 shader(FragmentIn input [[stage_in]],
                               constant Constants& c,
                               constant uint2& viewSize) {
            return float4(c.r,
                          input.position.x/viewSize.x,
                          input.position.y/viewSize.y,1);
        }
        """

    var body: some View {
        VStack {
            MSLView(shader: shader, constants: constants)
            HStack {
                Slider(value: $constants.r)
                Text("\(constants.r)")
            }.padding()
        }
    }

}
```
