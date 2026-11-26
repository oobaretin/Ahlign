# Ahlign (AffirmApp)

Guided **Root → Crown** chakra meditation for iOS. Pick affirmations and repetition counts per chakra, pulse-and-glow visuals sync with voice, then a completion screen with all chakras lit, a golden flower, and pulsating rays.

## Requirements

- Xcode **16+** (Swift 6 package with iOS application product)
- iOS **17+**
- Optional: [ElevenLabs](https://elevenlabs.io) API key for calm TTS (falls back to **AVSpeechSynthesizer**)

## Open & run

1. Open **`AffirmApp.xcodeproj`** in Xcode (not only the `affirmapp` folder — otherwise the toolbar may show **No Scheme**).
2. Select your **Team** on the AffirmApp target (Signing & Capabilities) if needed.
3. Choose the **AffirmApp** scheme and an iPhone simulator.
4. Run (⌘R).

## ElevenLabs (shipping)

End users do not see API keys in Settings. The target is already linked to **`Configuration/Secrets.xcconfig`** (gitignored):

1. Open `Configuration/Secrets.xcconfig` and set `INFOPLIST_KEY_ElevenLabsAPIKey = your_key_here` (no quotes).
2. Rebuild the app. Premium voice turns on automatically when the key is non-empty.
3. **Debug:** you can still paste a key in Settings; it is stored in **Keychain**, not UserDefaults.

**Voice ID** defaults to `45UYeUCUrGxt4rWuj2Ir`. Never commit `Secrets.xcconfig`.

Audio is cached under the app caches directory.

## Subscriptions (StoreKit 2)

Local testing uses **`Configuration/Products.storekit`** (3-day free trial on monthly & yearly). In **App Store Connect**, create subscription group `ahlign_premium` with matching product IDs:

- `com.affirmapp.ChakraAffirmations.premium.monthly` — **3-day free trial**, then monthly
- `com.affirmapp.ChakraAffirmations.premium.yearly` — **3-day free trial**, then yearly

Default local test prices: **$9.99/month**, **$59.99/year** (set the same in App Store Connect). **Begin journey** and **ElevenLabs voice** require an active subscription or trial. Sandbox Apple ID for purchase testing.

## Flow

1. **Home** — preview figure, **Begin journey**
2. **Configure** — affirmation picker + repetitions (1–99) per chakra, subtitles, voice
3. **Session** — automatic repetitions with pulse/glow; completed chakras stay fully lit
4. **Complete** — all seven chakras, flower glow, radiating rays

## Project layout

```
affirmapp/
├── AffirmApp.xcodeproj
├── README.md
└── AffirmApp/
    ├── AffirmAppApp.swift
    ├── Models/
    ├── ViewModels/
    ├── Services/
    ├── Views/
    └── Resources/Assets.xcassets
```

## Security & privacy

- Native **iOS** app only: no server database, login, or multi-user data.
- **ElevenLabs:** affirmation text is sent to `api.elevenlabs.io` over HTTPS when premium voice is on.
- **API keys:** Not written to UserDefaults; debug keys use **Keychain**. Release builds may use `Configuration/Secrets.example.xcconfig` → `Secrets.xcconfig` (gitignored). Keys embedded in the app binary can still be extracted—use a **backend TTS proxy** for high-assurance shipping.
- Never commit `Secrets.xcconfig`, `.env`, or live API keys.