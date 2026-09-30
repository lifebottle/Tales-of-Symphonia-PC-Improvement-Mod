// Shared fill and outline alpha for both hitboxes and hurtboxes.
// This allocation is installed with CollisionOverlay; Alpha alone enables no hooks.
[ENABLE]
alloc(overlay_alpha,4)
registersymbol(Alpha)
overlay_alpha:
Alpha:
  dd (float)0.25

[DISABLE]
unregistersymbol(Alpha)
dealloc(overlay_alpha)
