# academic-typora

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Editor: Typora](https://img.shields.io/badge/Editor-Typora-333333.svg)](https://typora.io/)
![Themes: Light and Dark](https://img.shields.io/badge/Themes-Light%20%26%20Dark-555555.svg)
[![Word export: Pandoc 3.1+](https://img.shields.io/badge/Word%20export-Pandoc%203.1%2B-1565c0.svg)](https://pandoc.org/)

English | [简体中文](README_CN.md)

## Introduction

Two simple, wide, single-column Typora themes for everyday academic writing: dark for drafting and light for reading, printing, and sharing. Times-style serif fonts, justified paragraphs, an abstract, index terms, numbered headings, simple tables, and white-backed figures provide a familiar academic writing environment. An optional Word reference document and a small Pandoc Lua filter produce an editable, light-background DOCX for feedback.

**This is a writing aid, not a professional publication style or an official IEEE submission template.** Some conventions resemble IEEE manuscripts, but the project does not reproduce their complete layout. Use the required LaTeX or Word template for final typesetting and submission.

The editor retains the existing comfortable settings: **19 px text, 1.65 line height, and a 1040 px maximum column including 48 px padding on each side**. Times New Roman is preferred when installed; fallback serif fonts are provided. Fonts are not bundled.

## Package contents

| Path | Purpose |
| --- | --- |
| `academic-typora-light.css` | Light writing theme; imports the installed `github.css` |
| `academic-typora-dark.css` | Dark writing theme; imports the installed `night.css` |
| `academic-typora/academic-typora.docx` | Word style reference with neutral demonstration content |
| `academic-typora/academic-typora.lua` | DOCX export filter |
| `README.md` / `README_CN.md` | English / Chinese documentation |
| `LICENSE` | Full GNU GPL version 3 license |

## Installation

### Typora themes

1. In Typora, open **Preferences → Appearance → Open Theme Folder**.
2. Copy both CSS files into that folder. Keep Typora's installed `github.css`, `night.css`, and their asset folders: these themes import them to retain the editor UI.
3. Restart Typora and select **Academic Typora Light** or **Academic Typora Dark** in the Themes menu; the displayed name may vary by version.

Use a recent Typora version: numbering uses CSS `counter-set`, and the final-section rule uses `:has()`. Typography rules are scoped to `#write`; UI colors come from the base theme and the dark palette variables.

### Word export in Typora

Use Typora's built-in **Word (.docx)** export on Windows, macOS, or Linux. The existing Lua filter handles academic conventions, HTML figures, and equation tags; no additional script, PowerShell, Python, or export postprocessor is required.

1. Install [Pandoc 3.1 or newer](https://pandoc.org/installing.html), restart Typora, and check its Pandoc path in **Preferences → Export → General**.
2. Keep `academic-typora.docx` and `academic-typora.lua` in a stable folder, for example `C:/Tools/academic-typora/` on Windows.
3. Open **Preferences → Export → Word (.docx)** and set **Style Reference** to `academic-typora.docx`.
4. Replace the entry's **Extra Arguments** with the following, adjusting the Lua path:

   ```text
   --lua-filter="C:/Tools/academic-typora/academic-typora.lua" --metadata=academic-typora-source="${currentPath}" --resource-path="${currentFolder}"
   ```

   On macOS or Linux, use the absolute path to the same Lua file. Keep `${currentPath}` and `${currentFolder}` as written: Typora replaces these variables with the current manuscript's paths. Do not add `-f markdown` to Typora's built-in entry.
5. **Save the Markdown**, then choose **File → Export → Word (.docx)**. Exports use the saved source, including original `<figure>` elements and manual `\tag{…}` labels, even if Typora's intermediate export data omits them.

If you configured the previous custom **Academic Word** PowerShell entry, switch back to **Word (.docx)** using the settings above. Remove the obsolete `--metadata=academic-typora-native-equations:true` argument; it is no longer needed.

Ordinary Markdown images already use Typora/Pandoc's native image embedding. The source argument additionally lets the filter recover HTML figures and equation tags from the saved file. Images are resolved relative to that file and embedded in the DOCX; an inaccessible image produces an export error instead of a caption-only result. No citation, placeholder, or TODO validation is performed.

The output uses editable native Word math, black text on white, Times New Roman where available, 12 pt body text, 1.5 line spacing, and justified body paragraphs. It does not depend on the selected editor theme. Formula numbers are manually controlled by `\tag{…}`; Word's equation-internal `#(…)` mechanism handles alignment but does not increment them automatically.

### Command-line export

The same Lua filter works directly with Pandoc on all three platforms. From the manuscript folder:

```sh
pandoc manuscript.md -o manuscript.docx --resource-path="." --reference-doc="/path/to/academic-typora/academic-typora.docx" --lua-filter="/path/to/academic-typora/academic-typora.lua"
```

No source metadata is needed here because Pandoc reads the original Markdown directly. For exports from another directory, use the manuscript's absolute path and set `--resource-path` to its folder.

**Native equation-number alignment targets modern Microsoft Word (Windows Word 2013 or later); LibreOffice and older Word versions may show a literal `#`.** The Lua filter builds the OMML equation array using Pandoc's built-in DOCX writer and ZIP API, following the Word-generated example in [Pandoc issue 2851](https://github.com/jgm/pandoc/issues/2851). Embedded image bytes and equation structures were tested with Pandoc 3.1.3; Microsoft Word was not available for direct rendering verification.

Source-based export uses Pandoc's Markdown parser. Standard Markdown, HTML image figures, and `$$…$$` math are supported; Typora-specific extensions may differ. Put the opening and closing `$$` on their own lines and avoid blank paragraphs inside a math block. The Markdown file is never rewritten. Do not combine this filter with `--number-sections`, manually typed heading numbers, or automatic Word heading numbering.

## Academic structures and syntax

| Structure | Source syntax | Result / convention |
| --- | --- | --- |
| Document title | `# Document Title` | Centered, unnumbered title; use one top-level title |
| Abstract | First `>` blockquote after the title, before any `##` | Adds bold **Abstract:** |
| Index terms | Second separate `>` blockquote in the same opening area | Adds bold italic **Index Terms --** |
| Section | `## Introduction` | `1. Introduction` |
| Subsection | `### Background` | `1.1. Background` |
| Subsubsection | `#### Details` | `1.1.1 Details` |
| Deeper headings | `#####` / `######` | Extend the decimal hierarchy; avoid skipping levels |
| Final bibliography heading | Final `## References` or `## Reference` | Unnumbered; position-based rule |
| Body paragraph | Ordinary Markdown paragraph | Justified, without first-line indentation |
| Emphasis | `**bold**`, `*italic*` | Native Markdown emphasis |
| Citation link | `[REF](#ref-example)` | Blue in Typora; first-use numbering in Word, red [REF] if the target ID is absent; no automatic numbering when the name is not REF; Language reference: Blue in Typora; first-use numbering in Word, red [REF] if the target ID is absent |
| Citation placeholder | `[source to add](#ref)` | Orange `[source to add]`; the label is arbitrary |
| Writing TODO | `[add supporting detail](#todo)` | Green `[add supporting detail]`; the label is arbitrary |
| Bibliographic record | `<a id="ref-example" name="ref-example">…</a>` | Visible raw record and jump target, without citation brackets |
| Figure | `<figure>` with `<img>` and `<figcaption>` | White panel in both themes; caption below |
| Table | Native Markdown table | Simple horizontal rules; manual caption above |
| Equations | `$x$` / `$$…\tag{1}$$` | Editable Word math; manual display tags retained, no automatic numbering |
| Footnotes | `[^1]` and `[^1]: text` | Native footnotes; independent of reference links |
| Other quotations | Later `>` blocks | Ordinary quotations, without abstract labels |
| Code / raw BibTeX | Fenced code block, e.g. language `bibtex` | Monospaced, left-aligned text |
| Table of contents | `[TOC]` | Native Typora TOC; editor heading numbers are visual only |

### Title, abstract, keywords, and headings

```markdown
# Document Title

> A concise summary of the purpose, approach, and main findings.

<!-- -->

> Academic writing, Markdown, document preparation.

## Introduction

A paragraph referring to an example source [1](#ref-example).

### Background

#### Details

## Discussion

### Observations

## References
```

The empty HTML comment prevents the two quotations from merging. Do not type the abstract/keyword labels yourself. Headings in this example display `1.`, `1.1.`, `1.1.1`, `2.`, and `2.1.`; lower counters restart whenever their parent changes.

**Reserve the final top-level `##` heading for the bibliography.** CSS cannot inspect heading text, so the last `##` is unnumbered regardless of its wording. The DOCX filter follows the same rule. Keep all numbered headings as direct document headings, descend through levels consecutively, and do not add subsections under References. Title, labels, and numbers are not written into your Markdown.

### Citation links and raw BibTeX

Use a stable, unique `ref-` key for the record and a manually chosen display number for the link:

```markdown
An example citation [1](#ref-example).

## References

<a id="ref-example" name="ref-example">@misc{example,<br>
  title = {Example Reference},<br>
  year = {2026}<br>
}</a>
```

Typora's [HTML support documentation](https://support.typora.io/HTML/) notes that custom `id` attributes may be omitted in editing preview. Include the same `name` alongside `id` for named-anchor compatibility. Jump behavior still depends on Typora's HTML handling; source mode displays the original markup.

Use `<br>` for line breaks inside an HTML anchor. Escape HTML-special characters in the record (`&amp;`, `&lt;`, `&gt;`). Do not nest Markdown code fences inside `<a>`. For long records that should retain their exact plain-text formatting, use an empty anchor followed by a fenced block instead:

````markdown
<a id="ref-example" name="ref-example"></a>

```bibtex
@misc{example,
  title = {Example Reference},
  year = {2026}
}
```
````

Write `[1](#ref-example)`, not `[[1]](#ref-example)`: the editor supplies the outer brackets. Numbers and ordering are **manual**. This project does not parse BibTeX into a formatted bibliography, sort references, renumber citations, or run citeproc. Keep the complete records for later use in your final bibliography workflow. The Word filter preserves supported record text and named bookmarks, and converts the citation brackets to actual text.

### Word citation numbering and reference checks

The existing Lua filter automatically applies the following rules during DOCX export:

- An internal `#ref-xxx` link whose target ID exists receives a blue `[1]`, `[2]`, etc., in order of first occurrence in the manuscript. Repeated links to the same ID reuse the same number. Footnotes and tables participate in reading order. The original link label may be `REF`, a number, or other text; it is replaced in the Word output.
- A formal citation to a missing ID becomes red `[REF]` text. It receives no number and no broken hyperlink.
- Exact `#ref` and `#ref-` placeholders stay orange, and exact `#todo` markers stay green. They do not take citation numbers. Other links and literal code remain unchanged.
- Records under the final `## References` heading receive the corresponding `[n]` prefix and are ordered by first citation. Uncited records follow in their original relative order, with their full text in red and no assigned number. Links inside the bibliography do not count as manuscript citations.

Use **one `ref-xxx` anchor per reference entry**, either enclosing the raw record or immediately before its fenced BibTeX block, as shown above. Keep any continuation blocks with their entry. Put all reference entries under the final References heading and avoid manually adding a numeric prefix to the stored record.

These checks only match citation targets to IDs and detect uncited records. They do not validate BibTeX fields, author names, years, or publication details. First-citation numbering, sorting, and red marks affect only the exported DOCX; the Markdown source and Typora citation labels are not rewritten. The editor's separate record counter is described above. Word receives ordinary editable numbers rather than live citation fields: re-export after changing citation order. No additional script or library is required.

### Lightweight writing markers

```markdown
A claim requiring a source [find a suitable source](#ref).
A reminder [add a comparison paragraph](#todo).
A completed citation [1](#ref-example).
```

The exact target `#ref` marks an **orange reference placeholder**, and `#todo` marks a **green writing task**. You can freely choose the text inside the Markdown link. The theme supplies the visible brackets; do not add a second pair inside the label. Longer reminders can wrap onto another line. Formal `#ref-xxx` citations remain **blue** and link to their bibliographic records.

Once the source is known, manually replace the placeholder with a formal citation, for example `[1](#ref-example)`. The former `[REF](#ref-)` syntax remains an orange placeholder alias for compatibility; use `#ref` in new drafts. No placeholder/task validation, automatic completion, or extra plugin is involved.

The DOCX filter exports placeholders and TODOs as **ordinary colored text with actual brackets**, rather than links to nonexistent bookmarks. The reference document defines separate Reference Placeholder and Writing TODO character styles: dark orange and green on white, with no underline. Labels retain their inline formatting and remain editable; formal citations retain blue hyperlinks and bookmarks. These draft markers stay visible in Word for feedback; remove or replace them manually when finished.

### Figures

Ordinary Markdown images are supported and receive a white background in both themes. For a simple image and manually written caption:

```markdown
![](./figure/fig1.png)

*Fig. 1. Example figure.*
```

You can also keep the HTML figure structure for explicit width and caption grouping:

```html
<figure style="background-color: #ffffff; padding: 12px; border-radius: 6px; text-align: center;">
  <img src="./figure/fig1.png" width="500" alt="Example figure" style="display: block; margin: 0 auto;">
  <figcaption style="text-align: center; color: #000000;">Fig. 1. Example figure.</figcaption>
</figure>
```

Replace the path with your own image. The theme also supplies these panel styles, but inline styles make the intention explicit in other HTML renderers. Figures remain responsive; no inversion filter is applied. Figure numbers and captions are written manually. For Word, the filter converts complete or split HTML figures and standalone `<img>` elements to native images; images and captions remain in the DOCX, while HTML padding and rounded corners are not reproduced. Use the built-in **Word (.docx)** entry with the extra arguments above. Image paths are relative to the saved manuscript, not the theme or Lua folder. For command-line exports from another directory, replace `--resource-path="."` with the manuscript folder. Embedded images no longer depend on the external image files when the resulting DOCX is shared. White-designed artwork should include its own white background for reliable Word output; transparent images appear against the white page.

### Tables

```markdown
*Table 1. Example values.*

| Item | Value |
| :--- | ---: |
| A | 1 |
| B | 2 |
```

Write captions and table numbers manually above the table. The theme uses top, header, and bottom rules without a vertical grid. A single paragraph beginning `Table` and a number immediately before a table receives the Word Table Caption style. Tables remain editable in Word; use simple structures and split very wide tables.

Tables follow the editor background, including in the dark theme. White panels apply to image figures only; Typora's native table containers are excluded.

### Math and footnotes

````markdown
Inline math: $x+y=z$.

$$
E = mc^2 \tag{1}
$$

A note marker[^1].

[^1]: Additional explanation.
````

Enable the relevant Markdown/math options in Typora. **Manual display-equation tags are retained in Word:** `\tag{1}` produces `(1)`, `\tag{A.1}` produces `(A.1)`, and `\tag*{A.1}` produces `A.1` without added parentheses. Use one tag per standalone `$$…$$` block. The Lua filter retains display math and places the number inside the equation’s OMML object, using Word’s native `#(number)` layout. The number belongs to the same editable equation, rather than a separate text run. The Numbered Equation style disables Keep lines together, Keep with next, and Page break before; no leading tab is inserted. 

Typora’s automatic MathJax numbering is a preview setting and is not stored as a manual tag in the Markdown; add `\tag{…}` when a number must survive DOCX export. This is manual numbering, not a Word numbering field. Very wide equations may require adjustment in Word. Automatic numbering, multiple row numbers within one aligned block, `\label`/`\ref` cross-references, and journal-specific math layout remain outside this project’s scope.

## Design choices and limitations

- A comfortable single column takes priority over reproducing a publication's two-column layout. The two themes share typography and differ in colors.
- The title/front matter and final References section follow positional conventions. Skipping heading levels can produce zero components such as `1.0.1`.
- CSS-generated labels and numbers change the rendered document, not the source or Typora's outline. Other Markdown readers need their own styling. The optional filter applies only to DOCX and adds ordinary text, not live Word numbering fields; export again after structural changes.
- Bibliographic records are retained as raw text. Figure/table numbers, citation display numbers, and reference ordering stay under your control.
- Word uses reference-document styles rather than CSS. HTML, PDF, editor preview, and Word may differ in wrapping, fonts, image sizing, and supported markup. Relative image paths must resolve from the manuscript's folder.
- Keep the installed base themes. This package does not redistribute their files or fonts. Older Typora builds may not support the required CSS features.

## License

Project additions and modifications are released under **GNU GPL v3 only (`GPL-3.0-only`)**; see [LICENSE](LICENSE). GPLv3 is suitable if you want redistributed derivatives of this project to remain under a compatible copyleft license. Retain the license and upstream notices when redistributing. The license covers these project files, not your independently authored manuscript or research assets.

The Word reference adapts Pandoc's default reference document. Pandoc's applicable upstream GPL v2-or-later terms permit redistribution of the adapted document under GPLv3; the attribution is retained below. Typora itself and its locally imported themes retain their own terms.

## Acknowledgments

- [Typora](https://typora.io/) and its installed **GitHub** and **Night** themes provide the base editor UI, imported locally through CSS. The [theme documentation](https://support.typora.io/About-Themes/), [automatic numbering guide](https://support.typora.io/Auto-Numbering/), [HTML support](https://support.typora.io/HTML/), and [export documentation](https://support.typora.io/Export/) informed compatibility choices. The base theme files are not bundled.
- [Pandoc](https://pandoc.org/), Copyright © 2006–2023 John MacFarlane, supplies the default Word reference document adapted here and the [Lua filter API](https://pandoc.org/lua-filters.html). The Lua filter was exercised with Pandoc 3.1.3, including its built-in DOCX writer and ZIP API. Native numbering structure was checked; Microsoft Word rendering was not available. See the upstream [COPYRIGHT](https://github.com/jgm/pandoc/blob/3.1.3/COPYRIGHT) and [license](https://github.com/jgm/pandoc/blob/3.1.3/COPYING.md).
- [Microsoft Office Math](https://learn.microsoft.com/en-us/office/math/) documents native editable equations; the Word-generated OMML example in [Pandoc issue 2851](https://github.com/jgm/pandoc/issues/2851) informed equation-number layout.
- [Shields.io](https://shields.io/) supplies the README badges.

IEEE-style terminology is an inspiration for a few writing conventions. This project is not affiliated with or endorsed by IEEE and does not include an IEEE submission template.
