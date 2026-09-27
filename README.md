# SMARA Account

Household books on your device: track what you spend and receive like a
notebook, with a history that can't quietly rewrite itself. No server, no
cloud, no account, and no ledger data leaving your device.

Runs on iOS, Android, macOS, and Linux from one Flutter codebase (a
Windows target is scaffolded but not CI-validated), in 43 languages.

This repository is also a working example of [OpenSpec](https://github.com/Fission-AI/OpenSpec)
and AI spec-driven development: features are specified first, then
implemented. That process is how the household books are built; it is not
the product pitch.

This is an experimental, personal project, shared in case it's useful to
others. It comes with **no liability and no support** from the author.

## Tamper-evident design

The ledger is deliberately designed so entries cannot be manipulated manually — this is the whole point of the project, not an afterthought.

- Every entry is signed with a key generated and stored on the user's own device, and chained to the entry before it.
- Users can optionally back this key up from Settings — as a 24-word recovery phrase, a passphrase-encrypted keystore file, or a device migration bundle that carries books and key together for moving to a new device. The app never transmits it anywhere.
- **If the signing key is lost with no backup, it cannot be recovered.** The app can re-sign the existing books under a brand-new key after the user reviews and confirms them, but trust restarts from that point: earlier entries are kept only as a read-only historical record that can no longer be proven untampered.

This tradeoff is intentional: without a recoverable key, there's no backdoor for editing history, which is what makes the transaction log genuinely immutable rather than immutable-in-name-only.

For a normal user, the useful promise is simpler: old financial history
cannot be quietly rewritten without the app noticing. That helps when
restoring backups, exporting records, reviewing corrections, or handing
books to an accountant. See the [user guide](docs/user-guide.md) and the
[project site](pages/index.md) for the plain-language version and
background references.

## Usage

See the [user guide](docs/user-guide.md) for how to use the app — onboarding, backing up your key and moving to a new device, accounts, categories, transfers, investments, importing bank statements, and more.

Privacy: see the [privacy policy](pages/open-source/smara-account/privacy-policy.md) and [`SECURITY.md`](SECURITY.md) for exactly what stays on the device and the few optional network lookups.

## Contributing

Feature requests are welcome as GitHub issues. Please describe the real
problem first: what you were trying to do, what felt missing, and what
outcome would help. Using AI tools to make the request clearer before
submitting is fine, especially for turning an idea into examples or
acceptance criteria. I will pick up issues as time permits.

Contributions are welcome too, but keep in mind this project follows a
spec-first workflow via [OpenSpec](https://github.com/Fission-AI/OpenSpec)
— changes are expected to be driven by a spec, not just a patch. See
[`CONTRIBUTING.md`](CONTRIBUTING.md) for the full workflow, branching
convention, and architecture/engineering guidelines.

## License

Released under the [MIT License](LICENSE).
