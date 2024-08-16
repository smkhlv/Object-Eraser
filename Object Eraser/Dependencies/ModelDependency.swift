import Vision
import UIKit
import CoreImage
public final class ModelDependency {
    
    public static let shared = ModelDependency()
    
    init() {
        guard let model = try? VNCoreMLModel(for: RMBG().model) else {
            return
        }
        segmentationRequest = VNCoreMLRequest(model: model)
        segmentationRequest?.imageCropAndScaleOption = .scaleFill
        guard let ciImage = CIImage(image: UIImage()) else { print("Image processing failed.Please try with another image."); return }
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        guard let segmentationRequest = segmentationRequest else {
            print("This func can't be used in this OS version."); return
        }
        try? handler.perform([segmentationRequest])
    }
    
    public var segmentationRequest: VNCoreMLRequest?
}
