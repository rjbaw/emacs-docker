# Emacs with LaTeX & Orgmode in Docker
Opinionated Emacs with orgmode, latex, and batteries included features in Docker Compose.

## Core Components
- Emacs 28.1 with Luid GUI  
- PDFLatex, XeLaTeX, LuaLaTeX.  
- Python 3, Julia, Jupyter Notebook  

## Screenshots
### Jupyter Blocks
![Alt text](https://github.com/rjbaw/org-latex-docker/blob/b4bf8c35ec9ab5192bd9723b4b26e00a1c4f01c0/images/code-block.gif)  
### LaTeX fragments (jkitchin)
![Alt text](https://github.com/rjbaw/org-latex-docker/blob/b4bf8c35ec9ab5192bd9723b4b26e00a1c4f01c0/images/latex-render.gif)  
### SymPy render
![Alt text](https://github.com/rjbaw/org-latex-docker/blob/b4bf8c35ec9ab5192bd9723b4b26e00a1c4f01c0/images/sym-render.gif)  

## Getting Started
### Requirements
- x86-64  
- Docker https://docs.docker.com/engine/install/  
- Docker Compose https://docs.docker.com/compose/install/  

### Setup
```
docker-compose up -d
```

### Notes

- Not supported in arm64 due to missing IJulia and other issues
- Console mode is not recommended due to missing features.

### General Usage
#### New Session
```
docker exec -it emacs-latex bash
```
##### GUI mode
```
em
```
##### Terminal mode
```
et
```

#### Evil-mode
If you do know Vim keybindings, learn them or add `(evil-mode 0)` to your init.el
#### Snippets
Included `yasnippet-snippets` and few more in `snippets/` folder.  
#### Code Blocks
Jupyter Code Blocks: `<js` & `TAB`  
Code execution: C-C  
Code Interupt: C-TAB or C-g  


