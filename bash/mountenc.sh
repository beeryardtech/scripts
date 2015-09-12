#!/bin/bash -
#Mount and unmount all encfs mount points for the current (or another) user

source ~/.bash_funcs

cleanup()
{
    echo "Trapped! Booh!"
    exit 255
}
trap cleanup SIGINT SIGTERM

cmd="encfs"

#Mount each point one by one. This allows for unique options for mount points
mnt()
{
    # Mounts is a assoc array of mount points.
    # Key - encrypted dir, value - mount point
    singlept=$1
    declare -A mounts=(
        ["${DROPBOX}/.Private"]="${HOME}/Private"
        ["${BTSYNC}/VMs/.vmdisks"]="${HOME}/vmdisks"
        ["${DROPBOX}/.sshkeys"]="${HOME}/.sshkeys"
        ["${DROPBOX}/Janie/.SharedPrivate"]="${HOME}/SharedPrivate"
    )

    for key in ${!mounts[@]} ; do
        val=${mounts[$key]}

        # If specified, only mount the single mount point
        if [[ -n "$singlept" ]] ; then
            if ! icontains $key $singlept ; then
                # Skip any that do not match the single point
                continue
            elif mountpoint -q $val ; then
                echo "Mount point $val is already mounted"
                return
            else
                echo "Do single mounting of $key to $val"
                $cmd $key $val
                return
            fi
        else
            if ! mountpoint -q $val ; then
                echo "Mounting $key to $val"
                $cmd $key $val
            fi
        fi
    done
}

unmnt()
{
    mounts=( $( mount -t fuse.encfs | grep "user=${2}" | awk '{print $3}' ) )
    echo "Unmounting all encfs mount points..."

    for mountpt in  $( mount -t fuse.encfs | grep "user=${2}" | awk '{print $3}' ) ; do
        echo $mountpt
        fusermount -u $mountpt
    done

}

# Setup arguments
optstring=hm:u

while getopts $optstring opt ; do
    case $opt in
        h) # Usage help and exit
            USAGE="USAGE: $FUNCNAME	-m [single point] | -u [user]"
            echo $USAGE
            exit 1 ;;
        m) # mount
            echo $OPTARG
           mnt $OPTARG
            exit 0 ;;
        u) # Unmount
            unmnt $OPTARG
            exit 0 ;;
    esac
done
