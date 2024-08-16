import SwiftUI
import SwiftUICoordinator
import StoreKit

struct PayWall<Coordinator: Routing>: View {
    
    @EnvironmentObject var coordinator: Coordinator
    @StateObject var viewModel = ViewModel<Coordinator>()
    
    @StateObject var storeManager = StoreManager()
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometryProxy in
                VStack(spacing: 20) {
                    Spacer(minLength: 5)
                    Text("Create, edit, share✨")
                        .font(Font.custom("Montserrat-Bold", size: 40))
                        .foregroundColor(.white)
                        //.frame(width: 400)
                        .multilineTextAlignment(.center)
    
                    Text("Unlimited use of AI with the highest quality")
                        .font(Font.custom("Montserrat-Regular", size: 16))
                        .foregroundColor(.white)
                    Spacer(minLength: 20)
                    Image(.paywall)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 282, height: 282)
                        .cornerRadius(20)
                    Text("Start your 3 days trial Then 1$/week. Cancel anytime")
                        .font(Font.custom("Montserrat-SemiBold", size: 16))
                        //.frame(width: 250)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        //onSubmit()
                        viewModel.didTapNext()
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .frame(width: 100)
                            .padding()
                            .foregroundColor(.white)
                            .makeGradientButtonBackground()
                            .cornerRadius(180)
                    }
                    Spacer(minLength: 50)
                    HStack(alignment: .center, spacing: 20) {
                        Button(action: {

                        }) {
                            Text("Restore Purchases")
                                .font(Font.custom("Montserrat-Regular", size: 12))
                                .foregroundColor(.white)
                        }
                        Button(action: {

                        }) {
                            Text("Term of Services")
                                .font(Font.custom("Montserrat-Regular", size: 12))
                                .foregroundColor(.white)
                        }
                        Button(action: {

                        }) {
                            Text("Privacy Policy")
                                .font(Font.custom("Montserrat-Regular", size: 12))
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(
                    width: geometryProxy.size.width,
                    height: geometryProxy.size.height,
                    alignment: .top
                )
            }
            .makeViewGradientBackground()
            .overlay(alignment: .topTrailing) {
                Button(action: {
                    viewModel.didTapClose()
                }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                        .padding()
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.coordinator = coordinator
            storeManager.fetchProducts()
        }
    }
}

extension PayWall {
    @MainActor class ViewModel<R: Routing>: ObservableObject {
        var coordinator: R?
        
        func didTapNext() {
            //purchaseProduct()
            coordinator?.handle(WelcomeAction.toPhotoPicker)
        }
        
        func didTapClose() {
            //coordinator?.handle(MainAction.closePayWall)
            coordinator?.handle(WelcomeAction.toPhotoPicker)
        }
        
        func purchaseProduct() {
            let product = SKProduct()
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }
}

#Preview {
    PayWall<WelcomeCoordinator>().environmentObject(DependencyContainer.mockWelcomeCoordinator)
}
