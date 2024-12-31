# PlantUML.nvim

A Neovim plugin for rendering PlantUML diagrams directly within your editor.

## Demo

![plant_uml](https://github.com/user-attachments/assets/80669717-e29e-4bb0-9316-8094812ac505)

## Features

- Render PlantUML diagrams in various formats (PNG, SVG, EPS, PDF, LaTeX, TXT, HTML, UTXT, XMI)
- Support for PlantUML blocks in Markdown, LaTeX, and standalone PlantUML files
- Asynchronous rendering to avoid blocking the editor
- Insert rendered diagrams directly into your document
- Configurable output formats and paths

## Requirements

- Neovim 0.5+
- [PlantUML](https://plantuml.com/starting) installed and accessible in your PATH
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)

## Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  'Gabz-Araujo/plantuml.nvim',
  requires = 'nvim-lua/plenary.nvim',
  config = function()
    require('plantuml').setup()
  end
}
```

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'Gabz-Araujo/plantuml.nvim',
  dependencies = 'nvim-lua/plenary.nvim',
  config = function()
    require('plantuml').setup()
  end
}
```

## Configuration

You can configure the plugin by passing options to the setup function:

```lua
require('plantuml').setup({
  plantuml_path = "plantuml", -- Path to PlantUML executable
  output_format = "png",      -- Default output format
  temp_dir = vim.fn.stdpath("cache") .. "/nvim/plantuml_temp", -- Temporary directory for PlantUML files
  image_output_dir = nil,     -- Directory for saving rendered images (nil = same as document)
})
```

## Usage

### Commands

- `:PlantUMLRender [format]`: Render the PlantUML diagram under the cursor and insert it into the document. Optionally specify the output format.
- `:PlantUMLDisplay [format]`: Render the PlantUML diagram under the cursor and display it in a new buffer (not yet implemented).

### Supported Formats

The plugin supports the following output formats:

- png
- svg
- eps
- pdf
- latex
- txt
- html
- utxt
- xmi

### Supported File Types

The plugin can find and render PlantUML blocks in:

- Markdown files (`plantuml ...`)
- LaTeX files (\begin{plantuml} ... \end{plantuml})
- Standalone PlantUML files (@startuml ... @enduml)

## Development

### Running Tests

To run the test suite:

1. Ensure you have [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) installed.
2. From the plugin directory, run:

```
nvim --headless -c "PlenaryBustedDirectory test/ {minimal_init = 'minimal_init.lua'}"
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

## Todo List

Some ideas that i want to Implement/improv:

1. Implement the `display_image_in_buffer` function in `inserters.lua` to allow viewing rendered diagrams in a new buffer.
2. Add support for more file types (e.g., AsciiDoc, reStructuredText).
3. Implement caching to avoid re-rendering unchanged diagrams.
4. Add error handling and more informative error messages.
5. Create keybindings for common operations.
6. Add support for custom PlantUML themes.
7. Implement live preview functionality.
8. Add support for including external files in PlantUML diagrams.
9. Create documentation for Vim help system.
10. Add CI/CD pipeline for automated testing and releases.
11. Implement a command to open the rendered image in the default system viewer.
12. Add support for PlantUML server rendering as an alternative to local rendering.
13. Implement syntax highlighting for PlantUML blocks in supported file types.
14. Add an option to automatically render diagrams on save.
15. Create a gallery of example renderings in the README.
