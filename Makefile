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

format:
	swift-format -i -r ./Sources && swift-format -i -r ./Tests

lint:
	swift-format lint -r ./Sources && swift-format lint -r ./Tests
