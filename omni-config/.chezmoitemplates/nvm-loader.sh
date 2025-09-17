# NVM (Node Version Manager) Loader Template
# This script loads NVM shell functions for interactive shells
# Included by both .bashrc and .zshrc for consistent behavior
# Managed by chezmoi - do not edit directly

# Only load NVM if the directory exists and contains the script
if [ -n "$NVM_DIR" ] && [ -s "$NVM_DIR/nvm.sh" ]; then
    # Source the main NVM script to load shell functions
    . "$NVM_DIR/nvm.sh"

    # Load bash completion if available (works in both bash and zsh)
    if [ -s "$NVM_DIR/bash_completion" ]; then
        . "$NVM_DIR/bash_completion"
    fi

    # Optional: Auto-use .nvmrc if present in directory
    # Uncomment the following lines if you want automatic Node version switching
    # autoload -U add-zsh-hook  # Only needed in zsh
    # load-nvmrc() {
    #     local node_version="$(nvm version)"
    #     local nvmrc_path="$(nvm_find_nvmrc)"
    #     if [ -n "$nvmrc_path" ]; then
    #         local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")
    #         if [ "$nvmrc_node_version" = "N/A" ]; then
    #             nvm install
    #         elif [ "$nvmrc_node_version" != "$node_version" ]; then
    #             nvm use
    #         fi
    #     elif [ "$node_version" != "$(nvm version default)" ]; then
    #         echo "Reverting to nvm default version"
    #         nvm use default
    #     fi
    # }
    # add-zsh-hook chpwd load-nvmrc  # Only works in zsh
    # load-nvmrc
fi