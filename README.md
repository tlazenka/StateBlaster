How-to/`.zsh_history` dump

## Swift/macOS/iOS

`swift test`

`swift format . --recursive --in-place`

`open ./DemoApps/OnboardingStick/OnboardingStick.xcodeproj/`
`open ./DemoApps/OnboardingSwiftUI/OnboardingSwiftUI.xcodeproj/`
`open ./DemoApps/OnboardingStoryboard/OnboardingStoryboard.xcodeproj/`

## Kotlin/Ktor/Android

`rm -rf ~/.m2/repository/com/stateblaster/`

`ls -al ~/.m2/repository/com/stateblaster`

```
./gradlew \
  :witness-annotations:publishToMavenLocal \
  :witness-runtime:publishToMavenLocal \
  :witness-processor:publishToMavenLocal
```
  
`ls -al ~/.m2/repository/com/stateblaster`
  
```
cd examples/ktor-server && \
  gradle clean run --no-daemon \
      --refresh-dependencies
```
  
```
cd examples/android  && \
  gradle clean assembleDebug \
    --refresh-dependencies \
    --no-daemon
```
