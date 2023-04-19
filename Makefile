build:
	swift build

update:
	swift package update

release:
	swift build -c release
	
test:
	swift test --parallel

clean:
	rm -rf .build

install: release
	install ./.build/release/toucan /usr/local/bin/toucan

uninstall:
	rm /usr/local/bin/toucan

# swift-format commands

format:
	@curl -s https://raw.githubusercontent.com/BinaryBirds/swift-format-template/main/config.json >> swift-format.json && \
	swift-format --configuration swift-format.json -i -r ./Sources && \
	swift-format --configuration swift-format.json -i -r ./Tests && \
	rm -f ./swift-format.json

lint:
	@curl -s https://raw.githubusercontent.com/BinaryBirds/swift-format-template/main/config.json >> swift-format.json && \
	swift-format lint --configuration swift-format.json -r ./Sources && \
	swift-format lint --configuration swift-format.json -r ./Tests && \
	rm -f ./swift-format.json