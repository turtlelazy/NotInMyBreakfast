#!/bin/bash

# NotInMyBreakfast Deep Link Test Script
# Usage: ./test_deeplinks.sh

echo "NotInMyBreakfast Deep Link Tester"
echo "===================================="
echo ""
echo "Make sure the app is running in the simulator first!"
echo ""

sleep 2

echo "Testing Home..."
xcrun simctl openurl booted "notinmybreakfast://home"
sleep 3

echo "Testing Blacklist..."
xcrun simctl openurl booted "notinmybreakfast://blacklist"
sleep 3

echo "Testing History..."
xcrun simctl openurl booted "notinmybreakfast://history"
sleep 3

echo "Testing Scan with barcode..."
xcrun simctl openurl booted "notinmybreakfast://scan?barcode=737628064502"
sleep 3

echo ""
echo "All tests complete!"
echo ""
echo "To test cold-start:"
echo "1. Force quit the app in simulator"
echo "2. Run: xcrun simctl openurl booted 'notinmybreakfast://scan?barcode=123456'"
echo "3. App should launch and navigate to scan view"
