import Testing
@testable import relux_sample

@Suite(.timeLimit(.minutes(1)))
struct NotesTests {
    @Suite
    struct Business {
        @Suite
        struct Saga { }

        @Suite
        struct State { }
    }
    @Suite
    struct UI {
    }
}
