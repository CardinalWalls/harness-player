## Summary

- What changed?
- Why is this change needed?

## Local Validation

- [ ] `omx doctor`
- [ ] `CODEX_HOME=.codex codex login status`
- [ ] If MoonBit-owned product surfaces changed: `moon check`
- [ ] If MoonBit-owned product surfaces changed: `moon test`
- [ ] If MoonBit-owned product surfaces changed: `moon fmt --check`
- [ ] If MoonBit-owned product surfaces changed: `moon info`
- [ ] If release/preflight proof was requested: `moon coverage analyze -- -f html -o coverage.html`

## GitHub Expectations

- [ ] I expect `moonbit-ci.yml` to run on this PR
- [ ] I expect `codex-pr-review.yml` to comment on this PR

## Notes

- Any local-only validation notes
- Say explicitly whether MoonBit-owned product surfaces changed
- Any known remote-only limits or assumptions
