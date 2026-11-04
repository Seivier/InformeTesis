#import "pendiente.typ": pendiente

= Síntesis y alcance de la contribución <sec:co-sintesis>

El trabajo documenta una construcción secuencial por cavidades: ordena candidatos
por radio de circunsfera y agrupa vecinos por cara según la posición de sus
circuncentros respecto de la semilla. Se distingue de las regiones terminales
(@sec:ta-polylla-3d) y de las cavidades de inserción (@sec:ea-delaunay).

La reparación está inactiva y la integración de Face y Edge permanece pendiente.
El diseño paralelo de @sec:ac-paralelo requiere implementación y validación.
El protocolo de @sec:ex-alcance propone verificar partición, calidad y recursos.
La hipótesis permanece por contrastar mediante la evaluación propuesta.

= Respuestas a las preguntas de investigación <sec:co-preguntas>

*Pregunta 1: construcción, semillas y refinamiento.* El procedimiento está
especificado. Bajo conectividad válida y geometría definida, el control de
propiedad permite deducir cobertura y exclusividad de índices; el recorrido por
vecinos, conectividad por caras (@sec:ac-algoritmo). Estas propiedades no prueban
simplicidad de frontera ni kernel no vacío. Se usa radio creciente sin desempate
por índice; no se ha probado su superioridad. El refinamiento permanece abierto,
pues la reparación provisional no está activa.

#pendiente[Respuesta experimental a la pregunta 1: validar los invariantes en
  entradas inspeccionables; comparar órdenes de semillas con desempate fijado y
  medir celdas aisladas, reducción y kernel. Si se requiere reparación, completar
  la reconstrucción de fronteras antes de compararla con la salida original.]

*Pregunta 2: representación y unificación.* Los vectores indexados y las listas
por poliedro expresan la topología y conservan los tetraedros constituyentes;
no demuestran eficiencia frente a otras estructuras. La interfaz común existe,
pero faltan adaptadores Face y Edge. Reducir celdas no implica reducir
proporcionalmente el almacenamiento, pues se conserva la subdivisión tetraédrica.

#pendiente[Respuesta cuantitativa a la pregunta 2: completar adaptadores y fijar
  su contrato; instrumentar memoria de entrada, salida y auxiliares y comparar
  con una representación aplanada, incluyendo construcción y copias. Completar
  la tabla de recursos de @sec:ex-tablas antes de concluir eficiencia.]

*Pregunta 3: viabilidad, kernel, reducción y límites.* No existen mediciones
propias que permitan asignar porcentajes o tamaños máximos procesables.
Los cálculos y exportaciones requieren las validaciones de @sec:ac-metricas.
El inventario de @sec:ex-datos identifica entradas disponibles, no casos
procesados con éxito. La viabilidad para VEM requiere evaluar el método numérico,
sin inferirla de la disponibilidad de estadísticas.

#pendiente[Respuesta a la pregunta 3: completar calidad y recursos por entrada y
  baseline, registrar fallos y ampliar familias de tamaño controlado. Para
  sostener aplicabilidad numérica, elegir un problema con solución de referencia
  y comparar error, convergencia y costo del sistema bajo condiciones comunes.]

*Pregunta 4: paralelización.* La separación de cálculos locales sugiere tareas
independientes para circunsferas y una salida aplanada construida por conteos y
desplazamientos. Sin embargo, el crecimiento puede competir por un mismo
tetraedro, por lo que no basta con ejecutar simultáneamente el recorrido actual.
La propuesta por rondas identifica ese conflicto y plantea resolver prioridades,
pero no establece todavía equivalencia con el orden secuencial, terminación o
aceleración. La respuesta disponible es un diseño por estudiar, no una versión
paralela comprobada.

#pendiente[Respuesta a la pregunta 4: acordar equivalencia exacta o invariantes
  de una partición alternativa; formalizar progreso y arbitraje, implementar
  casos con competencia y validar reproducibilidad al variar hilos. Después
  completar @tab:ex-paralelo con costos de sincronización y transferencias.]

= Trabajo futuro y balance de la hipótesis <sec:co-futuro>

Se propone validar primero entradas, orientación, tolerancias y métricas; luego
corregir exportaciones, integrar comparadores y ejecutar el protocolo. El paralelismo requiere un contrato de corrección. La contribución actual es
el método secuencial documentado; sus ventajas empíricas siguen pendientes.
Si no se confirma la hipótesis, se informarán los límites observados.
