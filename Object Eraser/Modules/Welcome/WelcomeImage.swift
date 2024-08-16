import SwiftUI

struct WelcomeImage: View {
    let imageUrl: URL
    
    var body: some View {
        AsyncImage(url: imageUrl) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
            case .failure(let error):
                Text("Failed to load image: \(error.localizedDescription)")
            case .empty:
                Text("Loading...")
            @unknown default:
                Text("Loading...")
            }
        }
    }
}

#Preview {
    WelcomeImage(imageUrl: URL(string: "https://fiverr-res.cloudinary.com/images/t_main1,q_auto,f_auto,q_auto,f_auto/gigs/272168124/original/8c9cd2bd515b97d48d1398bb1ea36b4113805ecd/remove-unwanted-object-or-person-and-background-from-image.jpg")!)
}
