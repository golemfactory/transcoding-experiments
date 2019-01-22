import os

import pytest
import pipeline as pipeline



class TestTranscodingPipeline(object):

    
    def test_Bear_video(self):
        
        PARAMS="working-dir/mount/work/Bear-params.json"

        task_def = pipeline.load_params(PARAMS)
        tests_dir = os.path.join( os.getcwd(), "working-dir/test/test_Bear_video" )

        pipeline.run_pipeline(task_def, tests_dir, "golemfactory/ffmpeg:0.2")
        
        # This intentionally won't happen if tests fails. User can check content of test directory.
        pipeline.clean_step(tests_dir)



