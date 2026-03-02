# Assistant Dismiss

Accessibility service that auto-dismisses the Google Assistant bubble when YouTube Music ReVanced starts playing.

## The problem

When you say **"Hey Google, play [song]"**, YouTube Music ReVanced starts playing the track but the **Google Assistant bubble stays open** on screen. This happens because Google's server doesn't send the close command when music starts playing through microG.

## The solution

A small standalone app that works as an accessibility service:

1. Detects when the Assistant bubble opens
2. Waits for music to start playing
3. Automatically dismisses it

If you're **not** listening to music (e.g. asking the Assistant a question), the bubble is **not** touched.

> Why a separate app instead of inside GmsCore? Because GmsCore is too large — Android blocks accessibility services from apps with too many components. A lightweight standalone app works without issues.

---

## Build

```bash
./gradlew assembleRelease
```

Output: `app/build/outputs/apk/release/AssistantDismiss-1.0.apk`

## Install

```bash
adb install -r app/build/outputs/apk/release/AssistantDismiss-1.0.apk
```

### Enable the accessibility service

```bash
adb shell settings put secure enabled_accessibility_services \
  "app.revanced.android.gms.assistant/org.microg.gms.assistant.AssistantDismissService"
adb shell settings put secure accessibility_enabled 1
```

Or from the phone: **Settings > Accessibility > Assistant Dismiss > Enable**.

### Auto-restart after reboot (optional)

Android disables accessibility services after reboot. To fix this, run once:

```bash
adb shell pm grant app.revanced.android.gms.assistant android.permission.WRITE_SECURE_SETTINGS
```

After that, the service will re-enable itself automatically at boot.

### Verify

```bash
adb shell dumpsys accessibility | grep assistant
```

If you see `app.revanced.android.gms.assistant` in enabled services, you're all set.

---

## Testing

| Voice command | Expected result |
|---|---|
| "Hey Google, play a song" | The bubble closes after a few seconds |
| "Hey Google, what's the weather?" | The bubble stays open (no music = no action) |
