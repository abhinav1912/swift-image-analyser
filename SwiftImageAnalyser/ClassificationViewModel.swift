//

import SwiftUI
import Vision

class ClassificationViewModel: ObservableObject {
    lazy var classifiers = getClassificationModels()
    var initError: CustomErrors? = nil
    @Published var predictions = [Prediction]()
    @ObservedObject var userPreferences: UserPreferences

    init(userPreferences: UserPreferences) {
        self.userPreferences = userPreferences
    }

    func detectObjects(for image: CGImage) throws {
        guard classifiers.count > .zero else {
            throw initError ?? CustomErrors.classifierInitFailed
        }
        var allPredictions = [Prediction]()
        for classifier in classifiers {
            do {
                let predictions = try makePredictions(for: image, using: classifier)
                allPredictions += predictions
            } catch {
                print(error.localizedDescription)
            }
        }
        self.predictions.append(contentsOf: allPredictions)
    }

    func makePredictions(for image: CGImage, using classifier: Classifier) throws -> [Prediction] {
        let request = VNCoreMLRequest(model: classifier.coreModel)
        request.imageCropAndScaleOption = .centerCrop
        let handler = VNImageRequestHandler(cgImage: image)
        try handler.perform([request])

        guard let results = request.results as? [VNClassificationObservation] else {
            throw CustomErrors.noClassificationResults
        }

        var predictions = results.map { observation in
            Prediction(
                identifier: observation.identifier,
                confidencePercentage: observation.confidence.description,
                model: classifier.modelType
            )
        }

        predictions = predictions.filter {
            Double($0.confidencePercentage) ?? .zero >= userPreferences.confidenceCutOff
        }

        if predictions.count > userPreferences.maxNumberOfPredictions {
            predictions = Array(predictions[0..<userPreferences.maxNumberOfPredictions])
        }

        guard predictions.count > .zero else {
            throw CustomErrors.noClassificationResults
        }

        return predictions
    }

    // MARK: Private Methods
    private func getClassificationModels() -> [Classifier] {
        var models = [Classifier]()
        for classificationModel in ClassificationModel.allCases {
            do {
                let classifier = try ClassifierComposer.createImageClassifier(for: classificationModel)
                models.append(
                    Classifier(
                        modelType: classificationModel,
                        coreModel: classifier
                    )
                )
            } catch let error as CustomErrors {
                print(error)
                self.initError = error
            } catch {
                print("Unexpected Error.")
            }
        }
        return models
    }
}

struct Prediction: Hashable {
    let uuid: UUID = UUID()
    let identifier: String
    let confidencePercentage: String
    let model: ClassificationModel
}
