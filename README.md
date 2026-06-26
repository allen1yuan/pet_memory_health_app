# Pet Memory Health App

Pet Memory Health App, also named `宠忆时光`, is a HarmonyOS ArkTS MVP for recording a pet's growth, memories, photos, health reminders, weight history, and nearby certified animal hospitals.

The current app is intentionally local-first: all backend-style data is fake/demo data or persisted locally on the device through HarmonyOS Preferences and RDB. It is ready for product demos, UI iteration, and later backend integration.

## Highlights

- Local login and demo-data entry flow
- Pet profile creation and editing
- Growth timeline with milestones and photos
- Album categories, local photo records, share captions, and delete/category actions
- Health reminders with recurrence, completion, weight tracking, and generated health profile
- Fake certified hospital directory with search, filters, details, and appointment state
- Local membership-plan selection
- Warm caramel/terracotta visual palette

## Tech Stack

- HarmonyOS / ArkTS
- ArkUI declarative UI
- HarmonyOS RDB for structured local data
- HarmonyOS Preferences for session, settings, and lightweight local state
- Hvigor / OHPM project structure

## Project Structure

```text
.
├── AppScope/                         # App-level metadata and app icon resources
├── entry/
│   ├── src/main/ets/
│   │   ├── common/                   # Theme, constants, icons, catalog, date utils
│   │   ├── components/               # Reusable UI components
│   │   ├── entryability/             # Main UIAbility
│   │   ├── model/                    # Data models
│   │   ├── pages/                    # App pages and tabs
│   │   └── service/                  # Local storage, seed data, repositories
│   ├── src/main/resources/           # App resources and fake rawfile data
│   └── build-profile.json5
├── hvigor/                           # Hvigor config
├── build-profile.json5
├── oh-package.json5
└── README.md
```

## Local Data Model

The MVP stores data locally:

- `PetStore` wraps RDB CRUD for pets, milestones, photos, reminders, and weight records.
- `PrefStore` stores session, current pet, notification status, selected plan, and local username.
- `SeedData` creates demo pets, milestones, health reminders, weight history, and placeholder album entries.
- `HospitalRepo` loads fake hospital data from `entry/src/main/resources/rawfile/hospitals.json`.

## Main Screens

### Login

Supports local phone-code login and one-tap demo data entry. The demo path creates a pet and fills the app with fake local data.

### Pet Setup

Creates or edits a pet profile, including name, species, breed, birthday, gender, weight, and avatar.

### Home

Shows pet switching, quick actions, recent milestones, and a reminder center connected to local health reminders.

### Album

Supports local photo records, category filtering, detail view, category editing, deleting local records, and share-caption copy.

### Health

Includes reminders, recurring completion, weight logging, visit/vaccine records, and an auto-generated health profile.

### Hospitals

Uses fake local hospital data with city toggle, search, star filters, detail pages, and local appointment state.

### Profile and Plans

Supports local profile editing, notification toggle, privacy/about sheets, and local membership-plan selection.

## Run in DevEco Studio

1. Open this folder in DevEco Studio.
2. Make sure the HarmonyOS SDK configured in DevEco matches the project SDK settings.
3. Sync OHPM/Hvigor dependencies if DevEco prompts you.
4. Run the `entry` module preview or build target.

The preview command DevEco commonly runs is similar to:

```sh
/Applications/DevEco-Studio.app/Contents/tools/node/bin/node \
  /Applications/DevEco-Studio.app/Contents/tools/hvigor/bin/hvigorw.js \
  --mode module \
  -p module=entry@default \
  -p product=default \
  -p pageType=page \
  -p compileResInc=true \
  -p requiredDeviceType=phone \
  -p previewMode=true \
  -p buildRoot=.preview \
  PreviewBuild \
  --watch \
  --analyze=normal \
  --parallel \
  --incremental \
  --daemon
```

## Current Limitations

- There is no real backend yet.
- Hospital data, membership plans, and appointment state are fake/local demo data.
- Photo pixels come from the system picker; seeded album items use placeholders until the user adds real photos.
- Authentication is local-only and intended for MVP demonstration.

## Roadmap

- Replace fake login with real account authentication.
- Add cloud sync for pets, albums, reminders, and profile data.
- Add real appointment APIs for hospitals.
- Add reminder notifications through HarmonyOS notification APIs.
- Add export/share flows for pet timelines and health reports.

## License

Apache-2.0
