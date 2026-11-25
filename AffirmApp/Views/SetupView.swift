import SwiftUI

struct SetupView: View {
    @ObservedObject var viewModel: SessionViewModel
    @State private var selectedStep: ChakraStep = .root

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Text("Pick affirmations and reps for each step.")
                    .font(DesignTokens.Typography.subhead)
                    .foregroundStyle(.white.opacity(0.55))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, DesignTokens.horizontalPadding)
                    .padding(.vertical, 12)

                Picker("Step", selection: $selectedStep) {
                    ForEach(ChakraStep.allCases) { step in
                        Text("\(step.rawValue)").tag(step)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, DesignTokens.horizontalPadding)
                .padding(.bottom, 12)

                if let index = viewModel.configurations.firstIndex(where: { $0.step == selectedStep }) {
                    let step = selectedStep
                    ScrollView {
                        VStack(alignment: .leading, spacing: DesignTokens.stackSpacing) {
                            Text("\(step.headerPhrase) · \(step.rawValue)")
                                .font(DesignTokens.Typography.sessionPhase)
                                .foregroundStyle(step.color)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Affirmation")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.5))
                                Picker("Affirmation", selection: $viewModel.configurations[index].selectedAffirmationID) {
                                    ForEach(AffirmationLibrary.affirmations(for: step)) { affirmation in
                                        Text(affirmation.english).tag(affirmation.id)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(.white)
                            }
                            .padding()
                            .background(Color.white.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                            Stepper(
                                "Repetitions: \(viewModel.configurations[index].repetitionCount)",
                                value: $viewModel.configurations[index].repetitionCount,
                                in: 1 ... 99
                            )
                            .padding()
                            .background(Color.white.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .foregroundStyle(.white)
                        }
                        .padding(DesignTokens.horizontalPadding)
                    }
                }

                Spacer()
            }
        }
        .navigationTitle("Customize")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onDisappear { viewModel.saveSetup() }
    }
}