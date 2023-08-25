//

import SwiftUI

struct PredictionsView: View {
    let predictions: [Prediction]

    init(predictions: [Prediction]) {
        self.predictions = predictions
    }

    var body: some View {
        ForEach(predictions, id: \.identifier) { prediction in
            Text("\(prediction.identifier): \(prediction.confidencePercentage)")
        }
    }
}
