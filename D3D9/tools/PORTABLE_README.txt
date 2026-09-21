Tales of Symphonia - Readable Patch Tools

AUTHORING
Run tos-ct-converter.exe. Choose your saved .CT table and TOS.exe, select
features, validate, and export to a new folder. No Python, WSL, Cheat Engine
process, or external assembler is needed by the converter.
Parents with the table's "Activate children as well" option include those
children automatically, including nested activation. Separately selected children
keep their own feature keys and are still enabled by the parent. Ordinary groups
do not activate children unless that option is set. Validation lists included
scripts; INSTALL.txt lists feature dependencies. Exports omit redundant manifest
fields and empty lists; custom CT IDs and descriptions are preserved.

INSTALLING PATCHES
Copy d3d9.dll and the desired complete folders from patches into the game
folder beside TOS.exe. Features start disabled; enable their keys in
 d3d9_config.ini and restart. Keep a backup of your previous mod installation.
This DLL replaces the old JSON patch format. Old JSON files are ignored.
Do not enable the same patches in Cheat Engine at the same time.

The authoring guide in docs/PATCH_AUTHORING.md explains supported CE syntax,
INI configuration, command-line use, and API version 2. See
 patches/README.md for bundled patch settings, controls, compatibility, and origins.

The converter does not modify TOS.exe, attach to a game, or change INI settings.
