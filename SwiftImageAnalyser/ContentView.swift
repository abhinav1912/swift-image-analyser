//

import SwiftUI
import PhotosUI
import UIKit

struct ContentView: View {
    @EnvironmentObject var viewModel: ClassificationViewModel
    @StateObject var navigationManager = NavigationManager.shared

    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            VStack {
                if let currentImage = viewModel.currentImage {
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
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .prediction(let result):
                    PredictionsView(predictions: result)
                case .settings:
                    UserPreferencesView()
                }
            }
            .onAppear {
                viewModel.resetState()
            }
            .onChange(of: viewModel.predictions) { predictions in
                if !predictions.isEmpty {
                    navigationManager.pushToStack(.prediction(result: predictions))
                }
            }
            .alert(
                "Error while detecting objects",
                isPresented: $viewModel.showError,
                actions: {
                    Button("Okay", role: .cancel) {}
                },
                message: {
                    Text("Please try again.")
                })
        }
    }

    var photoPicker: some View {
        PhotosPicker(
            selection: $viewModel.selectedItem,
            matching: .images
        ) {
            Label("Select a photo from your library", systemImage: "photo")
        }
        .onChange(of: viewModel.selectedItem) { newItem in
            guard let newItem else { return }
            Task {
                if
                    let data = try? await newItem.loadTransferable(type: Data.self),
                    let image = UIImage(data: data),
                    let cgImage = image.cgImage
                {
                    await MainActor.run {
                        viewModel.currentImage = SelectedImage(
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
            viewModel.currentImage = nil
        }, label: {
            Label("Dismiss current selection", systemImage: "eraser")
        })
    }

    var detectButton: some View {
        Button(action: {
            if let currentImage = viewModel.currentImage {
                do {
                    try viewModel.detectObjects(for: currentImage.cgImage)
                } catch {
                    print(error)
                    viewModel.showError = true
                }
            } else {
                viewModel.showError = true
            }
        }, label: {
            Label("Detect objects in the image", systemImage: "checkmark")
        })
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
