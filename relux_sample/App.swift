@_exported import Algorithms
@_exported import FoundationPlus
@_exported import Logger
@_exported import Relux
@_exported import ReluxRouter
@_exported import SwiftPlus
@_exported import SwiftUIPlus
@_exported import SwiftUIRelux

import SwiftUI
import SwiftUIRelux

@main
struct SampleApp: App {
    init() {
        // configuring IoC container
        Registry.configure()
    }

    var body: some Scene {
        WindowGroup {
            // simple splash view without any Relux interactions
            SampleApp.UI.Root.Splash()
                // resolvedRelux also propagates Relux States into Root view Environment
                // and access them can be reached with EnvironmentObject or Environment in view hierarchy
                // it depends on your choice to use ObservableObject or @Observable macros for state
                // under the hood passingObservableToEnvironment supports both ways
                .resolvedRelux(
                    content: appContent,
                    resolver: resolveModules
                )
        }
    }

    private func appContent(relux: Relux) -> some View {
        // now relux is ready, we can use it strait forward
        SampleApp.UI.Root.Container()
            .task { await setupAppContext() }
    }

    private func resolveModules() async -> Relux {
        await Registry.resolveAsync(Relux.self)
    }

    private func setupAppContext() async {
        await actions(.concurrently) {
            SampleApp.Business.Effect.setAppContext
            Auth.Business.Effect.obtainAvailableBiometryType
        }
    }
}
