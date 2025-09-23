# Contributing

Thanks for your interest in contributing to MeshChat!

## How to contribute
- Fork the repo and create a feature branch: `feat/<short-name>`
- Run the app and tests locally; keep PRs small and focused
- Ensure no analyzer/linter errors and tests pass
- Update README/CHANGELOG for user-visible changes

## Development
- Flutter stable 3.35+
- Run code generation: `flutter pub run build_runner build --delete-conflicting-outputs`
- Android: `flutter build apk` (grant permissions on device)
- iOS: open `ios/Runner.xcworkspace` and build in Xcode

## Commit & PR style
- Conventional commits (e.g., `feat:`, `fix:`, `docs:`, `refactor:`)
- Describe context and testing steps in PR description
- Link related issues and screenshots when applicable

## Code of Conduct
By participating, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).
