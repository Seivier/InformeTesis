= Síntesis y posicionamiento de la tesis <sec:ea-sintesis>

Esta sección integra los hallazgos de la revisión, los ordena según las preguntas
de investigación de la tesis y delimita el espacio que ocupa la propuesta.

== Hallazgos según las preguntas de investigación

*Construcción de poliedros mediante cavidades.* La literatura muestra que unir
tetraedros en celdas mayores es viable y útil: la recombinación hexaédrica
@owen2000h @baudouin2014afrontalapproach, la aglomeración para métodos poliédricos
@sorgente2024mesh @antonietti2024polytopal @fu2024particle y la familia Polylla
@polylla @salinasfernandez2025exploring lo hacen con criterios distintos. Lo que
distingue a estos métodos es el alcance y la naturaleza de la decisión de unión:
patrones de topología fija ordenados por calidad, particiones globales guiadas por
un indicador, criterios locales ligados a la estabilidad temporal, como el paso de tiempo del agregado, o criterios locales geométricos, como la cara mayor en Polylla 3D.
Ninguno usa como regla de unión la posición de los circuncentros respecto de la
circunsfera de un tetraedro semilla; en los trabajos revisados, las circunsferas
aparecen solo de forma auxiliar, en la construcción de mallas duales
@garimella2013polyhedral o en el filtrado de elementos según su radio circunscrito
@fu2024particle. Respecto de la elección de semillas, el antecedente más cercano es
la prioridad por medida de los elementos en el refinamiento de Chen y Tan
@delaunay, y la selección codiciosa por calidad en la recombinación
@baudouin2014afrontalapproach.

*Estructura de datos.* Los generadores tetraédricos eficientes usan estructuras mínimas basadas en el tetraedro y en la adyacencia por cara, con punteros en TetGen y con arreglos indexados en HXT @tetgen @marot2018one, y GPU Polylla aplica una representación indexada análoga en dos dimensiones @gpolylla; la
elección concreta debe hacerse a partir de las consultas que realiza el algoritmo
@garimella2002mesh. No se encontró una estructura diseñada para representar a la vez
una tetraedralización y su partición en regiones poliédricas, ni una que unifique
algoritmos de una misma familia.

*Viabilidad y calidad.* Muchos análisis de los métodos poliédricos exigen que las celdas sean estrelladas, aunque algunos admiten uniones de subdominios estrellados, y la existencia y el tamaño del _kernel_ son la medida más directamente vinculada con esa exigencia @veiga2012basic @sorgente2022polyhedral.
La evidencia numérica indica que las hipótesis son más restrictivas de lo necesario,
pero buena parte de ella es bidimensional o de orden bajo
@sorgente2022polyhedral @cao2018anisotropicerrorestimates. Polylla 3D obtuvo una
reducción cercana al 70~% del número de celdas, pero con poliedros muy lejos de ser
convexos y sin evaluar su calidad ni su comportamiento numérico
@salinasfernandez2025exploring. Existe un algoritmo de cálculo del _kernel_ adecuado
para celdas pequeñas @sorgente2022polyhedron.

*Paralelización.* La construcción concurrente de cavidades es un problema estudiado,
con soluciones basadas en bloqueos @cpuparallel @nave2004guaranteed, particiones
@marot2018one @lo2012parallel, conjuntos independientes @spielman2002parallel
@ma2025cpaft y prioridades atómicas en GPU @delaunay. Las fases irregulares, como la
reparación o la recuperación de la frontera, suelen limitar la aceleración global
@gpolylla @marot2018one, y la reproducibilidad del resultado depende de cómo se
resuelven los conflictos @marot2018one @ma2025cpaft.

== Posicionamiento respecto de los enfoques existentes

La @tab:ea-posicionamiento compara la propuesta de esta tesis con los enfoques más
cercanos según las dimensiones que la revisión mostró relevantes.

#figure(
  {
    set text(size: 9pt)
    set par(justify: false, first-line-indent: 0pt)
    table(
      columns: (1.2fr, 0.85fr, 1.35fr, 1.1fr, 1.2fr),
      align: left,
      inset: 4pt,
      stroke: 0.5pt,
      table.header(
        [*Enfoque*], [*Alcance de la decisión*], [*Criterio de unión o construcción*], [*Garantía sobre la forma*], [*Validación reportada*],
      ),
      [Dual de tetraedralización @garimella2013polyhedral], [Global], [Dualidad con circuncentros, corregidos hacia el centroide cuando quedan fuera], [Prueba conservadora de estrellamiento y optimización], [Ejemplos, sin simulaciones],
      [VoroCrust @vorocrust], [Global], [Semillas de Voronoi], [Celdas convexas], [Geométrica, sin simulaciones],
      [Recombinación en hexaedros @baudouin2014afrontalapproach], [Local, codiciosa], [Patrones de hexaedros ordenados por calidad], [Topología fija], [Análisis modal y acústico],
      [Aglomeración para VEM @sorgente2024mesh], [Global], [Partición del grafo dual ponderada por calidad], [Ninguna; calidad como peso], [VEM],
      [Aglomeración con redes neuronales @antonietti2024polytopal], [Global], [Bisección aprendida del grafo], [Ninguna], [Galerkin discontinuo],
      [PVEM @fu2024particle], [Local, codiciosa], [Paso de tiempo del agregado], [Ninguna], [Flujos con superficie libre],
      [Polylla 3D por caras @salinasfernandez2025exploring], [Local], [Cara terminal según un criterio de unión], [Ninguna; repara poliedros no simples], [Estadísticas de unión; VEM pendiente],
      [Propuesta de esta tesis], [Local, por semillas ordenadas], [Circuncentro del vecino dentro de la circunsfera de la semilla], [Ninguna a priori; _kernel_ medido], [Calidad geométrica],
    )
  },
  caption: [Posicionamiento de la propuesta de esta tesis respecto de los enfoques
    de generación poliédrica más cercanos.],
) <tab:ea-posicionamiento>

La propuesta comparte con Polylla la estrategia indirecta, local y sin inserción de
puntos, y con la recombinación hexaédrica y PVEM la selección codiciosa a partir de
elementos priorizados. Se diferencia de todos ellos en que su criterio de unión se
deriva de la estructura de Delaunay de la malla de entrada. Se diferencia también de
los métodos de aglomeración en que no resuelve una partición global, lo que la hace más simple y potencialmente paralelizable; en su forma actual, sin embargo, su criterio de unión no incorpora un objetivo explícito de calidad.

== Interpretación geométrica del criterio de circunsferas

La revisión de la @sec:ea-delaunay permite dar al criterio una interpretación
geométrica, que es una lectura propia y no un resultado tomado de la literatura.
Para dos tetraedros de Delaunay adyacentes, el segmento que une sus circuncentros es
la arista de Voronoi dual a la cara que comparten @engwirda2017jigsawgeo1. Por lo
tanto, que el circuncentro de un vecino directo quede dentro de la circunsfera de la
semilla equivale a que esa arista de Voronoi sea más corta que el radio de la
circunsfera de la semilla. En el límite en que cinco o más vértices son cosféricos,
los circuncentros coinciden, la arista de Voronoi tiene longitud nula y los
tetraedros involucrados son una subdivisión arbitraria de una misma celda convexa
de Delaunay @shewchuk2008generaldimensionalconstrained. El criterio puede leerse,
entonces, como una relajación de la unión de tetraedros cosféricos: agrupa
tetraedros cuyas circunsferas están «cerca» de coincidir, en una escala dada por el
radio de la semilla (@fig:ea-region). Las aristas de Voronoi cortas son, además,
un defecto conocido de las mallas de Voronoi @vorocrust, de modo que el criterio
tiende a unir precisamente las configuraciones que producen elementos duales
degenerados. Para vecinos no directos, la comparación sigue haciéndose con la
circunsfera de la semilla, de modo que los circuncentros de todos los tetraedros de
una región quedan dentro de una misma bola, y no solo encadenados por aristas de
Voronoi cortas.

#figure(
  image("../../imagenes/estado-del-arte/region-circunsfera-semilla.svg", width: 62%),
  caption: [Análogo bidimensional de una región inducida por la circunsfera de un
    elemento semilla (elaboración propia). El triángulo semilla (azul oscuro) y su
    circunferencia circunscrita (segmentada) determinan qué vecinos se agregan:
    aquellos cuyo circuncentro (punto relleno) cae dentro de ella. Los
    circuncentros que quedan fuera se muestran vacíos. A diferencia de la
    cavidad del panel (b) de la @fig:ea-delaunay, la región no se define respecto
    de un punto que se inserta.],
) <fig:ea-region>

Esta interpretación también explica por qué el criterio no garantiza por sí mismo
el estrellamiento. La cavidad de Bowyer–Watson es estrellada respecto del punto
insertado porque está formada por los tetraedros cuyas circunsferas contienen ese
punto @tetgen; la región de esta tesis, en cambio, está formada por tetraedros
cuyos _circuncentros_ están dentro de una circunsfera dada, condición que no
involucra un punto común de visibilidad. La existencia del _kernel_ debe, por lo
tanto, medirse.

== Brechas y riesgos

La revisión delimita también los riesgos que el trabajo debe abordar.

- *Estrellamiento no garantizado.* Ningún método de aglomeración revisado garantiza
  celdas estrelladas; la calidad se mide a posteriori o se incorpora como peso
  @sorgente2024mesh @sorgente2023mesh @antonietti2024polytopal. La propuesta comparte
  esta limitación.
- *Circuncentros fuera del dominio.* Los tetraedros de frontera de una malla de
  Delaunay pueden tener su circuncentro fuera del dominio @garimella2013polyhedral, y
  varios métodos descartan esos elementos @guo2016tetrahedral, lo que afecta a
  cualquier criterio basado en circuncentros cerca de la frontera.
- *Inestabilidad numérica.* Los circuncentros son puntos construidos: si se redondean a punto flotante, los predicados exactos posteriores dejan de garantizar decisiones correctas respecto de los circuncentros exactos @diazzi2023constrained, y son
  inestables en los _slivers_, que son frecuentes en mallas de Delaunay
  @cheng2000sliver.
- *Restricciones del dominio.* La malla de entrada de un generador con restricciones
  solo es localmente de Delaunay @si2009constrained, y una región no debería
  atravesar las caras del PLC si se desea preservar las fronteras internas.
- *Dependencia del orden.* La competencia de varias semillas por los mismos
  tetraedros hace que el resultado dependa del orden de procesamiento, del mismo
  modo que la reproducibilidad del generador paralelo de HXT depende del número de
  hilos @marot2018one; una versión paralela debe definir qué resultado considera
  correcto @ma2025cpaft.
- *Caras no planas y caras pequeñas.* Las caras de una celda formada por tetraedros
  son uniones de triángulos que pueden no ser coplanares, y muchas hipótesis suponen
  caras planas y un número acotado de ellas @certk2018thevirtualelement
  @sorgente2022polyhedral, aunque algunos análisis admiten caras coplanares consecutivas @cangiani2017aposteriorierror o muchas caras pequeñas, representando las interfaces mediante triángulos coplanares @antonietti2014multigridalgorithmsfor.

== Conclusión

El estado del arte muestra que la generación indirecta de mallas poliédricas por
unión de tetraedros es una línea activa, motivada por métodos numéricos que admiten celdas generales, aunque sus análisis suelen exigir que sean estrelladas. Los
métodos existentes deciden las uniones mediante patrones, particiones globales o
criterios locales que no controlan la forma de las celdas. La geometría de Delaunay
ofrece un criterio local con significado propio, basado en la proximidad de las
circunsferas, que no ha sido explorado como regla de unión en el corpus revisado.
Esta tesis propone y evalúa ese criterio, mide la calidad de las celdas resultantes
mediante su _kernel_, diseña una estructura de datos común a la familia Polylla y
analiza su paralelización a la luz de las técnicas de construcción concurrente de
cavidades. La ausencia de un método equivalente es una conclusión limitada al corpus
revisado y no una prueba de novedad absoluta.
