//

import SwiftUI
import Vision

class ClassificationViewModel: ObservableObject {
    let classificationModel: VNCoreMLModel
    @Published var results: String?
    @Published var predictions = [Prediction]()

    init() throws {
        self.classificationModel = try ClassifierComposer.createImageClassifier()
    }

    func detectObjects(for image: CGImage) throws {
        let request = VNCoreMLRequest(model: self.classificationModel)
        request.imageCropAndScaleOption = .centerCrop
        let handler = VNImageRequestHandler(cgImage: image)
        try handler.perform([request])

        guard let results = request.results as? [VNClassificationObservation] else {
            throw CustomErrors.noClassificationResults
        }

        let predictions = results.map { observation in
            Prediction(
                identifier: observation.identifier,
                confidencePercentage: observation.confidence.description
            )
        }

        guard predictions.count > .zero else {
            throw CustomErrors.noClassificationResults
        }

        self.predictions = predictions
    }
}

struct Prediction {
    let identifier: String
    let confidencePercentage: String
}
