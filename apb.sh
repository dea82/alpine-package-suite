#!/bin/sh

OPERATING_SYSTEM="$(uname -s)"
case "${OPERATING_SYSTEM}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    *)          echo "Unsupported operating system: ${OPERATING_SYSTEM}." && exit 1
esac
echo ${machine}

if [ ${machine} = "Linux" ]
then
  SCRIPT=$(readlink -f "$0")
elif [ ${machine} = "Mac" ]
then
  SCRIPT=$(realpath "$0")
fi

BASEDIR=$(dirname ${SCRIPT})

if [ -f ${BASEDIR}/config.cfg ]; then
    # shellcheck source=config.cfg
    . ${BASEDIR}/config.cfg
else
    echo "Could not find config file."
    exit 1
fi

APB_IMAGE_NAME="apb-image"
APB_CONTAINER_NAME="apb-container"
REPOS_SRC_DIR="repos"
REPOS_DST_DIR="repos"
REMOTE_FS_PATH="/remote-fs"



display_help() {
    echo "Usage: $0 COMMAND"
    echo
    echo "Options:"
    echo "  -h, --help  Help for the given command."
    echo
    echo "Commands:"
    echo
    echo "  build-image  Build the docker image for APB environment"
    echo "  start        Start the APB environment. If necessary image will be built"
    echo "  attach       Attach to the APB environment and access terminal."
    echo "  checksum     Calculate checksum for APKBUILD file(s)."
    echo "  build        Build package(s)."
}

cmd_build_image_help() {
    echo "Usage: $0 build-image"
    echo
    echo "Build the APB image."
    echo
}

cmd_build_image() {
  if [ "$#" -ne 0 ]; then
    while :
    do
	    case "$1" in
	      -h | --help)
		      cmd_build_image_help
		      exit 0
		      ;;
	      -*)
	        echo "Error: Unknown option: $1" >&2
	        exit 1
	        ;;
	      *)
		      echo "Error: Unknown parameter: $1" >&2
          exit 1
          ;;
	    esac
    done
  fi
  docker build -t ${APB_IMAGE_NAME} .
}

cmd_start() {
  if [ "$#" -ne 0 ]; then
    while :
    do
      case "$1" in
        -h | --help)
          cmd_start_help
          exit 0
          ;;
        *)
          echo "Error: Unknown parameter: $1" >&2
          exit 1
          ;;
      esac
    done
  fi
  if [ ! -z "$(docker inspect ${APB_IMAGE_NAME})" ]; then
    echo "Docker image ${APB_IMAGE_NAME} was not found. Building..."
    docker build -t ${APB_IMAGE_NAME} .
  fi
  docker run --privileged -itd --rm --name ${APB_CONTAINER_NAME} -v ${BASEDIR}/${REPOS_SRC_DIR}:/${REPOS_DST_DIR} ${APB_IMAGE_NAME}
  cmd_mount_ext_fs
  docker exec ${APB_CONTAINER_NAME} /bin/sh -c "abuild-priv-key.sh"
}

cmd_mount_ext_fs() {
  echo "Mounting external file system..."
  docker exec --user root ${APB_CONTAINER_NAME} /bin/sh -c "chmod 600 /home/root/deploy-key"
  docker exec --user root ${APB_CONTAINER_NAME} /bin/sh -c "sshfs ${host_user}@${host_address}:/ /remote-fs -o compression=yes -o idmap=user -o allow_other -o IdentityFile=/home/root/deploy-key -o StrictHostKeyChecking=no -p ${host_sshfs_port}"
}

cmd_stop() {
  if [ "$#" -ne 0 ]; then
    while :
    do
      case "$1" in
        -h | --help)
          cmd_stop_help
          exit 0
          ;;
        *)
          echo "Error: Unknown parameter: $1" >&2
          exit 1
          ;;
      esac
    done
  fi
  if [ "$(docker inspect -f '{{.State.Running}}' ${APB_CONTAINER_NAME} 2>/dev/null)" = "true" ]; then
    echo "Stopping container..."
    docker container stop ${APB_CONTAINER_NAME}
  else
    echo "Container already stopped."
  fi
}

cmd_attach() {
  if [ "$#" -ne 0 ]; then
    while :
    do
      case "$1" in
        -h | --help)
          cmd_stop_help
          exit 0
          ;;
        *)
          echo "Error: Unknown parameter: $1" >&2
          exit 1
          ;;
      esac
    done
  fi

  if [ "$(docker inspect -f '{{.State.Running}}' ${APB_CONTAINER_NAME} 2>/dev/null)" = "true" ]; then
    echo "Attaching to container..."
    docker exec -i -t ${APB_CONTAINER_NAME} /bin/sh
  else
    echo "Container is not running!"
  fi
}

cmd_checksum() {
while :
do
  if [ "$#" -ne 0 ]; then
      case "$1" in
        -h | --help)
          cmd_checksum_help
          exit 0
          ;;
        -p | --package)
          if [ ! -z "$2" ]; then
            package="$2"
            shift 2
          else
            echo "Error: No package name supplied." >&2
            exit 1
          fi
          ;;
        *)
          echo "Error: Unknown parameter: $1" >&2
          exit 1
          ;;
      esac
  else
    break
  fi
done
  docker exec ${APB_CONTAINER_NAME} /bin/sh -c "cd /${REPOS_DST_DIR}/${package} && abuild checksum"
}

cmd_build() {
    while :
    do
        if [ "$#" -ne 0 ]; then
          case "$1" in
            -h | --help)
              cmd_build_image_help
              exit 0
              ;;
            -a | --all)
              build_all=1
              shift 1
              ;;
            -p | --package)
              if [ ! -z "$2" ]; then
                package="$2"
                shift 2
              else
                echo "Error: No package name supplied." >&2
                exit 1
              fi
              ;;
          esac
        else
          break
        fi
    done
    docker exec --user root ${APB_CONTAINER_NAME} /bin/sh -c "chown -R builder:builder /${REPOS_DST_DIR}"
    if [ ! -z "$build_all" ]; then
      docker exec ${APB_CONTAINER_NAME} /bin/sh -c "buildrepo.sh"
    else
      docker exec ${APB_CONTAINER_NAME} /bin/sh -c "cd /${REPOS_DST_DIR}/${package} && abuild -r"
    fi

}

if [ "$#" -eq 0 ]; then
    display_help
    exit 0
fi

while :
do
    case "$1" in
      -h | --help)
        display_help
	      exit 0
	      ;;
      build-image)
	      shift
	      cmd_build_image "$@"
        exit 0
        ;;
      start)
        shift
        cmd_start "$@"
        exit 0
        ;;
      stop)
        shift
        cmd_stop "$@"
        exit 0
        ;;
      attach)
        shift
        cmd_attach "$@"
        exit 0
        ;;
      checksum)
        shift
        cmd_checksum "$@"
        exit 0
        ;;
      build)
        shift
        cmd_build "$@"
        exit 0
        ;;
      --)
        shift
	      break
	      ;;
      -*)
        echo "Error: Unknown option: $1" >&2
	      exit 1
	      ;;
      *)
        break
	      ;;
    esac
done
