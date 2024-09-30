return {
  "epwalsh/obsidian.nvim",
  -- version = "3.9.0",
  -- the obsidian vault in this default config  ~/obsidian-vault
  -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand':
  -- event = { "bufreadpre " .. vim.fn.expand "~" .. "/my-vault/**.md" },
  event = { "BufReadPre " .. vim.fn.expand "files/notes/**/*.md" },
  lazy = "false",
  version = "3.9.0",
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
    "nvim-telescope/telescope.nvim",
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["gf"] = {
              function()
                if require("obsidian").util.cursor_on_markdown_link() then
                  return "<Cmd>ObsidianFollowLink<CR>"
                else
                  return "gf"
                end
              end,
              desc = "Obsidian Follow Link",
            },
          },
        },
      },
    },
  },
  opts = {
    dir = vim.env.HOME .. "/files/notes", -- specify the vault location. no need to call 'vim.fn.expand' here
    use_advanced_uri = true,
    finder = "telescope.nvim",
    log_level = vim.log.levels.DEBUG,

    templates = {
      subdir = "obsidian-templates",
      date_format = "%Y-%m-%d-%a",
      time_format = "%H:%M",
    },

    -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
    -- URL it will be ignored but you can customize this behavior here.
    follow_url_func = vim.ui.open or function(url) require("astrocore").system_open(url) end,
  },
  daily_notes = {
    folder = "daily-notes",
    date_format = "%Y-%m-%d",
    -- Optional, if you want to change the date format of the default alias of daily notes.
    alias_format = "%B %-d, %Y",
    default_tags = nil,
    -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
    template = nil,
  },
  note_id_func = function(title)
    if title ~= nil then
      local date = os.date "%Y%m%d%H%M" -- e.g., "202409290930"
      local sanitized_title = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      return date .. "-" .. sanitized_title
    else
      local suffix = ""
      for _ = 1, 4 do
        suffix = suffix .. string.char(math.random(65, 90))
      end
      return "untitled-" .. suffix
    end
  end,

  -- Custom note path function
  note_path_func = function(spec)

    -- Sanitize the title
    local sanitized_title = spec.title and spec.title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower() or "untitled"

    -- Generate a timestamp
    local date = os.date "%Y%m%d%H%M%S" -- e.g., "20240929103045"

    -- Combine components to form the file path
    local path = spec.dir / (date .. "-" .. tostring(spec.title) .. "-" .. sanitized_title)

    -- Return the full path with the .md suffix
    return path:with_suffix ".md"
  end,
}
