Threat model (Phase 1)

- No central servers; all comms via BLE store-and-forward.
- Identity keys generated on-device (Ed25519 + X25519). Safety number = SHA-256 of identity pubkey (short form displayed).
- 1:1 uses X3DH to establish a shared secret; Double Ratchet for forward secrecy (scaffolded; current DM demo uses pre‑shared secret). Tampering should fail authentication.
- Channels use Sender Keys (32B). ChaCha20-Poly1305 AEAD. Nonce from per-sender counter.
- Rekey on membership change and periodically; new keys distributed over existing 1:1 sessions (to be enabled in a following release).
- Replay protection via LRU of msgIds. Constant-time comparisons used where possible.

Known limitations

- BLE metadata can leak presence and traffic timing.
- Background constraints on iOS limit mesh availability; delivery not guaranteed while suspended.
- DB encryption at rest is best-effort (no full at-rest encryption without Isar support enabled).

Key handling

- Private keys stored via flutter_secure_storage; references persisted in DB when DB is enabled.
- Avoid logging sensitive material; verbose logs should redact ciphertext and keys.

Future hardening

- Migrate crypto to libsignal FFI for audited implementations.
- Add Wi-Fi Direct transport as optional higher-bandwidth path.

