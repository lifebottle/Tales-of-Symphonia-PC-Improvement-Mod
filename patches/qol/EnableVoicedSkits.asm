// Port of TOS NoTSFix v26.10 CT entry number?, Enable Voiced Skits (sd).
// Enable with [QoL] EnableVoicedSkits=1.
// Enables the Japanese dub for the English language.
[ENABLE]
define(skit_voice_site,TOS.exe+1710CE)

assert(skit_voice_site,75 07)

skit_voice_site:
  jmp TOS.exe+1710D7
