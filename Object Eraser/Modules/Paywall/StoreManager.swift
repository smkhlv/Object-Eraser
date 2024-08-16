import StoreKit


public class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    @Published var myProducts = [SKProduct]()
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        fetchProducts()
    }
    
    func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: ["com.yourapp.productid"])
        request.delegate = self
        request.start()
    }
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count > 0 {
            myProducts = response.products
        }
    }
    
    func buyProduct(product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            print("User can't make payments")
        }
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                print("Purchase successful")
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                print("Purchase failed")
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                print("Purchase restored")
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
}
