#!/bin/bash

# Get the coverage threshold from argument or default to 90
THRESHOLD=${1:-90}

# Run flutter test with coverage
flutter test --coverage

# Extract the coverage percentage from lcov.info
# LH: lines hit, LF: lines found
LH=$(grep "LH:" coverage/lcov.info | awk -F: '{sum+=$2} END {print sum}')
LF=$(grep "LF:" coverage/lcov.info | awk -F: '{sum+=$2} END {print sum}')

if [ -z "$LF" ] || [ "$LF" -eq 0 ]; then
  echo "No coverage data found."
  exit 1
fi

COVERAGE=$(echo "scale=2; $LH * 100 / $LF" | bc)
echo "Current coverage: $COVERAGE%"

# Comparison using bc
if (( $(echo "$COVERAGE < $THRESHOLD" | bc -l) )); then
  echo "Coverage is below threshold ($THRESHOLD%). Failing..."
  exit 1
else
  echo "Coverage is acceptable!"
fi
