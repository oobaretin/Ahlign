import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var subscriptions: SubscriptionManager
    @ObservedObject var viewModel: SessionViewModel
    @State private var showPaywall = false

    var body: some View {
        List {
            Section {
                if subscriptions.hasPremiumAccess {
                    Label("Premium active", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                } else {
                    Button("Start 3-day free trial") {
                        showPaywall = true
                    }
                }
                Button("Restore purchases") {
                    Task { await subscriptions.restorePurchases() }
                }
            } header: {
                Text("Subscription")
            }

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
        .sheet(isPresented: $showPaywall) {
            PaywallView(subscriptions: subscriptions)
        }
        .task {
            viewModel.hasPremiumAccess = subscriptions.hasPremiumAccess
        }
        .onChange(of: subscriptions.hasPremiumAccess) { _, hasAccess in
            viewModel.hasPremiumAccess = hasAccess
        }
    }
}