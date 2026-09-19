#include "fast_forward_clock.h"
#include <cassert>
#include <cstdint>
#include <iostream>

int main() {
    FastForward::ScaledCounter clock;
    // Large epochs must not lose individual ticks to floating-point rounding.
    constexpr std::int64_t epoch = INT64_C(9007199254740993);
    clock.Start(epoch);
    assert(clock.Sample(epoch + 1) == epoch + 1);
    clock.SetSpeed(epoch + 10, 4.0);
    assert(clock.Sample(epoch + 10) == epoch + 10);
    assert(clock.Sample(epoch + 20) == epoch + 50);
    clock.SetSpeed(epoch + 20, 1.0);
    assert(clock.Sample(epoch + 20) == epoch + 50);
    assert(clock.Sample(epoch + 30) == epoch + 60);
    assert(clock.Sample(epoch + 29) == epoch + 60);

    clock.Start(0);
    clock.SetSpeed(0, 1.5);
    assert(clock.Sample(1) == 1);
    assert(clock.Sample(2) == 3);
    clock.SetSpeed(3, 1.0);
    assert(clock.Sample(4) == 5);
    clock.SetSpeed(4, 1.5);
    assert(clock.Sample(5) == 7); // Fraction survived both toggles.

    clock.Start(0);
    for (std::int64_t tick = 0; tick < 100000; tick += 2) {
        clock.SetSpeed(tick, 4);
        clock.SetSpeed(tick + 1, 1);
    }
    assert(clock.Sample(100000) == 250000);

    FastForward::SpeedCycle key;
    assert(key.Speed() == 1);
    for (unsigned expected : {2u, 4u, 8u, 16u, 1u, 2u}) {
        assert(key.Update(true, true) && key.Speed() == expected);
        assert(!key.Update(true, true) && key.Speed() == expected); // No repeat.
        assert(!key.Update(true, false));
    }
    assert(key.Update(false, true) && key.Speed() == 1); // Alt-tab cancels.
    assert(!key.Update(true, true) && key.Speed() == 1); // Held on return.
    key.Update(true, false);
    assert(key.Update(true, true) && key.Speed() == 2);
    key.Update(true, false);
    assert(key.Update(true, true) && key.Speed() == 4);
    key.Update(true, false);
    assert(key.Update(true, true) && key.Speed() == 8);
    key.Update(true, false);
    assert(key.Update(true, true) && key.Speed() == 16);
    assert(key.Update(false, false) && key.Speed() == 1);
    assert(!key.Update(false, true) && key.Speed() == 1); // Background ignored.
    assert(!key.Update(true, true) && key.Speed() == 1);

    clock.Start(100);
    std::int64_t expected = 100;
    std::int64_t real = 100;
    for (unsigned speed : {2u, 4u, 8u, 16u, 1u}) {
        clock.SetSpeed(real, speed);
        assert(clock.Sample(real) == expected); // No jump on any cycle edge.
        real += 10;
        expected += 10 * speed;
        assert(clock.Sample(real) == expected);
    }
    std::cout << "Fast-forward clock and speed-cycle tests passed\n";
}
