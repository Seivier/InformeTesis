// Marca contenido pendiente. Se oculta poniendo `mostrar-pendientes` en false.
#let mostrar-pendientes = true

#let pendiente(body) = if mostrar-pendientes {
  block(
    width: 100%,
    inset: 8pt,
    stroke: (left: 2pt + red),
    fill: red.lighten(92%),
    text(fill: red.darken(20%), size: 0.92em)[*Pendiente.* #body],
  )
} else []
