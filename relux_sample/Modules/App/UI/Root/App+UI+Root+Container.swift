import SwiftUI

extension SampleApp.UI.Root {
    // ReluxContainer separates the Relux-driven business layer from the SwiftUI view layer.
    struct Container: Relux.UI.Container {
        // In SwiftUI-Relux, the Relux resolver injects all UI states into the root view.
        // If a state conforms to ObservableObject, it’s accessible via @EnvironmentObject.
        // If it’s declared using the @Observable macro, it’s available via @Environment.
        @EnvironmentObject var appRouter: AppRouter
        @Environment(ModalRouter.self) private var modalRouter

        @Environment(\.scenePhase) private var scenePhase
        @EnvironmentObject private var notesState: Notes.UI.State
        @State private var pendingRevocations = 0
        let relux: Relux

        var body: some View {
            content
                // simple way to centralised control of app modals
                .onChange(of: scenePhase) { _, phase in
                    if phase == .background {
                        pendingRevocations += 1
                        notesState.hideProtectedContent()
                        Task {
                            await actions { Notes.Business.Effect.relock(noteId: nil) }
                            notesState.hideProtectedContent()
                            pendingRevocations -= 1
                        }
                    }
                }
                .sheet(item: modalRouter.binding.modalSheet, content: modalPage)
        }

        @ViewBuilder
        private var content: some View {
            // Destroy presentation drafts while background revocation is in flight.
            if scenePhase == .background || pendingRevocations > 0 {
                Color.clear
            } else {
                NavigationStack(path: $appRouter.path) {
                    Notes.UI.List.Container()
                        .navigationDestination(for: AppPage.self, destination: SampleApp.UI.Root.handleRoute)
                }
            }
        }

    }
}

// modal pages
extension SampleApp.UI.Root.Container {
    private func modalPage(for item: Navigation.Business.Model.ModalPage) -> some View {
        Group {
            switch item {
                case .debug: debugModal
            }
        }
        // we have to pass states into env to each modal, due to it's outside of our rootView hierarchy
        .passingObservableToEnvironment(fromStore: relux.store)
    }

    private var debugModal: some View {
        NavigationStack {
            Form {
                Section("Notes data flow") {
                    Text("Container → Effect → Flow → Service → Action → Reducer → UI projection")
                    Text("Views receive values and callbacks. Business state owns the notes; the service uses an in-memory data provider.")
                }
            }
            .navigationTitle("Architecture")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { Task { await actions { ModalRouter.Action.dismiss } } }
                }
            }
        }
    }
}
