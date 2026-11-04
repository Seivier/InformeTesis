#import "final.typ": agradecimientos, apendice, capitulo, conf, dedicatoria, end-doc, resumen, start-doc
#import "my-metadata.typ": metadata
#import "capitulos/pendiente.typ": pendiente

#let mostrar-comentarios = true

#let comentario(body) = if mostrar-comentarios {
  text(body, fill: red)
} else []


#show: conf.with(metadata: metadata)

#resumen(metadata: metadata)[
  Esta tesis estudia la generación indirecta de mallas poliédricas mediante la
  agrupación de tetraedros de una malla de entrada. Se propone una estrategia
  basada en cavidades definidas operacionalmente a partir de la circunsfera de
  un tetraedro semilla. El objetivo es investigar si esta forma de agrupación
  permite obtener celdas de calidad y un procedimiento eficiente, en comparación
  con otras variantes de la familia Polylla. La eficiencia, la robustez y la
  adecuación para métodos numéricos se plantean como hipótesis por contrastar.

  Se revisan fundamentos geométricos, calidad, estructuras de datos y
  paralelización. La implementación secuencial ordena candidatos por radio
  creciente y recorre vecinos por cara; su aceptación compara circuncentros con
  la esfera de la semilla. Se documentan propietarios y fronteras, conservando
  la subdivisión tetraédrica junto con las agrupaciones.

  El análisis diferencia el comportamiento activo de las capacidades aún
  incompletas. La reparación provisional no interviene en el operador principal,
  y la integración de Face y Edge en una interfaz común permanece pendiente.
  Se examinan además el cálculo de kernel y las razones geométricas disponibles,
  explicitando las condiciones de interpretación y las validaciones necesarias
  antes de usar sus exportaciones como evidencia experimental.

  Se establece un diseño experimental que relaciona las preguntas de
  investigación con métricas de partición, reducción de celdas, kernel, tiempo
  y memoria. El protocolo contempla entradas locales inventariadas, familias
  controladas por generar y comparadores sujetos a integración.

  #pendiente[Resultados del resumen: ejecutar el protocolo del capítulo 5 una
    vez validados entradas, métricas y comparadores; reemplazar este bloque por
    una frase con reducción, fracción de kernel, tiempo y memoria, indicando
    entradas y alcance de comparación. Si la hipótesis no se confirma,
    describir los límites observados sin atribuir mejoras inexistentes.]

  Se propone además paralelizar cálculos locales, resolver conflictos de
  propiedad y construir una salida aplanada. Su corrección y desempeño requieren
  desarrollo posterior.

]

// #dedicatoria[
// ]

// #agradecimientos[
// ]

#show: start-doc

#capitulo(title: "Introducción")[
  La generación de mallas es un área que ha estado en el foco de atención
  constantemente desde el asentamiento de la computación como disciplina. Tanto a
  nivel académico como industrial, discretizar un espacio, 2D o 3D, en
  primitivas de manera automática es clave para poder efectuar simulaciones
  avanzadas. En el contexto de poliedros, comúnmente se reconocen dos formas de generar estas mallas
  (@sec:ea-poliedros): de manera directa, que toma información espacial directa,
  como una nube de puntos o un dominio geométrico, y genera la estructura de datos;
  y de manera indirecta, que toma una malla de
  tetraedros previamente construida y le aplica una serie de transformaciones para
  generar una malla de poliedros manteniendo sus características en rasgos generales. El
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
  Tomando este como inspiración se desarrolló una versión tridimensional
  @salinasfernandez2025exploring, donde posteriormente se realizó un estudio en
  profundidad de la viabilidad y calidad de dichas mallas (@sec:ta-polylla-3d).

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
  método de elementos virtuales @veiga2012basic (_VEM_ por sus siglas en inglés),
  se necesita disponer de un algoritmo que sea escalable con respecto a la cantidad
  de células (tetraedros) mientras contenga propiedades deseables para que dicho método
  funcione correctamente. No obstante, el estudio realizado sobre POLYLLA 3D dio
  resultados poco satisfactorios en este ámbito, donde se concluyó que uno de los algoritmos,
  POLYLLA 3D Face, era capaz de obtener buenos resultados, pero que la ausencia de _kernel_ en ciertos
  poliedros podría afectar su usabilidad para VEM @pol3d.
  #pendiente[Fuente del diagnóstico de kernel: confirmar en el documento
    identificado por la clave bibliográfica `pol3d` la afirmación de que la
    ausencia de kernel podría afectar la usabilidad para VEM. Localizar la
    página, el dato exacto y la variante evaluada; P005
    (@salinasfernandez2025exploring) no cuantifica kernels vacíos
    (ver @sec:ta-motivacion).]
  Con esto en mente se propone una nueva forma de
  crear poliedros, alejada de la forma tradicional de unir triángulos por sus aristas en POLYLLA 2D: usar cavidades.
  En este trabajo, las regiones candidatas se definen a partir de la circunsfera
  asociada a cada tetraedro semilla, es decir, la esfera que pasa por sus cuatro
  vértices. Esta debe distinguirse tanto de la esfera inscrita, tangente a las
  cuatro caras, como de la cavidad de Bowyer--Watson, que es un conjunto de
  tetraedros en conflicto respecto de un punto de inserción @tetgen.


  == Hipótesis
  Es posible diseñar e implementar un algoritmo que genere mallas de
  poliedros a partir de una malla de tetraedros utilizando las cavidades de dichos tetraedros,
  seleccionando unos como semilla para formar el poliedro. Tal algoritmo resultaría más eficiente y robusto que otros implementados en la familia Polylla, produciendo mallas de calidad según los criterios de los métodos numéricos.
  == Preguntas de investigación
  #enum(numbering: (..nums) => text(weight: "bold", "Pregunta " + numbering("1", ..nums)))[
    ¿Es posible crear poliedros a partir de un algoritmo de generación de
    poliedros basado en cavidades? ¿Cómo se deberían escoger las semillas para formar los poliedros? ¿Qué pasos de refinamiento se deberían realizar sobre la malla creada?
  ][
    ¿Qué estructura de datos puede proveer un uso eficiente de memoria y tiempo de
    ejecución permitiendo manejar la topología de la malla? ¿Es posible crear una estructura que permita unir todos los algoritmos dentro de la familia Polylla?
  ][
    ¿El algoritmo final es una solución viable para problemas con mallas típicas?
    ¿Qué porcentaje de poliedros de la malla final poseen un _kernel_? ¿Se obtiene una reducción sustancial de primitivas?  ¿Cuáles son límites que el algoritmo tiene en términos de tamaño de la malla y cantidad de vértices?
  ][
    ¿Es posible paralelizar el algoritmo? ¿Existe una forma directa de hacerlo? ¿Cómo luciría una posible versión paralela?
  ]





  == Objetivos
  El objetivo general de esta investigación es diseñar, implementar y analizar un nuevo
  algoritmo de creación de mallas de poliedros de forma indirecta, inspirado en el
  uso de cavidades de los tetraedros.

  // == Objetivos específicos
  #enum(numbering: (..nums) => text(weight: "bold", "Objetivo " + numbering("1", ..nums)))[
    Diseñar e implementar un nuevo algoritmo basado en
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
  El capítulo 2 presenta los fundamentos y el estado del arte. El capítulo 3
  desarrolla los antecedentes de Polylla, con énfasis en las regiones terminales
  y el alcance de la evidencia publicada. El capítulo 4 describe el algoritmo de
  cavidades, su implementación secuencial y una propuesta de paralelización.
  El capítulo 5 establece el diseño experimental; no contiene resultados de
  ejecución. El capítulo 6 sintetiza las contribuciones, responde las preguntas
  hasta donde lo permite el trabajo actual y delimita las tareas pendientes.

]

#capitulo(title: "Estado del arte")[
  #set heading(offset: 1)
  #include "capitulos/estado-del-arte.typ"
]

#capitulo(title: "Trabajo anterior")[
  #set heading(offset: 1)
  #include "capitulos/trabajo-anterior.typ"
]

#capitulo(title: "Algoritmo de cavidades")[
  // Idea del autor conservada: ¿mencionar la intención de unir todo el ecosistema
  // como una sola biblioteca? ¿Y la herramienta para evaluar calidad de mallas?
  // Texto original conservado como antecedente: caracterizar las variantes por
  // forma de unión (Face/Edge) y criterio de unión; generalizar Polylla 3D.
  #set heading(offset: 1)
  #include "capitulos/algoritmo-cavidades.typ"
]

#capitulo(title: "Diseño experimental")[
  #set heading(offset: 1)
  #include "capitulos/experimentos.typ"
]

#capitulo(title: "Conclusión")[
  #set heading(offset: 1)
  #include "capitulos/conclusion.typ"
]

#show: end-doc.with(bib-file: "references.bib")
