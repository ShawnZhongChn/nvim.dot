#!/usr/bin/env bash
set -euo pipefail

# Install the Java toolchain used by this Neovim config's JDTLS setup.
#
# This script is intentionally opt-in: run it manually after reviewing it.
# It installs SDKMAN when missing, then installs a Java 21 runtime and Maven.
# Override versions with:
#   SDKMAN_JAVA_VERSION=21.0.8-tem SDKMAN_MAVEN_VERSION=3.9.11 ./scripts/setup_java_sdkman.sh

JAVA_VERSION="${SDKMAN_JAVA_VERSION:-21.0.8-tem}"
MAVEN_VERSION="${SDKMAN_MAVEN_VERSION:-}"
SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required to install SDKMAN." >&2
  exit 1
fi

if [ ! -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]; then
  echo "SDKMAN not found at $SDKMAN_DIR. Installing SDKMAN..."
  curl -s "https://get.sdkman.io" | bash
fi

# SDKMAN's init script expects several optional variables to be unsettable.
# Temporarily disable nounset while sourcing it, then restore strict mode.
set +u
# shellcheck source=/dev/null
source "$SDKMAN_DIR/bin/sdkman-init.sh"
set -u

echo "Installing Java $JAVA_VERSION via SDKMAN..."
set +u
sdk install java "$JAVA_VERSION" || sdk use java "$JAVA_VERSION"
sdk default java "$JAVA_VERSION"

if [ -n "$MAVEN_VERSION" ]; then
  echo "Installing Maven $MAVEN_VERSION via SDKMAN..."
  sdk install maven "$MAVEN_VERSION" || sdk use maven "$MAVEN_VERSION"
  sdk default maven "$MAVEN_VERSION"
else
  echo "Installing latest Maven via SDKMAN..."
  sdk install maven || true
fi
set -u

echo "Java toolchain setup complete. Restart your shell or source SDKMAN before starting Neovim."
java -version
mvn -version
