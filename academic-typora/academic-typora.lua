-- SPDX-License-Identifier: GPL-3.0-only
-- academic-typora: materialize writing conventions for Word, Pandoc 3.1+.
-- No citation database, citeproc, source rewriting, or non-DOCX modifications.
local equation_cache = {}

local function saved_source(doc)
  local value = doc.meta['academic-typora-source']
  if not value then return doc, nil end
  -- Repeated --metadata arguments become a list. Stringifying the whole list
  -- concatenates paths; use the last supplied path instead.
  if pandoc.utils.type(value) == 'List' then value = value[#value] end
  local path = pandoc.utils.stringify(value)
  if pandoc.path.is_relative(path) then
    path = pandoc.path.join{pandoc.system.get_working_directory(), path}
  end
  local file, reason = io.open(path, 'rb')
  if not file then error('academic-typora: cannot read saved Markdown: ' .. tostring(reason)) end
  local source = file:read('*a'); file:close()
  source = source:gsub('^\239\187\191', '') -- UTF-8 BOM
  -- Typora's native export may already have removed HTML media or math tags.
  -- Read the saved source explicitly; an AST-only filter cannot restore them.
  -- Typora also accepts LaTeX delimiters: \(...\) inline and \[...\] display.
  -- Enable them before parsing, so TeX commands and underscores stay in Math.
  local parsed = pandoc.read(source, 'markdown+raw_html+tex_math_dollars+tex_math_single_backslash')
  for key, item in pairs(doc.meta) do parsed.meta[key] = item end
  parsed.meta['academic-typora-source'] = nil
  return parsed, pandoc.path.directory(path)
end

local function embed_image(folder)
  return function(image)
    local src = image.src
    if src == '' then return nil end
    if folder and not src:match('^[%a][%w+.-]*:') and pandoc.path.is_relative(src) then
      src = pandoc.path.normalize(pandoc.path.join{folder, src})
    end
    -- Embed the actual bytes before the DOCX writer runs. A missing image must
    -- report a conversion error instead of silently becoming caption-only text.
    local ok, mime, bytes = pcall(pandoc.mediabag.fetch, src)
    if not ok or not bytes then
      error('academic-typora: cannot load image "' .. src .. '". Check its path relative to the saved Markdown file.')
    end
    pandoc.mediabag.insert(src, mime, bytes)
    image.src = src
    return image
  end
end

local function citation(link)
  local style
  if link.target == '#ref' or link.target == '#ref-' then
    style = 'Reference Placeholder'
  elseif link.target == '#todo' then
    style = 'Writing TODO'
  elseif not link.target:match('^#ref%-') then
    return nil
  end
  local text = pandoc.utils.stringify(link.content)
  if not (text:sub(1,1) == '[' and text:sub(-1) == ']') then
    link.content:insert(1, pandoc.Str('['))
    link.content:insert(pandoc.Str(']'))
  end
  -- Draft markers describe work rather than a navigation destination. Keep
  -- their text and inline formatting without creating a dangling Word link.
  if style then
    return pandoc.Span(link.content, pandoc.Attr('', {}, {['custom-style']=style}))
  end
  return link
end

local function anchor_id(html)
  local attrs = html:match('^%s*<[aA]%s+([^>]+)>')
  if not attrs or attrs:lower():match('%f[%a]href%s*=') then return nil end
  -- Support either quote style, either attribute order, and HTML named anchors.
  local id = attrs:match('%f[%a]id%s*=%s*"([^"]+)"')
    or attrs:match("%f[%a]id%s*=%s*'([^']+)'")
    or attrs:match('%f[%a]name%s*=%s*"([^"]+)"')
    or attrs:match("%f[%a]name%s*=%s*'([^']+)'")
  return id
end

local function anchor_span(id, content)
  -- Keep raw BibTeX visible; @misc is not a bibliographic citation command here.
  local span = pandoc.Span(content, pandoc.Attr(id))
  span = span:walk{Cite = function(c) return c.content end,
    RawInline = function(r)
      if r.format == 'html' and r.text:lower():match('^%s*<br%s*/?>%s*$') then
        return pandoc.LineBreak()
      end
    end}
  if id:match('^ref%-') then span.attributes['custom-style'] = 'Verbatim Char' end
  return span
end

local function anchors(inlines)
  local out, i = pandoc.List(), 1
  while i <= #inlines do
    local first = inlines[i]
    local id = first.t == 'RawInline' and first.format == 'html'
      and anchor_id(first.text)
    if id then
      if first.text:lower():match('</a%s*>') then
        local parsed = pandoc.read(first.text, 'html'):walk{
          Span = function(s)
            if s.identifier:match('^ref%-') then return anchor_span(s.identifier, s.content) end
          end}
        for _, b in ipairs(parsed.blocks) do
          if b.content then out:extend(b.content) end
        end
        i = i + 1
      elseif first.text:match('/>%s*$') then
        out:insert(anchor_span(id, {})); i = i + 1
      else
        local content, j = pandoc.List(), i + 1
        while j <= #inlines do
          local part = inlines[j]
          if part.t == 'RawInline' and part.format == 'html'
             and part.text:lower():match('^%s*</a%s*>%s*$') then break end
          content:insert(part); j = j + 1
        end
        if j <= #inlines then
          out:insert(anchor_span(id, content)); i = j + 1
        else
          -- An opening anchor split across blocks still receives a bookmark;
          -- subsequent content remains untouched rather than being discarded.
          out:insert(anchor_span(id, {})); i = i + 1
        end
      end
    elseif first.t == 'RawInline' and first.format == 'html'
       and first.text:lower():match('^%s*</a%s*>%s*$') then
      i = i + 1
    else
      out:insert(first); i = i + 1
    end
  end
  return out
end

local function html_blocks(blocks)
  -- Typora and Markdown readers may split a figure across multiple AST blocks.
  local out, i = pandoc.List(), 1
  while i <= #blocks do
    local block = blocks[i]
    local raw = block.t == 'RawBlock' and block
      or ((block.t == 'Para' or block.t == 'Plain') and #block.content == 1
          and block.content[1].t == 'RawInline' and block.content[1])
    local html = raw and raw.format:match('^html') and raw.text
    if html and html:lower():match('<figure[%s>]') then
      local collected, j, closed = pandoc.List(), i, false
      while j <= #blocks do
        local part = blocks[j]; collected:insert(part)
        local rendered = pandoc.write(pandoc.Pandoc{part}, 'html')
        if rendered:lower():match('</figure%s*>') then
          closed = true; break
        end
        j = j + 1
      end
      if closed then
        -- Re-read only the figure, so HTML becomes native images and captions.
        -- Typora can send a complete figure as RawInline rather than RawBlock.
        local source = #collected == 1 and html
          or pandoc.write(pandoc.Pandoc(collected), 'html')
        out:extend(pandoc.read(source, 'html').blocks)
        i = j + 1
      else
        out:insert(block); i = i + 1
      end
    elseif html and html:lower():match('<img[%s/]') then
      out:extend(pandoc.read(html, 'html').blocks)
      i = i + 1
    elseif block.t == 'RawBlock' and block.format == 'html' and anchor_id(block.text) then
      if block.text:lower():match('</a%s*>') then
        local parsed = pandoc.read(block.text, 'html'):walk{
          Span = function(s)
            if s.identifier:match('^ref%-') then return anchor_span(s.identifier, s.content) end
          end}
        out:extend(parsed.blocks)
      else
        out:insert(pandoc.Para{anchor_span(anchor_id(block.text), {})})
      end
      i = i + 1
    else
      out:insert(block); i = i + 1
    end
  end
  return out
end

local function html_image(raw)
  if not raw.format:match('^html') or not raw.text:lower():match('<img[%s/]') then return nil end
  local content = pandoc.List()
  for _, block in ipairs(pandoc.read(raw.text, 'html').blocks) do
    if block.t == 'Para' or block.t == 'Plain' then content:extend(block.content) end
  end
  if #content > 0 then return content end
end

local function numbered_equation(p)
  if #p.content ~= 1 or p.content[1].t ~= 'Math'
     or p.content[1].mathtype ~= 'DisplayMath' then return nil end
  local tex, label, starred = p.content[1].text
  -- TeX's tag is a display instruction, which Pandoc's DOCX writer drops.
  -- Convert display math with Pandoc itself, then place the manual tag inside
  -- Word's native equation object. No external program or DOCX postprocessor.
  local stripped = tex:gsub('\\tag(%*?)%s*(%b{})', function(star, braces)
    label, starred = braces:sub(2, -2), star == '*'
    return ''
  end)
  if not label then return nil end
  stripped = stripped:gsub('\\label%s*(%b{})', '')
  local number = pandoc.List()
  if not starred then number:insert(pandoc.Str('(')) end
  local parsed = pandoc.read(label, 'latex')
  for _, block in ipairs(parsed.blocks) do
    if block.t == 'Para' or block.t == 'Plain' then number:extend(block.content) end
  end
  if not starred then number:insert(pandoc.Str(')')) end
  local math = equation_cache[stripped]
  if not math then
    local bytes = pandoc.write(pandoc.Pandoc{pandoc.Para{pandoc.Math('DisplayMath', stripped)}}, 'docx')
    for _, entry in ipairs(pandoc.zip.Archive(bytes).entries) do
      if entry.path == 'word/document.xml' then
        local xml = entry:contents()
        math = xml:match('<m:oMath>(.-)</m:oMath>')
          or xml:match('<m:oMath%s[^>]*>(.-)</m:oMath>')
        break
      end
    end
    if not math then error('academic-typora: cannot convert numbered equation to Word math.') end
    equation_cache[stripped] = math
  end
  local text = pandoc.utils.stringify(number):gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;')
  local function math_text(value)
    return '<m:r><m:rPr><m:sty m:val="p"/></m:rPr><m:t>' .. value .. '</m:t></m:r>'
  end
  local tag = starred and math_text(text)
    or '<m:d><m:dPr><m:begChr m:val="("/><m:endChr m:val=")"/></m:dPr><m:e>'
      .. math_text(text:sub(2, -2)) .. '</m:e></m:d>'
  return pandoc.RawBlock('openxml',
    '<w:p><w:pPr><w:pStyle w:val="NumberedEquation"/>'
    .. '<w:keepNext w:val="0"/><w:keepLines w:val="0"/><w:pageBreakBefore w:val="0"/></w:pPr>'
    .. '<m:oMathPara><m:oMathParaPr><m:jc m:val="centerGroup"/></m:oMathParaPr><m:oMath>'
    .. '<m:eqArr><m:eqArrPr><m:maxDist m:val="1"/></m:eqArrPr><m:e>'
    .. math .. math_text('#') .. tag .. '</m:e></m:eqArr></m:oMath></m:oMathPara></w:p>')
end

local function anchor_paragraph(p)
  if pandoc.utils.stringify(p) == '' then
    for _, inline in ipairs(p.content) do
      if inline.t == 'Span' and inline.identifier ~= '' then
        return pandoc.Div({p}, pandoc.Attr('', {}, {['custom-style']='Anchor'}))
      end
    end
  end
  if #p.content == 1 and p.content[1].t == 'Span'
     and p.content[1].identifier:match('^ref%-') then
    return pandoc.Div({p}, pandoc.Attr('', {}, {['custom-style']='Source Code'}))
  end
end

local function frontmatter(quote, label)
  local first = quote.content[1]
  if first and (first.t == 'Para' or first.t == 'Plain') then
    local lead = label == 'Index Terms --' and pandoc.Emph{pandoc.Str(label)} or pandoc.Str(label)
    first.content:insert(1, pandoc.Space())
    first.content:insert(1, pandoc.Strong{lead})
  end
  return quote.content
end

function Pandoc(doc)
  if not FORMAT:match('docx') then return doc end
  local folder
  doc, folder = saved_source(doc)
  doc = doc:walk{Blocks = html_blocks}
  doc = doc:walk{RawInline = html_image}
  doc = doc:walk{Image = embed_image(folder)}
  doc = doc:walk{Inlines = anchors}
  doc = doc:walk{Para = anchor_paragraph, Plain = anchor_paragraph, Link = citation}
  doc = doc:walk{Para = numbered_equation, Plain = numbered_equation}
  local last_section
  for index, block in ipairs(doc.blocks) do
    if block.t == 'Header' and block.level == 2 then last_section = index end
  end
  local result, counters = pandoc.List(), {0,0,0,0,0,0}
  local title_seen, section_seen, quote_count = false, false, 0
  for index, block in ipairs(doc.blocks) do
    if block.t == 'Header' then
      if block.level == 1 and not title_seen then
        title_seen = true
      elseif block.level >= 2 then
        section_seen = true
        local level = block.level
        if not (level == 2 and index == last_section) then
          counters[level] = counters[level] + 1
          for i = level + 1, 6 do counters[i] = 0 end
          local parts = {}
          for i = 2, level do parts[#parts+1] = tostring(counters[i]) end
          local prefix = table.concat(parts, '.') .. (level <= 3 and '.' or '')
          block.content:insert(1, pandoc.Space())
          block.content:insert(1, pandoc.Str(prefix))
        end
      end
      result:insert(block)
    elseif block.t == 'BlockQuote' and title_seen and not section_seen and quote_count < 2 then
      quote_count = quote_count + 1
      result:extend(frontmatter(block, quote_count == 1 and 'Abstract:' or 'Index Terms --'))
    else
      result:insert(block)
    end
  end
  doc.blocks = result
  -- A manually written Table caption belongs above the following table.
  for i = 1, #doc.blocks - 1 do
    local block = doc.blocks[i]
    if block.t == 'Para' and pandoc.utils.stringify(block):match('^Table%s+%d')
       and doc.blocks[i+1].t == 'Table' then
      doc.blocks[i] = pandoc.Div({block}, pandoc.Attr('', {}, {['custom-style']='Table Caption'}))
    end
  end
  return doc
end
