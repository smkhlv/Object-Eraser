import SwiftUI
import SwiftUICoordinator

struct WelcomeView<Coordinator: Routing>: View {
    
    @EnvironmentObject var coordinator: Coordinator
    @StateObject var viewModel = ViewModel<Coordinator>()
    
    @State private var isNextScreenActive = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometryProxy in
                VStack(spacing: 20) {
                    //Spacer(minLength: 5)
                    Spacer()
                    Text("Magic AI editing")
                        .font(Font.custom("Montserrat-Bold", size: 40))
                        //.frame(width: 150)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    Text("Just 1 click and unwanted objects will be removed")
                        .font(Font.custom("Montserrat-Regular", size: 16))
                        //.frame(width: 209)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(20)
                    Image(.welcome)
                    
                    Button(action: {
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
                    .padding(50)
                }
                .frame(
                    width: geometryProxy.size.width,
                    height: geometryProxy.size.height,
                    alignment: .top
                )
            }
            .makeViewGradientBackground()
        }
        .onAppear {
            viewModel.coordinator = coordinator
        }
        .navigationBarHidden(true)
    }
    
    func onSubmit() {
        self.isNextScreenActive = true
    }
}

extension WelcomeView {
    @MainActor class ViewModel<R: Routing>: ObservableObject {
        var coordinator: R?
        
        func didTapNext() {
            coordinator?.handle(WelcomeAction.toPaywall)
        }
    }
}

#Preview {
    WelcomeView<WelcomeCoordinator>().environmentObject(DependencyContainer.mockWelcomeCoordinator)
}
