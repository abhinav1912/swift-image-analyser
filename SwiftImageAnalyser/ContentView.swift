//

import SwiftUI
import PhotosUI
import UIKit

struct ContentView: View {
    @EnvironmentObject var viewModel: ClassificationViewModel
    @StateObject var navigationManager = NavigationManager.shared
    @State private var selectedItem: PhotosPickerItem?
    @State private var currentImage: SelectedImage?
    @State private var showError = false

    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            VStack {
                if let currentImage {
                    Text("Current selection")
                    currentImage.image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                    dismissButton
                    detectButton
                } else {
                    photoPicker
                    settingsButton
                }
            }
            .alert("Couldn't make predictions", isPresented: self.$showError) {
                Button("Ok", role: .cancel) {}
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .prediction(let result):
                    PredictionsView(predictions: result)
                case .settings:
                    UserPreferencesView()
                }
            }
            .onAppear {
                resetState()
            }
            .onChange(of: viewModel.predictions) { predictions in
                navigationManager.pushToStack(.prediction(result: predictions))
            }
        }
    }

    var photoPicker: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images
        ) {
            Label("Select a photo from your library", systemImage: "photo")
        }
        .onChange(of: selectedItem) { newItem in
            guard let newItem else { return }
            Task {
                if
                    let data = try? await newItem.loadTransferable(type: Data.self),
                    let image = UIImage(data: data),
                    let cgImage = image.cgImage
                {
                    await MainActor.run {
                        self.currentImage = SelectedImage(
                            image: Image(uiImage: image),
                            cgImage: cgImage
                        )
                    }
                }
            }
        }
    }

    var settingsButton: some View {
        Button(action: {
            navigationManager.pushToStack(.settings)
        }, label: {
            Text("Change settings")
        })
    }

    var dismissButton: some View {
        Button(action: {
            self.currentImage = nil
        }, label: {
            Label("Dismiss current selection", systemImage: "eraser")
        })
    }

    var detectButton: some View {
        Button(action: {
            if let currentImage {
                do {
                    try viewModel.detectObjects(for: currentImage.cgImage)
                } catch {
                    print(error)
                    self.showError = true
                }
            } else {
                self.showError = true
            }
        }, label: {
            Label("Detect objects in the image", systemImage: "checkmark")
        })
    }

    // MARK: Private methods

    private func resetState() {
        viewModel.predictions = []
        selectedItem = nil
        currentImage = nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct SelectedImage {
    let image: Image
    let cgImage: CGImage
}
