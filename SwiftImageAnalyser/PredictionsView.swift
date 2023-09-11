//

import SwiftUI

struct PredictionsView: View {
    let predictions: [Prediction]

    init(predictions: [Prediction]) {
        self.predictions = predictions
    }

    var body: some View {
        ForEach(predictions, id: \.uuid) { prediction in
            Text("\(prediction.model.rawValue.capitalized) - \(prediction.identifier): \(prediction.confidencePercentage)")
        }
    }
}
