#!/bin/bash
# Clean test runner that filters out verbose LiveView duplicate ID warnings

echo "Running tests with clean output..."
mix test 2>&1 | \
  grep -v -E "(We can't find the internet|Attempting to reconnect|Something went wrong|Hang in there)" | \
  grep -v -E "(LiveView requires that all elements have unique ids|duplicate IDs will cause)" | \
  grep -v -E "(undefined behavior at runtime|DOM patching will not be able)" | \
  grep -v -E "(You can change this to raise|passing.*on_error.*raise)" | \
  grep -v -E "(Phoenix\.LiveViewTest\.live)" | \
  sed '/warning: Duplicate id found while testing LiveView:/,/^$/d'