# Repository Guidelines

## Project Structure & Module Organization

`main.typ` is the thesis entry point and contains the current chapters. Long chapters live in `capitulos/` and are included from `main.typ`. Chapter 2 is `capitulos/estado-del-arte.typ`, which includes one file per section from `capitulos/estado-del-arte/` with level-1 headings; `main.typ` includes it under `set heading(offset: 1)`, and `estado-del-arte.typ` compiles it as a standalone document with cover, outline and references. Update personal, degree, and committee information in `my-metadata.typ`; maintain citations in `references.bib`; and place thesis figures in `imagenes/`. The reusable document template is split across `final.typ`, `intro.typ`, `constants.typ`, and `utils.typ`. `metadata.typ`, `example_final.typ`, and `example_intro.typ` demonstrate the template independently of the thesis. Institutional logos live under `imagenes/institucion/`.

Keep thesis-specific prose and configuration separate from reusable template code. Prefer extending an existing helper in the template files instead of duplicating layout logic in `main.typ`.

## Build and Development Commands

Run commands from this repository root:

- `typst compile main.typ` builds the thesis as `main.pdf`.
- `typst watch main.typ` continuously rebuilds the document while editing.
- `typst compile example_final.typ` validates the final-document template example.
- `typst compile example_intro.typ` validates the proposal/report template example.
- `typst compile estado-del-arte.typ` builds the standalone state-of-the-art chapter PDF.
- From the parent `Tesis` repository, `.venv/bin/python literatura/scripts/build_thesis_bib.py --typ InformeTesis/main.typ --catalog literatura/papers.json --output InformeTesis/references.bib` regenerates `references.bib` from the citations in `main.typ` and its active `#include` files. Do not edit `references.bib` by hand.

Typst CLI is the only documented local prerequisite. Tinymist for VS Code is optional and provides live preview and language support.

## Coding Style & Naming Conventions

Use two-space indentation in new Typst blocks, matching `main.typ` and `my-metadata.typ`. Follow established kebab-case names such as `mostrar-comentarios`, `grado-titulo`, and `start-doc`. Keep imports at the top, use relative asset paths, and assign stable labels to cited figures and sections (for example, `<fig:tetgen>`). Reuse the exported helpers `capitulo`, `apendice`, `resumen`, and `end-doc` rather than reproducing their formatting.

Add bibliography entries with descriptive citation keys and cite them with `@key` or `#cite(...)`. Do not edit institutional SVGs unless the branding itself must change.

## Validation Guidelines

There is no automated test suite or coverage target. Compile every changed entry point and treat warnings or missing references as failures. Visually inspect affected PDF pages for overflow, typography, image resolution, captions, citation numbering, bibliography output, and page breaks. Template changes require compiling both examples in addition to `main.typ`.

## Commit & Pull Request Guidelines

The short Git history does not establish a reliable message convention. Use concise imperative subjects, preferably scoped Conventional Commits such as `docs(thesis): expand methodology` or `fix(template): correct appendix numbering`. Keep content, bibliography, and template changes logically separated. Pull requests should summarize the change, list compiled entry points, identify affected pages or chapters, link relevant issues, and include screenshots when layout changes.
