#!/usr/bin/env bash
set -euo pipefail

echo "=== Building portfolio ==="
./build_portfolio.sh

echo ""
echo "=== Building blog ==="
./build_blog.sh

echo ""
echo "=== Build complete ==="
