// Ewan implemented the Phishing Education tool that will provide an interactive list of tips to help users identify phishing
// Providing the user with a list of tips is made interactive and engaging with gestures and drop-downs
import SwiftUI
// Tip Model with Details and Expanded State
struct Tip {
    let title: String
    let details: String
    var isExpanded: Bool
}
struct PhishingEducationView: View {
    @State private var tips = [ //array of Tip objects, has a Boolean dictating whether the tip is expanded or not
        Tip(title: "Verify the sender's email address.", details: "Check if the email address looks legitimate or is from a trusted domain.", isExpanded: false),
        Tip(title: "Avoid clicking suspicious links.", details: "Hover over links to see the real URL and check for any inconsistencies.", isExpanded: false),
        Tip(title: "Check for spelling or grammar mistakes in messages.", details: "Phishing messages often have errors that legitimate companies avoid.", isExpanded: false),
        Tip(title: "Enable two-factor authentication (2FA).", details: "Adding an extra layer of security can help prevent unauthorized access.", isExpanded: false),
        Tip(title: "Use trusted antivirus software.", details: "Reliable antivirus programs can detect phishing attempts and malicious software.", isExpanded: false)
    ]
    @Binding var currentScreen: Screen
    @Binding var previousScreen: Screen // Diego added navigation through screens, connects back to PhishGuard's main menu
    var body: some View {
            ScrollView { // ScrollView allows the user to scroll through the tip list for readability
                VStack(alignment: .leading, spacing: 20) {
                    // Back Button
                    Button(action: {
                        currentScreen = previousScreen // navigation
                    }) {
                        HStack {
                            Image(systemName: "arrow.left") // button in UI to return to PhishGuard's main menu
                            Text("Back")
                        }
                        .padding()
                        .foregroundColor(.blue)
                    }
                    Text("Phishing Education") // Title
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    Text("""
                        Learn more about phishing tactics and how to protect yourself.
                        This section will provide educational resources on how to identify and avoid phishing attempts.
                        """) // Description
                    .foregroundColor(.gray)
                    Text("""
                    Phishing is a cyberattack where attackers trick users into revealing sensitive information such as usernames, passwords, or credit card details.
                    """)
                    .font(.body) // Phishing Definition
                    .padding()
                    // Iterate through the list, each tip has a button that toggles the isExpanded characteristic
                    ForEach(tips.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            Button(action: {
                                withAnimation {
                                    tips[index].isExpanded.toggle() // after the button is clicked, expand the tip
                                }
                            }) {
                                HStack {
                                    Text(tips[index].title) // horizontally display the tip title and the arrow button for expanding
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Spacer() // spacer between tip title and detail expansion button for user readability
                                    Image(systemName: tips[index].isExpanded ? "chevron.up" : "chevron.down") // Swift arrow image
                                        .foregroundColor(.blue)
                                }
                            }
                            if tips[index].isExpanded { // if the tip is expanded after the user taps on the button, display the tip's details
                                Text(tips[index].details)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding()
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
    }
}
