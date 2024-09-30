FROM ubuntu:latest

# Install curl
RUN apt-get update && apt-get install -y curl

# Copy the bash script into the Docker image
COPY main.sh /main.sh

# Make the script executable
RUN chmod +x /main.sh

# Set the entrypoint to your script
ENTRYPOINT ["/main.sh"]
