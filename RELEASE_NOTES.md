# Release Notes

## Version 1.1 (2025-12-28)

### New Features
- Added additional developer tools: `fzf`, `python3`, `wget`, `unzip`
- Improved volume structure: changed from Neovim-specific volumes to developer-wide volumes (`dev_config`, `dev_share`, `dev_state`, `dev_cache`)
- Enhanced entrypoint script with better initialization logic
- Added command override in docker-compose for proper entrypoint execution

### Changes
- Simplified Dockerfile by removing commented-out initialization code
- Updated entrypoint.sh to use `rsync` for copying custom configuration when available
- Fixed lazygit config installation path

### Bug Fixes
- Ensure proper cleanup of existing directories before LazyVim initialization
- Better handling of first-run detection

## Version 1.0 (Initial Release)

- Initial Dockerized Neovim with LazyVim configuration
- Includes custom plugins: tmux-navigator, snacks.nvim, opencode.nvim, gitsigns.nvim, avante
- Persistent volumes for Neovim configuration, share, state, and cache
- User mapping with UID/GID support for file permissions
- Docker Compose setup for easy deployment
- Published to Docker Hub as `okovalov/my-neovim:1.0`
