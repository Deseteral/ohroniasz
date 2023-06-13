import SwiftUI

struct WelcomeView: View {
    let onFolderPicked : (String) -> ()
    
    var body: some View {
        VStack {
            Image(systemName: "car.front.waves.up.fill")
                .font(.largeTitle)
                .padding(.bottom, 4)
            
            Text("Open *TeslaCam* folder with the footage you would like to watch.")

            Button("Select", action: self.selectFolder)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
        }
        .padding()
    }
    
    private func selectFolder() {
        let folderPicker = NSOpenPanel()
        
        folderPicker.title = "Select TeslaCam folder";
        folderPicker.showsResizeIndicator = false;
        folderPicker.showsHiddenFiles = false;
        folderPicker.canChooseDirectories = true
        folderPicker.canChooseFiles = false
        folderPicker.allowsMultipleSelection = false
        
        folderPicker.begin { response in
            guard response == .OK else { return }
            
            let pickedFolderPath = folderPicker.url!.path
            self.onFolderPicked(pickedFolderPath)
        }
    }
}
