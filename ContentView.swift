// Diego wrote the code for this file
// This content view handles scene changing and the main menu, along with button to change scenes to the other individual views
// Cursor helped come up with the idea of of having scenes and values for each, and saving a current/previous scene to reference and switch between for all views
import SwiftUI

// An enum that acts a scene value holder, to reference for when a scene change is required
enum Screen {
    case home // home/main menu scene
    case qrScanner // QR scanner scene
    case phishingTextDetector // phishing text detector scene
    case PhishingNews // phishing news scene
    case phishingEducation // phishing education scene
    case scanning // QR camera scanning scene
}


struct ContentView: View {
    @State private var currentScreen: Screen = .home // keeps track of the current scene
    @State private var previousScreen: Screen = .home // keeps track of the previous
    
    var body: some View {
        ZStack {
            // changes the color of the app to black
            Color.black.edgesIgnoringSafeArea(.all)
            
            // a switch case that checks the enum value of the current scene, then references the correct scene file
            switch currentScreen {
            case .home:
                homeMenu
            case .qrScanner:
                QRScannerView(currentScreen: $currentScreen, previousScreen: $previousScreen) // for QR code scanner
            case .scanning:
                QRScannerScene(currentScreen: $currentScreen, previousScreen: $previousScreen) // for camera scene once scanning starts
            case .phishingTextDetector:
                PhishingTextDetectorView(currentScreen: $currentScreen, previousScreen: $previousScreen) // phishing text detector
            case .PhishingNews:
                PhishingNewsView(currentScreen: $currentScreen, previousScreen: $previousScreen) // phishing news scene
            case .phishingEducation:
                PhishingEducationView(currentScreen: $currentScreen, previousScreen: $previousScreen) // phishing education scene
            }
        }
    }
    
    // the home menu set up, with text and image inside a vstack
    var homeMenu: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("PhishGuard")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                Image("MyImage") // logo image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                Text("The ultimate app for your digital protection")
                    .font(.title)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                // Buttons that lead to each scene, listed one after another
                VStack(spacing: 20) {
                    // QR code scanner button, with correct scene var updating
                    FeatureButton(title: "QR Code Scanner", iconName: "qrcode.viewfinder") {
                        previousScreen = .home
                        currentScreen = .qrScanner
                    }
                    // Phishing text detector button
                    FeatureButton(title: "Phishing Text Detector", iconName: "exclamationmark.shield") {
                        previousScreen = .home
                        currentScreen = .phishingTextDetector
                    }
                    // dailty phishing news button
                    FeatureButton(title: "Daily Phishing News", iconName: "newspaper") {
                        previousScreen = .home
                        currentScreen = .PhishingNews
                    }
                    // phishing education button
                    FeatureButton(title: "Phishing Education", iconName: "graduationcap") {
                        previousScreen = .home
                        currentScreen = .phishingEducation
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

// custom button used to natvigate the scenes in app
struct FeatureButton: View {
    var title: String
    var iconName: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: iconName) // icon image next to text
                Text(title)
                    .font(.title2)
                    .bold()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }
}
