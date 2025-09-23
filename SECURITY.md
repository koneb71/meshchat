Threat model (Phase 1)

- No central servers; all comms via BLE store-and-forward.
- Identity keys generated on-device (Ed25519 + X25519). Safety number = SHA-256 of identity pubkey (short form displayed).
- 1:1 uses X3DH to establish a shared secret; Double Ratchet for forward secrecy. Tampering should fail authentication.
- Channels use Sender Keys (32B). ChaCha20-Poly1305 AEAD. Nonce from per-sender counter.
- Rekey on membership change and periodically. Rekey announcements are signed (Ed25519) and verified before applying.
- Replay protection via LRU of msgIds. Constant-time comparisons used where possible.

Known limitations

- BLE metadata can leak presence and traffic timing.
- Background constraints on iOS limit mesh availability; delivery not guaranteed while suspended.
- DB encryption at rest is best-effort (no full at-rest encryption without Isar support enabled).
 - Nearby/Multipeer transports negotiate channels out of band of BLE; trust model assumes app identity keys for auth.

Key handling

- Private keys stored via flutter_secure_storage; references persisted in DB when DB is enabled.
- Avoid logging sensitive material; verbose logs should redact ciphertext and keys.
 - Rekey/member updates include signer public key alongside a signature; future versions will pin channel admin key.

Future hardening

- Migrate crypto to libsignal FFI for audited implementations.
- Add Wi‑Fi Direct transport as optional higher‑bandwidth path.
- Cache channel admin key and require signatures from pinned admin for rekey/member updates (with replay protection and windowed timestamps).

