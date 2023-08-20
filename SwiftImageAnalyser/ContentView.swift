//

import SwiftUI
import PhotosUI
import UIKit

struct ContentView: View {
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            Text("Select a photo from your library")
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                if
                    let data = try? await newItem?.loadTransferable(type: Data.self),
                    let image = UIImage(data: data)
                {
                    print(image.size)
                    // process image
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
