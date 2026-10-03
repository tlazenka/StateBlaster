# StateBlaster

StateBlaster is an experimental code-generation framework for describing an application or workflow as a state machine. From that graph, it generates legal transitions, state-handling machinery, and optional UI, navigation, and API plumbing.

The central idea is to make invalid transitions difficult to express. A state declares its outgoing edges, and generated APIs expose only those edges. Authority-based modes go further by representing permission to change state as a move-only capability.

StateBlaster is an early R&D project rather than a stable library. The repository currently explores the same model in Swift and Kotlin.

## How it works

In Swift, define an enum with one initial state and declare the legal transitions from each case:

```swift
import StateBlaster

@StateMachine(mode: .transitionAuthority)
enum OnboardingState {
    @MachineState(initial: true, transitions: ["codeEntry"])
    case phoneEntry

    @MachineState(transitions: ["finished", "error"])
    case codeEntry(phoneNumber: String)

    @MachineState
    case finished

    @MachineState(transitions: ["codeEntry"])
    case error(message: String)
}
```

`@StateMachine` generates `OnboardingStateMachine`. The generated machine:

- identifies the initial and terminal states;
- exposes only the transitions declared for the current state;
- validates state names and associated-value labels at compile time;
- carries matching associated values into destination states; and
- rejects stale state witnesses or witnesses from another machine instance.

Attach the generated machine to a model that owns its current state:

```swift
@StateMachineModel(OnboardingState.self)
final class OnboardingModel {
    typealias Machine = OnboardingStateMachine
    private(set) var state = Machine.initialState()
}
```

In `transitionAuthority` mode, a transition first requires an exact capability for its source and destination:

```swift
guard case .phoneEntry(let witness) = model.state,
      let authority = model.machine.authorizeCodeEntryFromPhoneEntry(using: witness)
else { return }

model.machine.state = .codeEntry(consume authority, phoneNumber: phoneNumber)
```

There is no generated authorization method for an undeclared edge, so an illegal transition fails at compile time. The capability is `~Copyable`, which prevents transition authority from being casually duplicated.

### Swift modes

| Mode | Generated transition model |
| --- | --- |
| `witness` | Copyable state witnesses guard legal transitions and reject stale or foreign witnesses. |
| `transitionAuthority` | A witness authorizes a move-only capability for one exact edge. |
| `scopedStateAuthority` | A move-only state capability is used inside a scoped transition closure. |
| `stateAuthority` | A move-only concrete state is acquired, then consumed by one of its generated transitions. |

## Presentation generation

`@Screen` attaches presentation metadata to a state, including its title, message, SF Symbol, screen kind, fields, actions, conditions, and fallback presentation. Adding `@SwiftUIPresentation` generates descriptors and a SwiftUI presentation layer with navigation, forms, actions, progress and error states.

The onboarding demo is the best complete example:

- [`DemoPackage/Sources/OnboardingShared/Onboarding.swift`](DemoPackage/Sources/OnboardingShared/Onboarding.swift) defines the graph and screen metadata.
- [`DemoPackage/Sources/OnboardingSwiftUI/OnboardingSwiftUI.swift`](DemoPackage/Sources/OnboardingSwiftUI/OnboardingSwiftUI.swift) connects generated state and presentation types to a view model.
- [`DemoPackage/Sources/OnboardingUIKitApp`](DemoPackage/Sources/OnboardingUIKitApp) uses the storyboard build plugin for UIKit.

## Kotlin implementation

The Kotlin implementation uses Kotlin Symbol Processing (KSP) and the same graph-first approach. A sealed hierarchy annotated with `@StateGraph`, `@Initial`, and `@Transition` can generate witnesses, transition authorities, and a state-machine wrapper.

Optional annotations extend that graph into other layers:

- `@ComposeNavigation3` generates Android Navigation 3 integration.
- `@KtorService` with `@KtorServer` or `@KtorClient` generates Ktor server or client plumbing from state operations.

See [`examples/android`](examples/android) and [`examples/ktor-server`](examples/ktor-server) for working declarations and build configuration.

## Repository guide

| Path | Purpose |
| --- | --- |
| `Sources/StateBlaster` | Public Swift macros and runtime support |
| `Sources/StateBlasterMacros` | Swift macro parsing, validation, and code generation |
| `DemoPackage` and `DemoApps` | SwiftUI and UIKit onboarding examples |
| `kotlin-witness-annotations` | Kotlin graph and projection annotations |
| `kotlin-witness-runtime` | Kotlin witness and transition-capability runtime |
| `kotlin-witness-processor` | KSP generators for state machines, Compose, and Ktor |
| `examples/android` | Android/Compose onboarding example |
| `examples/ktor-server` | Ktor server onboarding example |

The Swift package also contains two independent macro experiments: `Do`, for propagating `Result` failures with `#bind`, and `ObservableUserDefaults`, for typed observable preferences. They are separate from the StateBlaster state-machine model.

## Build and test

The Swift package currently requires Swift 6.4:

```sh
swift test
```

To inspect the iOS demos, open one of these projects in Xcode:

```sh
open DemoApps/OnboardingStick/OnboardingStick.xcodeproj
open DemoApps/OnboardingSwiftUI/OnboardingSwiftUI.xcodeproj
open DemoApps/OnboardingStoryboard/OnboardingStoryboard.xcodeproj
```

The Kotlin build requires JDK 17 and Gradle. Build and publish its three modules to Maven Local before building the standalone examples:

```sh
./gradlew \
  :witness-annotations:publishToMavenLocal \
  :witness-runtime:publishToMavenLocal \
  :witness-processor:publishToMavenLocal

(cd examples/ktor-server && gradle run --no-daemon --refresh-dependencies)
(cd examples/android && gradle assembleDebug --no-daemon --refresh-dependencies)
```
