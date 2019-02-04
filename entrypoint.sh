#!/bin/bash

# set up environment
export NODE_ENV=${NODE_ENV:-"production"}
export PKG_MANAGER=${PKG_MANAGER:-"npm"}

# include some helper methods
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$DIR/helpers.sh"


function help {
  echo "The following commands can be run from this script."
  echo ""
  echo "  - run <script>"
  echo "      execute the specified <script> on the package"
  echo ""
}

case $1 in
  # execute specified script using the specified mode
  run)
    runScript "$2"
    ;;

  # shorthand for entrypoint.sh run test
  test)
    runScript "test"
    ;;

  # deploy a build to a specific git branch
  gh-pages)
    ghActionsSetup
    ghPages
    ;;

  *)
    help;;
esac
