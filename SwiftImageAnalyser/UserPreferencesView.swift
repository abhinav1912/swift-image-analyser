//

import SwiftUI

struct UserPreferencesView: View {
    @AppStorage("maxNumberOfPredictions") var maxNumberOfPredictions = 5
    @AppStorage("confidenceCutOff") var confidenceCutOff = 0.2

    var body: some View {
        Text("Max number of predictions")
            .padding()
        predictionCountSlider
            .padding()
        Text("\(maxNumberOfPredictions)")
        Divider()
        
        Text("Confidence cut-off")
            .padding()
        cutOffConfidenceSlider
            .padding()
        Text(String(format: "%.1f", confidenceCutOff))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
    }

    var predictionCountSlider: some View {
        Slider(
            value: maxNumberOfPredictionsProxy,
            in: 1...5,
            step: 1
        ) {
            Text("Max number of predictions")
        } minimumValueLabel: {
            Text("1")
        } maximumValueLabel: {
            Text("5")
        }
    }

    var cutOffConfidenceSlider: some View {
        Slider(
            value: $confidenceCutOff,
            in: 0.1...1,
            step: 0.1
        ) {
            Text("Confidence cut-off")
        } minimumValueLabel: {
            Text("0.1")
        } maximumValueLabel: {
            Text("1")
        }
    }

    var maxNumberOfPredictionsProxy: Binding<Double>{
            Binding<Double>(get: {
                return Double(maxNumberOfPredictions)
            }, set: {
                maxNumberOfPredictions = Int($0)
            })
        }
}

class UserPreferences: ObservableObject {

    static let sharedInstance = UserPreferences()

    private init() {}

    @AppStorage("maxNumberOfPredictions") var maxNumberOfPredictions = 5
    @AppStorage("confidenceCutOff") var confidenceCutOff = 0.2
}
