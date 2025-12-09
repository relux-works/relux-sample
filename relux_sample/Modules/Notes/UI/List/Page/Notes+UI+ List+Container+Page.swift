import SwiftUI

extension Notes.UI.List.Container {
    struct Page: View {
        typealias Note = Notes.Business.Model.Note
        typealias Err = Notes.Business.Err

        let props: Props
        let actions: Actions

        var body: some View {
            content
                .navigationTitle("Notes")
                .navigationBarTitleDisplayMode(.large)
                .navigationBarItems(trailing: createBtn)
                .animation(.easeInOut, value: props.notes.asAnimatableValue)
                .animation(.easeInOut, value: props.notes.value?.flatCount)
                .refreshable(action: actions.onReload)
        }
    }
}

// header
extension Notes.UI.List.Container.Page {
    private var createBtn: some View {
        NavBarBtn.iconBtn(
            systemName: "plus",
            action: actions.onCreate
        )
    }
}

// subviews
extension Notes.UI.List.Container.Page {
    private var content: some View {
        List {
            listView(for: props.notes.value)
        }.overlay(content: loadingState)
    }

    @ViewBuilder
    private func loadingState() -> some View {
        switch props.notes {
            case .initial: initialView
            case .failure: failureView
            case let .success(notes): switch notes.isNotEmpty {
                case false: emptyListView
                case true: EmptyView()
            }
        }
    }
}

// loading overlays
extension Notes.UI.List.Container.Page {
    private var initialView: some View {
        ProgressView("Loading...")
            .extendingContent()
    }

    private var failureView: some View {
        Text("Failed to load")
            .extendingContent()
    }

    private var emptyListView: some View {
        Text("No notes yet...")
            .extendingContent()
    }
}

// list content
extension Notes.UI.List.Container.Page {
    @ViewBuilder
    private func listView(for noteGroups: [[Note]]?) -> some View {
        switch noteGroups {
            case .none: EmptyView()
            case let .some(groups): noteGroupsView(for: groups)
        }
    }

    @ViewBuilder
    private func noteGroupsView(for noteGroups: [[Note]]) -> some View {
        ForEach(noteGroups, id: \.id) { group in
            notesGroupSection(for: group)
        }
    }

    private func notesGroupSection(for group: [Note]) -> some View {
        Section(header: notesGroupSectionHeader(for: group.first?.createdAt ?? .now)) {
            ForEach(group) { note in
                noteRow(for: note)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) { removeSwipeAction(for: note) }
            }
        }
    }

    private func removeSwipeAction(for note: Note) -> some View {
        SwipeButton(
            props: .init(
                icon: Image(systemName: "trash"),
                tint: .red
            ),
            actions: .init(
                action: { await onRemove(note) }
            )
        )
    }

    private func notesGroupSectionHeader(for date: Date = .now) -> some View {
        Text(date.formatted(dateFormat: .dateAsDDMMMM))
    }

    private func noteRow(for note: Note) -> some View {
        Relux.NavigationLink(page: .app(page: .notes(.details(id: note.id)))) {
            noteRowContent(for: note)
        }
    }

    private func noteRowContent(for note: Note) -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .bottom) {
                Text(note.title)
                Spacer()
                Text(note.createdAt.formatted(date: .omitted, time: .shortened))
            }
            Text(note.content)
                .lineLimit(2)
        }
    }
}

// reactions
extension Notes.UI.List.Container.Page {
    private func onRemove(_ note: Note) async {
        await actions.onRemove(note)
    }
}

// utils
extension Array<Notes.Business.Model.Note> {
    public var id: Date? { self.first?.createdAt.startOfDay }
}
