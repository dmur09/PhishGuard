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

### Security
API Key Handling: The VirusTotal API key should be stored in a separate config.py file, which is not included in the repository for security reasons.
Headless Browser: The application uses Selenium in headless mode to safely analyze URLs in an isolated environment.
