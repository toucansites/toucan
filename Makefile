SHELL=/bin/bash

.PHONY: docker

build:
	swift build

release:
	swift build -c release
	
test:
	swift test --parallel

test-with-coverage:
	swift test --parallel --enable-code-coverage

clean:
	rm -rf .build

check:
	./scripts/run-checks.sh

format:
	./scripts/run-swift-format.sh --fix

install:
	./scripts/install-toucan.sh

uninstall:
	./scripts/uninstall-toucan.sh

docker:
	docker build -t toucan-image . -f ./Docker/Dockerfile.ubuntu && docker run --rm toucan-image