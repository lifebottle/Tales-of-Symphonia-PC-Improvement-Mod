# Fast-forward checks

Run from the repository root. The portable tests cover exact clock rates,
continuity across toggles, fractional multipliers, large counter values,
the complete 1× → 2× → 4× → 8× → 16× → 1× cycle, held-key behavior, and focus loss:

```bash
g++ -std=c++17 -Wall -Wextra -Werror -fsanitize=undefined -I D3D9/src \
    D3D9/tests/fast_forward_clock_test.cpp -o /tmp/tos-fast-forward-clock-test
/tmp/tos-fast-forward-clock-test
```

The Windows tests exercise the actual hook installer on a synthetic executable
image, reject mismatched instructions/pointers, verify memory protections,
read the hooked clock concurrently during speed changes, and check immediate
presentation and driver-failure fallback. They do not launch or patch TOS.
Run after creating the build directory with the README's CMake instructions:

```bash
i686-w64-mingw32-g++ -std=c++17 -O2 -Wall -Wextra -Werror \
    -DWIN32_LEAN_AND_MEAN -DNOMINMAX -I D3D9/src \
    D3D9/tests/fast_forward_windows_test.cpp -static \
    -o D3D9/build/fast_forward_windows_test.exe
mkdir -p /tmp/tos-fast-forward-wine
WINEPREFIX=/tmp/tos-fast-forward-wine WINEDEBUG=-all \
    wine D3D9/build/fast_forward_windows_test.exe
```

The overlay test uses an actual system D3D9Ex device. It verifies label pixels
at 2×, 4×, 8× and 16×, no drawing at 1×, graphics-state restoration (including an
offscreen render target and vertex buffer), and drawing after device resets.
It writes `fast-forward-2x.bmp`, `fast-forward-4x.bmp`, `fast-forward-8x.bmp` and `fast-forward-16x.bmp`
to its working directory for visual inspection. A display is required; on
Linux it can run on a virtual X display:

```bash
i686-w64-mingw32-g++ -std=c++17 -O2 -Wall -Wextra -Werror \
    -DWIN32_LEAN_AND_MEAN -DNOMINMAX -I D3D9/src \
    D3D9/tests/fast_forward_overlay_test.cpp D3D9/src/fast_forward_overlay.cpp \
    -static -o D3D9/build/fast_forward_overlay_test.exe
mkdir -p /tmp/tos-fast-forward-overlay-wine
cd D3D9/build
xvfb-run -a env WINEPREFIX=/tmp/tos-fast-forward-overlay-wine WINEDEBUG=-all \
    WINEDLLOVERRIDES='mscoree,mshtml=' wine ./fast_forward_overlay_test.exe
```

In-game acceptance check (Windows and Proton): start at normal speed, open a
dialogue/cutscene, and press/release F6 five times. Verify 2×, 4×, 8×, 16×, then normal
speed, with the matching label visible only during fast-forward. Holding F6
must not advance through multiple speeds. Check focus loss resets to 1× and
hides the label, and check map transitions and graphics-device reset while
enabled. Confirm `[FastForward] Ready` and ON/OFF log entries. Existing configs
with `Multiplier=4.0` must still use the new cycle. Repeat with `Enabled=0` and
`DisableVSync=0` to verify those settings. Audio synchronization and animation
accuracy during fast-forward are outside this feature's scope.

Readable patch compiler, converter, migration, and native hook checks are documented in [patches/README.md](patches/README.md).
