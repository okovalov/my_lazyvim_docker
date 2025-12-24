FROM fedora:43

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN dnf copr enable -y dejan/lazygit && \
  dnf install -y git \
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

# Copy entrypoint script
COPY --chown=developer:developer entrypoint.sh /home/developer/entrypoint.sh
RUN chmod +x /home/developer/entrypoint.sh

# RUN if [ -z "$(ls -A /home/developer/.config/nvim 2>/dev/null)" ]; then \
#   echo "Initializing LazyVim starter config..." && \
#   git clone https://github.com/LazyVim/starter /home/developer/.config/nvim && \
#   rm -rf /home/developer/.config/nvim/.git; \
#   fi

# Initialize LazyVim if config is empty and copy user plugins and settings
# RUN if [ -z "$(ls -A /home/developer/.config/nvim 2>/dev/null)" ]; then \
#   echo "Initializing LazyVim starter config..." && \
#   git clone https://github.com/LazyVim/starter /home/developer/.config/nvim && \
#   rm -rf /home/developer/.config/nvim/.git; \
#   \
#   echo "Adding custom Lua configuration..." && \
#   if [ -d "/tmp/lua_saved" ]; then \
#   mkdir -p /home/developer/.config/nvim/lua; \
#   cp -r /tmp/lua_saved/* /home/developer/.config/nvim/lua/ 2>/dev/null || true; \
#   fi; \
#   fi

# Use entrypoint script
ENTRYPOINT ["/home/developer/entrypoint.sh"]

CMD ["nvim"]
