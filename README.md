# Trailer Park Productions — iPhone app (sideload .ipa)

A tiny iPhone app that opens https://trailerparkproductions.net full screen,
with the TPP logo as its icon. Built for sideloading (iloader / LiveContainer),
not the App Store.

## How the .ipa gets built

iOS apps can only be compiled on a Mac, so the build runs free on GitHub's
Mac machines:

1. Put this folder in a GitHub repository (free account).
2. GitHub Actions runs `.github/workflows/build-ipa.yml` automatically on
   every push: it generates the Xcode project (XcodeGen), builds the app
   unsigned, and packages it as `TrailerParkProductions.ipa`.
3. Download the .ipa from the run's "Artifacts" section.
4. Sideload it with iloader (signs with your Apple ID — 7-day refresh like
   other free sideloads) or run it in LiveContainer.

## Files

- `Sources/TrailerParkProductionsApp.swift` — the whole app (WebView wrapper)
- `project.yml` — XcodeGen project spec (bundle id net.trailerparkproductions.app)
- `Assets.xcassets/` — app icon (TPP logo, 1024×1024)
- `.github/workflows/build-ipa.yml` — the free Mac build

## Notes

- The app just shows the live website, so site updates show up in the app
  automatically — no rebuild needed when the site changes.
- Rebuild only if the app itself changes (icon, name, web address).
