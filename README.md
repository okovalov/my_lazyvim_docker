# Dockerized Neovim with LazyVim

A Docker container providing a fully configured Neovim development environment based on LazyVim with custom plugins and tools. This setup ensures a consistent, portable development environment with persistent configuration.

## Features

- **Neovim with LazyVim**: Modern Neovim distribution with lazy-loaded plugins, (inluding OpenCode and Avante)
- **Custom Configuration**: Pre-configured with personal keymaps, options, and plugins
- **Developer Tools**: Includes `lazygit`, `git-delta`, `fd-find`, `ripgrep`, `tree-sitter-cli`, `fzf`, `python3`, `wget`, `unzip`
- **Persistent Storage**: Docker volumes for Neovim configuration, share, state, and cache
- **Automatic Initialization**: Entrypoint script clones LazyVim and applies custom config on first run
- **User Mapping**: Runs as non-root user with matching UID/GID for file permissions

## Quick Start

### Prerequisites

- Docker and Docker Compose

### Quick Run Command

If you just want to try the container with your current directory:

```bash
docker run -it --rm -v $(pwd):/workspace okovalov/my-neovim:latest
```

**Important**: This image includes the custom plugins and configurations from this repository baked into the container. On first run, it initializes with LazyVim starter and copies these custom settings.

### Environment Variables

Set user/group IDs to match your host user for proper file permissions:

```bash
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
docker compose up -d
```

## Pulling from Docker Hub

You can pull the pre-built image directly from Docker Hub:

```bash
docker pull okovalov/my-neovim:1.0
docker run -it --rm -v $(pwd):/workspace okovalov/my-neovim:latest
```

**Important Notes**:

1. This image includes the **author's custom plugins and configurations** (tmux-navigator, snacks, opencode, gitsigns, avante) baked into the container
2. On first run, the container clones LazyVim starter and copies these custom settings to persistent volumes
3. If you want different plugins or configurations, see the "Creating Your Own Customized Version" section below
4. The container runs with UID=1000/GID=1000 by default. To match your host user permissions:
   ```bash
   USER_ID=$(id -u) GROUP_ID=$(id -g) docker run -it --rm -v $(pwd):/workspace okovalov/my-neovim:1.0
   ```

## Docker Compose Commands

| Command                              | Description                                         |
| ------------------------------------ | --------------------------------------------------- |
| `docker compose up -d`               | Build (if needed) and start container in background |
| `docker compose down`                | Stop and remove container (keeps volumes)           |
| `docker compose down -v`             | Stop and remove container **and volumes**           |
| `docker compose exec my-neovim nvim` | Launch Neovim inside running container              |
| `docker compose exec my-neovim bash` | Get shell access to container                       |
| `docker compose logs -f`             | Follow container logs                               |
| `docker compose build --no-cache`    | Rebuild image from scratch                          |

## Project Structure

```
.
├── Dockerfile                 # Container definition
├── docker-compose.yml         # Docker Compose configuration
├── entrypoint.sh              # Container initialization script
├── lazygit_config.yml         # lazygit configuration
├── lua_saved/                 # Custom Neovim configuration
│   ├── config/
│   │   ├── autocmds.lua      # Auto-commands
│   │   ├── keymaps.lua       # Custom key mappings
│   │   └── options.lua       # Neovim options
│   └── plugins/
│       ├── 01_tmux_navigator.lua  # Tmux navigation
│       ├── 02_snacks.lua          # Snacks.nvim
│       ├── 03_opencode.lua        # OpenCode AI assistant
│       ├── 04_gitsigns.lua        # Git signs
│       ├── 09_avante.lua          # Avante theme/plugin
│       └── disabled.lua           # Disabled plugins
└── README.md                  # This file
```

## File Contents

### Dockerfile

```dockerfile
FROM fedora:43

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN dnf copr enable -y dejan/lazygit && \
  dnf install -y git lazygit git-delta \
  fzf python3 wget unzip \
  gcc \
  gcc-c++ \
  make \
  lazygit fd-find curl ripgrep tree-sitter-cli neovim sudo

# Use the ARG values passed from docker-compose
RUN groupadd -g ${GROUP_ID} developer && \
  useradd -u ${USER_ID} -g ${GROUP_ID} -m developer && \
  echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN echo "developer:dev" | chpasswd

WORKDIR /workspace

RUN chown -R developer:developer /workspace

USER developer

# Create directory structure
RUN mkdir -p \
  /home/developer/.config/nvim \
  /home/developer/.local/share/nvim \
  /home/developer/.local/state/nvim \
  /home/developer/.cache/nvim

# Copy your saved Lua config into the image
COPY --chown=developer:developer lua_saved /tmp/lua_saved

COPY --chown=developer:developer lazygit_config.yml /tmp/

# Copy entrypoint script
COPY --chown=developer:developer entrypoint.sh /home/developer/entrypoint.sh
RUN chmod +x /home/developer/entrypoint.sh

```

### docker-compose.yml

```yaml
services:
  my-neovim:
    build:
      context: .
      args:
        - USER_ID=${USER_ID:-1000}
        - GROUP_ID=${GROUP_ID:-1000}
    image: my-neovim
    working_dir: /workspace
    volumes:
      - ".:/workspace"
      # Named volumes for persistence
      - dev_config:/home/developer/.config
      - dev_share:/home/developer/.local/share
      - dev_state:/home/developer/.local/state
      - dev_cache:/home/developer/.cache
    tty: true
    command: ["/bin/bash", "-c", "/home/developer/entrypoint.sh && nvim"]
    stdin_open: true
    environment:
      - TERM=xterm-256color

volumes:
  dev_config:
  dev_share:
  dev_state:
  dev_cache:
```

### entrypoint.sh

```bash
#!/usr/bin/bash

CONFIG_DIR="/home/developer/.config/nvim"
SHARE_DIR="/home/developer/.local/share/nvim"
STATE_DIR="/home/developer/.local/state/nvim"
CACHE_DIR="/home/developer/.cache/nvim"

# We need to check if the volume was just created and needs initialization
if [ ! -d "$CONFIG_DIR/lua" ]; then
  echo "=== First run: Initializing LazyVim with default config ==="

  # Remove existing content if any (volume might be empty but dir exists)
  rm -rf "$CONFIG_DIR" 2>/dev/null || true
  rm -rf "$SHARE_DIR" 2>/dev/null || true
  rm -rf "$STATE_DIR" 2>/dev/null || true
  rm -rf "$CACHE_DIR" 2>/dev/null || true

  git clone https://github.com/LazyVim/starter "$CONFIG_DIR"

  rm -rf "$CONFIG_DIR/.git"

  echo "=== Default Initialization complete! ==="
fi

if [ -d "/tmp/lua_saved" ]; then
  echo "Copying custom configuration from /tmp/lua_saved..."
  mkdir -p "$CONFIG_DIR/lua"

  # Use rsync or copy with overwrite
  rsync -a /tmp/lua_saved/ "$CONFIG_DIR/lua/" 2>/dev/null ||
    cp -r /tmp/lua_saved/* "$CONFIG_DIR/lua/" 2>/dev/null || true

  # lazygit config
  mkdir -p "/home/developer/.config/lazygit"

  if [ -f "/tmp/lazygit_config.yml" ]; then
    cp /tmp/lazygit_config.yml "/home/developer/.config/lazygit/config.yml"
  fi

  echo "=== Custom Initialization complete! ==="
fi
```

### lazygit_config.yml

```yaml
gui:
  showIcons: true
  theme:
    selectedLineBgColor:
      - underline

git:
  paging:
    colorArg: always
    pager: delta --dark --paging=never --line-numbers
```

## Custom Configuration

The container includes several custom Neovim configurations as a starting point. This setup is designed to facilitate data and settings preservation—you can easily add more plugins, change keymaps, or modify settings to suit your workflow.

### Key Plugins

- **tmux-navigator**: Seamless navigation between Neovim and Tmux panes
- **snacks.nvim**: Enhanced input UI for OpenCode
- **opencode.nvim**: AI coding assistant with keybindings
- **gitsigns.nvim**: Git status in the sign column
- **avante**: AI coding assistant with keybindings

### Key Bindings

- `<leader>oA`: Ask OpenCode
- `<leader>oa`: Ask about cursor/selection
- `<leader>ot`: Toggle embedded OpenCode
- `<leader>at`: Toggle embedded Avante
- `<S-C-u>/<S-C-d>`: Scroll OpenCode messages

### Neovim Options

- Global statusline (`laststatus = 3`)
- Custom winbar display
- Prettier configuration handling

### Creating Your Own Customized Version

This Docker image includes the author's personal plugins and configurations. If you want to create your own customized version with different plugins or settings:

#### Option 1: Fork and Modify This Repository (see below the repository link)

1. **Clone this repository** and modify the `lua_saved/` directory with your custom configurations
2. **Rebuild the image** with your changes:
   ```bash
   docker compose build --no-cache
   docker compose up -d
   ```

#### Option 2: Create a New Dockerfile Based on This Template

Create a `Dockerfile` that extends or copies this approach:

```dockerfile
# Base on the published image (if you want to add tools)
FROM okovalov/my-neovim:1.0

# Add additional packages
USER root
RUN dnf install -y your-additional-package
USER developer

# Or create from scratch using this template
# FROM fedora:43
# ... copy the Dockerfile structure from this repository
```

#### Option 3: Create a Custom docker-compose.yml

Create a `docker-compose.yml` that uses the published image with your volumes:

```yaml
version: "3.8"
services:
  my-neovim:
    image: okovalov/my-neovim:1.0 # Use the published image
    working_dir: /workspace
    volumes:
      - ".:/workspace"
      - my_nvim_config:/home/developer/.config/nvim
      - my_nvim_share:/home/developer/.local/share/nvim
      - my_nvim_state:/home/developer/.local/state/nvim
      - my_nvim_cache:/home/developer/.cache/nvim
    tty: true
    stdin_open: true
    environment:
      - TERM=xterm-256color
      - USER_ID=${USER_ID:-1000}
      - GROUP_ID=${GROUP_ID:-1000}

volumes:
  my_nvim_config:
  my_nvim_share:
  my_nvim_state:
  my_nvim_cache:
```

### Example Repository

For a complete example of a customized Dockerized Neovim setup, see: [https://github.com/okovalov/my_lazyvim_docker](https://github.com/okovalov/my_lazyvim_docker)

This example repository demonstrates:

- Full project structure for a Dockerized Neovim environment
- How to organize custom plugins and configurations
- Docker Compose setup with persistent volumes
- Integration of additional tools and plugins

### Project Structure for Customization

```
.
├── Dockerfile                 # Container definition
├── docker-compose.yml         # Docker Compose configuration
├── entrypoint.sh              # Container initialization script
├── lazygit_config.yml         # lazygit configuration
├── lua_saved/                 # Custom Neovim configuration
│   ├── config/
│   │   ├── autocmds.lua      # Auto-commands
│   │   ├── keymaps.lua       # Custom key mappings
│   │   └── options.lua       # Neovim options
│   └── plugins/
│       ├── 01_tmux_navigator.lua  # Tmux navigation
│       ├── 02_snacks.lua          # Snacks.nvim
│       ├── 03_opencode.lua        # OpenCode AI assistant
│       ├── 04_gitsigns.lua        # Git signs
│       ├── 09_avante.lua          # Avante theme/plugin
│       ├── disabled.lua           # Disabled plugins
│       └── custom_plugin.lua      # Add your own plugins here
└── README.md                  # Documentation
```

**Note**: This Docker setup is a template idea for preserving Neovim settings across environments. You're encouraged to add your own plugins, modify keymaps, and tailor the configuration to your specific needs.

## Building and Pushing to Docker Hub

### Build the Image

```bash
# Build with latest tag
docker build -t yourusername/my-neovim:latest .

# Or build with version tag
docker build -t yourusername/my-neovim:1.0 .
```

**Note**: The built image includes the custom plugins and configurations from the `lua_saved/` directory. These are baked into the image and will be copied to the container's Neovim configuration on first run.

**Tagging Tip**: If you've already built an image and want to add another tag (e.g., create a `latest` tag for an existing `1.0` image):

```bash
docker tag yourusername/my-neovim:1.0 yourusername/my-neovim:latest
```

### Push to Docker Hub

```bash
# Push specific tag
docker push yourusername/my-neovim:1.0

# Push latest tag
docker push yourusername/my-neovim:latest

# Push all tags
docker push yourusername/my-neovim --all-tags
```

## Persistence

Four named volumes preserve Neovim state between container restarts:

1. `dev_config`: Neovim configuration files
2. `dev_share`: Plugin installations and shared data
3. `dev_state`: Session and state information
4. `dev_cache`: Cache files for faster startup

To reset the environment, remove the volumes:

```bash
docker compose down -v
```

## Development Workflow

1. **Start the container**: `docker compose up -d`
2. **Edit files**: Use mounted volume at `/workspace`
3. **Run Neovim**: `docker compose exec my-neovim nvim`
4. **Customize config**: Edit files in `lua_saved/` and rebuild (see "Creating Your Own Customized Version" for details)
5. **Rebuild image**: After configuration changes

For quicker (more convenient) launch, here is an example of the zsh alias.

```bash

# docker version of nvim
alias nvim-docker='docker run -it --rm \
  -v "$(pwd):/workspace" \
  -v dev_config:/home/developer/.config \
  -v dev_share:/home/developer/.local/share \
  -v dev_state:/home/developer/.local/state \
  -v dev_cache:/home/developer/.cache \
  -w /workspace \
  -e TERM=xterm-256color \
  my-neovim nvim'
```

## Repository

- **GitHub**: https://github.com/okovalov/my_lazyvim_docker
- **Author**: Oleksandr Kovalov <oleksandr.kovalov@gmail.com>
- **Docker Hub**: https://hub.docker.com/r/okovalov/my-neovim

## License

MIT

## Contributing

Feel free to submit issues or pull requests for improvements.
