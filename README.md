# Node.js Actions

This action is designed to help easily proxy any Node.js scripts into GH Actions to create workflows easily. By design, there are only a few predefined paths in this action, but the `run` path is flexible enough to build any workflow you may design.

The `entrypoint.sh` script takes in arguments to define what path to follow. There are currently two primary predefined tasks.

## Tasks

Each task is essentially a sub-task to the main entrypoint and will execute a very specific operation.

### `run`

The primary task is `run`. This simply executes the provided script within your NPM or yarn context. By configuring your action definition, you can use the `run` task to chain any number of operations within your system.

For example, if you had an NPM script titled `build` that would create your artifacts for deployment, you could set up your action like this:

```
action "Build" {
  uses = "guahanweb/actions/node-app@master"
  args = "run build"
}
```

**NOTE:** if you are using Yarn, provide an `env` definition specifying the `PKG_MANAGER` to be Yarn:

```
  env = {
    PKG_MANAGER = "yarn"
  }
```

Under the covers, this is essentially going to run `npm run build` or `yarn build` on the worker machine. Obviously, this can be expanded to run any actions you may need.

**Linting example:**

```
action "Lint" {
  uses = "guahanweb/actions/node-app@master"
  env = {
    PKG_MANAGER = "yarn"
  }
  args = "run lint"
}
```

#### Environment Variables

Several environment variables are availabe to customize the behavior of your actions.

<dl>
  <dt><code>NODE_ENV</code></dt>
  <dd>The environment in which to execute your node application.<br>
  <i>defaults to <code>production</code></i></dd>
  <dt><code>PKG_MANAGER</code></dt>
  <dd>Specifies which package manager you are using. Valid values are <code>npm</code> and <code>yarn</code>.<br>
  <i>defaults to <code>npm</code></i></dd>
</dl>

### `gh-pages`

This action also offers the ability to easily publish to an orphan branch on your repository. This is generally used for publishing static content to a `gh-pages` branch to be hosted by GitHub, but you can customize it to any branching strategy you desire.

This task requires the `GITHUB_TOKEN` secret from your action, or it will not have the appropriate permissions to push to your repo.

#### Example

```
action "GH Pages" {
  uses = "guahanweb/actions/node-app@master"
  secrets = ["GITHUB_TOKEN"]
  args = "gh-pages"
}
```

#### Environment Variables

Since every application is different, there are a few overrides you can provide within your `env` block to customize behavior.

<dl>
  <dt><code>GITHUB_TOKEN</code></dt>
  <dd>This token is provided by GitHub when you specify it in your secrets array. It is required for the operation to have permission to push to your repository.</dd>
  <dt><code>BUILD_DIR</code></dt>
  <dd>Specifies the directory that contains the static assets to be pushed.<br>
  <i>defaults to <code>build</code></i></dd>
  <dt><code>REMOTE_BRANCH</code></dt>
  <dd>Spcifies the branch name to which the contents of <code>$BUILD_DIR</code> should be pushed.<br>
  <i>defaults to <code>gh-pages</code></i></dd>
</dl>

### `test`

The `test` operation is provided as an alias to `run test`.

## Putting it all together

Once you have a handle on the options, you can create multiple actions easily and chain them together into a workflow. Here is an example of how you might specify a workflow to lint, test, build, and deploy a GH Pages website using this repository.

#### Example Workflow

```
workflow "Build and Deploy Pages" {
  on = "push"
  resolves = ["Lint", "Build", "Test", "Deploy Pages"]
}

action "Lint" {
  uses = "guahanweb/actions/node-app@master"
  env = {
    PKG_MANAGER = "yarn"
  }
  args = "run lint"
}

action "Build" {
  uses = "guahanweb/actions/node-app@master"
  env = {
    PKG_MANAGER = "yarn"
  }
  args = "run build"
}

action "Test" {
  uses = "guahanweb/actions/node-app@master"
  env = {
    PKG_MANAGER = "yarn"
  }
  args = "test"
}

action "Deploy Pages" {
  uses = "guahanweb/actions/node-app@master"
  secrets = ["GITHUB_TOKEN"]
  args = "gh-pages"
  needs = ["Lint", "Build", "Test"]
}
```