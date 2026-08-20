## Tasks

- [x] 1.1 Rewrite Home's pending-transfer line strings to plain language ("You sent X to Y — tap when you know what arrived") - `_PendingTransfers` in `home_view.dart`; title states the amount and destination (or "from {source}" when the destination can't be resolved), subtitle is "Tap when you know what arrived".
- [x] 1.2 Rewrite the settle screen's intro/fee copy to the same voice, hiding FX-settlement jargon - `settle_pending_transfer_view.dart`: app bar title "What arrived?", the same "You sent X to Y" sentence as Home, "Tell us what actually arrived so we can settle it." instead of "Provisional: ...", and the shortfall copy reworded from "Shortfall: ... - choose a category to cover it." to "You received X less than expected - choose a category to cover the difference."
- [x] 1.3 User guide: update pending-transfer section to match the new copy - Home section's pending-transfers bullet and the "Settling a pending transfer" section.
