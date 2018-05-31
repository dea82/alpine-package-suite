#!/bin/sh

APB_IMAGE_NAME="apb-image"
APB_CONTAINER_NAME="apb-container"

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
  docker run --privileged -itd --rm --name ${APB_CONTAINER_NAME} ${APB_IMAGE_NAME}
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
  #TODO: Check if running...
  docker container stop ${APB_CONTAINER_NAME}
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