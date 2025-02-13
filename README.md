# Auto Zsh Config for MacOS

Auto Zsh Config for MacOS is a bash script that automates the setup of a highly functional and visually appealing Zsh environment on macOS.  
It capitalises on existing powerful terminal window enhancement tools like [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) and [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) plugin.

Once run on your Mac, it will embellish your shell terminal with useful capabilities that will make your developer experience fun and smooth.  
Whether you are a savvy developer who uses macOS or simply someone who seldom uses a shell terminal, this script makes installing shell terminal  
enhancement tools seamless.

<details>
<summary>Content Navigation</summary>

- [Tools and Features](#tools-and-features)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
    - [Inspect Before Use](#inspect-before-use)
- [Want to Contribute?](#want-to-contribute)
- [See It in Action](#see-it-in-action)
    - [See Zsh-Autosuggestions in Action](#see-zsh-autosuggestions-in-action)
    - [How About Syntax highlight by Zsh-syntax-highlighting](#how-about-syntax-highlight-by-zsh-syntax-highlighting)
    - [Don't Get Me Started On Colorls](#dont-get-me-started-on-colorls)
</details>

## Tools and Features
Take a moment to peruse the shell terminal enhancement tools that will be installed when you run this script.
| S/N | Tool | What it will do |
|:---|:--------------------|:--------------------------------------------------------------------------------------------------------------------------------------|
| 1 | [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh)| Gives your terminal a posh lift and makes it easy to integrate with other enhancement tools |
| 2 | [Powerlevel10k Theme](https://github.com/romkatv/powerlevel10k)| Gives your Zsh terminal a stylish look with a blazing-fast prompt and intuitive visual cues|
| 3 | [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) | Adds icons, symbols, and glyphs needed for proper rendering of terminal visual enhancements. |
| 4 | [zsh-syntax-highlighting plugin](https://github.com/zsh-users/zsh-syntax-highlighting) | Highlights commands as you type, making it easy to spot errors and improve command-line productivity |
| 5 | [zsh-autosuggestions plugin](https://github.com/zsh-users/zsh-autosuggestions) | Suggests commands as you type based on your history, speeding up your workflow and reducing typing effort|
| 6 | [colorls](https://github.com/athityakumar/colorls) | Enhances your terminal’s file listing with color-coded and visually appealing outputs, basically makes navigating directories and files easier |

## Prerequisites
- `Operating System` - Do not attempt to run this script on any OS other than macOS 

- [Bash Shell](https://www.gnu.org/software/bash/) - The script assumes your macOS already has the Bash shell installed. Though most recent macOS comes with Bash, it won't hurt to confirm.

- [Zsh Shell](https://www.zsh.org) - As per [oh-my-zsh prerequisites](https://github.com/ohmyzsh/ohmyzsh?tab=readme-ov-file#prerequisites), **version 4.3.9+** of Zsh is a requirement for [oh-my-zsh](https://github.com/zsh-users/zsh-autosuggestions). The script will attempt to install a recent version of [Zsh](https://www.zsh.org) if not already installed,  **BUT** it is preferable if you already have it installed.

- [cURL](https://curl.se/) - The script depends on curl to install some of the terminal enhancement tools listed in [Tools and Features](#tools-and-features). It is a reasonable assumption that your macOS already has [cURL](https://curl.se/) installed, but it is safe to confirm. You can run `which curl` on your terminal and check for a positive output like ``/usr/bin/curl`` to confirm that cURL is, indeed, installed

- [Homebrew](https://brew.sh/) - The script will attempt to install [Homebrew](https://brew.sh/) package manager if not already installed, **BUT** we prefer you manually install [Homebrew](https://brew.sh/)  before running this script as successful installation of [Homebrew](https://brew.sh/) by this script is not guaranteed. You can visit [Homebrew Documentation](https://brew.sh/) for details on how to install Homebrew package manager on your macOS

- [Git](https://git-scm.com/) - Required to be installed

- [iTerm2](https://iterm2.com/) - Install iTerm2 terminal for a better terminal experience.

<details>
<summary>Extra Info</summary>
You can run any of the commands on your terminal to check that the listed prerequisites tools are installed and their versions.  

`bash --version`

`zsh --version`

`curl --version`

`brew --version`

`git --version`

A terminal output that shows a version statement like below is an indication that the tool is installed

```
❯ bash --version
bash --version
GNU bash, version 3.2.57(1)-release (x86_64-apple-darwin22)
Copyright (C) 2007 Free Software Foundation, Inc.
```
</details>



## Usage

For quick use of this script, you can run any of the followin commands on your terminal.

**Using cURL**
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/EricOgie/auto-mac-zsh-config/main/setup.sh)"
```

**Using wget**  
You can use this option if you have ` wget ` installed in you macOS.
```bash
bash -c "$(wget -qO- https://raw.githubusercontent.com/EricOgie/auto-mac-zsh-config/main/setup.sh)"
```

### Inspect Before Use
If you would like to inspect the script to understand what it does before installing, you can use the URL below to inspect the raw script.  
[https://raw.githubusercontent.com/EricOgie/auto-mac-zsh-config/main/setup.sh](https://raw.githubusercontent.com/EricOgie/auto-mac-zsh-config/main/setup.sh)

You can also clone the project for a more robust look around.
```
git clone https://github.com/EricOgie/auto-mac-zsh-config.git
```

## Want to Contribute?
This script already provides a well-rounded and feature-rich Zsh environment, but there’s always room for refinement. Whether it’s optimizing efficiency, expanding the list of useful tools, or fine-tuning configurations, I’m always open to fresh ideas that can make it even better.

If you have suggestions, optimizations, or additional tools that would enhance the developer experience, your contributions are more than welcome! Here’s how you can get involved:

- Fork the Repository – Start by creating your own copy of the project.
- Make Your Enhancements – Tweak, refine, and enhance the script to improve functionality or add useful features.
- Submit a Pull Request – Once you’re happy with your changes, open a pull request detailing what you’ve improved.
- Engage in Discussion – I’ll review your contributions and might suggest a few tweaks, so let’s collaborate to make the script even better!

No idea is too small—whether it’s fixing a minor inefficiency or introducing a game-changing improvement, your input is valued. Let’s build something awesome together! 🚀

**⭐ If you find this project useful, don’t forget to star the repo!**

Your support helps spread the word and encourages further development.

## See It in Action
You should see a success message like the image below on your terminal window.
<img width="721" alt="Image" src="https://github.com/user-attachments/assets/71847c47-b1e9-4883-bac8-d53223663697" />  
The number of installed tools and settings performed on your macOs by this script can be more or less depending on whether you already have some of the needed tools and settings in place

### See Zsh-Autosuggestions in Action
<img width="571" alt="Image" src="https://github.com/user-attachments/assets/fe06163d-564e-4867-ae3c-2728c4168964" />

Do you notice how it suggests commands based on history and the most matching command? I know, it's cool! 😎 🎩

### How About Syntax highlight by Zsh-syntax-highlighting
<img width="701" alt="Image" src="https://github.com/user-attachments/assets/f7c208e6-3367-419b-a01a-2b3609c94ef6" />
   
Valid commands are highlighted to differentiate them from invalid ones.

### Don't Get Me Started On Colorls
Give it to colorls - Its file and directory organization is 🔥
  
<img width="642" alt="Image" src="https://github.com/user-attachments/assets/fdc445dc-122c-4ca7-a2df-276be80301f7" />



