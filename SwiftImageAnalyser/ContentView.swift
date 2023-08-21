//

import SwiftUI
import PhotosUI
import UIKit

struct ContentView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var currentImage: Image?

    var body: some View {
        if let currentImage {
            VStack {
                Text("Current selection")
                currentImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                dismissButton
                detectButton
            }
        } else {
            photoPicker
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
            Task {
                if
                    let data = try? await newItem?.loadTransferable(type: Data.self),
                    let image = UIImage(data: data)
                {
                    await MainActor.run {
                        self.currentImage = Image(uiImage: image)
                    }
                    // process image
                }
            }
        }
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
            self.currentImage = nil
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
