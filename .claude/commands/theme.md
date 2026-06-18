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

For the app icon direction, consult the aso-skills `app-icon-optimization` skill (legibility
at small sizes, store-shelf contrast) and keep it consistent with the seed color/palette.
