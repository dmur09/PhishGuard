# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set environment variables to prevent interactive terminal
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages and dependencies
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    xvfb \
    curl \
    gnupg2 \
    libgconf-2-4 \
    libx11-dev \
    libxss1 \
    libappindicator1 \
    fonts-liberation \
    xdg-utils \
    --no-install-recommends \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

# Install Chrome browser (latest stable version)
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

# Install ChromeDriver (set to a known stable version compatible with the installed Chrome version)
RUN CHROME_VERSION=$(google-chrome --version | grep -oP '\d+\.\d+\.\d+') \
    && wget -O /tmp/chromedriver.zip https://chromedriver.storage.googleapis.com/$CHROME_VERSION/chromedriver_linux64.zip \
    && unzip /tmp/chromedriver.zip -d /usr/local/bin/ \
    && rm /tmp/chromedriver.zip

# Install Python dependencies from requirements.txt
COPY requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt

# Set the display variable to run headless
ENV DISPLAY=:99

# Create a non-root user
RUN useradd -m appuser
USER appuser

# Create a working directory
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Run the app
CMD ["python", "app.py"]
