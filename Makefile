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

docker-image:
	docker build -t toucan . -f ./Docker/Dockerfile

# docker run --rm -v $(pwd):/app/site toucan generate /app/site/src /app/site/docs
# docker run --rm -v $(pwd):/app/site toucan generate ./site/src ./site/docs --base-url "http://localhost:3000"
# docker run --rm -v $(pwd):/app/site --entrypoint /app/toucan toucan generate ./site/src ./site/docs --base-url "http://localhost:3000"
# docker run --rm -p 3000:3000 -v $(pwd):/app/site toucan serve --hostname "0.0.0.0" --port 3000 ./site/docs

docker-tests:
	docker build -t toucan-tests . -f ./Docker/Dockerfile.testing && docker run --rm toucan-tests
