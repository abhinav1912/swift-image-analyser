//

import Foundation

struct Prediction: Hashable {
    let uuid: UUID = UUID()
    let identifier: String
    let confidencePercentage: String
    let model: ClassificationModel
}
