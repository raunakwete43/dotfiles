import os
import shutil

# Set the base directory
base_dir = "."

# List all video files in the base directory
video_files = [f for f in os.listdir(base_dir) if f.endswith(".mp4")]

for video_file in video_files:
    # Extract the episode name from the video file
    episode_name = os.path.splitext(video_file)[0]

    # Construct the expected subtitle path
    subtitle_path = os.path.join(base_dir, "Subs", episode_name, "2_English.srt")

    # Check if the subtitle file exists
    if os.path.exists(subtitle_path):
        # Construct the new subtitle file name to match the video file
        new_subtitle_name = episode_name + ".srt"
        new_subtitle_path = os.path.join(base_dir, new_subtitle_name)

        # Copy the subtitle file to the base directory with the new name
        shutil.copy(subtitle_path, new_subtitle_path)
        print(f"Copied subtitle for {video_file} to {new_subtitle_name}")
    else:
        print(f"Subtitle for {video_file} not found")

print("Subtitle matching complete.")
