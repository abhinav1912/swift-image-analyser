//

import Foundation
import CoreML
import Vision

class ClassifierComposer {
    static func createImageClassifier() throws -> VNCoreMLModel {
        let defaultConfig = MLModelConfiguration()

        guard let imageClassifier = try? MobileNetV2(configuration: defaultConfig) else {
            throw CustomErrors.classifierInitFailed
        }

        guard let classifierVisionModel = try? VNCoreMLModel(for: imageClassifier.model) else {
            throw CustomErrors.visionModelInitFailed
        }

        return classifierVisionModel
    }
}

enum CustomErrors: Error {
    case classifierInitFailed
    case visionModelInitFailed
}
