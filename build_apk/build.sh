#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$SCRIPT_DIR/apk_done"
KEYSTORE="$HOME/.android/debug.keystore"

echo "=== Build APK ==="
echo ""

# Check keystore
if [ ! -f "$KEYSTORE" ]; then
    echo "ERROR: debug keystore not found at $KEYSTORE"
    echo "Run Android Studio at least once or create one with:"
    echo "  keytool -genkey -v -keystore ~/.android/debug.keystore -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 -storepass android -keypass android"
    exit 1
fi

# Clean output
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

cd "$PROJECT_DIR"

# Android SDK
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}"

# Build APK
echo "[1/3] Building AssistantDismiss..."
./gradlew :app:assembleRelease --quiet --no-configuration-cache

# Find APK
APK=$(find app/build/outputs/apk/release -name "*.apk" | head -1)

if [ -z "$APK" ]; then
    echo "ERROR: APK not found"
    exit 1
fi

# Sign APK
echo "[2/3] Signing APK..."
APKSIGNER="$ANDROID_HOME/build-tools/34.0.0/apksigner"
if [ ! -f "$APKSIGNER" ]; then
    APKSIGNER=$(find "$ANDROID_HOME/build-tools" -name "apksigner" | sort -V | tail -1)
fi
if [ -z "$APKSIGNER" ] || [ ! -f "$APKSIGNER" ]; then
    echo "ERROR: apksigner not found in $ANDROID_HOME/build-tools/"
    exit 1
fi
"$APKSIGNER" sign --ks "$KEYSTORE" --ks-pass pass:android --ks-key-alias androiddebugkey --key-pass pass:android "$APK"

# Copy to output
echo "[3/3] Copying APK..."
cp "$APK" "$OUTPUT_DIR/AssistantDismiss.apk"

echo ""
echo "=== Done! ==="
echo ""
echo "APK ready in: $OUTPUT_DIR/"
echo "  - AssistantDismiss.apk"
echo ""
echo "To install:"
echo "  adb install -r $OUTPUT_DIR/AssistantDismiss.apk"
