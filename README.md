# ZION OS v4.1

Zion OS is a Flutter/Android system environment focused on device information, monitoring, defensive network inspection, and a desktop-style interface.

> **Important:** This repository is an Android/Flutter application, not a bootable replacement kernel or standalone operating system. It does not replace Android's kernel, bootloader, drivers, or system services.

## Production status

- Flutter application shell: ready
- Android native bridge: enabled for Wi-Fi scanning
- Network discovery: real TCP probes; no shell-dependent `ping`
- Wi-Fi results: real Android framework results; no fabricated fallback networks
- Security analysis: defensive only
- Credential cracking / WPS exploitation: intentionally disabled
- Release signing: must be configured with a private production keystore before distribution
- CI: `flutter pub get`, static analysis, tests, and release APK build

## Requirements

- Flutter 3.22 stable (or a newer compatible stable release)
- Dart 3.x
- Android SDK 34
- JDK 17
- Android device/emulator for runtime validation

## Run locally

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Build an unsigned release artifact for internal testing:

```bash
flutter build apk --release --split-per-abi
```

Before publishing, configure an Android release keystore and signing configuration in CI or a private local Gradle configuration. Never commit keystores, passwords, signing keys, tokens, or API secrets.

## Network features

Network inspection is designed for systems and networks you are authorized to assess.

- LAN discovery uses bounded TCP connection probes and does not invoke `ping`, `arp`, `netstat`, or other host shell commands.
- TCP port checks accept only valid ports from 1 through 65535.
- Banner inspection is bounded to 512 bytes and does not attempt authentication bypass or exploitation.
- Wi-Fi scanning uses Android's Wi-Fi framework through a Flutter `MethodChannel`.
- Android Wi-Fi scanning requires the relevant runtime permissions and an enabled Wi-Fi radio.

An empty result is a valid result. The application never substitutes fake devices or networks when the platform denies access or returns no data.

## Security principles

1. No debug signing for release builds.
2. Cleartext HTTP is disabled at the Android application level.
3. Legacy external-storage permissions are not requested.
4. Platform-specific functionality belongs behind native/platform service boundaries.
5. Security findings must be based on observed device/network data, not random or fabricated values.
6. Offensive actions that would enable credential theft, exploitation, or unauthorized access are not part of the production application.

## Architecture direction

```text
Flutter UI
   |
   +-- Dart services
   |     +-- Network inspection
   |     +-- Device/system state
   |     +-- Secure storage
   |
   +-- MethodChannel
         |
         +-- Android framework APIs
               +-- Wi-Fi
               +-- Device/network state
```

Shell commands are not a portable Android API. Any future platform-specific capability should follow the same boundary and provide an explicit unsupported state on platforms where the capability is unavailable.

## CI

Every branch is validated by GitHub Actions with dependency installation, static analysis, tests, and release APK compilation. Build artifacts are retained for a limited period for verification.

## Standalone OS roadmap

If the long-term goal is a true bootable Zion operating system, that is a separate engineering track. It requires a bootloader, kernel, CPU/interrupt initialization, memory management, scheduler, IPC, drivers, filesystem, networking stack, security model, userland, graphics stack, and hardware-specific images. Flutter can serve as a GUI/userland component; it cannot be the kernel.
