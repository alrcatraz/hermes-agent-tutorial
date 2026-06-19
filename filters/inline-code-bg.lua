--[[
inline-code-bg.lua — Pandoc Lua filter for inline code rendering
==================================================================
Provides grey-background \colorbox for inline Code elements,
with robust special-character escaping for \texttt environments.

Usage:
  pandoc ... --lua-filter=inline-code-bg.lua

Requires:
  - astra-doc-style.sty (or equivalent with \icode command)
  - xcolor package with \definecolor{codebg}{HTML}{E4E4E4}
--]]

local SOH_L = '\1LB\1'
local SOH_R = '\1RB\1'

local function escape_tex(s)
  -- 1) Protect original braces with SOH placeholders
  s = s:gsub('\\{', SOH_L)
  s = s:gsub('\\}', SOH_R)

  -- 2) Escape backslashes (raw backslash → textbackslash)
  s = s:gsub('\\', '\\textbackslash{}')

  -- 3) Escape underscores
  s = s:gsub('_', '\\textunderscore{}')

  -- 4) Escape caret
  s = s:gsub('%^', '\\textasciicircum{}')

  -- 5) Escape tilde
  s = s:gsub('~', '\\~{}')

  -- 6) Escape remaining special chars (% $ # &)
  s = s:gsub('%%', '\\%%')
  s = s:gsub('%$', '\\$')
  s = s:gsub('#', '\\#')
  s = s:gsub('&', '\\&')

  -- 7) Restore protected braces as \{ \}
  s = s:gsub(SOH_L, '\\{')
  s = s:gsub(SOH_R, '\\}')

  -- 8) Allow line breaks after slashes, dots, and underscores in paths/identifiers
  s = s:gsub('/', '/\\allowbreak{}')
  s = s:gsub('%.', '.\\allowbreak{}')
  s = s:gsub('\\textunderscore%{%}', '\\textunderscore{}\\allowbreak{}')

  -- 9) Allow line breaks after commas in JSON/data
  s = s:gsub(',', ',\\allowbreak{}')

  -- 10) Allow line breaks after escaped ampersand (&amp; → \\&)
  s = s:gsub('\\&', '\\&\\allowbreak{}')

  return s
end

function Code(elem)
  local escaped = escape_tex(elem.text)
  return pandoc.RawInline('latex', '\\icode{' .. escaped .. '}')
end
