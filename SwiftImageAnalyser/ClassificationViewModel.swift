//

import SwiftUI
import Vision

class ClassificationViewModel: ObservableObject {
    lazy var classificationModel = getClassificationModel()
    var initError: CustomErrors? = nil
    @Published var results: String?
    @Published var predictions = [Prediction]()

    func detectObjects(for image: CGImage) throws {
        guard let classificationModel else {
            throw initError ?? CustomErrors.classifierInitFailed
        }
        let request = VNCoreMLRequest(model: classificationModel)
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

    // MARK: Private Methods
    private func getClassificationModel() -> VNCoreMLModel? {
        do {
            return try ClassifierComposer.createImageClassifier()
        } catch let error as CustomErrors {
            print(error)
            self.initError = error
        } catch {
            print("Unexpected Error.")
        }
        return nil
    }
}

struct Prediction {
    let identifier: String
    let confidencePercentage: String
}
