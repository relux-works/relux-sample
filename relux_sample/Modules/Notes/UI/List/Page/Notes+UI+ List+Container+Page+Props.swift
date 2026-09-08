import SwiftUIRelux

extension Notes.UI.List.Container.Page {
    struct Props: Relux.UI.ViewProps {
        let notes: MaybeData<[[Note]], Err>
        var errorMessage: String? = nil

        func groups(matching search: String) -> [[Note]] {
            let query = search.trimmingCharacters(in: .whitespacesAndNewlines)
            return (notes.value ?? []).map { group in
                group.filter { query.isEmpty || $0.title.localizedStandardContains(query) ||
                    $0.content.localizedStandardContains(query) }
            }.filter { !$0.isEmpty }
        }
    }

    struct Actions: Relux.UI.ViewCallbacks {
        let onReload: ViewCallback<Void>
        let onCreate: ViewCallback<Void>
        let onOpen: ViewInputCallback<Note.Id>
        let onRemove: ViewInputCallback<Note>
    }
}
