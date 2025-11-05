
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

-- require fmt helper
local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets("tex", {
  s("article", fmt([[
\documentclass[12pt]{{article}}
\usepackage[T1]{{fontenc}}
\usepackage{{multicol}}
\usepackage{{soul}}
\usepackage{{times}}
\usepackage{{setspace}}
\usepackage{{hyperref}}
\usepackage{{amsmath}}
\usepackage{{nicefrac}}
\usepackage{{graphicx}}
\usepackage[font=small,labelfont=it]{{caption}}
\usepackage[style=apa, backend=biber]{{biblatex}}
\addbibresource{{references.bib}}

\title{{{}}}
\author{{{}}}
\date{{\today}}

\begin{{document}}

\maketitle

\begin{{abstract}}
{}
\end{{abstract}}

\section{{Introduction}}
{}

\section{{Main Content}}
{}

\section{{Conclusion}}
{}

\end{{document}}
  ]], {
      i(1, "Title here"),
      i(2, "Author Name"),
      i(3, "Abstract goes here..."),
      i(4, "Introduction content..."),
      i(5, "Main content..."),
      i(6, "Conclusion content...")
  }))
})

