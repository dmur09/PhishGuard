# PhishGuard
PhishGuard is a mobile application that contains several tools to combat phishing attacks.

### Features
- QR Code Decoding
The application uses VirusTotal to check the URL’s reputation, providing the number of antivirus engines that flagged the URL as malicious.
Using Selenium in headless mode, the application analyzes the behavior of the URL (e.g., redirects) in a controlled environment.

- Phishing Text Detector
Detects potential phishing messages with the help of machine learning.
Provides a phishing confidence score to assess the likelihood of a message being malicious.

- Phishing News
Displays news about phishing scams and trends.
Keeps users updated on the latest phishing threats.

- Phishing Education
Offers users detailed information about phishing and tips for awareness.
Offers users a checklist when reviewing emails or messages.

### Contributions
Ewan Shen implemented the Phishing News Tool and Phishing Education tool and created the dataset for our version of the phishing text detector with machine learning.
Diego Murillo implemented the main menu, the QR code view, and the scanner view, incorporating the VirusTotal API in the analysis of decoded URLs.
Both team members also contributed to each other's sections through help with coding and debugging.

### References
- Cukmekerb's Coding Class (https://www.youtube.com/watch?v=yY0ciWj8oco) for teaching us about News API
- VirusTotal and News API for API functionality
- Cursor and Chat-GPT for helping us learn to implement and use the APIs of VirusTotal and NewsAPI
- Dr. Cibrian's slides and code on implementing machine learning into Swift
- The Phishing dataset from https://huggingface.co/datasets/ealvaradob/phishing-dataset/tree/main and the SMS Spam dataset from https://www.kaggle.com/datasets/uciml/sms-spam-collection-dataset?resource=download
