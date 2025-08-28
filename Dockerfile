# Use an official lightweight Python image as the base image
FROM python:3.9-slim-buster

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements.txt file into the working directory
COPY requirements.txt .

# Install the Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire Flask application code into the working directory
COPY . .

# Expose the port on which the Flask application will run
EXPOSE 5000

# Specify the command to run the Flask application when the container starts
CMD ["python", "api.py"]
