# SMARA Account

Local-first accounting with a tamper-evident ledger. No server, no cloud, no data leaving your device — just Flutter, your devices, and your own LAN.

## About this project

SMARA Account is a learning implementation of [OpenSpec](https://github.com/Fission-AI/OpenSpec) and AI spec-driven development. Every line of code is written by AI, constrained by a strict set of guidelines and the feature specs defined through OpenSpec — the specs drive the implementation, not the other way around.

This is an experimental, personal learning project, shared in case it's useful to others. It comes with **no liability and no support** from the author. Everything here is provided as-is, on a trial basis. If you'd like to improve it, pull requests are welcome — or fork it and take it in your own direction. This is a first pass, built with the knowledge I have today, and it will keep evolving.

## Tamper-evident design

The ledger is deliberately designed so entries cannot be manipulated manually — this is the whole point of the project, not an afterthought.

- Every entry is signed with a key generated and stored on the user's own device.
- Users can export this key and store it separately (e.g. as a backup) — the app never transmits it anywhere.
- **If the signing key is lost, it cannot be recovered.** In that event, all entries must be re-created from scratch to keep the ledger consistent and trustworthy.

This tradeoff is intentional: without a recoverable key, there's no backdoor for editing history, which is what makes the transaction log genuinely immutable rather than immutable-in-name-only.

## Contributing

Contributions are welcome, but keep in mind this project follows a spec-first workflow via [OpenSpec](https://github.com/Fission-AI/OpenSpec) — changes are expected to be driven by a spec, not just a patch.

- Changes are proposed and implemented as OpenSpec changes; each one gets its own branch named after the change (e.g. `core-ledger-single-account`).
- Nothing is committed directly to `main` — open a pull request from your branch/fork instead.
- No formal support or review SLA is provided. If something doesn't get merged or reviewed promptly, feel free to fork and continue independently.

## License

Released under the [MIT License](LICENSE).
