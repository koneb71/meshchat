# MeshChat

Offline Bluetooth P2P mesh messenger with channels and end‑to‑end encryption.

## Features
- Public channel (plaintext) for bring‑up
- Private channels (Sender Keys, AEAD ChaCha20‑Poly1305)
- 1:1 Direct Messages with X3DH bootstrap (control channel) + Double Ratchet (send/recv chains)
- Store‑and‑forward mesh over BLE, TTL + hop relay + de‑dup
- Background: Android ForegroundService; iOS background modes
- Persistence: channels, messages (per‑bubble delivery persisted), identity
- Invites: QR, text invite code; preview name/type; sender key hash for side‑channel verification
- Diagnostics: Nearby peers list, verbose logging toggle, re‑key prompts in chat

## Build

Prereqs: Flutter stable (3.35+), Android SDK, Xcode for iOS.

Android:
```bash
flutter build apk
```

iOS:
```bash
open ios/Runner.xcworkspace # build from Xcode
```

## Permissions

Android Manifest includes:
- BLUETOOTH, BLUETOOTH_ADMIN (maxSdk 30)
- BLUETOOTH_SCAN, BLUETOOTH_CONNECT, BLUETOOTH_ADVERTISE
- FOREGROUND_SERVICE, POST_NOTIFICATIONS
- Foreground service `MeshForegroundService` (connectedDevice|dataSync)

iOS `Info.plist`:
- UIBackgroundModes: bluetooth‑central, bluetooth‑peripheral
- NSBluetoothAlwaysUsageDescription: Bluetooth relaying for offline messaging

## Getting Started

1) Onboard
- Set your Display Name; see Safety Number (text + QR). You can edit later in Settings.

2) Channels
- Create a channel (toggle Private for encrypted)
- Share via: QR Invite, Invite Code, or Sender Key Hash (verify)
- Join via: Scan QR or paste Invite Code

3) Chat
- Messages relay across multiple hops. Private channels encrypt/decrypt automatically.
- Tooltip on bubbles shows sent time. Delivery receipts are shown per bubble (via ACK hop count).

4) Peers
- See nearby devices (advertising Mesh service). Open a DM or send a channel invite.

5) Re‑key & Members
- Private channels auto‑rotate Sender Keys periodically (and on demand). A re‑key message is broadcast to peers.
- Chat shows a banner prompting verification after a re‑key. You can view a read‑only Members sheet (you + nearby peers) from the channel menu.

## Testing (multi‑phone)
See `TESTING.md` for field tests (corridor, multi‑room, outdoor) and battery notes.

## Security
Summary in `SECURITY.md`. Keys are stored using flutter_secure_storage. Private channels use Sender Keys (ChaCha20‑Poly1305). 1:1 sessions use X3DH to derive a shared secret and Double Ratchet for forward secrecy.

## Roadmap
- Member management (add/remove, roles), full membership sync
- Re‑key announcement security hardening (signature + replay protection)
- Background delivery receipts batching; richer diagnostics (RSSI/hops per link)
- Identity export/import UI; Battery Mode (Normal/Aggressive)
