import SwiftUI
import Photos
import SwiftUICoordinator
import PhotosUI

struct PhotoPicker<Coordinator: Routing>: View {
    @State private var images: [UIImage?] = []
    @State private var allAssets: [PHAsset] = []
    @State private var isLoading: Bool = false
    @State private var lastLoadedIndex: Int = 0
    
    @EnvironmentObject var coordinator: Coordinator
    @StateObject var viewModel = ViewModel<Coordinator>()
    
    var body: some View {
        NavigationView {
            GeometryReader { geometryProxy in
                VStack {
                    if !images.isEmpty {
                        ZStack {
                            ScrollView {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                                    ForEach(images.indices, id: \.self) { index in
                                        if let image = images[index] {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 100, height: 100)
                                                .cornerRadius(10)
                                                .onTapGesture {
                                                    viewModel.selectedImage = image
                                                    viewModel.selectedAsset = allAssets[index]
                                                }
                                                .overlay(alignment: .topTrailing) {
                                                    if viewModel.selectedImage == image {
                                                        Image(systemName: "checkmark.circle")
                                                            .frame(width: 20, height: 20)
                                                            .padding(4)
                                                            .foregroundStyle(.white, .white)
                                                            .background(.green)
                                                            .clipShape(.circle)
                                                            .offset(x: 5, y: -5)
                                                    }
                                                }
                                                .onAppear {
                                                    loadImage(at: index)
                                                    if index == images.count - 1 {
                                                        Task {
                                                            await loadMorePhotos()
                                                        }
                                                    }
                                                }
                                                .onDisappear {
                                                    images[index] = nil
                                                }
                                        } else {
                                            Color.gray
                                                .frame(width: 100, height: 100)
                                                .cornerRadius(10)
                                                .onAppear {
                                                    loadImage(at: index)
                                                }
                                        }
                                    }
                                }
                                .padding()
                            }
                            VStack {
                                Spacer()
                                Button(action: {
                                    viewModel.didTapChosePhoto()
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
                        }
                        
                    } else {
                        Spacer()
                        Text("No images to select")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
                .frame(
                    width: geometryProxy.size.width,
                    height: geometryProxy.size.height,
                    alignment: .top
                )
                .makeViewGradientBackground()
            }
        }
        .navigationBarHidden(true)
        .task {
            await fetchPhotos()
            viewModel.coordinator = coordinator
        }
    }
    
    private func fetchPhotos() async {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        guard status == .authorized else {
            print("Access to photo library denied or restricted.")
            return
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        let assets = fetchResult.objects(at: IndexSet(integersIn: 0..<fetchResult.count))
        await MainActor.run {
            self.allAssets = assets
            self.images = Array(repeating: nil, count: assets.count)
        }
        
        await loadMorePhotos()
    }
    
    private func loadMorePhotos() async {
        guard !isLoading else { return }
        isLoading = true
        
        let nextIndex = min(lastLoadedIndex + 10, allAssets.count)
        let assetsToLoad = Array(allAssets[lastLoadedIndex..<nextIndex])
        
        await withTaskGroup(of: (Int, UIImage?).self) { group in
            for (index, asset) in assetsToLoad.enumerated() {
                group.addTask {
                    let image = await self.loadImage(for: asset)
                    return (index, image)
                }
            }
            
            for await (index, image) in group {
                self.images[self.lastLoadedIndex + index] = image
            }
        }
        
        lastLoadedIndex = nextIndex
        isLoading = false
    }
    
    private func loadImage(for asset: PHAsset) async -> UIImage? {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        
        guard let result = try? await PHImageManager.default().requestImage2(
            for: asset,
            targetSize: CGSize(width: 100, height: 100),
            contentMode: .aspectFill,
            options: requestOptions) else {
            return nil
        }
        
        return self.downsample(image: result)
    }
    
    private func loadImage(at index: Int) {
        guard images[index] == nil else { return }
        Task {
            let asset = allAssets[index]
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = false
            
            guard let result = try? await PHImageManager.default().requestImage2(
                for: asset,
                targetSize: CGSize(width: 100, height: 100),
                contentMode: .aspectFill,
                options: requestOptions
            ) else {
                return
            }
            
            self.images[index] = self.downsample(image: result)
        }
    }
    
    private func downsample(image: UIImage, to pointSize: CGSize = CGSize(width: 100, height: 100), scale: CGFloat = UIScreen.main.scale) -> UIImage {
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        guard let data = image.pngData() else { return image }
        
        let options = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                       kCGImageSourceShouldCacheImmediately: true,
                       kCGImageSourceCreateThumbnailWithTransform: true,
                       kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
        
        let source = CGImageSourceCreateWithData(data as CFData, nil)!
        let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options)!
        
        return UIImage(cgImage: cgImage)
    }
}

extension PhotoPicker {
    @MainActor class ViewModel<R: Routing>: ObservableObject {
        var coordinator: R?
        
        @Published var selectedImage: UIImage?
        @Published var selectedAsset: PHAsset?
        
        func didTapChosePhoto() {
            if let selectedAsset {
                coordinator?.handle(MainAction.toPhotoEditor(MainRoute.photoEditor(selectedAsset)))
            }
        }
        
        func showPayWall() {
            coordinator?.handle(MainAction.toPaywall)
        }
        
    }
}

#Preview {
    PhotoPicker<MainCoordinator>().environmentObject(DependencyContainer.mockMainCoordinator)
}
