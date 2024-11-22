from flask import Flask, request, jsonify
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import time

app = Flask(__name__)

# Function to analyze URL behavior using Selenium in headless mode
@app.route("/analyze", methods=["POST"])
def analyze_url_behavior():
    data = request.get_json()
    url = data.get("url")
    
    # Set up Chrome options for headless mode
    options = Options()
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')

    driver = webdriver.Chrome(options=options)
    
    try:
        # Open the URL in the headless browser
        driver.get(url)
        time.sleep(3)  # Wait for potential redirects
        
        # Capture the final URL after all redirects
        final_url = driver.current_url
        behavior_log = f"Initial URL: {url}, Final URL: {final_url}"
        
        if final_url != url:
            behavior_log += " - URL redirected."
        else:
            behavior_log += " - No redirects detected."
        
        driver.quit()  # Close the browser session
        return jsonify({"behavior_log": behavior_log})
    except Exception as e:
        driver.quit()
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(debug=True)
