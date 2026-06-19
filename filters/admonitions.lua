--[[
admonitions.lua — Pandoc Lua filter for admonition blocks
Supports MkDocs-style:  !!! type "title" (indented body)

Renders in LaTeX with:
- First paragraph of body = title (bold + type color), on its own line
- Remaining content = body (normal Markdown rendering)
- No blank line gap between title and body
- Code blocks inside admonitions rendered as lstlisting
- Consecutive text lines joined into single paragraphs (soft breaks)
- Proper LaTeX special character escaping
--]]

-- Map admonition class to LaTeX environment name and color name
local env_map = {
  note = "note",
  info = "note",
  tip = "tip",
  warning = "warning",
  danger = "dangerbox",
}
local color_map = {
  note = "noteborder",
  tip = "tipborder",
  warning = "warnborder",
  dangerbox = "dangerborder",
}

-- Escape LaTeX special characters in raw text
local function escape_tex(s)
  -- Backslash first (will be escaped in raw text, not in LaTeX commands)
  s = s:gsub("\\", "\\textbackslash{}")
  s = s:gsub("~", "\\textasciitilde{}")
  s = s:gsub("([#$%&_{}])", "\\%1")
  s = s:gsub("%^", "\\textasciicircum{}")
  return s
end

-- Markdown-to-LaTeX inline converter for admonition body text
-- Uses extract-store-restore pattern:
-- 1. Extract all constructs (bold, code, links, LaTeX commands) and store as table
-- 2. Replace with simple numeric markers that escape_tex can't damage
-- 3. escape_tex on remaining raw text (markers contain only NUL + digits, safe)
-- 4. Replace markers with stored LaTeX content
local function inline_to_tex(s)
  local tex_store = {}
  local mid = 0
  local function store(latex)
    mid = mid + 1
    tex_store[mid] = latex
    return "Z" .. mid .. "z"
  end

  -- Step 1: Extract LaTeX commands first (they should pass through verbatim)
  -- \command[...]{...} (e.g. \hyperref[ch:5]{第五章})
  s = s:gsub("(\\[a-zA-Z]+%b[]%b{})", store)
  -- \command{...} (e.g. \ref{label})
  s = s:gsub("(\\[a-zA-Z]+%b{})", store)

  -- Step 2: Protect *** from **bold** regex
  s = s:gsub("%*%*%*", function() return store("***") end)

  -- Step 3: Replace Markdown constructs
  -- **bold** → \textbf{...}
  s = s:gsub("%*%*([^*]-)%*%*", function(b)
    local safe = b:gsub("\\", "\\textbackslash{}")
    safe = safe:gsub("~", "\\textasciitilde{}")
    safe = safe:gsub("([#$%&_{}])", "\\%1")
    return store("\\textbf{" .. safe .. "}")
  end)
  -- `code` → \icode{...}
  s = s:gsub("`([^`]+)`", function(code)
    local safe = code:gsub("\\", "\\textbackslash{}")
    safe = safe:gsub("~", "\\textasciitilde{}")
    -- Allow line breaks at natural break points in inline code
    safe = safe:gsub("/", "/\\allowbreak{}")
    safe = safe:gsub("%.", ".\\allowbreak{}")
    -- Allow line breaks after commas in JSON/data
    safe = safe:gsub(",", ",\\allowbreak{}")
    -- Escape remaining special chars (NOT {} — they're part of tilde escaping)
    safe = safe:gsub("([#$%&_])", "\\%1")
    -- Allow line breaks after underscores in identifiers
    safe = safe:gsub("\\_", "\\_\\allowbreak{}")
    safe = safe:gsub("%^", "\\textasciicircum{}")
    return store("\\icode{" .. safe .. "}")
  end)
  -- [text](url) → \href{url}{text}
  s = s:gsub('%[([^%]]+)%]%(([^%)]+)%)', function(text, url)
    return store("\\href{" .. url .. "}{" .. text .. "}")
  end)

  -- Step 4: Escape remaining raw LaTeX special chars
  -- Markers are Z<N>z — letters+digits, unaffected by escape_tex
  s = escape_tex(s)

  -- Step 5: Replace markers with stored LaTeX content
  for i = 1, mid do
    s = s:gsub("Z" .. i .. "z", function() return tex_store[i] end)
  end

  return s
end

-- Render body text (after first line / title) into LaTeX
-- Supports:
-- - Paragraphs: blank-line-separated blocks
-- - Soft breaks: consecutive non-blank lines joined into one paragraph
-- - Bullet lists: lines starting with "- "
-- - Ordered lists: lines starting with "N. " (N = number)
-- - Code blocks: __CB__...__CE__ markers for verbatim lstlisting
local CODEBLOCK_START = "__CB__"
local CODEBLOCK_END = "__CE__"

local function render_body(body)
  if not body or body == "" then return "" end
  local latex = ""
  local in_bullet = false
  local in_enumerate = false
  local in_para = false
  local in_codeblock = false

  for line in body:gmatch("([^\r\n]+)") do
    -- Trim leading whitespace for processing
    local clean = line:gsub("^%s*", "")

    -- Code block start marker
    if clean:find("^" .. CODEBLOCK_START) then
      -- Close any open structures
      if in_para then latex = latex .. "\n"; in_para = false end
      if in_bullet then latex = latex .. "\\end{itemize}\n"; in_bullet = false end
      if in_enumerate then latex = latex .. "\\end{enumerate}\n"; in_enumerate = false end
      -- Extract language from marker: __CB__[lang]
      local lang = clean:match("^" .. CODEBLOCK_START .. "%[(.-)%]$") or ""
      if lang ~= "" then
        latex = latex .. "\\begin{lstlisting}[language=" .. lang .. "]\n"
      else
        latex = latex .. "\\begin{lstlisting}\n"
      end
      in_codeblock = true

    -- Code block end marker
    elseif clean == CODEBLOCK_END then
      latex = latex .. "\\end{lstlisting}\n"
      in_codeblock = false

    -- Inside code block: verbatim pass-through
    elseif in_codeblock then
      latex = latex .. line .. "\n"

    -- Empty line: close any open paragraph or list
    elseif clean == "" then
      if in_para then
        latex = latex .. "\n\n"
        in_para = false
      end
      if in_bullet then
        latex = latex .. "\\end{itemize}\n"
        in_bullet = false
      end
      if in_enumerate then
        latex = latex .. "\\end{enumerate}\n"
        in_enumerate = false
      end

    -- Non-empty text line
    else
      -- Check for ordered list item: "N. content" with at least one space after the dot
      local o_num, o_content = clean:match("^(%d+)%.%s+(.*)$")
      if o_num then
        -- Close any open paragraph or other list
        if in_para then latex = latex .. "\n"; in_para = false end
        if in_bullet then latex = latex .. "\\end{itemize}\n"; in_bullet = false end
        if not in_enumerate then
          latex = latex .. "\\begin{enumerate}\n"
          in_enumerate = true
        end
        latex = latex .. "  \\item " .. inline_to_tex(o_content) .. "\n"

      -- Check for bullet list item: "- content" with at least one space
      elseif clean:match("^%-%s+") then
        local content = clean:match("^%-%s+(.*)$")
        -- Close any open paragraph or other list
        if in_para then latex = latex .. "\n"; in_para = false end
        if in_enumerate then latex = latex .. "\\end{enumerate}\n"; in_enumerate = false end
        if not in_bullet then
          latex = latex .. "\\begin{itemize}\n"
          in_bullet = true
        end
        latex = latex .. "  \\item " .. inline_to_tex(content) .. "\n"

      -- Regular paragraph text
      else
        -- Close any open list
        if in_bullet then latex = latex .. "\\end{itemize}\n"; in_bullet = false end
        if in_enumerate then latex = latex .. "\\end{enumerate}\n"; in_enumerate = false end
        -- Join with previous line if we're in a paragraph (soft break)
        if not in_para then
          latex = latex .. inline_to_tex(clean)
          in_para = true
        else
          latex = latex .. " " .. inline_to_tex(clean)
        end
      end
    end
  end

  -- Close any remaining open structures
  if in_para then latex = latex .. "\n\n" end
  if in_bullet then latex = latex .. "\\end{itemize}\n" end
  if in_enumerate then latex = latex .. "\\end{enumerate}\n" end

  return latex
end

-- Generate raw LaTeX for an admonition
-- First body paragraph = title (bold + type color)
-- Rest = body content
function generate_admonition_latex(cls, title_attr, body_text)
  local env_name = env_map[cls]
  local color_name = color_map[env_name] or "accent"
  local latex = "\\begin{" .. env_name .. "}\n"

  -- Split body into lines
  local lines = {}
  for line in (body_text or ""):gmatch("([^\r\n]+)") do
    table.insert(lines, line)
  end

  -- Determine title: prefer !!! type "Title" attribute, else first body line
  local title_line = ""
  local title_idx = 0
  if title_attr and title_attr ~= "" then
    title_line = title_attr
  else
    -- Find first non-empty body line as title
    for i, line in ipairs(lines) do
      local clean = line:gsub("^%s*(.-)%s*$", "%1")
      if clean ~= "" and not clean:find("^__CB__") then
        title_line = clean
        title_idx = i
        break
      end
    end
  end

  -- Render title: bold with type color background
  if title_line ~= "" then
    -- Strip outer ** markers if present (since we re-wrap in \textbf)
    local display_title = title_line:gsub("^%*%*(.-)%*%*$", "%1")
    latex = latex .. "\\admonitiontitle{" .. color_name .. "}{\n  " .. escape_tex(display_title) .. "\n}\n"
  end

  -- Collect remaining body lines (skip title line and any blank lines after it)
  local body_start = 1
  if title_idx > 0 then
    body_start = title_idx + 1
    -- Skip blank line(s) after title
    while body_start <= #lines do
      local clean = lines[body_start]:gsub("^%s*(.-)%s*$", "%1")
      if clean == "" then
        body_start = body_start + 1
      else
        break
      end
    end
  end

  local body_lines = {}
  for i = body_start, #lines do
    table.insert(body_lines, lines[i])
  end
  local body = table.concat(body_lines, "\n")

  -- Render body
  latex = latex .. render_body(body)

  -- Strip trailing blank lines before closing
  latex = latex:gsub("[\n]+$", "\n")

  latex = latex .. "\\end{" .. env_name .. "}"
  return pandoc.RawBlock("latex", latex)
end

-- Convert a MkDocs-style "!!!" Para block to a raw LaTeX admonition
function convert_mkdocs_admonition(para, next_block)
  if #para.content < 3 then return nil, false end
  local first = para.content[1]
  if first.t ~= "Str" or first.text ~= "!!!" then return nil, false end

  -- Extract class (element 3 = Str after "!!!" + Space)
  local cls = ""
  if #para.content >= 3 and para.content[3].t == "Str" then
    cls = para.content[3].text
  end
  if not cls or not env_map[cls] then return nil, false end

  -- Extract title from the 5th element if it's a Quoted
  local title = ""
  local body_text = ""
  local skip_next = false

  if #para.content >= 5 and para.content[5].t == "Quoted" then
    -- Build title from AST elements
    local tp = {}
    for _, ci in ipairs(para.content[5].content) do
      if ci.t == "Str" then
        table.insert(tp, ci.text)
      elseif ci.t == "Space" then
        table.insert(tp, " ")
      end
    end
    title = table.concat(tp)
    -- Collect body from remaining content after the Quoted element
    local lines = {}
    local current_line = {}
    local collect = false
    local title_quoted_seen = false
    for _, item in ipairs(para.content) do
      if item.t == "Quoted" and not title_quoted_seen then
        title_quoted_seen = true
        collect = true
      elseif collect then
        if item.t == "SoftBreak" then
          if #current_line > 0 then
            table.insert(lines, table.concat(current_line, " "))
            current_line = {}
          end
        elseif item.t == "Space" then
          table.insert(current_line, " ")
        elseif item.t == "Str" then
          table.insert(current_line, item.text)
        elseif item.t == "Strong" then
          local text = pandoc.utils.stringify(item)
          table.insert(current_line, "**" .. text .. "**")
        elseif item.t == "Code" then
          -- Preserve inline code with backticks (inline_to_tex will convert them)
          table.insert(current_line, "`" .. item.text .. "`")
        elseif item.t == "Quoted" then
          -- Chinese/smart quotes: preserve with actual Unicode quote chars
          local qtext = pandoc.utils.stringify(item)
          local qt = item.qt or "Double"
          if qt == "Single" then
            table.insert(current_line, "\226\128\152" .. qtext .. "\226\128\153")
          else
            table.insert(current_line, "\226\128\156" .. qtext .. "\226\128\157")
          end
        elseif item.t == "Link" then
          -- Link element: [text](url) – preserve as \hyperref for internal anchors
          local link_text = pandoc.utils.stringify(item)
          local target = item.target or ""
          if target:match("^#") then
            -- Internal anchor: [第五章](#ch:5) → \hyperref[ch:5]{第五章}
            table.insert(current_line, "\\hyperref[" .. target:sub(2) .. "]{" .. link_text .. "}")
          else
            -- External link: \href{url}{text}
            table.insert(current_line, "\\href{" .. target .. "}{" .. link_text .. "}")
          end
        elseif item.t == "RawInline" then
          -- Raw inline (could be HTML or other format)
          table.insert(current_line, item.text)
        elseif item.t == "Underline" or item.t == "Emph" then
          local text = pandoc.utils.stringify(item)
          table.insert(current_line, text)
        else
          table.insert(current_line, pandoc.utils.stringify(item))
        end
      end
    end
    if #current_line > 0 then
      table.insert(lines, table.concat(current_line, " "))
    end
    body_text = table.concat(lines, "\n")
  else
    -- No quoted title, everything after "!!!" is body
    title = ""
    local text = pandoc.utils.stringify(para)
    local header_len = #("!!!" .. " " .. cls)
    body_text = text:sub(header_len + 1)
  end

  -- If next_block is a CodeBlock, absorb it
  -- Handles three cases:
  -- 1. Fenced code block: Pandoc parsed it correctly -> use classes/language
  -- 2. Indented code block with backtick markers: Pandoc treated ```bash as literal
  -- 3. Indented bullet list: blank line split a list from the admonition body
  if next_block and next_block.t == "CodeBlock" then
    local code_text = next_block.text
    local lang = ""
    local is_list = false

    -- Check if first line looks like a backtick-fenced code block in literal form
    local first_line = code_text:match("^(`+)(.-)$")
    if first_line then
      -- Indented code block containing backtick markers
      -- Extract language from the opening fence
      local fence_lang = code_text:match("^`+([^\n]*)")
      lang = fence_lang or ""
      -- Strip opening and closing backtick lines
      code_text = code_text:gsub("^`+[^\n]*\n?", "")
      code_text = code_text:gsub("\n?`+\n?$", "")
    elseif next_block.classes and #next_block.classes > 0 then
      -- Proper fenced code block: use the detected language
      -- But classes[1] might be empty string '' - check length
      if type(next_block.classes[1]) == "string" and next_block.classes[1] ~= "" then
        lang = next_block.classes[1]
      end
    end

    -- Check if the code content is actually a bullet list (indented after blank line)
    local check_line = (code_text:gsub("^%s*", "")):match("^([^\n]+)")
    if check_line and (check_line:match("^[-*] ") or check_line:match("^%d+%.[- ]")) then
      -- Looks like a list, not code — treat as body text
      body_text = body_text .. "\n" .. code_text
      skip_next = true
    elseif code_text ~= "" then
      -- Real code block — wrap in lstlisting
      local marker = CODEBLOCK_START
      if lang ~= "" then
        marker = marker .. "[" .. lang .. "]"
      end
      body_text = body_text .. "\n" .. marker .. "\n" .. code_text .. "\n" .. CODEBLOCK_END
      skip_next = true
    end
  end

  return generate_admonition_latex(cls, title, body_text), skip_next
end

-- Handle native Pandoc ::: Div syntax
function Div(elem)
  local classes = elem.classes
  if not classes or #classes == 0 then return nil end

  local env_name = nil
  for _, cls in ipairs(classes) do
    if env_map[cls] then
      env_name = env_map[cls]
      break
    end
  end
  if not env_name then return nil end

  local latex = "\\begin{" .. env_name .. "}\n"
  local color_name = color_map[env_name] or "accent"

  -- Extract title from first block
  local first_block = elem.content[1]
  local body_start = 1
  if first_block then
    local title_text = pandoc.utils.stringify(first_block):gsub("^%s*(.-)%s*$", "%1")
    if title_text ~= "" then
      latex = latex .. "{\\color{" .. color_name .. "}\\textbf{" .. title_text .. "}}\\\\\\[4pt]\n"
      body_start = 2
    end
  end

  for i = body_start, #elem.content do
    latex = latex .. pandoc.utils.stringify(elem.content[i]) .. "\n\n"
  end

  latex = latex .. "\\end{" .. env_name .. "}"
  return pandoc.RawBlock("latex", latex)
end

-- Top-level filter: scan for !!! Para blocks followed by CodeBlock
function Pandoc(doc)
  local new_blocks = {}
  local i = 1
  while i <= #doc.blocks do
    local block = doc.blocks[i]
    local next_block = doc.blocks[i + 1]

    if block.t == "Para" then
      local result, skip = convert_mkdocs_admonition(block, next_block)
      if result then
        table.insert(new_blocks, result)
        if skip then
          i = i + 1
        end
      else
        table.insert(new_blocks, block)
      end
    else
      table.insert(new_blocks, block)
    end
    i = i + 1
  end
  doc.blocks = new_blocks
  return doc
end
