// Ewan implemented the Phishing News tool that will provide a list of top news stories regarding phishing
// Up-to-date news on threats and trends keep users informed
// Implements NewsAPI to fetch news stories
// References: Cukmekerb's Coding Class (https://www.youtube.com/watch?v=yY0ciWj8oco) gave me an overview of News API, an API I have not used before.
// References: Additioanlly, Chat-GPT helped me with the fetchNews functiona and taught me how to create a URL session to fetch news articles from News API.
import SwiftUI

// the following are defined outside the view as the API news article models are independent from the UI of the app
// model for API Response
struct NewsAPIResponse: Decodable {
    let articles: [APIArticle] // the array of articles in the API response.
}

// model for an API article, raw structure of each article as returned by the API, maps to JSON keys in the API response, decodeable and not ready for Swift (cannot be stored in a list)
struct APIArticle: Decodable {
    let title: String
    let description: String?
    let url: String
}

// News Article Model, processed version of an article, ready for use in the app's UI, identifiable and ready for Swift (can be stored in a list)
struct NewsArticle: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let url: String
}

struct PhishingNewsView: View {
    @State private var newsArticles: [NewsArticle] = [] // store news articles in an array data structure, each index stores ID, title, description, and URL
    @State private var isLoading = true
    @State private var errorMessage: String?
    @Binding var currentScreen: Screen
    @Binding var previousScreen: Screen  // Diego added these two new bindings to interconnect PhishGuard home screen to the Phishing News screen

    // Phishing News view,
    var body: some View {
        VStack { // Correctly wraps all elements in a single VStack to avoid overlay issues
            // Back Button
            HStack {
                Button(action: {
                    currentScreen = previousScreen // navigation
                }) {
                    HStack {
                        Image(systemName: "arrow.left") // button in UI to return to PhishGuard's main menu
                        Text("Back")
                    }
                }
                Spacer() // Ensures Back button stays to the left
            }
            .padding()
            
            VStack {
                Text("Phishing News")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                Text("""
                    Stay updated with the latest news on phishing attempts and how to protect yourself.
                    This section will highlight important news related to phishing threats.
                    """) // description of the tool
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(.gray)

                if isLoading {
                    ProgressView("Loading News...") // Progress View to express action in progress (source: Apple Developer Documentation)
                        .padding()
                } else { // once done loading
                    List(newsArticles.prefix(10), id: \ .id) { article in // list the top 10 articles
                        VStack(alignment: .leading, spacing: 5) { // stack and display title and description
                            Text(article.title) // title
                                .font(.headline)
                                .foregroundColor(.blue)
                                .onTapGesture { // when tapped, the article URL is loaded
                                    if let url = URL(string: article.url) { // check if valid URL
                                        UIApplication.shared.open(url) // opens URL in system's web browsers
                                    }
                                }
                            Text(article.description) // description
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 5)
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
        }
        .onAppear(perform: fetchNews) // call the fetchNews function to initiate bringing information from News API
        .padding()
    }

    // Fetch News from API
    // function uses the URL to create a session to fetch data from News API
    // Reference: Chat-GPT to explain URL sessions and fetching data from News API with a DispatchQueue
    private func fetchNews() {
        guard let url = URL(string: "https://newsapi.org/v2/everything?q=phishing&apiKey=60ad00fada874ef8a4103b5e340f40b7&language=en") else { // throwaway API key, everthing?=phishing and language=en restricts appearing news articles to what we want
            self.errorMessage = "Invalid API URL" // error handling
            self.isLoading = false
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in // make the API request based on the URL
            DispatchQueue.main.async { // update UI state
                self.isLoading = false // not loading anymore

                if let error = error {
                    self.errorMessage = error.localizedDescription // error protocol in Swift, displays localized errors to the user
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received." // error handling
                    return
                }
                do {
                    let decodedResponse = try JSONDecoder().decode(NewsAPIResponse.self, from: data) // decode JSON into NewsAPIResponse
                    self.newsArticles = decodedResponse.articles.map { // convert to NewsArticle objects that can be used by Swift and store the object in the newsArticle list
                        NewsArticle(
                            id: UUID(), // article ID
                            title: $0.title, // article title
                            description: $0.description ?? "No description available.", // article description
                            url: $0.url // article URL
                        )
                    }
                } catch {
                    self.errorMessage = "Failed to parse response: \(error.localizedDescription)" // error handling
                }
            }
        }.resume()
    }
}

