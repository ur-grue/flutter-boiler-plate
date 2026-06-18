# /theme — Material 3 theme
Use the **ui-ux-pro-max** skill to generate a design system for the app's product
category (style direction, color palette, type pairing, key UX rules) from the brand
keywords in APP_SPEC.md (or the tokens in /design if present). Treat its output as
DESIGN INTENT only.

Then apply that intent to `ThemeData` in `lib/core/theme/` (seed color, type scale,
spacing). Keep light + dark + a persisted seed color.

Flutter + Material 3 ONLY — ignore any HTML/Tailwind/CSS code or web advice the skill
emits (it defaults to web); map its palette/typography onto Material 3 + the boilerplate
theme. impeccable + gstack `design-review` refine the built UI afterward.

## App icon (generate it here — don't ship the Flutter default logo)
The launcher icon is a native image asset, separate from the in-app UI; nothing replaces the
default Flutter logo unless you generate one. Design it from real data, not a blank square:

1. **Look at the competitors' icons** — competitor analysis includes logos. Pull them from
   MARKET.md §1 and/or `mcp-appstore` `get_app_details` / `get_similar_apps` (icon URLs) for this
   category. Use the aso-skills **`app-icon-optimization`** skill to choose a design that fits the
   category's visual conventions yet **stands out on the shelf** (Apple 4.3 differentiation):
   legible at 1×, strong contrast, one clear glyph, no tiny text.
2. **Render the source** `assets/icon/app_icon.png` — **1024×1024, square, NO alpha** (iOS rejects
   transparency): the brand seed color as background + a simple distinctive brand glyph consistent
   with the in-app branding. Also refresh `assets/icon/app_icon_foreground.png` (Android adaptive
   foreground). Source: AI image generation or a templated SVG→PNG with the seed color applied.
3. **Set the background** — update `flutter_launcher_icons.adaptive_icon_background` in
   `pubspec.yaml` to the app's actual seed color (not the default).
4. `scripts/postcreate.sh` runs `dart run flutter_launcher_icons` (after the platform folders
   exist) to regenerate all iOS/Android sizes + the Android adaptive icon from your source.
   Commit `assets/icon/*` — the native `AppIcon.appiconset`/`mipmap-*` stay regenerable.
