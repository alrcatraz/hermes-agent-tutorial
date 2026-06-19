--[[
diagram-path.lua — Pandoc Lua filter for diagram images
1. Fixes relative paths (../diagrams/x.svg → src/diagrams/x.svg)
2. Wraps standalone figure images in figure environment with caption
3. Tracks section/subsection numbers for proper figure numbering
   (since Pandoc uses starred sections, LaTeX counters aren't reliable)
--]]

local function fix_path(path)
  return path:gsub('^%.%./diagrams/', 'src/diagrams/'):gsub('%.svg$', '.pdf')
end

local function is_diagram(path)
  return path:match("diagrams/.*%.pdf$") ~= nil
end

-- Track current heading context for figure numbering
local section_num = ""
local figure_count = 0
local last_heading_key = ""

local function heading_key(level, text)
  if level == 1 then
    -- Chapter: "# 第N章：..." or "# 附录X：..."
    local ch = text:match("^第(%d+)章")
    if ch then
      section_num = ch
      figure_count = 0
      return "ch" .. ch
    end
    local app = text:match("^附录(%w)：")
    if app then
      section_num = app
      figure_count = 0
      return "app" .. app
    end
    -- Volume divider or other heading: don't change section num
    return nil
  elseif level == 2 then
    -- Subsection: "## X.Y ..."
    local ch, sec = text:match("^(%d+)%.(%d+)")
    if ch then
      section_num = ch .. "." .. sec
      figure_count = 0
      return "sec" .. ch .. "." .. sec
    end
    return nil
  end
  return nil
end

function Header(header)
  local text = pandoc.utils.stringify(header)
  heading_key(header.level, text)
  return nil
end

function Figure(fig)
  -- Fix image paths inside the figure
  if fig.content and #fig.content > 0 then
    for _, block in ipairs(fig.content) do
      if block.t == "Plain" or block.t == "Para" then
        for _, item in ipairs(block.content) do
          if item.t == "Image" then
            item.src = fix_path(item.src)
            if is_diagram(item.src) then
              -- Get caption/alt text from the Figure's caption (Pandoc 3.x Caption object)
              local alt_text = ""
              if fig.caption then
                if fig.caption.long and #fig.caption.long > 0 then
                  alt_text = pandoc.utils.stringify(fig.caption.long[1])
                end
              end
              -- Fallback to image's inline caption
              if alt_text == "" and #item.caption > 0 then
                alt_text = pandoc.utils.stringify(item.caption)
              end

              figure_count = figure_count + 1
              local fig_label = ""
              if section_num ~= "" then
                fig_label = section_num .. "-" .. tostring(figure_count)
              else
                fig_label = tostring(figure_count)
              end

              local latex = "\\begin{figure}[H]\n"
                .. "  \\centering\n"
                .. "  \\includegraphics[width=0.7\\textwidth]{" .. item.src .. "}\n"
                .. "  \\caption*{"
                .. "\\figurename~" .. fig_label .. " " .. alt_text
                .. "}\n"
                .. "\\end{figure}"
              return pandoc.RawBlock("latex", latex)
            end
          end
        end
      end
    end
  end
  return fig
end
