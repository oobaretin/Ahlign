import Foundation
import StoreKit

enum PremiumProductID {
    static let monthly = "com.affirmapp.ChakraAffirmations.premium.monthly"
    static let yearly = "com.affirmapp.ChakraAffirmations.premium.yearly"
    static let all = [monthly, yearly]
}

@MainActor
final class SubscriptionManager: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var hasPremiumAccess = false
    @Published private(set) var isLoading = false
    @Published var purchaseError: String?
    @Published var selectedProductID = PremiumProductID.yearly

    private var updatesTask: Task<Void, Never>?

    var monthlyProduct: Product? {
        products.first { $0.id == PremiumProductID.monthly }
    }

    var yearlyProduct: Product? {
        products.first { $0.id == PremiumProductID.yearly }
    }

    var selectedProduct: Product? {
        products.first { $0.id == selectedProductID }
    }

    init() {
        updatesTask = Task { await observeTransactionUpdates() }
        Task { await refresh() }
    }

    deinit {
        updatesTask?.cancel()
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        await loadProducts()
        await refreshEntitlements()
    }

    private func loadProducts() async {
        do {
            let loaded = try await Product.products(for: PremiumProductID.all)
            products = loaded.sorted { $0.price < $1.price }
            if selectedProduct == nil {
                selectedProductID = PremiumProductID.yearly
            }
        } catch {
            purchaseError = "Could not load subscription options."
        }
    }

    func refreshEntitlements() async {
        var active = false
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if PremiumProductID.all.contains(transaction.productID) {
                active = true
                break
            }
        }
        hasPremiumAccess = active
    }

    func purchaseSelected() async {
        guard let product = selectedProduct else {
            purchaseError = "Select a plan to continue."
            return
        }
        await purchase(product)
    }

    func purchase(_ product: Product) async {
        purchaseError = nil
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    await refreshEntitlements()
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    func restorePurchases() async {
        purchaseError = nil
        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            purchaseError = "Restore failed. Try again or use your Apple ID subscriptions."
        }
    }

    private func observeTransactionUpdates() async {
        for await result in Transaction.updates {
            guard case .verified(let transaction) = result else { continue }
            await transaction.finish()
            await refreshEntitlements()
        }
    }
}

extension Product {
    var trialDescription: String? {
        guard let offer = subscription?.introductoryOffer else { return nil }
        if offer.paymentMode == .freeTrial {
            return formatPeriod(offer.period) + " free trial"
        }
        return nil
    }

    private func formatPeriod(_ period: Product.SubscriptionPeriod) -> String {
        switch (period.unit, period.value) {
        case (.day, 3): return "3-day"
        case (.day, let v): return "\(v)-day"
        case (.week, 1): return "1-week"
        case (.week, let v): return "\(v)-week"
        case (.month, 1): return "1-month"
        case (.month, let v): return "\(v)-month"
        case (.year, 1): return "1-year"
        case (.year, let v): return "\(v)-year"
        @unknown default: return "intro"
        }
    }
}