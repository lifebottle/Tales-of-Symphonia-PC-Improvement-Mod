#pragma once

#include <cstdint>
#include <limits>

namespace FastForward {

// One decision per BeginScene..Present interval, including multi-scene frames.
// All times are REAL counter ticks, independent of the game's scaled clock.
// Owned and used by the device's render thread.
class FrameScheduler {
public:
    void Reset() { *this = FrameScheduler{}; }

    void BeginFrame(unsigned speed, std::int64_t now,
                    std::int64_t frequency) {
        if (active_) return;
        if (speed <= 1 || now < 0 || frequency < 60) {
            Reset();
            active_ = true;
            return;
        }

        // Round upward by at most one QPC tick. Never run faster than 60 Hz.
        const auto interval = frequency / 60 + (frequency % 60 != 0);
        if (now > std::numeric_limits<std::int64_t>::max() - interval) {
            Reset();
            active_ = true;
            return;
        }
        if (speed != speed_ || frequency != frequency_ || now < lastNow_)
            next_ = now;
        speed_ = speed;
        frequency_ = frequency;
        lastNow_ = now;
        active_ = true;
        skip_ = now < next_;
        if (!skip_) {
            // Advance directly past missed deadlines. A stall never creates
            // a backlog of frames to render, and no game update sleeps here.
            next_ = now + interval - (now - next_) % interval;
        }
    }

    bool ShouldSkip() const { return active_ && skip_; }
    bool Active() const { return active_; }
    void EndFrame() { active_ = skip_ = false; }

private:
    bool active_ = false;
    bool skip_ = false;
    unsigned speed_ = 0;
    std::int64_t frequency_ = 0;
    std::int64_t lastNow_ = 0;
    std::int64_t next_ = 0;
};

} // namespace FastForward
