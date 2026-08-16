# Cloud Agent base image for SMARA Account (Flutter).
#
# Bakes the pinned Flutter SDK and the OS packages needed to fetch
# dependencies and run the repo's canonical checks (dart format,
# flutter analyze, flutter test) into the image. Repository dependency
# resolution (`flutter pub get`) runs in the `install` phase after the
# source is checked out (see environment.json).
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
# Keep in sync with .github/workflows/flutter-ci.yml and pubspec.yaml.
ENV FLUTTER_VERSION=3.44.6
ENV FLUTTER_HOME=/opt/flutter
ENV PATH=/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:$PATH

# Minimal toolchain for the Flutter test/analyze workflow. git and curl
# are required in fully custom images; the rest are Flutter's documented
# Linux prerequisites.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        unzip \
        xz-utils \
        zip \
        libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Pinned Flutter SDK. Extracted, not cloned, so the image matches the
# exact stable release the CI uses.
RUN curl -fsSL -o /tmp/flutter.tar.xz \
        "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    && tar -xf /tmp/flutter.tar.xz -C /opt \
    && rm /tmp/flutter.tar.xz \
    && git config --system --add safe.directory /opt/flutter \
    && chown -R ubuntu:ubuntu /opt/flutter

USER ubuntu

# Warm the SDK: precache host (Linux) engine artifacts including the
# headless flutter_tester used by `flutter test`, and disable analytics
# so setup stays non-interactive.
RUN flutter config --no-analytics \
    && flutter precache --universal \
    && flutter --version
