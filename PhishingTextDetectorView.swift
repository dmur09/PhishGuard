// PhishingTextDetector uses machine learning from PhishingIdentifier to display whether input text is a phishing attempt
// Ewan created a new dataset by sampling from the phishing dataset from https://huggingface.co/datasets/ealvaradob/phishing-dataset/tree/main and SMS spam dataset from https://www.kaggle.com/datasets/uciml/sms-spam-collection-dataset?resource=download
// The initial text detector view is from Dr. Cibrian's lesson implementing machine learning into Swift, Ewan added code here and there to conform the view to our app and aesthetics
// References: Dr. Cirbian's lesson on implementing machine learning into Swift

import SwiftUI

struct PhishingTextDetectorView: View {
    @State var phishingIdentifier = PhishingIdentifier()
    @State private var input = ""
    @Binding var currentScreen: Screen
    @Binding var previousScreen: Screen
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Phishing Text Detector") // title of the tool
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("""
                    Use the Phishing Text Detector to check suspicious text for phishing attempts. 
                    Enter or paste the text, and the app will analyze it for potential risks.
                    """) // decription of the tool
                .padding()
                .foregroundColor(.gray)
                
                Spacer()
                
                // Prediction Result
                Text(self.phishingIdentifier.prediction == "spam" ? "PHISHING DETECTED" : "No Phishing Detected") // Phishing vs no phishing detection to be read by the user
                    .font(.system(size: 30))
                    .fontWeight(.bold)
                    .padding()
                    .multilineTextAlignment(.center)
                
                // Confidence Level
                Text("Confidence: \(String(format: "%.2f", self.phishingIdentifier.confidence * 100))%") // converted Dr. Cibrian's initial decimal code to percentage for user readability
                    .font(.title2)
                    .foregroundColor(.gray)
                
                // Input Text Editor
                VStack(alignment: .leading) {
                    Text("Enter the text to analyze:")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    TextEditor(text: $input)
                        .font(.body)
                        .frame(height: 150)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10) // added rounded blue rectangle text input field to give the view a minimalistic and clean look
                                .stroke(Color.blue, lineWidth: 2)
                        )
                        .onChange(of: input) { oldValue, newValue in
                            if newValue.last == " " {
                                self.phishingIdentifier.predict(newValue)
                            }
                        }
                    
                    // Back Button
                    Button(action: {
                        currentScreen = previousScreen  // Use the previousScreen value, added by Diego for navigation
                    }) {
                        HStack {
                            Image(systemName: "arrow.left") // button for returning to PhishGuard's home screen
                            Text("Back")
                        }
                        .padding()
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Text Detector")
        }
    }
}
