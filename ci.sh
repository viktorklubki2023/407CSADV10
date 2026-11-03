#!/usr/bin/env bash
set -euo pipefail

mkdir -p dist
cargo build --release
cargo test --release
cp target/release/hello dist/
