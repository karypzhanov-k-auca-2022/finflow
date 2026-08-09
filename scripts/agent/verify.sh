#!/usr/bin/env bash
set -euo pipefail

show_help() {
  command cat <<'USAGE'
Usage: scripts/agent/verify.sh [--analyze] [--all-tests] [test-path ...]

Examples:
  scripts/agent/verify.sh test/bloc/transactions_bloc_test.dart
  scripts/agent/verify.sh --analyze test/repository/transaction_repository_test.dart
  scripts/agent/verify.sh --analyze --all-tests

The script intentionally does nothing without an explicit test target or flag.
USAGE
}

analyze=false
all_tests=false
test_targets=()

while (($# > 0)); do
  case "$1" in
    --analyze)
      analyze=true
      ;;
    --all-tests)
      all_tests=true
      ;;
    --help|-h)
      show_help
      exit 0
      ;;
    --*)
      command echo "Unknown option: $1" >&2
      show_help >&2
      exit 2
      ;;
    *)
      test_targets+=("$1")
      ;;
  esac
  shift
done

if ! $analyze && ! $all_tests && ((${#test_targets[@]} == 0)); then
  show_help >&2
  exit 2
fi

if ! command -v fvm >/dev/null 2>&1; then
  command echo "FVM is required but was not found. Install FVM, then run 'fvm install' for the SDK pinned in .fvmrc." >&2
  exit 127
fi

flutter_cmd=(fvm flutter)

if $analyze; then
  command echo "==> flutter analyze"
  "${flutter_cmd[@]}" analyze
fi

if $all_tests; then
  command echo "==> flutter test"
  "${flutter_cmd[@]}" test
elif ((${#test_targets[@]} > 0)); then
  command echo "==> flutter test ${test_targets[*]}"
  "${flutter_cmd[@]}" test "${test_targets[@]}"
fi
