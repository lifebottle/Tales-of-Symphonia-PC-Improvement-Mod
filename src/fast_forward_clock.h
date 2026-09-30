#pragma once

#include <cstdint>
#include <algorithm>

namespace FastForward {

// Callers serialize access and sample the real clock inside the same lock.
// Keep the epoch in integer ticks: converting a large QPC value to floating
// point would lose precision. Retain fractional ticks across speed changes.
class ScaledCounter {
public:
    void Start(std::int64_t now) {
        real_ = virtual_ = now;
        fraction_ = 0;
        speed_ = 1;
    }

    std::int64_t Sample(std::int64_t now) {
        if (now <= real_) return virtual_;
        const long double elapsed = (now - real_) * speed_ + fraction_;
        const auto whole = static_cast<std::int64_t>(elapsed);
        fraction_ = elapsed - whole;
        virtual_ += whole;
        real_ = now;
        return virtual_;
    }

    void SetSpeed(std::int64_t now, double speed) {
        Sample(now); // Finish the old interval before changing its rate.
        speed_ = speed;
    }

private:
    std::int64_t real_ = 0;
    std::int64_t virtual_ = 0;
    long double fraction_ = 0;
    double speed_ = 1;
};

// Track the high key-state bit, not GetAsyncKeyState's shared "pressed" bit.
// Losing focus cancels fast-forward and consumes any held key until release.
class SpeedCycle {
public:
    bool Update(bool focused, bool increaseDown, bool decreaseDown, int speedStep, int maxSpeed) {
        const unsigned previous = speed_;
        const int current = static_cast<int>(speed_);

        if (!focused)
            speed_ = 1;
        else if (increaseDown && !increaseDown_)
            speed_ = std::clamp(
                current == 1 ? speedStep : current + speedStep,
                1,
                current + speedStep > maxSpeed ? current : maxSpeed
            );
        else if (decreaseDown && !decreaseDown_)
            speed_ = std::clamp(current - speedStep, 1, maxSpeed);
        increaseDown_ = increaseDown;
        decreaseDown_ = decreaseDown;
        return previous != speed_;
    }
    unsigned Speed() const { return speed_; }

private:
    unsigned speed_ = 1;
    bool increaseDown_ = false;
    bool decreaseDown_ = false;
};

} // namespace FastForward
