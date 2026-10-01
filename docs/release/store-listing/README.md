# Store listing sources (English)

The maintained source for what the App Store and Google Play listings
show. Edit here, never in the archived
`openspec/changes/archive/2026-09-22-store-listing-assembly/` copy, which
stays frozen as the record of the first submission. Listings are English
only. When to update: the listing check in
[`../store-release-runbook.md`](../store-release-runbook.md).

| File | Store field(s) |
|---|---|
| [`listing.md`](listing.md) | App Store subtitle, promotional text, description, keywords, category, support URL; Play short and full description |
| [`app-privacy.md`](app-privacy.md) | App Store Connect App Privacy answers and export compliance |
| [`content-rating-and-data-safety.md`](content-rating-and-data-safety.md) | Play content rating (IARC), Data Safety form, other Play declarations |
| [`graphics/`](graphics/) | Play 512×512 icon and 1024×500 feature graphic |
| [`screenshots/<size-class>/`](screenshots/) | Screenshots per store size class (below) |

The three drafts were carried over from the first submission and still
contain notes from it ("Covers tasks …", "Open items …"). Treat their
answers, not those notes, as current, and re-check them against
[the privacy policy](../../../pages/open-source/smara-account/privacy-policy.md)
whenever it changes.

## Screenshot size classes

| Folder | Store | Size (px) | Device used here |
|---|---|---|---|
| `iphone-6.9in` | App Store (required) | 1320×2868 | iPhone 17 Pro Max Simulator |
| `iphone-6.5in` | App Store | 1242×2688 | `smara_iphone_65` Simulator |
| `ipad-13in` | App Store (required, universal app) | 2064×2752 | iPad Pro 13-inch Simulator |
| `android-phone` | Play (2–8) | 1080×2424 | `smara_store_phone` emulator |
| `android-tablet-10in` | Play (optional) | 2560×1600 (landscape) | `smara_kiosk_pixel` tablet emulator |
| `mac` | Mac App Store | 2880×1800 | 👤 by hand: window of the signed macOS build |

Capture with `tool/capture_store_screenshots.sh -d <device-id> -c <folder>`.
Each automated class gets 19 screenshots, named in store-priority order —
the App Store takes at most **10** per size and Play at most **8** per
device type, so upload the first 10 / 8:

`01_home`, `02_register`, `03_add`, `04_record_spent`, `05_split`,
`06_summary`, `07_categories_limits`, `08_holdings`, `09_transfer`,
`10_fix`, `11_accounts`, `12_search`, `13_settings`,
`14_books_copy`, `15_recurring`, `16_payees`, `17_import`,
`18_setup_choice`, `19_language`.

## Preview videos

`tool/record_store_previews.sh -d <device-id> -c <class>` records 11
feature chapters and writes to `build/store_media/<class>/` (not
committed; videos are large and re-recorded when the UI changes):

| Output | Use |
|---|---|
| `app_preview_1_record.mp4`, `app_preview_2_fix.mp4`, `app_preview_3_invest.mp4` (iOS classes) | App Store app previews: 15–30 s, 886×1920 (iPhone) or 1200×1600 (iPad), 30 fps, silent audio track. Max 3 per size |
| `tour_1920x1080.mp4` (record once on the Android phone emulator) | Captioned full tour: Google Play promo video (upload to YouTube, paste the URL in Play Console) and the website's Smara Account page |

The App Store text never mentions YouTube, Android, or Google Play (App
Review guideline 2.3.10); Apple users reach the tour through the website
link in the description.
