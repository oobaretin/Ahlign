import StoreKit
import SwiftUI

struct PaywallView: View {
    @ObservedObject var subscriptions: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    var allowsDismiss: Bool = true

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                LinearGradient(
                    colors: [.purple.opacity(0.25), .black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: DesignTokens.sectionSpacing) {
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 96, height: 96)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .shadow(color: DesignTokens.accentPurple.opacity(0.35), radius: 16, y: 6)
                            .padding(.top, 8)
                            .accessibilityLabel("Ahlign")

                        Text("Ahlign Premium")
                            .font(DesignTokens.Typography.screenTitle)
                            .foregroundStyle(.white)

                        Text("Start with a **3-day free trial**, then keep your full Root → Crown journey.")
                            .font(DesignTokens.Typography.subhead)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.75))
                            .padding(.horizontal, 24)

                        VStack(alignment: .leading, spacing: 10) {
                            bullet("Full 7-step guided journeys")
                            bullet("Premium voice for affirmations")
                            bullet("Customize repetitions & affirmations")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, DesignTokens.horizontalPadding)

                        planPicker

                        if let error = subscriptions.purchaseError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }

                        Button {
                            Task { await subscriptions.purchaseSelected() }
                        } label: {
                            Group {
                                if subscriptions.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text(ctaTitle)
                                        .font(.headline)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(DesignTokens.accentPurple)
                        .disabled(subscriptions.selectedProduct == nil || subscriptions.isLoading)

                        Button("Restore purchases") {
                            Task { await subscriptions.restorePurchases() }
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.55))

                        Text(legalCopy)
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.38))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                    }
                }
            }
            .preferredColorScheme(.dark)
            .toolbar {
                if allowsDismiss {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Not now") { dismiss() }
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
            .onChange(of: subscriptions.hasPremiumAccess) { _, hasAccess in
                if hasAccess { dismiss() }
            }
            .task { await subscriptions.refresh() }
        }
    }

    private var ctaTitle: String {
        if let trial = subscriptions.selectedProduct?.trialDescription {
            return "Start \(trial)"
        }
        return "Subscribe"
    }

    private var legalCopy: String {
        "Payment is charged to your Apple ID. Trial converts to a subscription unless canceled at least 24 hours before it ends. Manage in Settings → Apple ID → Subscriptions."
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(DesignTokens.accentPurple)
                .font(.subheadline)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
        }
    }

    @ViewBuilder
    private var planPicker: some View {
        if subscriptions.products.isEmpty {
            ProgressView("Loading plans…")
                .tint(.white)
                .padding()
        } else {
            VStack(spacing: 12) {
                if let yearly = subscriptions.yearlyProduct {
                    planRow(product: yearly, badge: "Best value")
                }
                if let monthly = subscriptions.monthlyProduct {
                    planRow(product: monthly, badge: nil)
                }
            }
            .padding(.horizontal, DesignTokens.horizontalPadding)
        }
    }

    private func planRow(product: Product, badge: String?) -> some View {
        let selected = subscriptions.selectedProductID == product.id
        return Button {
            subscriptions.selectedProductID = product.id
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(product.displayName)
                            .font(.headline)
                            .foregroundStyle(.white)
                        if let badge {
                            Text(badge)
                                .font(.caption2.weight(.semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(DesignTokens.accentPurple.opacity(0.35))
                                .clipShape(Capsule())
                        }
                    }
                    if let trial = product.trialDescription {
                        Text(trial)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.55))
                    }
                }
                Spacer()
                Text(product.displayPrice)
                    .font(.headline)
                    .foregroundStyle(.white)
                Image(systemName: selected ? "largecircle.fill.circle" : "circle")
                    .foregroundStyle(selected ? DesignTokens.accentPurple : .white.opacity(0.35))
            }
            .padding()
            .background(selected ? Color.white.opacity(0.12) : Color.white.opacity(0.06))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(selected ? DesignTokens.accentPurple : Color.clear, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}