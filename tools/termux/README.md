# Zion terminal userland

The terminal is a real Android shell boundary. The UI no longer simulates commands or invents scan/credential output.

## Full Termux-compatible userland

Zion uses the official Termux packages project as the upstream source. A custom Android application id requires a custom bootstrap; official documentation says packages for com.termux must not be mixed with packages built for a different application id.

Build the Zion bootstrap with:

    ./tools/termux/build_zion_bootstrap.sh aarch64

The resulting archive is placed in:

    build/termux-bootstrap/bootstrap-aarch64.zip

The generated binary is intentionally not committed to the repository. It should be produced by CI or a controlled build environment and then packaged into the Android application.

Until that bootstrap is installed, the terminal starts Android /system/bin/sh as a functional fallback.

## Current command path

Flutter terminal -> MethodChannel/EventChannel -> Android shell process -> Zion prefix.

The next integration step is to install the generated bootstrap into:

    <app files>/termux/usr

and start its bash executable when present.

