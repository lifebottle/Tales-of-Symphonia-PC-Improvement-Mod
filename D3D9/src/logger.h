#pragma once
/*
 * D3D9 Texture Replacement Proxy - Logger
 * Simple file-based logger that works on both Windows and Proton/Wine.
 */

#include <cstdio>
#include <cstdarg>
#include <mutex>
#include <string>

class Logger {
public:
    static Logger& Instance() {
        static Logger instance;
        return instance;
    }

    void Init(const char* filename) {
        std::lock_guard<std::mutex> lock(m_mutex);
        if (m_file) fclose(m_file);
        m_file = fopen(filename, "w");
    }

    void Log(const char* fmt, ...) {
        std::lock_guard<std::mutex> lock(m_mutex);
        if (!m_file) return;

        va_list args;
        va_start(args, fmt);
        vfprintf(m_file, fmt, args);
        va_end(args);
        fprintf(m_file, "\n");
        fflush(m_file);
    }

    void Shutdown() {
        std::lock_guard<std::mutex> lock(m_mutex);
        if (m_file) {
            fclose(m_file);
            m_file = nullptr;
        }
    }

    ~Logger() { Shutdown(); }

private:
    Logger() : m_file(nullptr) {}
    Logger(const Logger&) = delete;
    Logger& operator=(const Logger&) = delete;

    FILE* m_file;
    std::mutex m_mutex;
};

#define LOG(fmt, ...) Logger::Instance().Log(fmt, ##__VA_ARGS__)
