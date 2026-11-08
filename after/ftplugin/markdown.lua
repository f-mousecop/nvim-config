local set = vim.opt_local

set.shiftwidth = 4
set.number = true
set.relativenumber = false

-- navigate to a Markdown heading using an anchor link under the cursor
-- example:
--  [Stop process](#stop-process)
--                    |
--                    V
--  ### Stop process
local function follow_markdown_anchor()
  -- get the entire line where the cursor is currently positioned
  local line = vim.api.nvim_get_current_line()

  -- nvim_win_get_cursor() returns { row, column }
  -- rows are 1-based, but columns are 0-based
  --
  -- string.find() uses 1-based positions, add 1 to the
  -- cursor column to make the indices compatible
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1

  -- starting pos for searching the current line
  -- lets us process multiple md links on the same line
  local pos = 1

  -- search for md anchor links until we find one containing
  -- the cursor or reach the end of line
  --
  -- match links formatted like:
  --  [Link text](#heading-anchor)
  --
  -- lua pattern:
  --  %b[]    = balanced square brackts containing link text
  --  %(      = literal opening parenthesis
  --  ( ... ) = capture link destination
  --  #       = destination must begin with '#'
  --  [^)]+   = one or more chars other than ')'
  --  %)      = literal closing parenthesis (written as %))
  --
  -- string.find() returns:
  --  start   = first char of the complete md link
  --  finish  = last char of the complete link
  --  link    = captured destination
  while true do
    local start, finish, link = line:find("%b[]%((#[^)]+)%)", pos)

    -- no more matching anchor links on this line -> exit loop
    if not start then
      break
    end

    -- only follow the link if the cursor is positioned somewhere
    -- within its complete md syntax
    if col >= start and col <= finish then
      -- remove leading '#' because generated heading slugs
      -- don't include it
      --
      -- "#stop-process" -> "stop-process"
      local anchor = link:sub(2)

      -- we need to track heading slugs we've already encountered
      -- numeric suffixes assigned to duplicate headings:
      --   ## Example -> example
      --   ## Example -> example-1
      --   ...
      local occurrences = {}

      for row, text in ipairs(
        vim.api.nvim_buf_get_lines(0, 0, -1, false)
      ) do
        -- detect md ATX headings such as # Heading ## Heading ...
        --
        -- pattern:
        --  ^     = beginning of line
        --  %s*   = optional leading whitespace
        --  #+    = one or more '#' chars
        --  %s+   = required whitespace after the hashes
        --  (.+)  = capture the heading text
        --  $     = end of line
        --
        --  returns nil if the line isn't a matching heading
        local heading = text:match("^%s*#+%s+(.+)$")

        if heading then
          -- we need to convert the heading into an approximate
          -- GitHub-style slug and convert upper to lowercase:
          --
          --  "Stop Background Process!"
          --  -> "stop-background-process"
          local slug = heading:lower()

          -- remove optional closing '#' chars:
          --  "My Heading ###" -> "My Heading"
          slug = slug:gsub("%s+#+%s*$", "")

          -- remove backticks and asterisks
          slug = slug:gsub("[`*]", "")

          -- remove punctuation, while preserving letters,
          -- digits, whitespace, underscores, and hyphens
          slug = slug:gsub("[^%w%s_%-]", "")

          -- replace one or more ws chars with single hyphens
          slug = slug:gsub("%s+", "-")

          -- we need to check how many times this slug base appeared
          -- earlier in the document
          --
          -- or 0 initializes the count for a new slug
          local count = occurrences[slug] or 0

          occurrences[slug] = count + 1

          if count > 0 then
            slug = slug .. "-" .. count
          end

          -- compare the generated heading slug against
          -- the anchor extracted from the md link
          if slug == anchor then
            -- now we need to move the cursor to the matching heading
            vim.api.nvim_win_set_cursor(0, { row, 0 })

            -- center the destination line in the window
            -- 'normal!' executes the command without
            -- honoring custom key mappings
            -- 'zz' scrolls so the cursor line is centered
            vim.cmd("normal! zz")
            return
          end
        end
      end

      -- we found the anchor link under the cursor, but couldn't
      -- find a matching heading anywhere in the cur buffer
      vim.notify(
        "Heading not found: " .. anchor,
        vim.log.levels.WARN
      )
      return
    end

    -- the current link doesn't contain the cursor
    -- continue searching immediately after this link,
    -- allowing multiple md links to exist on the same line
    pos = finish + 1
  end

  -- no supported anchor link was found under the cursor
  vim.notify(
    "No Markdown anchor link under cursor",
    vim.log.levels.INFO
  )
end

-- create a normal-mode keymap for navigating md anchor links
vim.keymap.set("n", "<leader>mh", follow_markdown_anchor, {
  -- make the mapping local to the current md buffer
  -- useful when placed in after/ftplugin/markdown.lua
  buffer = true,
  desc = "Follow Markdown heading anchor",
})
