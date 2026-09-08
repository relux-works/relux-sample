import AuthReluxInt
import SwiftUI
import SwiftUIRelux

extension Auth.UI.LocalAuth.Container {
    struct Page: Relux.UI.View {
        let props: Props
        let actions: Actions

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Image(systemName: "lock.shield").font(.largeTitle).foregroundStyle(.tint).accessibilityHidden(true)
                    Text("Your Local Session").font(.largeTitle).bold()
                    Text("Use system authentication to open the demo. Your notes stay on this device, in memory, until the app restarts.")
                        .foregroundStyle(.secondary)
                    AsyncButton(action: actions.onTryLocalAuth) {
                        Label("Unlock Demo", systemImage: "lock.open")
                    }
                    .buttonStyle(.borderedProminent)
                    Text("If authentication is canceled, you can try again here.").font(.footnote).foregroundStyle(.secondary)
                }
                .frame(maxWidth: 520, alignment: .leading).padding(24)
            }
            .navigationTitle("Welcome")
        }
    }
}
