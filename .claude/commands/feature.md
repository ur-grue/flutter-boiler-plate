# /feature — add a screen via the 11-step recipe
Add feature "$ARGUMENTS" by copying features/example_notes/ and following the
11-step recipe in AGENTS.md (entity→repo iface→DTO→data source+mock→repo impl
guardAsync→sealed cubit→pages→injector→routes→ARB keys in en/de/es/ar→blocTest).
Before adding any new dependency, consult docs/PACKAGES.md (no codegen / no build_runner;
keyed or native capabilities go behind a services/ interface with a mock default).
Then run `flutter analyze` (clean) + `flutter test`. Show a short diff summary.
