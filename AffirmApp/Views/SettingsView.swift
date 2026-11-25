import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SessionViewModel

    var body: some View {
        List {
            Section {
                Toggle("Voice during session", isOn: $viewModel.settings.voiceEnabled)
                Toggle("Tap to advance repetition", isOn: $viewModel.settings.tapToAdvance)
                Text("When on, tap the figure or Next to move to the next repetition without waiting for audio.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Interval between affirmations: \(viewModel.settings.affirmationIntervalSeconds, specifier: "%.1f") s")
                        .foregroundStyle(.white)
                    Slider(
                        value: $viewModel.settings.affirmationIntervalSeconds,
                        in: 1 ... 5,
                        step: 0.5
                    )
                    Text("Breathing space after each line (voice on or off).")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Session")
            }

            #if DEBUG
            Section {
                Toggle("Premium voice (ElevenLabs)", isOn: $viewModel.settings.useElevenLabs)
                if viewModel.settings.useElevenLabs {
                    SecureField("API key", text: $viewModel.settings.elevenLabsAPIKey)
                    TextField("Voice ID", text: $viewModel.settings.elevenLabsVoiceID)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Text("Debug only. Release builds use bundled voice config.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Advanced audio")
            }
            #endif

            Section {
                Stepper(
                    "Default repetitions per step: \(viewModel.settings.defaultRepetitionsPerChakra)",
                    value: $viewModel.settings.defaultRepetitionsPerChakra,
                    in: 1 ... 99
                )
                Button("Apply default to all steps") {
                    viewModel.applyDefaultRepetitionsToAll()
                }
            } header: {
                Text("Defaults")
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.black)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { viewModel.saveSetup() }
    }
}