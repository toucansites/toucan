FROM swift:6.1-noble AS build

WORKDIR /build
COPY ./Package.* ./
RUN swift package resolve
COPY Sources ./Sources
COPY Tests ./Tests
COPY Package.swift .
COPY Package.resolved .
RUN swift build -c release --static-swift-stdlib

WORKDIR /staging
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/toucan" ./
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/toucan-generate" ./
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/toucan-init" ./
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/toucan-serve" ./
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/toucan-watch" ./
RUN cp "/usr/libexec/swift/linux/swift-backtrace-static" ./
RUN find -L "$(swift build --package-path /build -c release --show-bin-path)/" -regex '.*\.resources$' -exec cp -Ra {} ./ \;

FROM ubuntu:noble

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get -q install -y tzdata locales curl unzip \
    && ln -fs /usr/share/zoneinfo/UTC /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 \
    && rm -r /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app toucan

WORKDIR /app
COPY --from=build --chown=toucan:toucan /staging /app

# ✅ Ensure all files in /app are executable by all users
RUN chmod -R a+rx /app

ENV SWIFT_BACKTRACE=enable=yes,sanitize=yes,threads=all,images=all,interactive=no,swift-backtrace=./swift-backtrace-static
ENV PATH="/app:$PATH"

USER toucan:toucan

EXPOSE 3000

ENTRYPOINT ["/app/toucan"]
CMD ["--help"]
