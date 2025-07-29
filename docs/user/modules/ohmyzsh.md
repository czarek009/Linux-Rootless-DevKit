**Oh My Zsh** is a popular, open-source framework for managing your Zsh (Z shell) configuration. It simplifies customizing your terminal by providing a rich collection of themes, plugins, and sensible defaults that make the command line more powerful and enjoyable to use.

Key features include:

- **Extensive plugin ecosystem** for Git, Docker, Kubernetes, and many other tools
- **Highly customizable themes** to personalize your prompt appearance
- **Improved auto-completion and syntax highlighting** for a smoother workflow

Oh My Zsh is widely used by developers and system administrators to boost productivity and improve the shell experience.


## ⚡ Powerlevel10k (`p10k`) Prompt

[Powerlevel10k](https://github.com/romkatv/powerlevel10k) is a powerful and ultra-fast Zsh prompt theme with a focus on **speed**, **customizability**, and **useful visual context**.

### ⚙️ Configuration

If `p10k` is installed and set as the theme (`ZSH_THEME="powerlevel10k/powerlevel10k"` in `.zshrc`), run the configuration wizard:

```bash
p10k configure
```

This will walk you through customizing:

- Prompt style (classic, rainbow, lean, etc.)
- Icons, spacing, and colors
- Git status indicators
- Left/right segment layout

Your preferences will be saved to `~/.p10k.zsh`, which you can manually edit anytime for fine-grained control.

### 🧠 Tips

- To reload prompt config:  
  ```bash
  source ~/.p10k.zsh
  ```

- To re-run the configuration wizard:  
  ```bash
  p10k configure
  ```

## Useful Links

- Official Website & Repo: [https://ohmyz.sh](https://ohmyz.sh)
- GitHub Repository: [https://github.com/ohmyzsh/ohmyzsh](https://github.com/ohmyzsh/ohmyzsh)
- Popular Plugins: [https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins](https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins)
- Themes Gallery: [https://github.com/ohmyzsh/ohmyzsh/wiki/Themes](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes)  
