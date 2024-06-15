-- configurations for plugins on which many different plugins depend
-- not meant to be loaded directly

return {
  ["web-devicons"] = {
    "nvim-tree/nvim-web-devicons",
    build = function()
      local fonts_dir = vim.fn.expand("~/.local/share/fonts")
      local zip_file = fonts_dir .. "/Hack.zip"
      -- chain of shell commands to spawn (inverted)
      local function nop() end
      local function update_cache(code)
        if code ~= 0 then return end
        vim.loop.spawn("fc-cache", {}, nop)
      end
      local function unzip(code)
        if code ~= 0 then return end
        vim.loop.spawn("unzip", {
          args = { "-o", zip_file, "-d", fonts_dir }
        }, update_cache)
      end
      vim.loop.spawn("curl", {
        args = { "--create-dirs", "-fLo", zip_file, "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip" }
      }, unzip)
    end,
  },
  ["plenary"] = { "nvim-lua/plenary.nvim" },
}
