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

End users do not see API keys in Settings. For **Release**, set a build-time Info key:

- Target **AffirmApp** → Build Settings → add User-Defined `INFOPLIST_KEY_ElevenLabsAPIKey` = your key (or use an xcconfig), **do not commit the key**.

**Voice ID** defaults to `45UYeUCUrGxt4rWuj2Ir`. **Debug** builds still show an optional ElevenLabs section in Settings.

Audio is cached under the app caches directory.

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

## Privacy

ElevenLabs requests send affirmation text to ElevenLabs’ API when enabled. Keys are stored locally in `UserDefaults` (use Keychain for production hardening).