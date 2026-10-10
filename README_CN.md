# academic-typora

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Editor: Typora](https://img.shields.io/badge/Editor-Typora-333333.svg)](https://typora.io/)
![Themes: Light and Dark](https://img.shields.io/badge/Themes-Light%20%26%20Dark-555555.svg)
[![Word export: Pandoc 3.1+](https://img.shields.io/badge/Word%20export-Pandoc%203.1%2B-1565c0.svg)](https://pandoc.org/)

[English](README.md) | 简体中文

## 简介

一套辅助使用 Typora 进行日常学术写作的黑白主题：深色用于起草，浅色用于阅读、打印和分享。采用宽幅单栏、Times 风格衬线字体、两端对齐正文，并提供摘要、关键词、层级标题编号、简洁表格和白色背景图片区域。可选的 Word 样式参考文档和轻量 Pandoc Lua 过滤器用于生成白底、可编辑的 DOCX，方便反馈与修改。

**这是一套写作辅助样式，不是专业出版排版样式，也不是 IEEE 官方投稿模板。** 部分约定接近 IEEE 稿件，但不复刻完整版式；最终投稿仍应使用目标期刊要求的 LaTeX 或 Word 模板。

保留原来的舒适参数：**19 px 正文字号、1.65 倍行距，最大列宽 1040 px（包含左右各 48 px 内边距）**。优先使用已安装的 Times New Roman，另有衬线字体回退；不附带字体文件。

## 文件说明

| 路径 | 用途 |
| --- | --- |
| `academic-typora-light.css` | 浅色主题，导入本机 `github.css` |
| `academic-typora-dark.css` | 深色主题，导入本机 `night.css` |
| `academic-typora/academic-typora.docx` | Word 样式参考文档，含通用演示内容 |
| `academic-typora/academic-typora.lua` | DOCX 导出过滤器 |
| `README.md` / `README_CN.md` | 英文 / 中文说明 |
| `LICENSE` | 完整 GNU GPL 第 3 版许可文本 |

## 安装

### Typora 主题

1. 打开 **偏好设置 → 外观 → 打开主题文件夹**。
2. 将两个 CSS 文件复制进去。保留 Typora 本机的 `github.css`、`night.css` 及其资源文件夹，以便继承编辑器 UI。
3. 重启 Typora，从主题菜单选择 **Academic Typora Light** 或 **Academic Typora Dark**；不同版本显示名称可能略有差异。

请使用较新的 Typora：编号使用 CSS `counter-set`，末节识别使用 `:has()`。排版规则限定在 `#write` 内；UI 配色继承基础主题及深色主题的颜色变量。

### 在 Typora 中导出 Word

Windows、macOS、Linux 均使用 Typora 内置的 **Word (.docx)** 导出。现有 Lua 过滤器处理学术结构、HTML 图片和公式标号；无需新增脚本、PowerShell、Python 或导出后处理工具。

1. 安装 [Pandoc 3.1 或更高版本](https://pandoc.org/installing.html)，重启 Typora，在 **偏好设置 → 导出 → 通用** 中确认 Pandoc 路径。
2. 将 `academic-typora.docx` 和 `academic-typora.lua` 放在固定文件夹，例如 Windows 的 `C:/Tools/academic-typora/`。
3. 打开 **偏好设置 → 导出 → Word (.docx)**，将 **样式参考 / Style Reference** 设为 `academic-typora.docx`。
4. 将此入口的 **额外参数 / Extra Arguments** 替换为以下内容，按实际位置修改 Lua 路径：

   ```text
   --lua-filter="C:/Tools/academic-typora/academic-typora.lua" --metadata=academic-typora-source="${currentPath}" --resource-path="${currentFolder}"
   ```

   macOS / Linux 改用同一 Lua 文件的绝对路径。`${currentPath}`、`${currentFolder}` 原样保留，由 Typora 替换为当前稿件路径。内置 Word 入口不要添加 `-f markdown`。
5. **先保存 Markdown**，再选择 **文件 → 导出 → Word (.docx)**。导出以已保存的源码为准，可读取原始 `<figure>` 图片及手动 `\tag{…}` 标号，即使 Typora 的中间导出数据没有保留它们。

如果之前配置了 PowerShell 自定义 **Academic Word** 入口，请按以上设置改回 **Word (.docx)**。旧参数 `--metadata=academic-typora-native-equations:true` 已不再需要，可删除。

普通 Markdown 图片本来就由 Typora / Pandoc 原生嵌入。源码参数让现有 Lua 还能从已保存文件恢复 HTML 图片和公式标号。图片路径按稿件目录解析，图片数据直接嵌入 DOCX；无法访问图片时报告导出错误，不生成只有图题的假成功结果。不进行引用、占位或待办检查。

Word 输出使用可编辑的原生公式、黑字白底，优先使用 Times New Roman，正文 12 pt、1.5 倍行距、两端对齐，不随编辑器主题变色。序号由 `\tag{…}` 手动填写；Word 的公式内 `#(…)` 机制处理对齐，不自动递增序号。

### 命令行导出

同一 Lua 过滤器也能在三个平台直接配合 Pandoc 使用。在稿件目录运行：

```sh
pandoc manuscript.md -o manuscript.docx --resource-path="." --reference-doc="/path/to/academic-typora/academic-typora.docx" --lua-filter="/path/to/academic-typora/academic-typora.lua"
```

此时 Pandoc 直接读取原始 Markdown，无需再传源码参数。如果在其他目录导出，请使用稿件绝对路径，并将 `--resource-path` 设为稿件目录。

**公式内编号的对齐以现代 Microsoft Word 为目标（Windows Word 2013 或更高版本）；LibreOffice 和较旧 Word 可能直接显示 `#`。** Lua 使用 Pandoc 自带的 DOCX 写入与 ZIP API 构建 OMML 公式数组，参考 [Pandoc issue 2851](https://github.com/jgm/pandoc/issues/2851) 中 Word 生成的示例。已使用 Pandoc 3.1.3 验证嵌入图片数据及公式结构；测试环境没有 Microsoft Word，无法直接验证其最终显示。

源码导出使用 Pandoc 的 Markdown 解析器。支持标准 Markdown、HTML 图片区域及 `$$…$$` 公式；Typora 特有语法可能存在差异。公式开头和结尾的 `$$` 应各自独占一行，公式内部不要插入空白段落。不会修改 Markdown 源码。不要同时启用 `--number-sections`、手工标题编号或 Word 自动标题编号。

## 学术结构与语法对照

| 结构 | 源码语法 | 显示效果 / 约定 |
| --- | --- | --- |
| 文档标题 | `# Document Title` | 居中、不编号；全文使用一个一级标题 |
| 摘要 | 标题之后、首个 `##` 之前的第一个 `>` 引用块 | 自动添加加粗 **Abstract:** |
| 关键词 | 同一区域第二个独立 `>` 引用块 | 自动添加粗斜体 **Index Terms --** |
| 节标题 | `## Introduction` | `1. Introduction` |
| 子节标题 | `### Background` | `1.1. Background` |
| 下一级标题 | `#### Details` | `1.1.1 Details` |
| 更深标题 | `#####` / `######` | 继续扩展层级数字；不要跳级 |
| 末尾参考文献标题 | 最后一个 `## References` 或 `## Reference` | 不编号；按位置识别 |
| 正文段落 | 普通 Markdown 段落 | 两端对齐，不设置首行缩进 |
| 强调 | `**bold**`、`*italic*` | 原生 Markdown 加粗、斜体 |
| 引用链接 | `[REF](#ref-example)` | Typora 中为蓝色；Word 中按首次引用编号，目标 ID 不存在时为红色 `[REF]`; 名称为非REF时不自动编号； |
| 引用占位 | `[待补文献](#ref)` | 橙色 `[待补文献]`；提示文字任意填写 |
| 写作待办 | `[补充对比说明](#todo)` | 绿色 `[补充对比说明]`；提示文字任意填写 |
| 文献记录 | `<a id="ref-example" name="ref-example">…</a>` | 显示原始记录并提供跳转目标，不套引用方括号 |
| 图片 | 含 `<img>`、`<figcaption>` 的 `<figure>` | 两种主题均为白色面板，图题在下方 |
| 表格 | 原生 Markdown 表格 | 简洁横线，手工表题放上方 |
| 公式 | `$x$` / `$$…\tag{1}$$` | 可编辑 Word 公式，保留手动块级标号，不自动编号 |
| 脚注 | `[^1]` 与 `[^1]: text` | 原生脚注，与文献链接独立 |
| 普通引文 | 后续 `>` 引用块 | 普通引用样式，不添加摘要标签 |
| 代码 / 原始 BibTeX | 围栏代码块，例如 `bibtex` | 等宽、左对齐 |
| 目录 | `[TOC]` | Typora 原生目录；编辑器标题编号仅为视觉内容 |

### 标题、摘要、关键词及层级编号

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

空 HTML 注释用于阻止两个引用块合并。无需手工填写摘要和关键词标签。此例的编号依次为 `1.`、`1.1.`、`1.1.1`、`2.`、`2.1.`；父级变化时，下级重新计数。

**最后一个顶层 `##` 必须预留给参考文献。** CSS 无法读取标题文字，因此最后一个 `##` 无论写什么都会取消编号；Word 过滤器采用相同约定。编号标题应直接位于文档顶层，逐级使用，不在 References 下再添加子标题。主题不会把自动标签和编号写回 Markdown 源码。

### 引用链接与原始 BibTeX

为记录选择稳定、唯一的 `ref-` 标识，显示编号手工填写：

```markdown
An example citation [1](#ref-example).

## References

<a id="ref-example" name="ref-example">@misc{example,<br>
  title = {Example Reference},<br>
  year = {2026}<br>
}</a>
```

Typora 的 [HTML 支持说明](https://support.typora.io/HTML/)指出：编辑预览可能忽略自定义 `id`。建议同时填写相同的 `name` 和 `id`，兼容命名锚点。跳转仍受 Typora 的 HTML 处理方式影响；源码模式显示原始标签。

HTML 锚点内部用 `<br>` 换行，并转义 HTML 特殊字符：`&amp;`、`&lt;`、`&gt;`。不要在 `<a>` 内嵌套 Markdown 围栏代码块。较长记录若需要保留准确的纯文本排版，可以使用空锚点加独立代码块：

````markdown
<a id="ref-example" name="ref-example"></a>

```bibtex
@misc{example,
  title = {Example Reference},
  year = {2026}
}
```
````

引用写成 `[1](#ref-example)`，不要写成 `[[1]](#ref-example)`，因为编辑器自动补上外侧方括号。编号和顺序均为**手工管理**。本项目不将 BibTeX 解析成格式化文献，不排序、重新编号，也不启用 citeproc。完整记录可保留供最终参考文献工具使用。Word 过滤器保留支持写法中的记录文字、命名书签，并将引用方括号变为实际文本。

### 轻量写作标记

```markdown
需要来源的论述 [寻找合适文献](#ref)。
一条写作提醒 [补充对比段落](#todo)。
已确定的正式引用 [1](#ref-example)。
```

目标精确写成 `#ref` 时，显示为**橙色引用占位**；写成 `#todo` 时，显示为**绿色写作待办**。Markdown 链接中的提示文字可以任意填写，外侧方括号由主题添加，不要在提示文字内部再套一对。较长提示可以换行。正式的 `#ref-xxx` 引用仍为**蓝色**，并链接到对应文献记录。

确定文献后，手工将占位替换为正式引用，例如 `[1](#ref-example)`。此前的 `[REF](#ref-)` 保留为橙色占位的兼容写法，新稿建议使用 `#ref`。不进行占位 / 待办检查，不自动完成任务，也无需额外插件。

DOCX 过滤器会将占位与待办导出为**带实际方括号的普通彩色文本**，不生成指向不存在书签的链接。Word 参考文档提供独立的 Reference Placeholder、Writing TODO 字符样式，在白底上使用深橙色、绿色，不添加下划线。提示的行内格式会保留，文字仍可编辑；正式引用保留蓝色超链接及书签。草稿标记在 Word 中继续可见，便于反馈，完成后手工删除或替换。

### 图片

支持普通 Markdown 图片，两种主题均为图片提供白色背景。简单图片及手工图题可以直接写成：

```markdown
![](./figure/fig1.png)

*Fig. 1. Example figure.*
```

需要明确宽度并将图片和图题放在同一区域时，也可以保留 HTML 写法：

```html
<figure style="background-color: #ffffff; padding: 12px; border-radius: 6px; text-align: center;">
  <img src="./figure/fig1.png" width="500" alt="Example figure" style="display: block; margin: 0 auto;">
  <figcaption style="text-align: center; color: #000000;">Fig. 1. Example figure.</figcaption>
</figure>
```

将路径替换为自己的图片。主题已提供这些面板样式；保留内联样式也能向其他 HTML 渲染器明确表达效果。图片宽度自适应，不应用反色滤镜。图号、图题手工填写。Word 过滤器会将完整或拆分的 HTML 图片区域及单独的 `<img>` 转为原生图片，保留图片和图题，不复现 HTML 内边距及圆角。使用内置 **Word (.docx)** 入口及上文的额外参数。图片路径以已保存的 Markdown 文件目录为基准，不以主题文件夹或 Lua 文件夹为基准。若在其他目录使用命令行导出，将 `--resource-path="."` 改为稿件目录。图片会嵌入 DOCX，分享导出的 Word 文件时无需再附带原始图片文件。为使 Word 中效果可靠，按浅色背景设计的图片最好自带白底；透明图片在 Word 白色页面上显示。

### 表格

```markdown
*Table 1. Example values.*

| Item | Value |
| :--- | ---: |
| A | 1 |
| B | 2 |
```

表号、表题手工放在表格之前。主题使用顶线、表头下横线、底线，不设置竖向网格。紧邻表格之前、以 `Table` 和数字开头的单独段落会在 Word 中应用 Table Caption 样式。Word 表格可编辑；建议使用简单结构，过宽的表格应拆分。

表格跟随编辑器背景，深色主题下不会变成白底。白色面板仅用于图片区域，Typora 的原生表格容器已排除。

### 公式与脚注

````markdown
Inline math: $x+y=z$.

$$
E = mc^2 \tag{1}
$$

A note marker[^1].

[^1]: Additional explanation.
````

在 Typora 中启用对应 Markdown / 公式选项。**手动公式标号会保留到 Word：**`\tag{1}` 显示 `(1)`，`\tag{A.1}` 显示 `(A.1)`，`\tag*{A.1}` 显示 `A.1`，不额外添加圆括号。每个独立的 `$$…$$` 公式块使用一个标号。Lua 过滤器保留块级公式，并通过 Word 原生 `#(编号)` 结构将标号放进公式的 OMML 对象；编号属于同一个可编辑公式，不再是公式外的文字。Numbered Equation 样式取消“段中不分页”“与下段同页”“段前分页”，不插入前置制表符。

Typora 的 MathJax 自动编号属于预览设置，不会作为手动标号写入 Markdown；需要保留到 DOCX 的标号请明确填写 `\tag{…}`。这里使用手动编号，不生成 Word 自动编号字段。很宽的公式可能需要在 Word 中调整。自动编号、同一个 aligned 块中多行分别编号、`\label` / `\ref` 交叉引用及期刊特定公式排版仍留到最终排版处理。

## 取舍与限制

- 优先保证宽幅单栏写作的舒适度，不复刻出版双栏布局。黑白主题共用排版参数，只调整颜色。
- 标题、开头摘要 / 关键词、末尾参考文献采用位置约定。跳过标题级别可能出现 `1.0.1` 等编号。
- CSS 自动标签和编号只影响渲染，不修改源码或 Typora 大纲；其他 Markdown 阅读器需要相应样式。可选过滤器仅处理 DOCX，添加普通文本而非动态 Word 编号字段；结构变化后重新导出。
- 原始文献信息得以保留；图表编号、引用显示编号和文献排序由使用者管理。
- Word 使用参考文档样式，不直接使用 CSS。HTML、PDF、编辑预览、Word 之间的换行、字体、图片尺寸和 HTML 支持可能不同。相对图片路径应以稿件目录为基准。
- 请保留本机基础主题。本包不分发基础主题或字体；旧版 Typora 可能不支持所需 CSS 功能。

## 许可

本项目新增内容及修改采用 **GNU GPL v3 only（`GPL-3.0-only`）**，完整文本见 [LICENSE](LICENSE)。如果希望再分发的派生版本继续遵守兼容的 copyleft 许可，GPLv3 是合适的选择。再分发时保留许可与上游声明。此许可针对项目文件，不改变你独立创作的稿件或研究素材的许可。

Word 参考文档基于 Pandoc 默认参考文档修改；上游适用的 GPL v2-or-later 允许修改后的文档按 GPLv3 分发，下方保留其署名。Typora 及本机导入的基础主题仍遵循各自条款。

## 致谢

- [Typora](https://typora.io/) 及其本机 **GitHub**、**Night** 主题提供基础编辑器 UI，通过 CSS 本地导入；本包不附带基础主题文件。[主题文档](https://support.typora.io/About-Themes/)、[自动编号指南](https://support.typora.io/Auto-Numbering/)、[HTML 支持说明](https://support.typora.io/HTML/)和[导出说明](https://support.typora.io/Export/)为兼容处理提供依据。
- [Pandoc](https://pandoc.org/)，Copyright © 2006–2023 John MacFarlane：提供本项目修改所基于的默认 Word 参考文档及 [Lua 过滤器 API](https://pandoc.org/lua-filters.html)。Lua 过滤器已使用 Pandoc 3.1.3 及其自带 DOCX 写入与 ZIP API 实际运行，原生编号结构已检查；测试环境没有 Microsoft Word，无法直接验证其显示。上游声明见 [COPYRIGHT](https://github.com/jgm/pandoc/blob/3.1.3/COPYRIGHT) 和 [许可文本](https://github.com/jgm/pandoc/blob/3.1.3/COPYING.md)。
- [Microsoft Office Math](https://learn.microsoft.com/en-us/office/math/) 提供原生可编辑公式文档；[Pandoc issue 2851](https://github.com/jgm/pandoc/issues/2851) 中 Word 生成的 OMML 示例为编号布局提供依据。
- [Shields.io](https://shields.io/) 提供 README 徽章。

IEEE 风格术语仅用于启发部分写作约定。本项目与 IEEE 无隶属或背书关系，不包含 IEEE 投稿模板。
