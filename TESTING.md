Field Test Plan (Phase 1)

Setup
- Build and install on 3–6 phones (Android recommended for background tests).
- Ensure Bluetooth is enabled and app has permissions.

Scenarios
1) Public channel hop test
   - Place phones linearly with ~5–15m spacing.
   - Send messages from one end; confirm delivery across ≥3 hops.

2) Private channel (sender keys)
   - Create a channel on phone A; invite B via QR or invite code.
   - Verify messages decrypt on A/B; ciphertext appears on others.

3) 1:1 E2E session (phase 2)
   - Bootstrap X3DH and use Double Ratchet for A↔B.
   - Send messages both directions; verify decryption & forward secrecy.

4) Rekey on membership change
   - Remove phone B from channel; rotate key.
   - Verify B can’t decrypt new messages; A/C can.

5) Background behavior
   - Android: enable foreground service; screen off for 10–20 min.
   - iOS: background, move devices; verify periodic wake and relay.

Battery metrics (Normal mode)
- Record battery % change over 1 hour of active relaying.
- Target ≤ ~6–8%/hr on mid-range Android.

Notes
- BLE is opportunistic; retries expected. Test multiple placements: corridor, multi-room, outdoor.

