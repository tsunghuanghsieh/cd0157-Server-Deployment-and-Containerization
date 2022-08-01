#!/bin/zsh

#
# This util script to is automate:
#    * build a docker image, run locally and publish to public docker registry
#    * remove running container and image locally
#

. "`dirname $0`/sh_common.sh"

# docker binary version 20.10.17
DockerBinary=`which docker`

if [ ! -f $DockerBinary ]; then
    echo $DockerBinary is not installed on the system...
    exit 1
fi

#
# usage
#
usage() {
    echo -e usage: $MSG_ERROR_PREFIX $* 1>&2
    echo -e usage: $MSG_ERROR_PREFIX `basename ${funcfiletrace[1]%:*}` \[i\|u\]. 1>&2
    echo -e usage: $MSG_ERROR_PREFIX i: build docker image, run locally, publish to public registry. 1>&2
    echo -e usage: $MSG_ERROR_PREFIX u: remove container and image locally. 1>&2
    exit 1
}

[ $# -ne 1 ] && usage "incorrect number of arguments"

if [ ! -f $DockerFile ]; then
    echo $DockerFile does not exist...
    exit 1
fi

# back up default internal field separator (IFS)
OriginalIFS=$IFS

# initialize default values
BuildNumber=`date +%Y%m%d_%H%M%S`
# DockerFile=${0:h}'/Dockerfile'
DockerFile='Dockerfile'
DockerImageName='04project'
DockerUserId='tsungh'

#
# Functions
#

install() {
    echo Creating docker image...
    $DockerBinary build -t $DockerUserId/$DockerImageName:$BuildNumber -f $DockerFile .

    # echo Exporting docker image to disk...
    # $DockerBinary save -o $DockerImageName-$BuildNumber.image $DockerImageName:$BuildNumber

    echo $DockerBinary run --name $DockerImageName-$BuildNumber --env-file=.env_prod -p 80:8080 -d $DockerUserId/$DockerImageName:$BuildNumber
    $DockerBinary run --name $DockerImageName-$BuildNumber --env-file=.env_prod -p 80:8080 -d $DockerUserId/$DockerImageName:$BuildNumber

    echo $DockerBinary push $DockerUserId/$DockerImageName:$BuildNumber
    $DockerBinary push $DockerUserId/$DockerImageName:$BuildNumber
}

uninstall() {
    setopt SH_WORD_SPLIT
    # remove all related containers of the image
    containerList=`$DockerBinary ps -a | grep $DockerImageName`
    if [[ ! -z $containerList ]]; then
        echo
        # set IFS for splitting the list of docker containers
        IFS=$'\n'
        containers=($containerList)
        for container in ${containers[@]}; do
            echo $container
            RemoveContainer "$container"

            # restore IFS to default for splitting docker container columns
            IFS=$OriginalIFS
            # 7 columns in `docker ps` output
            # CONTAINER ID|IMAGE|COMMAND|CREATED|STATUS|PORTS|NAMES
            containerCols=($container)
            containerColsCount=${#containerCols[@]}
            echo uninstall containerColsCount is $containerColsCount

            # zsh array appears to be 1-based, not 0-based.
            imageInUse=`$DockerBinary ps -a | grep ${containerCols[2]}`
            # if image does not have any container, add it to the list for removal
            if [[ -z $imageInUse ]]; then
                # verify if the image is already in the pending deletion list before adding
                # if [[ ! "${imagesPendingDeletion[*]}" =~ ${containerCols[1]}]]; then
                #     echo image ${containerCols[1]} is no longer in use, pending deletion...
                #     imagesPendingDeletion[${#imagesPendingDeletion[@]}]=${containerCols[1]}
                # fi
                echo removing image ${containerCols[2]}...
                $DockerBinary rmi -f ${containerCols[2]}
            fi
        done
    fi
    unsetopt SH_WORD_SPLIT
}

#
RemoveContainer() {
    echo $1
    # back up internal field separator (IFS)
    PreviousIFS=$IFS

    IFS=$OriginalIFS
    # 7 columns in `docker ps` output
    # CONTAINER ID|IMAGE|COMMAND|CREATED|STATUS|PORTS|NAMES
    containerCols=($1)
    containerColsCount=${#containerCols[@]}
    echo $1
    echo RemoveContainer containerColsCount is $containerColsCount
    # zsh array appears to be 1-based, not 0-based.
    echo container name ${containerCols[$containerColsCount]} id ${containerCols[1]}

    # stop and remove container
    if [[ $1 =~ "Up" ]]; then
        echo stopping container ${containerCols[$containerColsCount]}...
        $DockerBinary stop ${containerCols[$containerColsCount]} > /dev/null
    else
        echo container ${containerCols[$containerColsCount]} is not running...
    fi
    echo removing container ${containerCols[$containerColsCount]}...
    $DockerBinary rm ${containerCols[$containerColsCount]} > /dev/null

    # restore IFS
    IFS=$PreviousIFS
}

#
# DO WORK
#
if expr $1 = 'i' > /dev/null; then
    install
elif expr $1 = 'u' > /dev/null; then
    uninstall
else
    usage "unsupported switch"
fi