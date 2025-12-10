@_exported import Relux
@_exported import ReluxRouter
@_exported import SwiftUIRelux

import AuthModels
import AuthReluxInt
import SwiftUI
import SwiftUIRelux
import Logging
import NotesUIAPI

@main
struct SampleApp: App {
    static var relux: Relux {
        get async { await Registry.ioc.waitForResolve(Relux.self) }
    }

    private let notesUIProvider: any NotesUIProviding
    private let notesNavigation: any NotesUIRouting

    init() {
        // configures the IoC container.
        Registry.configure()

        self.notesUIProvider = Registry.resolve(NotesUIProviding.self)
        self.notesNavigation = Registry.resolve(NotesUIRouting.self)
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
            .environment(\.notesUIProvider, notesUIProvider)
            .environment(\.notesNavigation, notesNavigation)
            .task { await setupAppContext() }
    }

    private func resolveModules() async -> Relux {
        await Registry.resolveAsync(Relux.self)
    }

    // for now our Relux modules are successfully resolved
    // we can start set our app context
    // for instance, define is user authorised or not, what kind of flow we should present at first etz.
    private func setupAppContext() async {
        await actions(.concurrently) {
            SampleApp.Business.Effect.setAppContext
            Auth.Business.Effect.obtainAvailableBiometryType
        }
    }
}
