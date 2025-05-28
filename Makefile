SHELL=/bin/bash

.PHONY: docker

baseUrl = https://raw.githubusercontent.com/BinaryBirds/github-workflows/refs/heads/main/scripts

check: symlinks language deps lint headers

symlinks:
	curl -s $(baseUrl)/check-broken-symlinks.sh | bash
	
language:
	curl -s $(baseUrl)/check-unacceptable-language.sh | bash
	
deps:
	curl -s $(baseUrl)/check-local-swift-dependencies.sh | bash
	
lint:
	curl -s $(baseUrl)/run-swift-format.sh | bash

format:
	curl -s $(baseUrl)/run-swift-format.sh | bash -s -- --fix

headers:
	curl -s $(baseUrl)/check-swift-headers.sh | bash

fix-headers:
	curl -s $(baseUrl)/check-swift-headers.sh | bash -s -- --fix

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

install:
	./scripts/install-toucan.sh

uninstall:
	./scripts/uninstall-toucan.sh

docker-image:
	docker build -t toucan . -f ./Docker/Dockerfile

docker-image:
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		-t toucan \
		-f ./Docker/Dockerfile \
		--load \
		.

# docker run --rm -v $(pwd):/app/site toucan generate /app/site/src /app/site/docs
# docker run --rm -v $(pwd):/app/site toucan generate ./site/src ./site/docs --base-url "http://localhost:3000"
# docker run --rm -v $(pwd):/app/site --entrypoint /app/toucan toucan generate ./site/src ./site/docs --base-url "http://localhost:3000"
# docker run --rm -p 3000:3000 -v $(pwd):/app/site toucan serve --hostname "0.0.0.0" --port 3000 ./site/docs

docker-tests:
	docker build -t toucan-tests . -f ./Docker/Dockerfile.testing && docker run --rm toucan-tests
