#!/usr/bin/env bash
# Fallback test runner that does not require Ant. Prefer: ant test
# Usage: ./run-tests.sh [path/to/test_data.osm]
#
# Exit 0 = harness ran successfully (findings in the data are expected).
# Non-zero = harness itself crashed.

set -euo pipefail

JOSM="../../josm/core/dist/josm-custom.jar"
TEST_DATA="${1:-test/test_data.osm}"

cd "$(dirname "$0")"

mkdir -p build build-test

echo "Compiling plugin..." >&2
javac -cp "$JOSM" -d build --release 11 \
    $(find src -name '*.java')

echo "Compiling test harness..." >&2
javac -cp "$JOSM:build" -d build-test --release 11 test/RunTests.java

echo "Running tests against $TEST_DATA..." >&2
java -cp "$JOSM:build:build-test" \
    -Djava.awt.headless=true \
    RunTests "$TEST_DATA"
