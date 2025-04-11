import SwiftUI

extension SampleApp.UI.Main {
    struct Container: Relux.UI.Container {
        var body: some View {
            content
                .navBar(trailing: accountBtn)
                .navigationBarHidden(true)
        }

        private var content: some View {
            ScrollView {
                VStack {
                    Spacer()
                    Text("Main")
                    Spacer()
                }
            }
        }

        private var accountBtn: some View {
            Relux.NavigationLink(page: .app(page: .account)) {
                Text("Account")
            }.padding(.horizontal)
        }
    }
}
