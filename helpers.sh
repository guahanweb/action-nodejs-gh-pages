# helper functions for our script handler

# This function will validate the mode of build and return
# a normalized mode
function parseMode {
  if [[ ! $# -eq 1 ]]; then
    exit 1
  fi

  if [[ "$1" =~ ^[Yy]arn$ ]]; then
    echo "yarn"
    exit 0
  elif [[ "$1" =~ ^(npm|NPM)$ ]]; then
    echo "npm"
    exit 0
  fi
  exit 1
}

# This function will process the provided script with either
# NPM or Yarn
#   usage: runScript [npm|yarn] <script>
function runScript {
  script="$1"
  mode=$PKG_MANAGER

  if [[ "$PKG_MANAGER" =~ ^[Yy]arn$ ]]; then
    mode="yarn"
  fi

  if [[ -z "$script" ]]; then
    echo "[ERROR] No script provided to execute"
    exit 1
  fi

  case $mode in
    yarn)
      echo "running: yarn $script"
      npm install yarn -g > /dev/null 2>&1
      yarn install > /dev/null 2>&1
      yarn $script
      ;;

    *)
      # default to NPM build
      echo "running: npm run $script"
      npm install > /dev/null 2>&1
      npm run $script
      ;;
  esac
}

# This function checks for some of the necessary environment variables
# that are provided by GH for interaction with the repo
function ghActionsSetup {
  # required variables
  if [[ -z "$GITHUB_TOKEN" || -z "$GITHUB_REPOSITORY" || -z "$GITHUB_ACTOR" ]]; then
    echo "[ERROR] Environment is not set up appropriately: missing GH variables"
    exit 1
  fi

  export REMOTE_REPO="https://${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
  export SCRIPT_USER="${GITHUB_ACTOR}"
  export SCRIPT_EMAIL="${GITHUB_ACTOR}@users.noreply.github.com"
}

# This function will force push a $build directory to a specified
# branch in the specified repository using the actions environment
# variables
#
# Required environment variables:
#   GITHUB_ACTOR
#
function ghPages {
  export BUILD_DIR=${BUILD_DIR:-"build"}
  export REMOTE_BRANCH=${REMOTE_BRANCH:-"gh-pages"}

  # navigate into build directory
  cd $BUILD_DIR

  # initialize the repo, and be sure we identify as the triggering user
  git init && \
  git config user.name "${SCRIPT_USER}" && \
  git config user.email "${SCRIPT_EMAIL}" && \
  git add . && \
  echo -n 'Files to Commit:' && ls -l | wc -l && \
  git commit -m 'action build' > /dev/null 2>&1 && \
  git push --force ${REMOTE_REPO} master:${REMOTE_BRANCH} > /dev/null 2>&1 && \
  rm -rf .git

  # navigate back to the previous directory
  cd -
}
