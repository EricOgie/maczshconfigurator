#! /bin/bash
#
# This script should be run using curl:
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/EricOgie/maczshconfigurator/main/setup.sh)"

# or using wget:
# bash -c "$(wget -qO- https://raw.githubusercontent.com/EricOgie/maczshconfigurator/main/setup.sh)"

# For a more personalised usage, you can download the setup.sh script, tweak  and run afterward.
#
set -e

# Define color functions
blue() { printf "\e[34m%s\e[0m\n" "$1"; }

green() { printf "\e[32m%s\e[0m\n" "$1"; }

red() { printf "\e[31m%s\e[0m\n" "$1"; }

yellow() { printf "\e[33m%s\e[0m\n" "$1"; }

info() { printf "\e[34m%s\e[0m\n" "$1"; }

# Ensure required variables exist.
# Establish a min ruby version of 3.1.0
MIN_RUBY_VERSION="3.1.0"

# Get current Ruby version.
# A simple ruby -v | awk '{print $2}' can output x.x.xpx instead of x.x.x
# Remove any unwanted [a-zA-Z] from the version output using sed
CURRENT_RUBY_VERSION=$(ruby -v | awk '{print $2}' | sed 's/[a-zA-Z].*//')

# Compute the lower version between CURRENT_RUBY_VERSION and MIN_RUBY_VERSION
LOWER_VERSION=$(printf '%s\n%s\n' "$CURRENT_RUBY_VERSION" "$MIN_RUBY_VERSION" | sort -V | head -n 1)

# Login User and User home
USER=${USER:-$(id -u -n)}
HOME="${HOME:-$(eval echo ~$USER)}"
PLUGINS_DIR=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/

# Array to keep track of tools and their correspondings action
# Iterms appendded to this array should be in key-value pair formatted as "tool_name=action_done". e.g., "Zsh=Set as user default shell"
tools_installed=()

command_exists(){
    # Check if a command is available on the system.
    #
    # Arguments:
    #   $@ - Command(s) to check.
    #
    # Returns:
    #   0 if the command exists and is executable.
    #   1 if the command does not exist or is not executable.
    command -v "$@" > /dev/null 2>&1 
}

handle_error() {
    # Print the error message using formatted output
    red "Error: $1" >&2
    exit 1
}

execute_command() {
    # This function executes a command passed as arguments and captures its output or error message.
    # If the command fails, it handles the error by invoking a custom error handler.

    # Arguments:
    #   $@: Command and its arguments to be executed (passed as a series of arguments to the function).

    local output

    # Execute the command and capture any output or error message
    output=$("$@" 2>&1) || handle_error "Command failed: $* : Msg: $output"
    echo "$output"
}

run_remote_installer(){
    # This function downloads a remote installer script from a given URL, executes it, and cleans up afterward.
    # It also accepts an optional argument to pass additional options to the installer script.

    # Arguments:
    #   $1: installerUrl (required) - The URL to the remote installer script to be downloaded.
    #   $2: installerOption (optional) - An optional argument that can be passed to the installer script. Default is an empty string.

    local installerUrl="$1"
    local installerOption=${2:-""}
    local installerScript

    # create tmp location for installer
    installerScript=$(mktemp) || { echo "Failed to create tmp file for installer"; return 1; }

    # Download installer script
    execute_command curl -fsSL "$installerUrl" -o "$installerScript" || { rm -f "$installerScript"; return 1; }

    # Run installer script
    execute_command /bin/bash "$installerScript" "$installerOption"

    # Cleanup
    rm -f "$installerScript"
}

can_sudo() {
    # This function checks if the user can use the sudo command.
    # It performs two checks:
    # 1. Checks if sudo is installed.
    # 2. Attempts to refresh the sudo timestamp to verify if the user has valid sudo permissions.
    #    - If there is an active sudo session, this will succeed without prompting for a password.
    #    - If there is no active session or the user needs to authenticate, this will prompt for a password.

    # Check if sudo is installed
    command_exists sudo || return 1

    # Attempt to refresh the sudo timestamp to validate sudo permissions
    # Redirect output to /dev/null to avoid displaying any prompts or errors
    sudo -v >/dev/null 2>&1
}

print_section_header() {
    echo
    blue "***********************************************"
    blue "${2:-Installing} $1"
    blue "***********************************************"
    echo
}

print_finish_feedback () {
    echo 
    green "✅ Successfully installed $1"
    echo
}

install_prerequisites() {
    print_section_header "Preliminary Checks and Configurations" "Running"
    # Check if Homebrew is installed - Install if not
    if ! command_exists brew; then
        yellow "Homebrew not found. Installing Homebrew..."

        run_remote_installer "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

        # Homebrew does not automatically configure environment path upon successful installation
        # its environment path has to be calculated and configured manually.

        # Detect CPU architecture (M series chip or Intel)
        if [[ $(uname -m) == "arm64" ]]; then 
            BREW_PREFIX="/opt/homebrew"
        else
            BREW_PREFIX="/usr/local"
        fi

        SHELL_NAME=$(basename "$SHELL")

        case "$SHELL_NAME" in
            zsh)
                SHELL_CONFIG="$HOME/.zshrc"
                ;;
            bash)
                # On macOS, bash configuration file can be named .bashrc or .bash_profile 
                if [[ -f "$HOME/.bash_profile" ]]; then
                    SHELL_CONFIG="$HOME/.bash_profile"
                else
                    SHELL_CONFIG="$HOME/.bashrc"
                fi
                ;;
            *)
                echo "Unsupported shell: $SHELL_NAME. Please add Homebrew to your PATH manually."
                exit 1
                ;;
        esac

        # Add Homebrew to PATH
        echo 'eval "$('$BREW_PREFIX'/bin/brew shellenv)"' >> "$SHELL_CONFIG"
        
        # Apply changes immediately
        eval "$($BREW_PREFIX/bin/brew shellenv)"

        if ! command_exists brew; then
            handle_error "❌ Could not install homebrew successfully. Please visit https://brew.sh/ for details on how to install Homebrew on your machine."
            exit 1 
            
        fi

        # Run update
        execute_command brew update

        # Add Homebrew to the list of tools installed
        tools_installed+=("Homebrew Package Manager=✅ Installed successfully")

        print_finish_feedback  Homebrew

    fi

    # Check if zsh is installed - Install if not
    if ! command_exists zsh; then
        yellow "Zsh shell not found.  Installing..."
        execute_command brew install zsh

        tools_installed+=("Zsh Shell=✅ Installed successfully")

        print_finish_feedback  "zsh shell"
    fi

    # Setup Zsh as default shell if not set
    if [[ "$SHELL" != *"zsh" && "$SHELL" != "$(which zsh)" ]]; then

        info "Default login shell is not zsh. Configuring zsh as default shell for user, $USER..."

        # Change to MacOs pre installed zsh or fallback to homebrew installed zsh shell
        if [[ -x "/bin/zsh" ]]; then
            ZSH="/bin/zsh"
        else
            ZSH="$(which zsh)"  # Fallback to Homebrew-installed Zsh
        fi

        execute_command sudo chsh -s "$ZSH" "$USER"

        tools_installed+=("Zsh Shell=💡 Set as default shell for user, $USER")

        info "zsh shell is set as default login shell for $USER"
        echo
    fi
}

install_oh_my_zsh() {
     # Install Oh-my-zsh
    print_section_header "oh-my-zsh"
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing oh-my-zsh..."

        run_remote_installer "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh" "--unattended"

        tools_installed+=("oh-my-zsh=✅ Installed successfully")

        # Disable automatic update set by default. Most users find the auto update feature prompt to be a little too much.
        if [[ -f "$HOME/.zshrc" ]]; then
            sed -i '' "s/# zstyle ':omz:update' mode disabled/zstyle ':omz:update' mode disabled/" "$HOME/.zshrc"
            tools_installed+=("oh-my-zsh=💡 Disabled automatic update prompt")
        fi
 
        print_finish_feedback  oh-my-zsh

    else
        info "Oh-My-Zsh is already installed."
    fi
}

install_themes_and_fonts() {
    print_section_header "Themes and Fonts"

    # Install Powerlevel10k theme
    if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
        info "Installing Powerlevel10k theme..."
        execute_command git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

        # Set the theme to Powerlevel10k in ~/.zshrc file
        sed -i '' 's/^ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

        tools_installed+=("powerlevel10k Plugin=✅ Installed successfully")

        print_finish_feedback  "Powerlevel10k theme"

    else
        info "Powerlevel10k theme already installed."
        echo "Moving on to other installations..."
        echo
    fi

    # Install and configure Nerd Fonts
    if [ ! -f "$HOME/Library/Fonts/HackNerdFont-Regular.ttf" ]; then

        info "Installing Hack Nerd Font..."

        execute_command env HOMEBREW_NO_AUTO_UPDATE=1 brew install --cask font-hack-nerd-font
        tools_installed+=("Nerd-Font=✅ Installed successfully")

        print_finish_feedback  "Hack Nerd Font"
    else
        info "Hack Nerd Font already installed"
    fi

    if [ -d "/Applications/iTerm.app" ]; then

        # Update iTerm2 preferences to use Hack Nerd Font
        info "Configuring Iterm2 to use Hack Nerd Font for Non Ascii Fonts"
        # Set Non-ASCII Font
        defaults write com.googlecode.iterm2 "Non Ascii Font" -string "HackNF-Regular 12"
        # Set Normal Font
        defaults write com.googlecode.iterm2 "Normal Font" -string "MesloLGS-NF-Regular 13"
        # Ensure Non-ASCII Font usage is enabled
        defaults write com.googlecode.iterm2 "Use Non-ASCII Font" -bool true

    fi
}

install_plugins() {
    print_section_header "Plugins"
    # Install zsh plugins
    # - Install zsh-syntax-highlighting
    if [ ! -d "$PLUGINS_DIR/zsh-syntax-highlighting" ]; then
        info "Installing zsh-syntax-highlighting..."
        execute_command git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

        tools_installed+=("zsh-syntax-highlighting Plugin=✅ Installed successfully")

        print_finish_feedback  "zsh-syntax-highlighting"
    else
        info "zsh-syntax-highlighting is already installed"
        echo "Moving on to other installations..."
        echo
    fi

    if [ ! -d "$PLUGINS_DIR/zsh-autosuggestions" ]; then
        # - Install zsh-autosuggestions
        echo
        info "Installing zsh-autosuggestions..."
        execute_command git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        tools_installed+=("zsh-autosuggestions=✅ Installed successfully")

        print_finish_feedback  "zsh-autosuggestions"
    else
        info "zsh-autosuggestions is already installed"
        echo
    fi

    # Add plugins to .zshrc
    sed -i '' 's/^plugins=(.*)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc
}

install_colorls() {
    print_section_header "colorls"
    if ! command_exists colorls; then

        # Check if CURRENT_RUBY_VERSION meets the min requirement of 3.1.0. If not, Install a compatible version using rbenv.
        # Note: CURRENT_RUBY_VERSION here is system installed ruby version.
        if [[ "$LOWER_VERSION" != "$MIN_RUBY_VERSION" ]]; then

            yellow "Your current Ruby version, $CURRENT_RUBY_VERSION is below the minimum required version, $MIN_RUBY_VERSION."
            info "Installing a compatible Ruby version..."
            echo 

            if ! command_exists rbenv ; then
                execute_command brew install rbenv
                execute_command brew install ruby-build

                tools_installed+=("rbenv=✅ Installed successfully")
                print_finish_feedback  "rbenv"
            fi


            if ! rbenv versions | grep -q "3.1.0"; then
                info "Installing ruby 3.1.0 using rbenv"
                echo
                execute_command rbenv install 3.1.0
                execute_command rbenv global 3.1.0
                execute_command rbenv rehash

                print_finish_feedback  "ruby@v3.1.0"
            fi

        fi

        # Ensure rbenv initialized in each terminal session
        RBENV_INIT_LINE='if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi'
        if ! grep -Fq "$RBENV_INIT_LINE" ~/.zshrc 2>/dev/null; then
            echo "$RBENV_INIT_LINE" >> ~/.zshrc
        fi

        # If rbenv is used to install a compatible ruby (as seen above), we may have a situation where two ruby versions exist in parallel -
        # System installed ruby and rbenv managed ruby. 
        # When Ruby gems are installed, bash will naturally default to the system installed Ruby (whose version may be < the min required) 
        # To ensure rbenv Ruby is use for gem installations, we init rbenv in the running bash session
        info "Initialized rbenv in current bash session..."
        if command_exists rbenv; then
            eval "$(rbenv init - bash)"
        fi

        # Install colorls
        RUBY_PATH="$(which ruby)"

        if [[ "$RUBY_PATH" == *".rbenv"* ]]; then
            info "Installing colorls using rbenv Ruby..."
            execute_command gem install colorls
        else
            info "Installing colorls using system Ruby (sudo required)..."
            execute_command sudo gem install colorls
        fi

        tools_installed+=("Colorls=✅ Installed successfully")

        print_finish_feedback  "colorls"
   
    fi

    if ! grep -Eq '^\s*alias\s+ls=.*colorls' ~/.zshrc 2>/dev/null; then
        # Prompt user to add alias ls=colorls
        blue "Would you like to set up 'ls' alias to use colorls? (y/n): "
        read setup_alias

        # Check user's response and respond accordingly
         if [[ $setup_alias == "y" || $setup_alias == "Y" ]]; then
            echo "Adding alias 'ls=colorls' to ~/.zshrc..."

            tools_installed+=("Colorls=💡 Added ls as alias for colorls")
            echo "alias ls=colorls" >> ~/.zshrc
         else
            echo "Skipping alias setup..."
         fi
    fi
}

print_success_message() {
    # Prints a success message block upon successfull completion, 
    # along with a formatted table that lists the tools installed and actions performed.
    echo
    echo
    green "   🔥 Installation complete - You are all set!"
    echo

    blue "Take a look at your Trophies 🏆🏆🏆 below"
    # Print Headers
    printf "%-87s\n" | tr ' ' '-'
    printf "| %-3s | %-32s | %-42s |\n" "S/N" "Tools" "Action Done"
    printf "%-87s\n" | tr ' ' '-'

    # Populate table installed tool's table
    for i in "${!tools_installed[@]}"; do
        tool="${tools_installed[i]%%=*}"      # Extract tool name
        action_done="${tools_installed[i]#*=}" # Extract action done

        # Adjust width for Action Done column to fit longer content
        printf "| %-3d | %-32s | %-43s |\n" "$((i + 1))" "$tool" "$action_done"
    done

    printf "%-87s\n" | tr ' ' '-'
    echo
    blue "Restart your terminal and follow Powerlevel10k configuration wizard to customize your terminal looks"
}

main() {
    can_sudo

    install_prerequisites

    install_oh_my_zsh

    install_themes_and_fonts

    install_plugins

    install_colorls
    
    print_success_message
}


main "$@"
