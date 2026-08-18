## Tasks

- [ ] 1.1 Lock gate in `app_router.dart`: redirect to unlock screen on cold start and after idle timeout when enabled.
- [ ] 1.2 PIN set/change flow; `local_auth` biometric option where available.
- [ ] 1.3 Settings: enable lock, change PIN, timeout duration.
- [ ] 1.4 Snapshot hiding: platform mechanism on iOS/Android; Settings states plainly where no equivalent exists (desktop) rather than showing a no-op toggle.
- [ ] 1.5 Tests: lock gate blocks/allows correctly with mocked `local_auth`; timeout behavior; snapshot-hiding toggle only offered where implemented.
- [ ] 1.6 User guide: enabling lock, PIN vs biometric, snapshot hiding and its platform coverage.
