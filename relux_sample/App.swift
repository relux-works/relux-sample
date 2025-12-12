@_exported import Relux
@_exported import ReluxRouter
@_exported import SwiftUIRelux
@_exported import NavigationReluxImpl

import AuthModels
import AuthReluxInt
import SwiftUI
import SwiftUIRelux
import Logging
import NotesUIAPI

@main
struct SampleApp: App {
    
    
    //todo: sample usage of temporal states from other modules
    static var relux: Relux {
        get async { await Registry.ioc.waitForResolve(Relux.self) }
    }

    private let notesUIProvider: any NotesUIProviding

    init() {
        Registry.configure()
        self.notesUIProvider = Registry.resolve(NotesUIProviding.self)
    }

    var body: some Scene {
        WindowGroup {
            Relux.Resolver(
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
        SampleApp.UI.Root.Container(relux: relux)
            .environment(\.notesUIProvider, notesUIProvider)
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
