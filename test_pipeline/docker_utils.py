import os
import subprocess
import shutil


def exec_cmd(cmd, file=None):
    print("Executing command:")
    print(cmd)

    pc = subprocess.Popen(cmd, stdout=file, stderr=file)
    return pc.wait()


def exec_cmd_to_file(cmd, filepath):

    # Ensure directory exists
    filedir = os.path.dirname( filepath )
    if not os.path.exists( filedir ):
        os.makedirs( filedir )

    # Execute command and send results to file.
    with open(filepath, "w") as result_file:
        exec_cmd(cmd, result_file)


def print_list( list_to_print, intend = 1 ):
    for element in list_to_print:
        intend_str = ""
        for i in range( 0, intend ):
            intend_str += "    "
        print( intend_str + str( element ) )


def default_golem_mounts(host_dir):
    
    mount_list = []

    mount_list += [ [ os.path.join(host_dir, "work"), "/golem/work/" ] ]
    mount_list += [ [ os.path.join(host_dir, "output"), "/golem/output/" ] ]
    mount_list += [ [ os.path.join(host_dir, "resources"), "/golem/resources/" ] ]

    return mount_list


def create_environment(host_dir, mount_dirs, work_files, resource_files):

    # Create directories that will be mounted to docker filesystem
    for mount_dir in mount_dirs:
        if not os.path.exists(mount_dir[0]):
            os.makedirs(mount_dir[0])


    ################################################
    print("Coping files to /golem/work/:")
    print_list( work_files )

    work_dir = os.path.join( host_dir, "work" )
    for file in work_files:
        destination = os.path.join( work_dir, os.path.basename(file))
        shutil.copyfile(file, destination)

    ################################################
    print("Coping files to /golem/resources/:")
    print_list( resource_files )

    resources_dir = os.path.join( host_dir, "resources" )
    for file in resource_files:
        destination = os.path.join( resources_dir, os.path.basename(file))
        shutil.copyfile(file, destination)


def docker_mount_command(mount_dirs):

    cmd = []
    for mount_dir in mount_dirs:
        
        # Can't mount not existing host path. Create to be sure it exists.
        if not os.path.exists(mount_dir[0]):
            os.makedirs(mount_dir[0])

        single_mount = [ "--mount" ]
        single_mount += [ "type=bind,source=" + mount_dir[0] + ",target=" + mount_dir[1] ]

        cmd += single_mount

    return cmd


def run(image, script, mount_dirs, docker_log):

    cmd = [ "docker", "run" ]
    cmd += [ "--rm" ]
    #cmd += [ "-it" ]
    cmd += [ "-e", "LOCAL_USER_ID=" + str( os.getuid() ) ]
    cmd += docker_mount_command(mount_dirs)
    cmd += [ image ]
    cmd += [ "python3 " + script ]

    exec_cmd_to_file(cmd, docker_log)




