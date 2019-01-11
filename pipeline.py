import os
import glob


def purge(pattern):
    for f in glob.glob(pattern):
        os.remove(f)



def clean():

    print("Cleanup...")

    purge( "working-dir/mount/resources/*.ts" )
    purge( "working-dir/mount/resources/*.m3u8" )
    purge( "working-dir/mount/output/*" )


def split_video():

    print("Splitting...")



def run_pipeline():

    clean()
    split_video()



def run():
    run_pipeline()


if __name__ == "__main__":
    run()


