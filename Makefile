.PHONY: format-swift
format-swift:
	swift format . --recursive --in-place 

.PHONY: format-kotlin
format-kotlin:
	ktfmt --enable-editorconfig . 
	
.PHONY: test-swift
test-swift:
	swift test

.PHONY: test-swift-docker
test-swift-docker:
	docker-compose run --rm tests

.PHONY: format-swift-docker
format-swift-docker:
	docker-compose run --rm format

.PHONY: build-kotlin
build-kotlin:
	./gradlew :witness-annotations:publishToMavenLocal :witness-runtime:publishToMavenLocal :witness-processor:publishToMavenLocal

.PHONY: run-ktor
run-ktor:
	cd examples/ktor-server && gradle clean run --no-daemon --refresh-dependencies

.PHONY: build-android
build-android:
	cd examples/android  && gradle clean assembleDebug --refresh-dependencies --no-daemon

.PHONY: build-kotlin-docker
build-kotlin-docker:
	docker-compose run --rm build-kotlin
        
