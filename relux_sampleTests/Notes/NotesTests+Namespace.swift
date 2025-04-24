import Testing
@testable import relux_sample

@Suite(.timeLimit(.minutes(1)))
struct NotesTests {
    @Suite
    struct Business {
        @Suite(.serialized)
        struct Saga { }

        @Suite
        struct State { }
    }
    @Suite
    struct UI {
    }
}
