import SwiftUI

extension SampleApp.UI.Root {
    struct Splash: View {
        var body: some View {
            ProgressView()
                .navigationBarBackButtonHidden()
                .navigationBarHidden(true)
        }
    }
}
