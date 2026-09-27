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
