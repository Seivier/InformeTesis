// Documento independiente con el estado del arte de la tesis.
// Usa el mismo contenido que main.typ (capitulos/estado-del-arte.typ) con títulos de nivel 1.
#import "my-metadata.typ": metadata
#import "constants.typ": logos

#set document(title: "Estado del arte", author: metadata.autoria.nombre)
#set page(paper: "us-letter", margin: (left: 3cm, rest: 2.5cm))
#set text(lang: "es", font: "New Computer Modern", size: 12pt)
#set par(justify: true, first-line-indent: 15pt, spacing: 1.6em, leading: 0.7em)
#set heading(numbering: "1.1.")
#set cite(style: "cse-citation-sequence-brackets-8th-edition")
#show heading.where(level: 1): it => {
  v(1.2em)
  text(size: 17pt, it)
  v(0.4em)
}
#show heading.where(level: 2): set text(size: 14pt)
#show heading.where(level: 3): set text(size: 12.5pt)
#show figure.caption: set text(size: 10.5pt)

// Portada
#align(center)[
  #stack(
    dir: ltr,
    spacing: 12pt,
    box(width: 1.35cm, image(logos.escudo)),
    align(left + horizon, text(size: 11pt)[
      UNIVERSIDAD DE CHILE \
      FACULTAD DE CIENCIAS FÍSICAS Y MATEMÁTICAS \
      DEPARTAMENTO DE CIENCIAS DE LA COMPUTACIÓN
    ]),
  )
  #v(1fr)
  #text(size: 24pt, weight: "bold")[Estado del arte]
  #v(0.8em)
  #text(size: 14pt)[#metadata.titulo]
  #v(1fr)
  #text(size: 12pt)[
    #metadata.autoria.nombre \
    #v(0.6em)
    Profesora guía: #metadata.profesores.at(0).nombre \
    Profesor co-guía: #metadata.coguias.at(0).nombre
  ]
  #v(1fr)
  #text(size: 12pt)[Santiago de Chile, #datetime.today().display("[year]")]
]
#pagebreak()

#set page(numbering: "i", number-align: center)
#counter(page).update(1)
#outline(title: [Índice], depth: 2, indent: auto)
#pagebreak()

#set page(numbering: "1")
#counter(page).update(1)
#include "capitulos/estado-del-arte.typ"

#pagebreak(weak: true)
#bibliography("references.bib", title: "Referencias", style: "ieee")
