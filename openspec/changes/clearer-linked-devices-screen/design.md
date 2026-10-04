## Context

`LinkedDevicesSection` renders the pending joins, every device, and then
seven buttons in one column. Nothing calls `setLocalDeviceDisplayName`, so
every device falls back to "This device". `LinkedDevice.personDisplayName`
is set only for devices added through Add a person. Peers already apply
`linked_device`/`displayName` metadata ops (`_upsertLinkedDeviceField`).

## Goals / Non-Goals

**Goals:**
- Make it obvious which button to press on which device.
- Show who each entry is and which one is "me".
- Give every device a real name.

**Non-Goals:**
- No new roles and no permission changes. In particular, the Owner can
  already approve claims (`MembershipRoleGates.canApproveClaims`).
- No change to the join or sync protocol.

## Decisions

- **Grouping rule:** an entry goes under People when `personDisplayName` is
  non-null, and under My devices otherwise. No new data is needed.
- **Section visibility:** People, Add a person and Review claims keep their
  current gates (`canManageMembership` / `canApproveClaims`). A device that
  may not see them gets no People section.
- **New keys, not rewording old ones:** the plain role words are new ARB
  keys (`linkedDevicesRole*`). The existing `claimsRoleClaimant` and
  `claimsRoleApprover` stay as they are, because claim screens use them in
  other contexts.
- **Default name:** "My iPhone", "My iPad", "My Mac", "My Android phone",
  "My Android tablet", "My Windows PC" or "My Linux PC". The view decides
  phone or tablet from `MediaQuery` (shortest side ≥ 600). iOS doesn't let
  apps read the user's own device name, so the name is asked for once.
- **Rename propagation:** a rename updates the local row and enqueues a
  `linked_device`/`displayName` op through `MetadataOutbox`. HLC
  last-write-wins makes the latest rename win.
- **Finders:** existing widget keys stay. The new section headings get keys
  so tests can find them without depending on the language.

## Risks / Trade-offs

- A Claimant phone's metadata ops are filtered on the host, so a Claimant's
  later self-rename may stay local until the Owner's side accepts it. The
  name given at join is the main path.
- 43 locales of new strings. Lower-resource languages are best-effort, as
  in earlier changes.
