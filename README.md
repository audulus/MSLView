# MSLView

![build status](https://github.com/audulus/MSLView/actions/workflows/build.yml/badge.svg)
<img src="https://img.shields.io/badge/SPM-5.3-blue.svg?style=flat"
     alt="Swift Package Manager (SPM) compatible" />

SwiftUI view for Shadertoy-style MSL shaders

```Swift
import MSLView

struct Constants {
    var r: Float
}

struct ContentView: View {

    @State var constants = Constants(r: 0)
    let shader = """
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
