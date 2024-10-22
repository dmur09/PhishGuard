from flask import Flask, request, render_template
import cv2
from pyzbar.pyzbar import decode
from PIL import Image
import requests
import numpy as np
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from config import API_KEY
import time

app = Flask(__name__)

# Function to decode QR code
def decode_qr(image_stream):
    image = Image.open(image_stream)
    image_np = np.array(image)
    qr_codes = decode(image_np)
    
    if qr_codes:
        return qr_codes[0].data.decode('utf-8')  # Return the first QR code's data
    else:
        return None

# Function to check URL reputation using VirusTotal
def check_url_reputation(url):
    api_key = API_KEY
    api_url = "https://www.virustotal.com/vtapi/v2/url/report"
    
    # Prepare the parameters for the request
    params = {'apikey': api_key, 'resource': url}
    
    # Send the GET request to VirusTotal
    response = requests.get(api_url, params=params)
    
    if response.status_code == 200:
        data = response.json()
        positives = data.get('positives', 0)  # The number of engines that flagged the URL
        total = data.get('total', 0)  # The total number of engines that scanned the URL

        # Get the list of antivirus engines that flagged the URL as malicious
        scan_results = data.get('scans', {})
        flagged_by = [engine for engine, result in scan_results.items() if result['detected']]

        # Build the result message
        result_message = f"Total Scans: {total}<br>Flagged as Malicious by {positives} engines."
        
        if flagged_by:
            result_message += f"<br>Engines that flagged the URL: {', '.join(flagged_by)}"
        else:
            result_message += "<br>No engines flagged this URL as malicious."
        
        return result_message
    else:
        return f"Error checking URL reputation. Status Code: {response.status_code}"

# Helper function to extract total scans from the VirusTotal response
def extract_total_scans(reputation):
    """Extract the total number of scans from the reputation result."""
    if "Total Scans" in reputation:
        total_scans_line = [line for line in reputation.split("<br>") if "Total Scans" in line]
        if total_scans_line:
            return int(total_scans_line[0].split(":")[1].strip())
    return 0

# Helper function to extract the number of engines that flagged the URL as malicious
def extract_flagged_engines(reputation):
    """Extract the number of engines that flagged the URL as malicious."""
    if "Flagged as Malicious by" in reputation:
        flagged_line = [line for line in reputation.split("<br>") if "Flagged as Malicious by" in line]
        if flagged_line:
            return int(flagged_line[0].split("by")[1].split("engines")[0].strip())
    return 0

# Helper function to extract the list of malicious engines
def extract_malicious_engines(reputation):
    """Extract the list of malicious engines that flagged the URL."""
    if "Engines that flagged the URL" in reputation:
        flagged_line = [line for line in reputation.split("<br>") if "Engines that flagged the URL" in line]
        if flagged_line:
            return flagged_line[0].split(":")[1].strip()
    return "None"

# Function to analyze URL behavior using Selenium in headless mode
def analyze_url_behavior(url):
    # Set up Chrome options for headless mode
    options = Options()
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')

    # Start a new Selenium WebDriver session with Chrome
    driver = webdriver.Chrome(options=options)
    
    try:
        # Open the URL in the headless browser
        driver.get(url)
        time.sleep(3)  # Wait for potential redirects
        
        # Capture the final URL after all redirects
        final_url = driver.current_url
        behavior_log = f"Initial URL: {url}<br>Final URL: {final_url}"
        
        if final_url != url:
            behavior_log += "<br>Note: The URL redirected during navigation."
        else:
            behavior_log += "<br>No redirects detected."
        
        driver.quit()  # Close the browser session
        return behavior_log
    except Exception as e:
        driver.quit()
        return f"Error during behavior analysis: {str(e)}"

# Helper function to parse the behavior analysis
# Updated behavior analysis parsing to fix URL extraction
def parse_behavior_analysis(behavior):
    """Extract the initial URL, final URL, and whether redirects were detected from the behavior analysis."""
    initial_url = ""
    final_url = ""
    redirects_detected = "No redirects detected."
    
    if "Initial URL" in behavior:
        initial_url_line = [line for line in behavior.split("<br>") if "Initial URL" in line]
        if initial_url_line:
            initial_url = initial_url_line[0].split("Initial URL:")[1].strip()

    if "Final URL" in behavior:
        final_url_line = [line for line in behavior.split("<br>") if "Final URL" in line]
        if final_url_line:
            final_url = final_url_line[0].split("Final URL:")[1].strip()

    if "redirected" in behavior:
        redirects_detected = "Redirects detected."

    return initial_url, final_url, redirects_detected


# Main route to handle QR code upload and analysis
@app.route("/", methods=["GET", "POST"])
def index():
    result_safe = False
    decoded_url = ""
    total_scans = 0
    flagged_engines = 0
    malicious_engines = "None"
    initial_url = ""
    final_url = ""
    redirects_detected = "No redirects detected."
    
    if request.method == "POST":
        file = request.files["qr_image"]
        if file:
            decoded_data = decode_qr(file.stream)
            if decoded_data:
                # If it's a URL, check its reputation
                if decoded_data.startswith("http"):
                    reputation = check_url_reputation(decoded_data)
                    
                    # Extract data from reputation
                    decoded_url = decoded_data
                    total_scans = extract_total_scans(reputation)
                    flagged_engines = extract_flagged_engines(reputation)
                    malicious_engines = extract_malicious_engines(reputation)
                    
                    # Perform behavior analysis
                    behavior = analyze_url_behavior(decoded_data)
                    initial_url, final_url, redirects_detected = parse_behavior_analysis(behavior)
                    
                    # Check if the URL is safe
                    if flagged_engines == 0:
                        result_safe = True
                        
                result = True
            else:
                result = "No valid QR code found."
            
            # Pass all variables to the template
            return render_template("index.html", result=result, result_safe=result_safe,
                                   decoded_url=decoded_url, total_scans=total_scans,
                                   flagged_engines=flagged_engines, malicious_engines=malicious_engines,
                                   initial_url=initial_url, final_url=final_url, redirects_detected=redirects_detected)
    return render_template("index.html", result=None)

if __name__ == "__main__":
    app.run(debug=False)
