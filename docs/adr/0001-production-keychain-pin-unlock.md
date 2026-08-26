# Production-correct Keychain path for PIN unlock

App Lock stores the PIN hash in the same OS secure storage as signing keys. On ad-hoc signed macOS, PIN verify hung indefinitely in acceptance even with `usesDataProtectionKeychain: false`. We decided to fix the real storage/entitlements/signing path so unlock works for developers and users — not an acceptance-only in-memory bypass — and to require unlock acceptance green on macOS, iOS, and Android (`acceptance-app-lock-unlock`).
