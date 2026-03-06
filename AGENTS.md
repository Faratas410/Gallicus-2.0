# Agent Rules (Repository-Local)

These rules apply to all coding agents working in this repository.

## Mojibake Policy (Non-Negotiable)

- Mojibake characters/sequences are forbidden in source and docs.
- Common forbidden patterns include (not exhaustive): U+00C3, U+00C2, U+FFFD, and malformed UTF-8 quote/dash sequences.
- Do not introduce malformed encoding in any patch.

## Mandatory Correction Rule

- If an agent introduces mojibake in a patch, it must be fixed in the same patch before completion.
- If mojibake is found in touched files during work, fix it before closing the task.
- Do not leave known mojibake as follow-up.

## Verification Before Finalizing

- Run a repository scan for mojibake markers on text files before final response.
- Suggested command:
  - `rg -n -P "\\x{00C3}|\\x{00C2}|\\x{FFFD}" .`
- If matches are real encoding errors, correct them and re-run the scan until clean.
