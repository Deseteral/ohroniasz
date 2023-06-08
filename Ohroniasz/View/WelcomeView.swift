import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack {
            Image(systemName: "car.front.waves.up.fill")
                .font(.largeTitle)
                .padding(.bottom, 4)
            
            Text("Open *TeslaCam* folder with the footage you would like to watch.")
            
            Button("Select") {
                self.selectFolder()
            }
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
            if response == .OK {
                let pickedFolderPath = folderPicker.url!.path
                print(pickedFolderPath)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
