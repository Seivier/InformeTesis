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
  La generación de mallas es un área que ha estado en el foco de atención
  constantemente desde el asentamiento de la computación como disciplina. Tanto a
  nivel académico como industrial, el discretizar un espacio, 2D o 3D, en
  primitivas de manera automática es clave para poder efectuar simulaciones
  avanzadas.  Bajo el contexto de poliedros, comúnmente se reconocen 2 formas de generar estas mallas:
  de manera directa, la cual toma información espacial directa,
  como una nube de puntos o un dominio geométrico, y genera la estructura datos;
  y la manera indirecta, que toma una malla de
  tetraedros previamente construida y le aplica una serie de transformaciones para
  generar una malla de poliedros manteniendo su características en rasgos generales. El
  presente trabajo se centrará en esta última forma.

  // Para aplicar simulaciones de ecuaciones diferenciales parciales sobre cuerpos,
  // comúnmente se hace uso de triángulos o tetraedros como primitivas debido a su
  // simpleza y las propiedades que contienen. Métodos como el Método de Elementos
  // Finitos (FEM) hacen uso de estas primitivas para sus aproximaciones. Sin
  // embargo, existen formas más modernos como el Método de Elementos Virtuales (VEM)
  // que no requiere ni de polígonos o poliedros convexos para su aproximación.

  // Debido a esto, el desarrollo de algoritmos para crear mallas de poliedros se ha
  // vuelto más popular en el último tiempo. Las mallas de hexaedros, por ejemplo,
  // modelan mucho mejor los fenómenos físicos que las de tetraedros. Esto debido a
  // que la eficiencia de FEM depende exclusivamente en la cantidad de primitivas que
  // tenga la malla, por lo que mallas con menos primitivas permiten que las
  // simulaciones sean más veloces.

  // Una de las más primitivas más común en tres dimensiones es el tetraedro, por su
  // simplicidad y propiedades únicas, pero en las últimas décadas se ha visto
  // interés por el uso de hexaedros y poliedros en general, debido a que estas
  // permiten cubrir el mismo cuerpo o espacio haciendo uso de menos células.


  Actualmente, existe un algoritmo en dos dimensiones capaz de generar una malla
  de polígonos a partir de una malla de triángulos conocido como POLYLLA @polylla.
  Tomando este como inspiración se desarrollo una versión tridimensional, donde posteriormente
  se realizó un estudio en profundidad de la viabilidad y calidad de dichas mallas.

  // Este consiste en ir uniendo los triángulos por su arista más larga, esta
  // transformación lleva a la creación de 'regiones' las cuales se corresponden a la
  // unión de los _longest-edge propagation path_ @rivara que terminan en el mismo lugar.
  // Son estas regiones las que finalmente se transforman en los polígonos.
  // La ventaja
  // principal de este proceso es que es más eficiente y robusto que sus
  // competidores.// los
  // cuales se basan principalmente en trabajar con restricciones en una malla de Delaunay.
  // En particular, el generador de mallas Polylla se basa en 3 pasos:
  // etiquetar las aristas de interés, crear los polígonos y
  // luego reparar los polígonos no simples. Gracias a que
  // en cada uno de estos pasos existen problemas con independencia en los datos, o _data-parallel_,
  // es que se desarrolló una versión en GPU llamada GPolylla @gpolylla. En
  // particular para este contexto, son las operaciones sobre los vértices, arcos y
  // polígonos las que se puede modelar de manera _data-parallel_.
  // son las 'regiones' antes mencionadas cumplen con
  // los requisitos de que ninguna se superpone, por lo que se pueden construir en
  // paralelo de manera independiente.

  // Sumado a lo anterior, Polylla ha sido adaptado a GPU @gpolylla, un algoritmo
  // basado en 3 pasos: etiquetar las aristas de interés, crear los polígonos y luego
  // reparar los polígonos irregulares. Esto es posible debido a que versión original
  // es un problema de tipo _data-parallel_, también conocido como
  // 'problema con independencia de datos', en particular estas 'regiones'
  // mencionadas cumple con los requisitos de que ninguna se superpone, por lo que se
  // pueden construir en paralelo sin ningún inconveniente mayor.

  // La principal ventaja que tiene Polylla/* (y 3D Polylla) */ por sobre el resto de
  // algoritmos yace en su enfoque en formas arbitraria, es decir, que las mallas
  // generadas pueden incluir tanto polígonos convexos como no convexos y, por lo tanto,
  // requiere menos polígonos para representar un dominio que una malla de triángulos.
  // Lo que le
  // permite construir mallas de manera más eficiente.
  // El implementar una versión paralela inspirada en Polylla en tres dimensiones
  // permitiría una mayor
  // escalabilidad del problema. En particular, un algoritmo
  // adaptado a un modelo paralelo,
  // donde cada procesos o _threads_ trabaja concurrentemente sobre una primitiva,
  // permitiría manejar mallas con millones de vértices más rápido que la versión secuencial.
  // en cuestión de segundos, además de obtener una mejora significativa en
  // la rapidez del algoritmo.
  // Todo esto gracias a que, al igual que su versión
  // bidimensional, es un problema _data-parallel_, ya que la construcción de
  // poliedros se puede separar de por 'terminal-face regions' de manera que la
  // manipulación de estas no afecten a las otras, consiguiendo así la independencia
  // de datos.// #figure(
  //   grid(
  //     columns: 3, column-gutter: 3em, row-gutter: 1em, image("imagenes/pikachu PLSG.png", width: 5cm), image("imagenes/pikachutriangulization.png", width: 5cm), image("imagenes/pikachuPolylla.png", width: 5cm), "(a) orignal", "(b) malla de triángulos", "(c) malla de polígonos",
  //   ), caption: [Proceso del algoritmo de Polylla],
  // )<pikachu>


  == Problema
  // A nivel tridimensional, existe un algoritmo capaz de generar mallas de
  // poliedros, debido a que este es un problema _data-parallel_, una versión
  // utilizando de arquitectura altamente paralela en GPU es deseable para obtener
  // resultados eficientes a la hora de trabajar con mallas con mucha cantidad de
  // vértices. Sin embargo, se carece de dicha implementación, la cual debería ser
  // capaz de mitigar el sobre-costo por sincronización entre CPU y GPU, así como
  // mejorar el uso de memoria.

  // Existe un algoritmo secuencial capaz de generar mallas de poliedros, a través de
  // su diseño se encontró que este algoritmo posee patrones los cuales lo hacen un
  // problema independiente en los datos. Un algoritmo basado en una arquitectura
  // altamente paralela (GPU) permitirá una mejor escalabilidad, para así obtener
  // resultados eficientes a la hora de trabajar con mallas con una cantidad enorme
  // de puntos. Por lo tanto, una versión en GPU eficiente es deseable y debe ser
  // capaz de mitigar el sobre-costo por sincronización con la CPU, así como mejorar
  // el uso de memoria, y mantener la correctitud del método VEM 3D a la hora de
  // aplicarlo con mallas de poliedros no convexos.
  //
  Debido al creciente interés y consolidación de nuevos métodos numéricos, como el
  método de elementos virtuales #comentario[Habria que poner cita aca??] (_VEM_ por sus siglas en inglés),
  se necesita disponer un algoritmo que sea escalable con respecto a la cantidad
  de células (tetraedros) mientras contenga propiedades deseables para que dicho método
  funcione correctamente. No obstante, el estudio realizado sobre POYLLA 3D dio
  resultados poco satisfactorios en este ámbito, donde se concluyó que uno de los algoritmos,
  POLYLLA 3D Face, era capaz de obtener buenos resultados, pero que la ausencia de _kernel_ en ciertos
  poliedros podría afectar su usabilidad para VEM @pol3d.  Con esto en mente se propone una nueva forma de
  crear poliedros, alejada de la tradicional forma de unir triángulos por sus arista de POLYLLA 2D: usando cavidades.
  Dichas cavidades se corresponden a la esfera inscrita de cada tetraedro, es decir,
  a la esfera en cuya superficie se encuentran todos los vertices del tetraedro.


  == Hipótesis
  Es posible implementar un algoritmo que genera mallas de
  poliedros a partir de una malla de tetraedros utilizando las cavidades de dichos tetraedros,
  seleccionando unos como semilla para formar el poliedro. Tal algoritmo resultaría más eficiente y robusto que otros implementados en la familia Polylla, produciendo mallas de calidad según los criterios de los métodos numéricos.
  == Preguntas de investigación
  #enum(numbering: (..nums) => text(weight: "bold", "Pregunta " + numbering("1", ..nums)))[
    ¿Es posible crear poliedros a partir de un algoritmo de generación de
    poliedros basado en cavidades? ¿Cómo se debería escoger las semillas para formar los poliedros? ¿Qué pasos de refinamiento se deberían realizar con la malla creada?
  ][
    ¿Que estructura de datos puede proveer un uso eficiente de memoria y tiempo de
    ejecución permitiendo manejar la topología de la malla? ¿Es posible crear una estructura que permita unir todos los algoritmos dentro de la familia Polylla?
  ][
    ¿El algoritmo final es una solución viable para problemas con mallas típicas?
    ¿Qué porcentaje de poliedros de la malla final poseen un _kernel_? ¿Se obtiene una reducción sustancial de primitivas?  ¿Cuáles son límites que el algoritmo tiene en términos de tamaño de la malla y cantidad de vértices?
  ][
    ¿Es posible paralelizar el algoritmo? ¿Existe una forma directa de hacerlo? ¿Cómo luciría una posible versión paralela?
  ]





  == Objetivos
  El objetivo general de esta investigación es la de diseñar, implementar y analizar un nuevo
  algoritmo de creación de malla de poliedro de forma indirecta, inspirado en el
  uso de cavidades de los tetraedros.

  // == Objetivos específicos
  #enum(numbering: (..nums) => text(weight: "bold", "Objetivo " + numbering("1", ..nums)))[
    Diseñar e implementar una nuevo algoritmo basado en
    las cavidades de tetraedros semillas.][
    Crear o seleccionar una estructura de datos que
    sea consistente con un modelo de programación en paralelo.
  ][
    Analizar el desempeño del algoritmo basándose en métricas que permitan evaluar
    el sobrecosto en memoria y la eficiencia en tiempo de ejecución de un algoritmo
    paralelo tomando en cuenta su versión secuencial.
  ][
    Estudiar y comparar la calidad de los poliedros contenidos en las mallas generadas con respecto a las versiones actuales de Polylla 3D.
  ][
    Investigar y diseñar una posible versión paralela del algoritmo propuesto.
  ]

  == Estructura de la Tesis
  En el capítulo 2 abordaremos el estado del arte, pasando por otros algoritmos de generación de mallas de poliedros, estructura de datos y terminaremos hablando de una investigación que sirvió de inspiración para el algoritmo desarrollado. En consecuencia, en el capítulo 3 analizaremos en detalle el estado actual de la familia de algoritmos POLYLLA, reconociendo sus fundamentos e analizando la calidad de las mallas generadas.
  En el capítulo 4 postularemos el algoritmo de cavidades en detalle para finalmente en el capítulo 5 mostrar los resultados de los experimentos y luego concluir en el capítulo 6.
]

#capitulo(title: "Estado del arte")[
  #comentario[
    Pauta:
    - Tetgen
    - Tetwild
    - Vorocrust
    - Tetgen GPU (cavidades)
  ]

  En la actualidad las mallas de tetraedros son objeto de estudio de múltiple disciplinas, por su utilidad en gráficos, simulaciones, modelamiento, entre otros.
  Por otro lado, las mallas de poliedros se han mantenido como algo puramente académico hasta recientemente, con la ayuda de los nuevos métodos numéricos para
  simulaciones físicas. Estos dos tipos han estado intrínsecamente ligados, por lo tanto, es imperativo conocer, para esta investigación, los algoritmos más relevantes
  para generar dichas mallas.

  == Generación de mallas de tetraedros
  // En #comentario[(fecha)] Hang Si publicó su paper "..." el cual
  // == Generación de mallas de tetraedros secuencial
  #cite(<tetgen>, form: "prose") planteó un algoritmo secuencial robusto y
  eficiente que ha servido como base para la generación de tetraedros durante la
  última década. Su trabajo contiene una sólida justificación teórica e incluye
  buenas heurísticas prácticas. El algoritmo toma como entrada un _Piecewise Linear Complex_
  o PLC (@fig:tetgen) para entregar una
  malla de tetraedros llamada tetraedralización de Delaunay limitada o CDT
  (_Constrained Delaunay Tetrahedralization_), la cual consiste en una
  tetraedralización en la que no se exige que se cumpla la condición de Delaunay
  sobre las primitivas que se encuentran en el borde.
  // La mayoría opta por este tipo
  // de solución ya que no esta garantizada la partición de todo dominio 3D en
  // un conjunto de tetraedros.
  El proceso completo consta de 3
  etapas: Primero construye la tetraedralización de Delaunay del espacio convexo que cubre
  el PLC, luego, a partir de esto, crea un CDT en base a los límites o bordes del PLC, y,
  finalmente, se mejora la calidad de la malla en base a criterios definidos por
  el usuario.

  #figure(
    image("imagenes/Piecewise Linear.gif", width: 40%),
    caption: [Un PLC es el conjunto de vertices, segmentos y caras que definen la geometría del dominio, extraído de @tetgen (Figura 1a)],
  )<fig:tetgen>

  En detalle, la tetraedralización del espacio se realiza mediante dos algoritmos:
  el de Bowyer-Watson @tetgen:watson@tetgen:bowyer y el _randomized flip_ @tetgen:flip, para
  implementarlos de manera eficiente el autor ordena espacialmente los vértices
  del _input_. Al momento de construir CDT se puede optar por conservar la
  superficie del PLC o no, esto se traduce a si el algoritmo tiene permitido o no
  crear nuevos puntos para alterar la superficie de la malla, en caso de poder hacerlo,
  la creación de una buena CDT esta garantizada.
  // ya que es posible eliminar las _sharp features_ de la malla.
  // En caso de querer mantener la superficie el algoritmo crea la CDT de
  // todas formas, pero mediante la operación de _edge removal_, se busca recuperar
  // los _constraints_ o límites de la malla original.
  Para el paso final el algoritmo usa
  _Delaunay refinement_ para conseguir los criterios de calidad dados por el
  usuario. Los resultados de su investigación culminan en la herramienta TetGen escrita en
  C++ y disponible gratis en #link("http://ww.tetgen.org").

  // CGAL
  Dentro de la _Computational Geometry Algorithms Library_ @cgal, se encuentra
  un algoritmo desarrollado por #cite(<cgal:mesh>, form: "prose") basado
  principalmente en el trabajo de Chew @cgal:chew y Ruppert @cgal:ruppert.
  Su solución esta adaptada para trabajar coherentemente con toda la librería,
  lo cual lo hace una de las más completas, capaz de generar
  mallas de tetraedros a partir de un _3D Complex_ el cual consiste en un conjunto
  de _caras_ con dimensiones 0, 1, 2 y 3 de forma que todas las caras son
  interiores disjuntos por pares y el límite de cada cara del _complex_ es la
  unión de caras de dimensiones inferiores del complejo. Es un concepto similar
  al de un PLC donde las dimensiones 0, 1, 2 y 3 son las esquinas, curvas,
  parches de superficie y sub-dominios, respectivamente.

  En líneas generales este algoritmo consiste en un refinamiento de Delaunay
  iterativo, donde inicialmente se lleva una fase de protección, donde
  se protegen características de 0 y 1 dimensiones mediante inserciones iniciales
  y el uso de bolas. Luego del refinamiento, se pasa por una fase de optimización
  donde se eliminan los _slivers_ que corresponden a tetraedros con ángulos
  muy pequeños y muy grandes, pero que tienen un buen _radius edge ratio_ lo que
  hace que el refinamiento no los elimine.

  // realiza una triangulación de Delaunay con pesos, para
  // después hacer un refinamiento iterativo, donde se protegen las características 0
  // y 1 dimensionales. Adicionalmente, se puede optimizar la malla en base a la
  // cantidad de tetraedros y sus ángulos interiores, usando métodos como ODT o
  // LLoyd. #comment[Añadir cita?]

  // CGAL

  Por último, #cite(<tetwild>, form: "prose") también desarrollaron un
  algoritmo para construir una malla de tetraedros a partir de un PLC. No
  obstante, su trabajo se basa en 3 puntos claves: no se presume nada de la forma
  de la malla de entrada, lo único que se asume es que fundamentalmente siempre
  contiene errores, por lo que el algoritmo es capaz de alterar su
  superficie dentro de un $epsilon$ especificado; la robustez del algoritmo viene
  primero que todo; y el algoritmo es conservador donde considera la totalidad de
  la malla de entrada, incluyendo su superficie y conectividad interna.
  El algoritmo funciona de la siguiente manera: Primero se parte hace una
  tetraedralización de Delaunay considerando solo los vértices de la malla, luego
  se construye un árbol de tipo _Binary Spatial Partition_ donde las hojas se
  corresponde a los triángulos que conforman la superficie del PLC. Con esto el
  algoritmo trata de mejorar la calidad de la malla teniendo en cuenta la
  superficie original, haciendo una serie de operaciones locales como _edge collapsing_, _edge splitting_, _face swapping_ y _vertex smoothing_.
  Finalmente, el algoritmo usa la información del BSP para extraer los tetraedros
  que se encuentran en el interior de la malla y así obtener el resultado final.
  La robustez se garantiza mediante al uso de una representación exacta de números
  racionales para los valores, asegurándose de trabajar solo con operaciones que
  sean cerradas respecto a los racionales. Sumado a esto también existen
  invariantes que respeta el algoritmo y que el usuario puede ajustar previo a la
  construcción de la malla. El trabajo de Y. Hu esta disponible en #link("https://github.com/Yixin-Hu/TetWild") mediante
  el nombre de TetWild.

  #figure(
    image("imagenes/Tet.png", width: 80%),
    caption: [Comparación entre las mallas generados por CGAL con la de TetWild (ours), extraído de @tetwild (Figura 16)],
  )<fig:tetwild>
  // #cite(<cgal:mesh>, form: "prose") desarrollaron un algoritmo capaz de generar
  // mallas de tetraedros a partir de un _3D Complex_ el cual consiste en un conjunto
  // de _caras_ con dimensiones 0, 1, 2 y 3 de forma que todas las caras son
  // interiores disjuntos por pares y el límite de cada cara del _complex_ es la
  // unión de caras de dimensiones inferiores del complejo. Dicho de otro modo, las
  // dimensiones 0, 1, 2 y 3 son las esquinas, curvas, parches de superficie y
  // subdominios, respectivamente. A partir de esta información se genera una malla
  // de poliedros la cual puede ser escrita en formatos como Medit, VTK, Avizo y
  // Tetgen, todos los cuales son un estándar dentro de CGAL.
  //
  // Inicialmente el algoritmo realiza una triangulación de Delaunay con pesos, para
  // después hacer un refinamiento iterativo, donde se protegen las características 0
  // y 1 dimensionales. Adicionalmente, se puede optimizar la malla en base a la
  // cantidad de tetraedros y sus ángulos interiores, usando métodos como ODT o
  // LLoyd.
  //
  // #figure(
  //   image("imagenes/mesh.jpg", width: 55%), caption: [Malla 3D generada a partir de una imagen segmentada],
  // )<fig:cgal>

  // == Generación de mallas de tetraedros en paralelo
  #cite(<delaunay>, form: "prose") desarrollaron un algoritmo en GPU
  basado en @tetgen. En su trabajo se detallan las consideraciones a la hora de
  trabajar con una arquitectura _data-parallel_. En particular, el desafío se
  encuentra al momento de insertar puntos en la malla cuando se debe construir la
  CDT. Esto debido a que en 3D no existe forma de recuperar el estado antiguo de
  una malla mediante un _edge flipping_#footnote[Consiste en cuando un par de triángulos
    $a b c$ y $c d a$ comparten una arista $a c$ la cual se "voltea" (_flip_) para generar
    los triángulos $a b d$ y $b c d$ compartiendo ahora $b d$] como si se puede hacer en 2D.

  La solución a esto consiste en usar los conceptos de puntos _Delaunay_ independientes
  y regiones de _Delaunay_. La primera hace referencia a puntos que se encuentran
  en la misma arista, dichos puntos no pueden ser insertados a la vez de manera
  concurrente ya que puede provocar que el algoritmo nunca termine. El segundo
  hace referencia al conjunto de tetraedros cuya bola circunscrita _cubra_ un punto $p$ dado
  y cuyos puntos interiores son visibles para $p$. Con esto, la inserción de
  puntos cuyas regiones de _Delaunay_ sean disjuntas se puede hacer en paralelo.

  Para calcular estas regiones, se construyen cavidades, las cuales consisten
  en potenciales regiones de _Delaunay_. Se parte inicialmente del punto a
  insertar y su tetraedro y luego se hace crecer esa cavidad añadiendo los
  tetraedros vecinos que cumplan con la primera condición de la región de _Delaunay_.
  Luego se encoge la cavidad para cumplir con la condición de visibilidad dentro de
  la región. Una vez calculada la región se realiza la inserción en paralelo.

  // AQUI VA EL OTRO ALGORITMO EN CPU
  Por otro lado, #cite(<cpuparallel>, form: "prose") desarrollaron un algoritmo paralelo
  basado en un modelo de memoria compartida en CPU. En su trabajo se detallan, además, diversas
  formas de afrontar el problema de construir una triangulación de Delaunay a partir
  de una distribución uniforme, donde clasificaron las soluciones
  en dos tipos: _incremental insert_ e _incremental construction_. La primera se basa en
  partir de una cerradura convexa e ir insertando los puntos interiores a la malla, arreglando los
  triángulos para cumplir con la condición de Delaunay mediante _edge flipping_. La
  segunda consiste en partir de una celda única e ir añadiendo puntos adyacentes a
  la malla.

  Para modelos paralelos, la mayor dificultad para la primera solución es la inserción, la cual
  debe considerar posibles escrituras sobre la misma celda y correcciones que estas conllevan,
  requiriendo necesariamente de herramientas de sincronización. Para el segundo tipo
  se encontró que al implementar la solución con un modelo de estilo _divide and
  conquer_, a la hora de hacer el _merge_ este era considerablemente complejo y costoso,
  por lo que no existía un buen _speed-up_.

  Por lo tanto, la solución propuesta por los autores fue un algoritmo llamado _randomized
  incremental insertion_, como su nombre indica, esta basado en el primer esquema. Es un
  algoritmo bastante flexible pensado para trabajar con 2-4 procesos en paralelo. Se
  basa en 3 etapas: '_location_ donde una celda en espera a ser dividida se debe
  encontrar rápidamente, seguido de la _subdivision_ y la _legalization_ donde
  se aplica el criterio de la circunferencia y, si es necesario, la localidad
  de la triangulación es modificada' @cpuparallel. Para conseguir esto, el algoritmo
  trabaja con una grafo acíclico dirigido donde va guardando el historial
  de cambios de la triangulación.

  La solución asume que los posibles _deadlocks_ dados por la sincronización entre
  procesos son poco probable dado la gran diferencia de escala entre la cantidad
  de procesos (2-4) versus la cantidad de vértices (+1000). Cabe destacar que
  los costos de sincronización y uso operaciones atómicas son
  bastante más grandes en arquitecturas modernas, las cuales cuentan con una mayor cantidad de procesos.

  // Esto lo hace una
  // inviable para este trabajo ya que es la si bien la escala de procesos sigue sin
  // ser igual a la de vértices, los costos dados por la sincronización y operaciones
  // atómicas son bastante más grande en GPU que en CPU.

  Sin embargo, el autor destaca en su investigación el algoritmo presentado por @paragon
  como 'útil para paralelización masiva' @cpuparallel. El algoritmo de #cite(<paragon>, form: "prose") procede de la siguiente manera: primero toma asigna a cada _thread_ un punto o más a ser
  procesado, luego para cada punto se computa su punto más cercano, para asi formar una arista.
  Luego de esto, secuencialmente un _thread_ descarta las aristas repetidas y asigna cada
  arista única a un _thread_. En paralelo se buscan los dos puntos más cercano a la arista y
  se construyen 2 triángulos. El proceso continua de esta forma hasta que no queden puntos por
  procesar.

  // Se debe encontrar rápidamente la ubicación donde se subdividirá un simplex, seguido de la subdivisión y la legalización donde se aplica el criterio de la circunferencia y, si es necesario, se modifica la parte local de la triangulación.

  == Generación de mallas de poliedros
  En cuanto a mallas más generales, #cite(<vorocrust>, form: "prose")
  crearon un algoritmo demostrablemente correcto capaz de generar mallas de poliedros
  de manera consistente.
  Basado en los mismos conceptos de la tetraedralización de Delaunay,
  pero ahora en base a su contra parte que es el diagrama de Voronoi bajo el nombre
  de VoroCrust.
  Gracias a esto es capaz de generar mallas de poliedros para dominios generales
  (convexo, cóncavo y no simples).
  Funciona generando una malla implícita _dual_ dada por un conjunto de semillas
  de Voronoi y la tetraedralización. En particular, el algoritmo
  parte generando un conjunto de bolas que describen el borde de la malla o dominio,
  con las cuales se crean pares de semillas que delimitan el interior y exterior
  de la malla final. Este malla de la superficie es luego refinada para capturar
  las _sharp features_ de la malla original y entregar una superficie de calidad.
  Finalmente, se crean bolas para el interior de la malla, partiendo de semillas
  de Voronoi generadas aleatoriamente.
  // #comment[No me quedó muy claro que es lo que tengo que corregir en esta
  // parte (VoroCrust)]


  // Como se ha descrito hasta el momento, todas las soluciones actuales depende de una
  // tetraedralización de Delaunay como punto de partida, para luego aplicar
  // transformaciones o refinamientos sobre esta.
  // === Polylla
  Recientemente fue publicado el algoritmo conocido como Polylla @polylla,
  el cuál es capaz de generar mallas de polígonos de forma arbitraria.
  Este algoritmo toma como entrada una malla de triángulos y
  luego va uniendo estas primitivas para formar polígonos arbitrarios, pudiendo
  ser convexo como no convexos. La unión se hace a través de las aristas más
  largas de cada triángulo. Actualmente existe una versión paralelizada en GPU de
  este algoritmo @gpolylla. Para construir los polígonos, Polylla usa el concepto de
  // clasifica las
  // aristas de la malla de la siguiente manera:
  //
  // Dado dos triángulos $t_1$ y $t_2$ que comparten una arista $e$, se puede
  // clasificar $e$ como:
  //
  // - _Terminal-edge_: Si $e$ es la arista más larga de tanto $t_1$ como $t_2$.
  // - _Frontier-edge_: Si $e$ no es la arista más larga ni de $t_1$ ni de $t_2$.
  // - _Internal-edge_: Si $e$ es la arista más larga de $t_1$ pero no de $t_2$, o al
  //   revés.
  // - _Boundary-edge_: Si $e$ sólo pertenece a un triángulo.
  //
  // Con esto definimos el
  _Longest-edge propagation path_ (Lepp) @rivara (
  lista ordenadas de triángulos $t_0, t_1, ..., t_n$, tales que
  $t_i$ es vecino de $t_(i-1)$ por la arista más larga de $t_(i-1)$,
  para todo $i = 1, 2, ..., n$), y la de _Terminal-edge region_ @polylla como
  la region $R$ formada por la union
  de todos los triángulos $t_i$ cuyos Lepp tengan el mismo _terminal-edge_
  (consiste en la arista compartida entre 2 triángulos que a la vez es la más
  larga de ambos). Polylla va
  generando polígonos (@fig:pol) a partir de estas regiones de
  manera antihoraria. Esto suele producir polígonos degenerados que deben ser
  revisados una vez generada la malla.

  #figure(
    grid(
      columns: 3,
      column-gutter: 3em,
      row-gutter: 1em,
      image("imagenes/pol1.png", width: 5cm),
      image("imagenes/pol2.png", width: 5cm),
      image("imagenes/pol3.png", width: 5cm),

      "(a)", "(b)", "(c)",
    ),
    caption: [Creación de una _Terminal-edge region_],
  )<fig:pol>

  2D Polylla convierte _Terminal-edge regions_ en polígonos, este proceso hace uso
  de las _terminal-edge_ que pueden definirse tanto en 2D como en 3D @rivara, con esto se
  puede desarrollar un generador de mallas de poliedros. Adicionalmente, con esta
  nueva dimensión, podemos extender el concepto de _terminal-edge_ a las caras de
  los tetraedros, creando así las _Terminal-face region_, y luego estas regiones
  transformarlas en poliedros @pol3d. Por lo tanto, dada una malla de tetraedros $tau = (V, E, F)$ y
  un criterio de unión $J$, podemos diseñar este algoritmo de dos maneras:

  == Estructura de datos

  == Cavidades
]

#capitulo(title: "Trabajo anterior")[

  #comentario[
    Pauta:
    - Polylla 2D
    - Polylla 3D Face y Edge
    - Criterios investigados
    - Experimentos y resultados
  ]
  == POLYLLA 2D

  == POLYLLA 3D

  == Criterios de unión
]

#capitulo(title: "Algoritmo de cavidades")[
  #comentario[Deberia mencionar la intención de unir todo el ecosistema como una sola libreria? Que tal la herramienta para testear la calidad de las mallas?]
  == Arquitectura
  == Visualización
]

#capitulo(title: "Experimentos y resultados")[

]

#capitulo(title: "Conclusión")[
]

#show: end-doc.with(bib-file: "references.bib")
