import params
import scripts.ffmpeg_commands as ffmpeg

def run():
    ffmpeg.transcode_video(params.params)

if __name__ == "__main__":
    run()
