import SwiftUI

extension SampleApp.UI.Root {
    struct Splash: Relux.UI.View {
        
        struct Props: Relux.UI.ViewProps { }
        
        let props: Props
        
        var body: some View {
            ProgressView()
                .navigationBarBackButtonHidden()
                .navigationBarHidden(true)
        }
    }
}
