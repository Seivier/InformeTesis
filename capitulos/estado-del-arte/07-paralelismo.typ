= Paralelización de algoritmos de mallas basados en cavidades <sec:ea-paralelo>

La cuarta pregunta de investigación de esta tesis es si el algoritmo de cavidades
puede paralelizarse y cómo luciría una versión paralela. El algoritmo tiene dos
etapas de naturaleza distinta: el cálculo de la circunsfera de cada tetraedro, que
es independiente para cada elemento, y el crecimiento de regiones desde semillas
que compiten por los mismos tetraedros. Esta segunda etapa es análoga a la
construcción concurrente de cavidades de Bowyer–Watson, que la literatura de
generación de mallas ha estudiado durante más de dos décadas. Esta sección
introduce los conceptos de computación paralela necesarios, describe el problema de
la concurrencia entre cavidades y organiza las estrategias propuestas, primero en
CPU y memoria distribuida y luego en GPU.

== Conceptos de computación paralela

Navarro et al. @navarro2013asurveyon ofrecen un marco conceptual para diseñar y
evaluar algoritmos paralelos. El _trabajo_ $T(n, 1)$ es el tiempo total necesario
para ejecutar un algoritmo paralelo con un procesador, y el _span_ $T(n, infinity)$
es el tiempo de la ruta de cómputo más larga ejecutada por un hilo; de ellos se
derivan las cotas $T(n, p) >= T(n, 1) slash p$ y $T(n, p) >= T(n, infinity)$. La
_aceleración_ se define como $S_p = T_s (n, 1) slash T(n, p)$, donde $T_s$ es el
tiempo del mejor algoritmo secuencial, y la _eficiencia_ como $E_p = S_p slash p$;
la ley de Amdahl corresponde al escalamiento fuerte, con tamaño de problema fijo, y
la de Gustafson al escalamiento débil, en el que el problema crece con el número de
procesadores @navarro2013asurveyon. El modelo PRAM supone procesadores síncronos
sobre una memoria compartida de acceso unitario y distingue variantes según se
permitan lecturas y escrituras concurrentes; en el caso de escrituras concurrentes,
la variante de _prioridad_ establece que escribe el procesador de mayor prioridad
@navarro2013asurveyon. El modelo BSP, en cambio, organiza el cómputo en
superpasos de cómputo local, comunicación y sincronización por barrera.

Para el diseño, Navarro et al. recomiendan la metodología de Foster en cuatro
etapas: _partición_, que busca la descomposición con el mayor número de
subproblemas; _comunicación_, en la que las condiciones de carrera se resuelven con
secciones críticas u operaciones atómicas; _aglomeración_, que elige la
granularidad adecuada, de modo que un algoritmo para CPU multinúcleo debería
producir aglomeraciones mayores que el mismo algoritmo diseñado para GPU; y
_mapeo_, que asigna las aglomeraciones a procesadores buscando patrones balanceados
y simples @navarro2013asurveyon. Los autores advierten que en GPU los hilos de un
mismo _warp_ solo se ejecutan completamente en paralelo si siguen el mismo camino de
ejecución, que el acceso coalescente a memoria es determinante, y que estructuras
como arreglos dinámicos, tablas de dispersión y grafos complejos aún no son
amigables con el rendimiento @navarro2013asurveyon. Blelloch et al.
@blelloch1999design añaden una medida útil para comparar algoritmos paralelos con
sus contrapartes secuenciales: un algoritmo es $alpha$-eficiente en trabajo respecto
de otro si realiza a lo sumo $1 slash alpha$ veces sus operaciones.

== Concurrencia entre cavidades

Dos puntos pueden insertarse concurrentemente en una triangulación de Delaunay si
sus cavidades no se intersectan; en caso contrario, hay un conflicto
@marot2018one (@fig:ea-conflicto). Re-triangular cavidades que se intersectan
puede producir una triangulación inconsistente o que no sea de Delaunay
@chrisochoides2003parallel. Nave et al. @nave2004guaranteed precisan la condición:
no basta con que las cavidades sean disjuntas, sino que deben serlo sus
_clausuras_, formadas por la cavidad y los tetraedros que comparten una cara con
ella. Bajo esa condición, la triangulación resultante es la misma
independientemente del orden de las inserciones, y el mecanismo de bloqueo que la
asegura es, en esencia, un algoritmo dinámico de conjuntos independientes, no
necesariamente máximos @nave2004guaranteed. Los mismos autores reconocen que este
esquema simple puede caer en _livelock_ y que diseñar un algoritmo determinista que
lo evite no es directo; proponen como trabajo futuro calcular y re-triangular
iterativamente conjuntos independientes maximales de cavidades
@nave2004guaranteed.

#figure(
  image("../../imagenes/estado-del-arte/conflicto-cavidades.svg", width: 62%),
  caption: [Análogo bidimensional de la concurrencia entre cavidades
    (elaboración propia). Las cavidades de Bowyer–Watson de dos puntos (naranjo y
    azul) comparten dos triángulos (rojo), por lo que no pueden procesarse
    simultáneamente. La cavidad del tercer punto (verde) no comparte triángulos con
    las anteriores y puede procesarse en paralelo con cualquiera de ellas.],
) <fig:ea-conflicto>

El paralelo con esta tesis es directo: en el algoritmo de cavidades, cada
tetraedro debe pertenecer a un único poliedro, de modo que dos regiones que crecen
simultáneamente compiten por los tetraedros de su frontera común, igual que dos
cavidades de Delaunay compiten por sus tetraedros compartidos. La diferencia es que
aquí no hay re-triangulación: el conflicto se resuelve asignando cada tetraedro a
una sola región.

== Estrategias en CPU y memoria distribuida

La literatura ofrece cinco grandes estrategias para resolver o evitar los
conflictos, resumidas en la @tab:ea-paralelo.

*Desacoplamiento geométrico a priori.* Estas estrategias demuestran una condición
local que vuelve independientes los subproblemas antes de resolverlos. Blelloch et
al. @blelloch1999design construyen en dos dimensiones un camino de aristas de
Delaunay que separa dos subproblemas, proyectando los puntos sobre un paraboloide y
calculando una envolvente convexa, lo que elimina la fase de unión; usan su
algoritmo como particionador grueso y terminan cada subproblema con un algoritmo
secuencial, con cerca de 50~% de eficiencia paralela. Linardakis y Chrisochoides
@linardakis2006delaunay definen una _zona de desacoplamiento_, formada por los
círculos diametrales abiertos de los segmentos separadores, y la prerrefinan para
que los subdominios puedan refinarse con un programa secuencial sin modificarlo y
sin comunicación; el precio es cierto sobre-refinamiento, y los autores reconocen
que la extensión a tres dimensiones es difícil. Lo @lo2012parallel lleva una idea
similar a tres dimensiones con un criterio basado en circunsferas: agrupa los
puntos en celdas y zonas que se triangulan simultáneamente, y añade capas de celdas
en las fronteras entre zonas hasta que todas las circunsferas de los tetraedros de
frontera quedan acotadas. Los tetraedros duplicados se asignan a la zona de menor
índice entre las de sus vértices, de modo que pueden eliminarse sin coordinación, y
el resultado es exactamente la triangulación que produciría la inserción
secuencial; con 12 procesadores y 20 millones de puntos alcanza una aceleración de
10,82, siempre que el número de zonas sea múltiplo del número de procesadores
@lo2012parallel.

*Descomposición del dominio y reutilización de un generador secuencial.* Otra
familia divide el dominio en muchos más subdominios que procesadores y malla cada
uno con un generador secuencial. Ito et al. @ito2007parallel fijan de antemano las
interfaces entre subdominios para evitar comunicación adicional, pero el
refinamiento de superficies y el pegado final, realizados por un único procesador,
limitan la aceleración. Chen et al. @chen2012improvements observan que la
descomposición secuencial del dominio impide que todo el esquema sea escalable.
Yu et al. @yu2019robust paralelizan el problema y no el algoritmo, con capas de
partición generadas alrededor de los planos de corte que no quedan como
restricciones en la malla final, y generan mallas de hasta 11 mil millones de
tetraedros, aunque reconocen que el balance de carga es menos prometedor en
dominios complejos. Chen et al. @chen2014highly reparan a posteriori los
tetraedros que no son de Delaunay en las interfaces entre subdominios mediante una
región de reconstrucción mínima, y muestran que la proporción del tiempo dedicada a esa reparación crece con el número de procesadores en los casos evaluados. En la misma línea, Loseille et al. @loseille2016unique
mallan en paralelo las partes del dominio manteniendo fijas sus interfaces y luego
iteran el procedimiento sobre las interfaces, con un único operador basado en
cavidades para todas las modificaciones.

*Especulación con bloqueos.* Kohout et al. @cpuparallel comparan estrategias de
memoria compartida basadas en la inserción incremental aleatorizada para pocos
procesadores; su método optimista bloquea los nodos necesarios y, si detecta una
espera mutua, abandona la inserción, deshace los cambios y la reintenta. Observan
que el número de bloqueos mutuos crece mucho más lento que el número de puntos y
recomiendan minimizar el número y la duración de las secciones críticas
@cpuparallel. Chrisochoides y Nave @chrisochoides2003parallel aplican la
especulación en memoria distribuida: suspenden las cavidades que requieren datos
remotos y ejecutan otras inserciones locales mientras tanto, ocultando más del
90~% de la latencia a costa de un sobrecosto de comunicación de entre 2~% y 20~%.

*Particiones dinámicas.* HXT particiona los puntos según su coordenada en una
curva de Moore y, cuando una inserción cae en conflicto con otra partición, la
pospone y modifica las particiones en la siguiente ronda mediante un
reescalamiento de la curva, evitando mecanismos de sincronización pesados
@marot2018one.

*Conjuntos independientes.* Spielman et al. @spielman2002parallel analizan un
refinamiento de Delaunay que en cada iteración inserta un conjunto de puntos
independientes, y demuestran, bajo las hipótesis de su análisis, que el número de
iteraciones es polilogarítmico en la razón entre el diámetro del dominio y la arista
más pequeña. Ma et al. @ma2025cpaft convierten esta idea en una garantía de
reproducibilidad para el frente de avance: asignan a cada cara del frente un índice
global invariante respecto de la descomposición del dominio y, en cada iteración,
aceptan un avance solo si su índice es menor o igual que el de todos los avances
vecinos con los que entra en conflicto. Con ello obtienen mallas independientes del
número de procesadores, a diferencia de una búsqueda codiciosa cuyos resultados
dependen del orden @ma2025cpaft.

#figure(
  {
    set text(size: 9.5pt)
    set par(justify: false, first-line-indent: 0pt)
    table(
      columns: (1.25fr, 0.95fr, 1.55fr, 1.15fr),
      align: left,
      inset: 4.5pt,
      stroke: 0.5pt,
      table.header([*Trabajo*], [*Plataforma*], [*Resolución de conflictos*], [*Determinismo*]),
      [Kohout et al. @cpuparallel], [Memoria compartida, 2–4 procesadores], [Bloqueos optimistas con retroceso], [No discutido],
      [Chrisochoides y Nave @chrisochoides2003parallel; Nave et al. @nave2004guaranteed], [Memoria distribuida], [Bloqueo de clausuras de cavidades], [Independiente del orden si las clausuras son disjuntas],
      [Spielman et al. @spielman2002parallel], [Análisis teórico], [Conjuntos independientes por ronda], [—],
      [Lo @lo2012parallel], [Memoria compartida], [Zonas con capas acotadas por circunsferas; dueño de menor índice], [Igual a la inserción secuencial],
      [Linardakis y Chrisochoides @linardakis2006delaunay], [Memoria distribuida, 2D], [Zona de desacoplamiento prerrefinada], [No discutido; garantiza conformidad],
      [Marot et al. @marot2018one], [Memoria compartida], [Particiones por curva de Moore modificadas en cada ronda], [Para un número fijo de hilos, como opción],
      [Ma et al. @ma2025cpaft], [Memoria distribuida], [Conjunto independiente maximal con índices globales], [Independiente del número de procesadores],
      [Chen y Tan @delaunay], [GPU], [Marcado atómico por prioridad], [No discutido],
      [Coll y Guerrieri @coll2017parallel], [GPU, 2D], [Una operación por triángulo por ronda; desempate por índice], [No discutido],
      [Zhou et al. @zhou2022saft], [GPU y CPU, 2D], [Descarte de propuestas en conflicto con otras de menor índice], [No: selección aleatoria],
    )
  },
  caption: [Estrategias de resolución de conflictos en la generación paralela de
    mallas. La columna «Determinismo» indica lo que cada trabajo reporta sobre la
    reproducibilidad de su resultado.],
) <tab:ea-paralelo>

Dos lecciones transversales emergen de estos trabajos. La primera es el balance de
carga: cuando el trabajo se concentra espacialmente, como en la adaptación
localizada de mallas, el desbalance es casi el peor posible, y conviene predecir la
carga antes de ejecutar y repartir en consecuencia @oliker2000parallel. La segunda
es la ley de Amdahl en la práctica: en casi todos los esquemas queda una fase
secuencial o irregular, como la descomposición inicial @chen2012improvements, el
pegado de subdominios @ito2007parallel o la recuperación de la frontera en HXT, que
en uno de sus casos ocupa más de un tercio del tiempo total @marot2018one, y esa
fase termina limitando la aceleración.

== Algoritmos en GPU

La GPU impone restricciones adicionales: miles de hilos deben recibir cargas de
trabajo balanceadas y regulares, la sincronización entre hilos es costosa y la
divergencia de ejecución degrada el rendimiento @delaunay @qi2019gpredicates. El
trabajo de Chen y Tan @delaunay sobre refinamiento de Delaunay con restricciones es
la principal referencia de esta tesis en este aspecto. Para insertar puntos
concurrentemente exigen que sean _independientes en el sentido de Delaunay_, es
decir, que no formen una arista, para evitar que el algoritmo no termine; definen
la _región de Delaunay_ de un punto como la unión de los tetraedros cuyas
circunsferas lo contienen y cuyo interior es visible desde él, y observan que dos
puntos con regiones disjuntas, salvo vértices o aristas, son independientes. En dos
dimensiones, los conflictos pueden resolverse deshaciendo _flips_; en tres
dimensiones no se sabe si los _flips_ pueden alcanzar todas las triangulaciones, de
modo que esa estrategia podría quedar atrapada, y por ello calculan las regiones
haciendo crecer cavidades antes de insertar los puntos @delaunay.

El crecimiento se organiza para que el trabajo sea regular. Cada cavidad se
representa con tuplas formadas por un tetraedro y una de sus caras, almacenadas en
listas en memoria global; cada hilo procesa una tupla y prueba si el vecino a través
de esa cara contiene al punto en su circunsfera, y las nuevas tuplas se agregan en
posiciones calculadas con sumas prefijas y se compactan @delaunay. La exclusión
mutua se resuelve con prioridades: cada tetraedro puede pertenecer a lo sumo a una
cavidad; un elemento intenta marcar un tetraedro escribiendo atómicamente su
prioridad, y si no lo logra, su cavidad deja de crecer y el punto se descarta en esa
ronda. Entre elementos de igual dimensión, dar mayor prioridad a los de mayor
medida mejoró la aceleración, porque dividir primero los elementos grandes genera
más trabajo para la GPU @delaunay. Una fase posterior encoge las cavidades para
respetar la visibilidad respecto de las caras restringidas, y requiere menos
cómputo que el crecimiento. El resultado es hasta un orden de magnitud más rápido
que TetGen, con cantidades similares de puntos de Steiner y calidades
comparables; en modelos de Thingi10k, la aceleración llegó a 19 veces para la
versión puramente en GPU y a 34 para la variante híbrida @delaunay. Esta variante
traslada a la CPU la división de subsegmentos y subcaras, porque requiere muchas
rondas con poco trabajo cada una y no aprovecha la capacidad de la GPU @delaunay.

Otros trabajos completan el repertorio de patrones. Coll y Guerrieri
@coll2017parallel construyen en GPU la triangulación de Delaunay con restricciones
en dos dimensiones mediante rondas de _kernels_ en las que solo puede insertarse un
punto por triángulo y voltearse una arista por triángulo, resuelven los empates
eligiendo el índice menor y asignan los índices de los triángulos nuevos sin
contadores atómicos, a partir del índice del triángulo y del punto insertado.
SAFT paraleliza el frente de avance asignando una cara del frente a cada hilo, que
propone un elemento nuevo; una propuesta se acepta si no intersecta a ninguna de
índice menor, y los conflictos se resuelven descartando los elementos ilegales
@zhou2022saft. Su experiencia es ilustrativa: la selección y la actualización del
frente quedaron en la CPU, y las transferencias y la parte secuencial pasaron a
dominar el tiempo; además, la selección aleatoria de caras hace que el resultado no
sea reproducible, crítica que recogen Ma et al. @ma2025cpaft. Gao y Chen
@gao2025parallel3ddelaunay presentan la primera triangulación de Delaunay
tridimensional calculada completamente en GPU: cada punto se procesa de forma
independiente gracias a una generalización del lema de Delaunay local, y triangulan
diez millones de puntos uniformes en 0,91~s con un resultado idéntico al de CGAL,
aunque su estructura de cubetas favorece las distribuciones uniformes. GPredicates
reduce la divergencia separando en dos _kernels_ la evaluación rápida de los
predicados, que resuelve la mayoría de los casos, de la evaluación exacta, a la que
llegó cerca de un 5~% de las consultas en datos sintéticos y un 8~% en datos reales
@qi2019gpredicates. En la familia Polylla, la versión para GPU reserva posiciones en
el arreglo de salida mediante sumas atómicas; su fase más costosa fue el
etiquetado y la reparación no mostró ventaja significativa sobre la versión
secuencial, pese a que muy pocos polígonos la requieren @gpolylla.

Finalmente, dos patrones de bajo nivel son relevantes para construir las
estructuras de salida. Mlakar et al. @mlakar2020subdivisionspecialized expresan la
subdivisión de superficies como operaciones de álgebra dispersa y construyen la
conectividad en GPU con el patrón contar, sumar prefijos y llenar, usando
operaciones atómicas cuya contención está acotada por la valencia de cada vértice;
argumentan que las estructuras _half-edge_ son difíciles de paralelizar porque
requieren bloqueos y sufren accesos dispersos a memoria. Morrical et al.
@morrical2022quickclustersa ordenan los elementos de mallas volumétricas según la
curva de Hilbert de sus centroides y agrupan elementos consecutivos, obteniendo en
segundos una partición con buena localidad para cientos de millones de elementos.

== Implicancias para esta tesis

La literatura distingue tres tipos de trabajo, que se corresponden con las etapas
del algoritmo de cavidades. Los cálculos locales por elemento, como los predicados
y las circunsferas, son trivialmente paralelos. La construcción de regiones que
compiten por elementos requiere resolver conflictos, y las opciones probadas son
los bloqueos con retroceso @cpuparallel @nave2004guaranteed, las particiones
@marot2018one @lo2012parallel, los conjuntos independientes por ronda
@spielman2002parallel @ma2025cpaft, el marcado atómico por prioridad @delaunay y la selección por índice en rondas @coll2017parallel. Las fases irregulares o con poco trabajo concurrente, como la
reparación @gpolylla, suelen limitar la aceleración global.

Dos observaciones, que son interpretaciones propias a partir de esta revisión,
orientan el diseño de una versión paralela. Primero, el algoritmo secuencial
procesa las semillas en orden de radio circunscrito, de modo que su resultado
depende de ese orden; una versión paralela por rondas que resuelva los conflictos
con una prioridad derivada de ese mismo orden, al estilo del marcado de Chen y Tan o
del conjunto independiente de Ma et al., puede producir un resultado reproducible,
pero no necesariamente idéntico al secuencial, y la referencia de corrección debe
definirse en consecuencia. Segundo, Lo amplía las capas de celdas entre zonas hasta que las circunsferas de los tetraedros de frontera quedan acotadas @lo2012parallel; una partición análoga para las regiones de esta tesis requeriría un criterio equivalente, porque su extensión depende de la circunsfera de cada semilla y no se conoce de antemano. Esto favorece los esquemas por rondas sobre listas de trabajo regulares, como los de Chen y Tan @delaunay.
