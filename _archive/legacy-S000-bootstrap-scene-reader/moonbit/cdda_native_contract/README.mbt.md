# cdda_native_contract

This MoonBit module is the corrected domain core for the CDDA native contract rebuild.

## What it guarantees
- raw truth is separate from canonical channels
- canonical channels are produced by role-specific constructors
- role-specific constructors validate upstream ownership
- section-stack composition reuses the same canonical channel across multiple sections

## What it does not do
- it does not treat captured prose as canonical truth
- it does not keep the deleted adapter-backed runtime alive
