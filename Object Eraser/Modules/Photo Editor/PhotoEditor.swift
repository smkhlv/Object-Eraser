import SwiftUI
import Photos
import SwiftUICoordinator
import Vision

public struct GrouppedColors: Hashable {
    var imageName: String?
    var color: Color?
}

struct PhotoEditor<Coordinator: Routing>: View {
    
    @EnvironmentObject var coordinator: Coordinator
    @StateObject var viewModel = ViewModel<Coordinator>()
    
    @State var asset: PHAsset
    
    let preparedColors: [GrouppedColors] = [
        GrouppedColors(imageName: "erased"),
        GrouppedColors(color: .red),
        GrouppedColors(color: .yellow),
        GrouppedColors(
            color: .green
        ),
        GrouppedColors(
            color: .blue
        ),
        GrouppedColors(
            color: .purple
        ),
        GrouppedColors(
            color: .brown
        ),
        GrouppedColors(
            color: .cyan
        ),
        GrouppedColors(
            color: .gray
        )
    ]
    @State private var backgroundViewColor: Color = .clear
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometryProxy in
                VStack(spacing: 20) {
                    if let image = viewModel.image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 300, height: 460)
                            .cornerRadius(20)
                            .padding(52)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(preparedColors, id: \.self) { model in
                                if let image = model.imageName {
                                    Image(image)
                                        .resizable()
                                        .frame(width: 34, height: 34)
                                        .clipShape(Circle())
                                        .onTapGesture {
                                            viewModel.didTapEraseBackground()
                                        }
                                }
                                if let color = model.color {
                                    Circle()
                                        .foregroundColor(color)
                                        .frame(width: 34, height: 34)
                                        .onTapGesture {
                                            viewModel.selectedColor = color
                                            viewModel.didTapColor()
                                        }
                                }
                            }
                        }
                        .padding(12)
                    }
                    .frame(width: 300, height: 70)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(20)
                }
                .frame(
                    width: geometryProxy.size.width,
                    height: geometryProxy.size.height,
                    alignment: .center
                )
            }
            .makeViewGradientBackground()
        }
        .accentColor(.white)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.selectedColor == .clear,
                   let image = viewModel.erasedForSharing() {
                    let photo = Photo(image: Image(uiImage: image), caption: "Edited image")
                    ShareLink(item: photo, preview: SharePreview(photo.caption,  image: photo.image))
                        .offset(x: 20, y: -20)
                } else if let image = viewModel.image {
                    let photo = Photo(image: Image(uiImage: image), caption: "Edited image")
                    ShareLink(item: photo, preview: SharePreview(photo.caption,  image: photo.image))
                        .offset(x: 20, y: -20)
                }
            }
        }
        .onAppear {
            viewModel.loadImage(for: asset)
            viewModel.coordinator = coordinator
        }
    }
}

struct Photo: Transferable {
    
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.image)
    }
    var image: Image
    var caption: String
}

extension PhotoEditor {
    @MainActor class ViewModel<R: Routing>: ObservableObject {
        var coordinator: R?
        
        @Published var selectedColor: Color = .clear
        
        @Published var originalImage: UIImage? {
            didSet {
                image = originalImage
            }
        }
        
        @Published var image: UIImage? {
            didSet {
                objectWillChange.send()
            }
        }
        
        public func loadImage(for asset: PHAsset)  {
            Task {
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = false
                
                originalImage = try? await PHImageManager.default().requestImage2(
                    for: asset,
                    targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
                    contentMode: .aspectFill,
                    options: requestOptions)
            }
        }
        
        private func imageFromColor(color: UIColor, size: CGSize = CGSize(width: 1, height: 1), scale: CGFloat) -> UIImage? {
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            color.setFill()
            UIRectFill(CGRect(origin: .zero, size: size))
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        
        let ciContext = CIContext()
        
        public func swapBackgroundOfPerson(personUIImage: UIImage, backgroundUIImage: UIImage) -> UIImage? {
            let newPersonUIImage = getCorrectOrientationUIImage(uiImage:personUIImage)
            let newBackgroundUIImage = getCorrectOrientationUIImage(uiImage:backgroundUIImage)
            
            guard let personCIImage = CIImage(image: newPersonUIImage),
                  let backgroundCIImage = CIImage(image: newBackgroundUIImage),
                  let maskUIImage = personMaskImage(uiImage: newPersonUIImage),
                  let maskCIImage = CIImage(image: maskUIImage) else {
                return nil }
            
            let backgroundImageSize = backgroundCIImage.extent
            let originalSize = personCIImage.extent
            var scale:CGFloat = 1
            let widthScale =  originalSize.width / backgroundImageSize.width
            let heightScale = originalSize.height / backgroundImageSize.height
            if widthScale > heightScale {
                scale = personCIImage.extent.width / backgroundImageSize.width
            } else {
                scale = personCIImage.extent.height / backgroundImageSize.height
            }
            
            let scaledBG = backgroundCIImage.resize(as: CGSize(width: backgroundCIImage.extent.width*scale, height: backgroundCIImage.extent.height*scale))
            let BGCenter = CGPoint(x: scaledBG.extent.width/2, y: scaledBG.extent.height/2)
            let originalExtent = personCIImage.extent
            let cropRect = CGRect(x: BGCenter.x-(originalExtent.width/2), y: BGCenter.y-(originalExtent.height/2), width: originalExtent.width, height: originalExtent.height)
            let croppedBG = scaledBG.cropped(to: cropRect)
            let translate = CGAffineTransform(translationX: -croppedBG.extent.minX, y: -croppedBG.extent.minY)
            let traslatedBG = croppedBG.transformed(by: translate)
            guard let blended = CIFilter(name: "CIBlendWithMask", parameters: [
                kCIInputImageKey: personCIImage,
                kCIInputBackgroundImageKey:traslatedBG,
                kCIInputMaskImageKey:maskCIImage])?.outputImage else { return nil }
            guard let safeCGImage = ciContext.createCGImage(blended, from: blended.extent) else { print("Image processing failed.Please try with another image.") ; return nil }
            let blendedUIImage = UIImage(cgImage: safeCGImage)
            return blendedUIImage
        }
        
        public func personMaskImage(uiImage:UIImage) -> UIImage? {
            let newImage = getCorrectOrientationUIImage(uiImage:uiImage)
            guard let ciImage = CIImage(image: newImage) else { print("Image processing failed.Please try with another image."); return nil }
            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            do {
                guard let segmentationRequest = ModelDependency.shared.segmentationRequest else {
                    print("This func can't be used in this OS version."); return nil
                }
                try handler.perform([segmentationRequest])
                guard let result = segmentationRequest.results?.first as? VNPixelBufferObservation
                else { print("Image processing failed.Please try with another image.") ; return nil }
                let maskCIImage = CIImage(cvPixelBuffer: result.pixelBuffer)
                let scaledMask = maskCIImage.resize(as: CGSize(width: ciImage.extent.width, height: ciImage.extent.height))
                
                guard let safeCGImage = ciContext.createCGImage(scaledMask, from: scaledMask.extent) else { print("Image processing failed.Please try with another image.") ; return nil }
                let maskUIImage = UIImage(cgImage: safeCGImage)
                return maskUIImage
            } catch let error {
                print("Vision error \(error)")
                return nil
            }
        }
        
        public func getCorrectOrientationUIImage(uiImage:UIImage) -> UIImage {
            var newImage = UIImage()
            switch uiImage.imageOrientation.rawValue {
            case 1:
                guard let orientedCIImage = CIImage(image: uiImage)?.oriented(CGImagePropertyOrientation.down),
                      let cgImage = ciContext.createCGImage(orientedCIImage, from: orientedCIImage.extent) else { return uiImage}
                
                newImage = UIImage(cgImage: cgImage)
            case 3:
                guard let orientedCIImage = CIImage(image: uiImage)?.oriented(CGImagePropertyOrientation.right),
                      let cgImage = ciContext.createCGImage(orientedCIImage, from: orientedCIImage.extent) else { return uiImage}
                newImage = UIImage(cgImage: cgImage)
            default:
                newImage = uiImage
            }
            return newImage
        }
        
        func didTapShare() {
            //coordinator?.handle(MainAction.toPhotoEditor)
        }
        
        private func invertImage(_ image: UIImage) -> UIImage? {
            guard let ciImage = CIImage(image: image) else { return nil }
            guard let filter = CIFilter(name: "CIColorInvert") else { return nil }
            
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            
            guard let outputCIImage = filter.outputImage else { return nil }
            guard let safeCGImage = ciContext.createCGImage(outputCIImage, from: outputCIImage.extent) else { return nil }
            
            return UIImage(cgImage: safeCGImage)
        }
        
        func erasedForSharing() -> UIImage? {
            guard let image,
            let maskedImage = personMaskImage(uiImage: image) else {
                return nil
            }
            
            // Invert the mask
            guard let invertedMask = invertImage(maskedImage) else {
                return nil
            }
            
            guard let maskRef = invertedMask.cgImage,
                  let mask = CGImage(maskWidth: maskRef.width,
                                     height: maskRef.height,
                                     bitsPerComponent: maskRef.bitsPerComponent,
                                     bitsPerPixel: maskRef.bitsPerPixel,
                                     bytesPerRow: maskRef.bytesPerRow,
                                     provider: maskRef.dataProvider!,
                                     decode: nil,
                                     shouldInterpolate: false) else {
                return nil
            }

            guard let masked = image.cgImage?.masking(mask) else { return nil }
            return UIImage(cgImage: masked)
        }
        
//        @objc func didTapShareButton() {
//            if selectedColor == .clear,
//                let image = erasedForSharing() {
//                let photo = Photo(image: Image(uiImage: image), caption: "Edited image")
//                ShareLink(item: photo, preview: SharePreview(photo.caption,  image: photo.image))
//            } else if let image = image {
//                let photo = Photo(image: Image(uiImage: image), caption: "Edited image")
//                ShareLink(item: photo, preview: SharePreview(photo.caption,  image: photo.image))
//            }
//        }
        
        func didTapColor() {
            guard let image = self.originalImage,
                  let bgImage = imageFromColor(
                    color: UIColor(selectedColor),
                    size: image.size,
                    scale: image.scale
                  ) else {
                debugPrint("can't get image")
                return
            }
            
            
            self.image = swapBackgroundOfPerson(personUIImage: image, backgroundUIImage: bgImage)
            print("selected color is \(selectedColor.description)")
        }
        
        func didTapEraseBackground() {
            selectedColor = .clear
            guard
                let image = self.originalImage,
                let bgImage = imageFromColor(
                    color: UIColor(.white),
                    size: image.size,
                    scale: image.scale
                ) else {
                debugPrint("can't get image")
                return
            }
            
            
            self.image = swapBackgroundOfPerson(personUIImage: image, backgroundUIImage: bgImage)
            print("selected color is \(selectedColor.description)")
        }
        
        func showPayWall() {
            coordinator?.handle(MainAction.toPaywall)
        }
    }
}

//#Preview {
//PhotoEditor<MainCoordinator>(image: UIImage(named: "welcome")!)
//   .environmentObject(DependencyContainer.mockMainCoordinator)
//}
