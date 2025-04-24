relux-sample

A sample project showcasing the use of Relux — a Redux-inspired, async-first architecture written purely in Swift.

🔧 Tech Stack
	•	Language: Swift 6
	•	Architecture: Unidirectional data flow (Redux-like)
	•	Navigation: Built using the same action-based flow
	•	IoC: Asynchronous dependency injection (SwiftIoC)
	•	UI: SwiftUI with extras via SwiftUI-Relux

📦 Core Concepts

📚 Modular Namespaces

Each module is organized using enum-based namespaces like SampleApp.UI.Root, Auth.UI, Notes.UI, Account.UI, Navigation.UI. This keeps things scoped, clean, and scalable.

🔁 Redux-Like Flow

This project leverages the Relux engine to implement a predictable and structured data flow:
	•	State → single source of truth
	•	Relux.State: base protocol
	•	HybridState: for simple local UI/business states
	•	BusinessState + UIState: used when you need separation or reuse of logic across UIs
	•	Action → intent from user/system
	•	Typed enums conforming to Relux.Action
	•	Reducer → async state mutation
	•	Implemented as mutating func reduce(action: Action) async
	•	Not a pure function — it mutates self and can perform async work
	•	Saga → asynchronous side effects
	•	Powered by async/await
	•	Great for API calls, timers, async workflows
	•	Effect → triggers for logic outside the store
	•	Conform to Relux.Effect
	•	Used as internal signals in sagas to start external behavior (analytics, push, etc.)

Relux is entirely built on top of Swift Concurrency and supports structured concurrency. Everything — from effects to reducers — is async and safe.

🧭 Navigation via Redux

Navigation is state-driven and controlled via actions:
	•	Deep links are actions
	•	Navigation is inspectable and testable
	•	Supports both iOS 16 (via backport) and native iOS 17 navigation stacks

📌 Two ways to navigate:

1. View modifier style:

Text("Go to Profile")
    .navigate(to: .profile)

2. With Relux.NavigationLink:

Relux.NavigationLink(page: .profile) {
    Text("Profile")
}

Under the hood it’s an AsyncButton that prevents double taps during transition.

🧵 Async Redux + Async IoC

Everything in Relux is async — reducers, effects, sagas, and IoC:
	•	Uses await-based resolution
	•	Supports .container and .transient lifecycles
	•	Thread-safe with built-in locking

🧼 SwiftUI Integration with SwiftUI-Relux
	•	Relux.Resolver wraps your splash and root view and resolves Relux instance asynchronously
	•	Injects ObservableObject instances from store into environment
	•	Supports Container protocol and .navigate(to:) modifier

Example:

Relux.Resolver(
    splash: {
        SplashScreenView()
    },
    content: { relux in
        SampleApp.UI.Root.Container()
            .passingObservableToEnvironment(fromStore: relux.store)
    },
    resolver: {
        await Relux.Registry.resolve(Relux.self)
    }
)

☂️ swiftui-relux Umbrella Package

Adds SwiftUI-friendly helpers:
	•	Relux.Resolver for async bootstrap
	•	.passingObservableToEnvironment() for UI injection
	•	Container protocol for entry points

📁 Project Structure

Modules/
  SampleApp/           — root app module (Root + Main UI)
  Auth/                — authentication screen
  Account/             — account management
  Notes/               — notes feature
  Navigation/          — navigation layer
  Logger/              — action logger
Utils/                 — helpers and extensions (GCD, Sequence, etc.)

🧩 Dependencies
	•	darwin-relux
	•	swift-ioc
	•	swiftui-relux
	•	swiftui-reluxrouter

Additional dependencies
	•	darwin-foundationplus
	•	darwin-logger
	•	swift-algorithms
	•	swift-stdlibplus
	•	swiftui-plus

🪪 License MIT
*Authors*
• Alexis Grigorev
• Artem Grishchenko

