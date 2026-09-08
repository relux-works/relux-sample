@_exported import Relux
@_exported import ReluxRouter
@_exported import SwiftUIRelux

import SwiftUI
import SwiftUIRelux
import Logging

@main
struct SampleApp: App {
    static var relux: Relux {
        get async { await Registry.ioc.waitForResolve(Relux.self) }
    }

    init() {
        // configures the IoC container.
        Registry.configure()
    }

    var body: some Scene {
        WindowGroup {
            // resolvedRelux also propagates Relux States into Root view Environment
            // and access them can be reached with EnvironmentObject or Environment in view hierarchy
            // it depends on your choice to use ObservableObject or @Observable macros for state
            // under the hood passingObservableToEnvironment supports both ways
            Relux.Resolver(
                // simple splash view without any Relux interactions
                splash: splash,
                content: appContent,
                resolver: resolveModules
            )
        }
    }

    private func splash() -> some View {
        SampleApp.UI.Root.Splash(props: UI.Root.Splash.Props())
    }

    private func appContent(relux: Relux) -> some View {
        // now relux is ready, we can use it strait forward
        SampleApp.UI.Root.Container(relux: relux)

    }

    private func resolveModules() async -> Relux {
        await Registry.resolveAsync(Relux.self)
    }

}
