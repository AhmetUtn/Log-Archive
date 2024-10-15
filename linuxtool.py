import os
import tarfile
from datetime import datetime
import argparse

def archive_logs(log_directory, output_directory):
    # Create output directory if it doesn't exist
    if not os.path.exists(output_directory):
        os.makedirs(output_directory)

    # Define the archive file name with current date and time
    current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
    archive_name = f"logs_archive_{current_time}.tar.gz"
    archive_path = os.path.join(output_directory, archive_name)

    # Compress the logs into a .tar.gz file
    with tarfile.open(archive_path, "w:gz") as tar:
        for root, dirs, files in os.walk(log_directory):
            for file in files:
                file_path = os.path.join(root, file)
                try:
                    tar.add(file_path, arcname=os.path.relpath(file_path, log_directory))
                except PermissionError:
                    print(f"Skipping {file_path} due to permission error")
    
    # Log the archive operation
    with open(os.path.join(output_directory, "archive_log.txt"), "a") as log_file:
        log_file.write(f"Archived {log_directory} at {current_time} to {archive_path}\n")
    
    print(f"Logs archived to {archive_path}")

if __name__ == "__main__":
    # Setup argument parser
    parser = argparse.ArgumentParser(description="Log Archiving Tool")
    parser.add_argument("log_directory", help="Directory containing logs to be archived")
    parser.add_argument("--output-directory", default="./archived_logs", help="Directory to store the archived logs")

    args = parser.parse_args()

    archive_logs(args.log_directory, args.output_directory)
