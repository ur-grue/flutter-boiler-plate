# App icon source

`flutter_launcher_icons` reads these to generate the native iOS + Android launcher icons
(replacing the default Flutter logo). They are **placeholders** — `/theme` regenerates
`app_icon.png` from the app's brand + seed color during `/mvp`, and sets
`flutter_launcher_icons.adaptive_icon_background` (in `pubspec.yaml`) to the seed.

- `app_icon.png` — 1024×1024, **square, NO alpha** (iOS rejects transparency).
- `app_icon_foreground.png` — 1024×1024 Android adaptive-icon foreground (alpha allowed);
  drawn on the `adaptive_icon_background` color.

Regenerate the native icons after changing these (the platform folders must exist):

```bash
dart run flutter_launcher_icons
```

`scripts/postcreate.sh` runs this for you. The generated native assets
(`ios/.../AppIcon.appiconset`, `android/.../mipmap-*`) live under the gitignored platform
folders and are reproducible; only these source images are committed.
