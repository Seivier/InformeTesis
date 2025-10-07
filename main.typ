#import "final.typ": agradecimientos, apendice, capitulo, conf, dedicatoria, end-doc, resumen, start-doc
#import "my-metadata.typ": metadata

#let mostrar-comentarios = true

#let comentario(body) = if mostrar-comentarios {
  text(body, fill: red)
} else []


#show: conf.with(metadata: metadata)

#resumen(metadata: metadata)[
]

// #dedicatoria[
// ]

// #agradecimientos[
// ]

#show: start-doc

#capitulo(title: "Introducción")[
  #lorem(100)

  #lorem(100)

  #lorem(100)
  #comentario[Hola]
]

#capitulo(title: "Segundo")[
  #lorem(100)

  #lorem(50)

  #figure(
    table(
      columns: 3,
      "Campo 1", "Campo 2", "Num",
      "Valor 1a", "Valor 2a", "3",
      "Valor 1b", "Valor 2b", "3",
    ),
    caption: "Tabla 1",
  )

  #figure(
    table(
      columns: 3,
      "Campo 1", "Campo 2", "Num",
      "Valor 1a", "Valor 2a", "3",
      "Valor 1b", "Valor 2b", "3",
    ),
    caption: "Tabla 2",
  )

  #lorem(100)
]

#capitulo(title: "Tercero")[
  #lorem(100)

  #lorem(50) @CorlessJK97 @Turing38

  #figure(
    image("imagenes/institucion/fcfm.svg", width: 20%),
    caption: "Logo de la facultad",
  )

  #lorem(100)
  @NewmanT42
]

#capitulo(title: "Conclusión")[
  #lorem(100)

  #lorem(100)

  #lorem(100)
]

#show: end-doc

#apendice(title: "Anexo")[
  #lorem(100)

  #lorem(100)

  #lorem(100)
]
