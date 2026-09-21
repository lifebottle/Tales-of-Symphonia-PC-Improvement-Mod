# Pinned patch compiler dependencies

Vendored source; no downloads are needed when building.

- [AsmJit](https://github.com/asmjit/asmjit): `c87860217e43e2a06060fcaae5b468f6a55b9963` (license included in its directory).
- [AsmTK](https://github.com/asmjit/asmtk): `1261a46fabb0b353be1f52ff77b0245aa9c170f4` (license included in its directory).
- [Zydis](https://github.com/zyantific/zydis): `a2278f1d254e492f6a6b39f6cb5d1f5d515659dc` (license included in its directory).
- [toml++](https://github.com/marzer/tomlplusplus): `30172438cee64926dc41fdd9c11fb3ba5b2ba9de` (license included in its directory).
- [pugixml](https://github.com/zeux/pugixml): `ee86beb30e4973f5feffe3ce63bfa4fbadf72f38` (license included in its directory).

Zydis includes Zycore at `0b2432ced0884fd152b471d97ecf0258ff4d859f` (MIT).
AsmJit is pinned to the compatible December 2025 API used by this AsmTK revision.

Local AsmTK patch: string-instruction aliases construct SI/DI memory operands
from the emitter architecture instead of downcasting BaseEmitter to an unrelated
x86::Emitter type. The undefined-behavior sanitizer exposed that upstream cast.
