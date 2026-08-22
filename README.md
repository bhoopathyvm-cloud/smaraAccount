# SMARA Account

Household books on your device: track what you spend and receive like a
notebook, with a history that can't quietly rewrite itself. No server, no
cloud, no data leaving your device — just Flutter, your devices, and your
own LAN.

This repository is also a working example of [OpenSpec](https://github.com/Fission-AI/OpenSpec)
and AI spec-driven development: features are specified first, then
implemented. That process is how the household books are built; it is not
the product pitch.

This is an experimental, personal project, shared in case it's useful to
others. It comes with **no liability and no support** from the author.

## Tamper-evident design

The ledger is deliberately designed so entries cannot be manipulated manually — this is the whole point of the project, not an afterthought.

- Every entry is signed with a key generated and stored on the user's own device.
- Users can export this key and store it separately (e.g. as a backup) — the app never transmits it anywhere.
- **If the signing key is lost, it cannot be recovered.** In that event, all entries must be re-created from scratch to keep the ledger consistent and trustworthy.

This tradeoff is intentional: without a recoverable key, there's no backdoor for editing history, which is what makes the transaction log genuinely immutable rather than immutable-in-name-only.

For a normal user, the useful promise is simpler: old financial history
cannot be quietly rewritten without the app noticing. That helps when
restoring backups, exporting records, reviewing corrections, or handing
books to an accountant. See the [user guide](docs/user-guide.md) and the
[project site](pages/index.md) for the plain-language version and
background references.

## Usage

See the [user guide](docs/user-guide.md) for how to use the app — onboarding and your recovery phrase, accounts, categories, transfers, importing bank statements, and more.

## Contributing

Contributions are welcome, but keep in mind this project follows a spec-first workflow via [OpenSpec](https://github.com/Fission-AI/OpenSpec) — changes are expected to be driven by a spec, not just a patch. See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the full workflow, branching convention, and architecture/engineering guidelines.

## License

Released under the [MIT License](LICENSE).
