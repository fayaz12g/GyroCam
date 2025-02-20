# Contributing to GyroCam

We welcome contributions! Please follow these guidelines:

## Getting Started
1. Fork the repository
2. Clone your fork locally
3. Create feature branch: `git checkout -b feature/your-feature`
4. Install dependencies using Swift Package Manager
5. Test changes using Xcode previews

## Development Requirements
- Xcode 16+ 
- Swift 5.9+
- iOS 18 SDK
- SwiftLint installed

## How to Contribute

### Bug Reports
- Use GitHub Issues template
- Include:
  - iOS version
  - Device model
  - Reproduction steps
  - Console logs if available

### Feature Requests
- Check [Roadmap](GyroCam/UpcomingFeaturesView.swift) first
- Describe use case clearly
- Include mockups if applicable

### Code Contributions
1. Ensure tests pass
2. Update documentation
3. Follow SwiftUI patterns
4. Use `@ViewBuilder` for complex components
5. Maintain 70%+ test coverage for new code

## Coding Standards
- 4-space indentation
- MARK comments for sections
- Type-first protocol conformance
- Prefer structs over classes
- Document public APIs
- Use SwiftLint rules:
  - 120 character line limit
  - Explicit self references
  - No force unwrapping

## Pull Requests
1. Reference related issue
2. Include before/after screenshots
3. Update CHANGELOG.md
4. Keep commits atomic
5. Use conventional commit messages:
   - feat: New features
   - fix: Bug fixes
   - docs: Documentation
   - chore: Maintenance

## Code of Conduct
- Be respectful
- Assume positive intent
- Keep discussions technical
- No harassment tolerated

## License
By contributing, you agree your contributions will be licensed under the project's MIT License.

Need help? Open a discussion ticket!
