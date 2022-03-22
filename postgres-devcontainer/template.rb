file '.devcontainer/devcontainer.json', <<~CODE
  // For format details, see https://aka.ms/devcontainer.json. For config options, see the README at:
  // https://github.com/microsoft/vscode-dev-containers/tree/v0.166.1/containers/ruby-rails
  {
    "name": "#{app_name}",
    "dockerComposeFile": "docker-compose.yml",
    "service": "app",
    "workspaceFolder": "/workspace",
    // Set *default* container specific settings.json values on container create.
    "settings": {
      "terminal.integrated.profiles.linux": {
        "bash": {
          "path": "bash"
        },
        "zsh": {
          "path": "zsh"
        }
      }
    },
    // Add the IDs of extensions you want installed when the container is created.
    "extensions": [
      "rebornix.ruby"
    ],
    // Use 'forwardPorts' to make a list of ports inside the container available locally.
    "forwardPorts": [
      3000
    ],
    // Use 'postCreateCommand' to run commands after the container is created.
    "postCreateCommand": "bin/setup",
    // Comment out connect as root instead. More info: https://aka.ms/vscode-remote/containers/non-root.
    "remoteUser": "vscode"
  }
CODE

file '.devcontainer/Dockerfile', <<~CODE
  # [Choice] Ruby version: 2, 2.7, 2.6, 2.5
  ARG VARIANT=2
  FROM mcr.microsoft.com/vscode/devcontainers/ruby:0-${VARIANT}

  # Install Rails
  RUN gem install rails

  ARG NODE_VERSION="lts/*"
  RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1"

  # [Optional] Uncomment this section to install additional OS packages.
  # RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
  #     && apt-get -y install --no-install-recommends <your-package-list-here>

  # [Optional] Uncomment this line to install additional gems.
  # RUN gem install <your-gem-names-here>

  # [Optional] Uncomment this line to install global node packages.
  # RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1
CODE

file '.devcontainer/docker-compose.yml', <<~CODE
  version: '3'

  volumes:
    postgres_data:

  services:
    app:
      user: vscode

      build:
        context: ..
        dockerfile: .devcontainer/Dockerfile
        args:
          VARIANT: 3.1
          USER_UID: 1000
          USER_GID: 1000
          NODE_VERSION: lts/*

      volumes:
        - ..:/workspace:cached
        - $HOME/.ssh/:/home/vscode/.ssh/ # Mount the ssh folder to authenticate with github

      # Overrides default command so things don't shut down after the process ends.
      command: sleep infinity

      links:
        - pg_#{app_name}

    pg_#{app_name}:
      image: postgres:14.2
      restart: unless-stopped
      volumes:
        - postgres_data:/var/lib/postgresql/data
      ports:
        - 5432:5432
      environment:
        POSTGRES_USER: #{app_name}
        POSTGRES_PASSWORD: #{app_name}_password
CODE

file 'config/database.yml', <<~CODE
  default: &default
    adapter: postgresql
    encoding: unicode
    pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

  development:
    <<: *default
    database: #{app_name}_development
    username: #{app_name}
    password: #{app_name}_password
    host: pg_#{app_name}
    port: 5432

  test:
    <<: *default
    database: #{app_name}_test
    username: #{app_name}
    password: #{app_name}_password
    host: pg_#{app_name}
    port: 5432

  production:
    <<: *default
    url: <%= ENV['DATABASE_URL'] %>
CODE
