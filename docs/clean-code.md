# Clean Code Rules
*Distilled from Robert C. Martin's "Clean Code." Apply at all times, not just on request.*

## Naming
- Use intention-revealing names. `daysSinceCreation`, not `d`.
- Avoid disinformation and false encodings (`userList` for a non-List is a lie).
- Use pronounceable, searchable names. Single-letter vars only in tiny local scope.
- Functions are verbs (`getUserById`). Classes are nouns (`UserRepository`).
- Booleans are predicates (`isActive`, `hasPermission`).
- Drop redundant context (`user.userName` → `user.name`).
- One word per concept — don't mix `fetch`, `retrieve`, and `get` for the same idea.

## Functions
- Do one thing. If you can extract a sub-function with a non-redundant name, it did more than one thing.
- Keep them small — ideally < 20 lines, almost never > 40.
- Arguments: 0–2 ideal, 3 borderline, 4+ is a design smell (pass an object).
- No hidden side effects beyond what the name implies.
- Command/query separation: a function either does something or answers something, not both.
- Prefer exceptions to error codes. Don't return `null`; don't pass `null`.

## Comments
- Good code is mostly self-documenting; comments compensate for failures to express intent in code.
- Explain *why*, not *what*.
- Never leave commented-out code — that's what git is for.
- Delete noise comments (`// default constructor`).
- TODO/FIXME are fine if tracked.

## Formatting
- Vertical: related code stays together; blank lines separate concepts.
- Declare variables close to their use.
- Newspaper structure: high-level functions on top, details below (caller above callee).
- Keep lines reasonable (≤ 120 chars).
- Defer to the project's formatter/linter — don't hand-fight it.

## Error Handling
- Use exceptions, not error codes.
- Provide context in messages: the operation that failed and why.
- Don't swallow exceptions silently.
- Don't return or pass `null` — use empty collections, Option/Result types, or throw.
- Wrap third-party errors at the boundary so callers see one consistent type.

## Objects & Data Structures
- Small, single-responsibility classes; few instance variables (high cohesion).
- Hide internals — expose behavior, not raw data.
- Prefer composition over inheritance.
- Law of Demeter: a method talks only to itself, its arguments, objects it creates,
  and its direct components. Avoid train wrecks (`a.getB().getC().doThing()`).

## Tests (F.I.R.S.T.)
- **Fast** — run in milliseconds so you run them often.
- **Independent** — no test depends on another's state or order.
- **Repeatable** — same result on any machine, offline.
- **Self-validating** — a boolean pass/fail, no manual log-reading.
- **Timely** — write them with (ideally just before) the production code.
- One assert *concept* per test. Test boundary conditions explicitly.
- Keep test code as clean as production code — don't let it rot.

## The Boy Scout Rule
*Leave the code cleaner than you found it.* Each session: rename one unclear variable,
split one over-long function, delete one comment that states the obvious.
