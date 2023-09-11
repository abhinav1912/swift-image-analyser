//

import Foundation
import CoreML
import Vision

enum ClassificationModel: String, CaseIterable {
    case resnet50
    case mobileNetV2
    case squeezeNet
}

struct Classifier {
    let modelType: ClassificationModel
    let coreModel: VNCoreMLModel
}

class ClassifierComposer {
    static func createImageClassifier(for model: ClassificationModel) throws -> VNCoreMLModel {
        let defaultConfig = MLModelConfiguration()

        let model = try loadMLModel(for: model)

        guard let classifierVisionModel = try? VNCoreMLModel(for: model) else {
            throw CustomErrors.visionModelInitFailed
        }

        return classifierVisionModel
    }

    static func loadMLModel(for model: ClassificationModel) throws -> MLModel {
        let defaultConfig = MLModelConfiguration()
        switch model {
        case .resnet50:
            guard let imageClassifier = try? Resnet50(configuration: defaultConfig) else {
                throw CustomErrors.classifierInitFailed
            }
            return imageClassifier.model
        case .mobileNetV2:
            guard let imageClassifier = try? MobileNetV2(configuration: defaultConfig) else {
                throw CustomErrors.classifierInitFailed
            }
            return imageClassifier.model
        case .squeezeNet:
            guard let imageClassifier = try? SqueezeNet(configuration: defaultConfig) else {
                throw CustomErrors.classifierInitFailed
            }
            return imageClassifier.model
        }
    }
}

enum CustomErrors: Error {
    case classifierInitFailed
    case visionModelInitFailed
    case noClassificationResults
}
