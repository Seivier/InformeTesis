= Generación de mallas tetraédricas <sec:ea-tetraedricas>

Un método indirecto hereda las propiedades de su malla de entrada: su número de
elementos, la distribución de sus vértices, la calidad de sus tetraedros y la forma
en que respeta la frontera del dominio. Esta sección revisa cómo se generan las
mallas tetraédricas, con énfasis en los programas que producen las entradas
habituales de los métodos indirectos, y cómo se mejoran una vez construidas.

== Familias de métodos

Los métodos de generación de tetraedros pueden agruparse en cuatro familias, que a
menudo se combinan.

*Retículas y octrees.* Estos métodos parten de una subdivisión regular del espacio
y la adaptan a la geometría. El _isosurface stuffing_ de Labelle y Shewchuk
@labelle2007isosurface rellena un dominio definido implícitamente usando la
triangulación de Delaunay de una retícula cúbica centrada en el cuerpo, cuyos
tetraedros son idénticos, y deforma los vértices cercanos a la superficie; garantiza
que todos los ángulos diedros quedan entre $10,78 degree$ y $164,74 degree$ y es
numéricamente robusto porque no depende de predicados sensibles. Su precio es que no
preserva aristas ni esquinas agudas y que, al graduar el tamaño en la superficie y
en el interior, las garantías se debilitan @labelle2007isosurface.

*Frente de avance.* Estos métodos construyen la malla desde la frontera hacia el
interior. NETGEN combina modelado por geometría sólida constructiva, seguimiento de
aristas y generación de mallas de superficie y de volumen por frente de avance, y
separa las reglas locales de generación del código que las aplica @schoberl1997netgen.
Su autor reconoce que, en tres dimensiones, no siempre es posible cortar un elemento
sin insertar puntos nuevos y que la elección de las reglas es heurística
@schoberl1997netgen. Los métodos híbridos combinan la colocación de puntos del frente
de avance con la conectividad de Delaunay @mavriplis1995anadvancingfront
@yang2005algorithm.

*Delaunay.* Estos métodos construyen una tetraedralización de Delaunay, recuperan
las restricciones del dominio y la refinan, como se describió en la
@sec:ea-delaunay. Son la base de TetGen @tetgen, de los generadores de CGAL
@cgal:mesh, de HXT @marot2018one y del núcleo propio de Gmsh @geuzaine2009gmsh.

*Muestreo y optimización.* Una cuarta familia distribuye primero los puntos y luego
los conecta. El muestreo de Poisson maximal coloca puntos separados por una
distancia mínima que cubren el dominio, y conecta las muestras mediante una
triangulación de Delaunay o regular @guo2016tetrahedral; sus autores advierten que
incluso vértices bien espaciados pueden crear _slivers_ y descartan los tetraedros
cuyo circuncentro queda fuera del dominio. Los métodos variacionales mueven los
vértices para minimizar una energía, como se discute más adelante en esta sección
@alliez2005variational @du2003tetrahedral.

== Generadores de referencia

La @tab:ea-generadores resume los generadores más relevantes para esta tesis.

#figure(
  {
    set text(size: 9.5pt)
    set par(justify: false, first-line-indent: 0pt)
    table(
      columns: (0.95fr, 1.3fr, 1.65fr, 1.35fr),
      align: left,
      inset: 4.5pt,
      stroke: 0.5pt,
      table.header([*Generador*], [*Entrada*], [*Enfoque*], [*Observaciones*]),
      [TetGen @tetgen @si2009constrained], [PLC o nube de puntos], [Delaunay incremental, CDT y refinamiento de Delaunay], [Solo fronteras lineales por partes; puede fallar ante entradas defectuosas],
      [CGAL @cgal:mesh], [Frontera del dominio], [Refinamiento de Delaunay restringido a la superficie], [La salida no necesariamente respeta el complejo de entrada @delaunay],
      [NETGEN @schoberl1997netgen], [Geometría sólida constructiva], [Frente de avance con reglas], [Reglas heurísticas en 3D],
      [Gmsh @geuzaine2009gmsh], [Modelo CAD], [Delaunay propio o núcleos de NETGEN y TetGen, y optimización], [Integra preproceso y postproceso],
      [TetWild y fTetWild @tetwild @hu2020fast], [Sopa de triángulos posiblemente defectuosa], [Partición del espacio o inserción incremental, y optimización dentro de una tolerancia], [Robustez casi total; aproxima la superficie],
      [HXT @marot2018one @marot2020quality], [Superficie triangulada], [Delaunay paralelo y mejora con cavidades crecientes], [Recuperación de frontera secuencial],
      [Isosurface stuffing @labelle2007isosurface], [Superficie implícita], [Retícula y deformación de vértices], [Ángulos diedros garantizados; no preserva rasgos agudos],
    )
  },
  caption: [Generadores de mallas tetraédricas revisados.],
) <tab:ea-generadores>

*TetGen.* TetGen es la referencia principal de este grupo y el generador de las
mallas de entrada de esta tesis @tetgen. Implementa dos algoritmos incrementales de
Delaunay, la inserción de Bowyer–Watson y el método de _flips_ aleatorizado;
construye la CDT recuperando primero las aristas y luego las caras del PLC; y aplica
refinamiento de Delaunay con restricciones y mejora local para alcanzar los
criterios de calidad pedidos por el usuario @tetgen @si2009constrained. Su autor
reconoce como limitaciones que solo maneja fronteras lineales por partes y que la
calidad de sus mallas puede ser inferior a la de otros programas @tetgen. Su
estructura de datos y sus predicados se discuten en la @sec:ea-estructuras y en la
@sec:ea-delaunay.

*CGAL, NETGEN y Gmsh.* Los generadores de CGAL aproximan la frontera del dominio
mediante triangulaciones de Delaunay restringidas a la superficie, por lo que su
salida no necesariamente respeta el complejo de entrada @delaunay @cgal:mesh. Gmsh se
organiza en cuatro módulos (geometría, malla, _solver_ y postproceso), usa
predicados geométricos robustos en las partes críticas de sus algoritmos e integra,
además de su propio algoritmo de Delaunay basado en Bowyer–Watson, los núcleos
tetraédricos de NETGEN y TetGen @geuzaine2009gmsh. Sus autores usan una medida de calidad que, para tetraedros, combina el volumen, el área de las caras y la longitud de la arista más larga, toma valores en $[0, 1]$ y se anula en un _sliver_, y reconocen que los procedimientos de optimización de mallas
tienen mucho de «magia negra» @geuzaine2009gmsh.

*TetWild y fTetWild.* Estas herramientas priorizan la robustez frente a entradas
defectuosas. TetWild convierte una sopa de triángulos, posiblemente con
autointersecciones y huecos, en una malla tetraédrica: construye una partición
binaria del espacio con coordenadas racionales exactas y luego mejora la malla
manteniéndola válida y dentro de una tolerancia $epsilon$ respecto de la superficie
de entrada; los autores reconocen que el método es más lento que la mayoría de sus
competidores @tetwild. fTetWild sustituye esta etapa por una inserción incremental
que garantiza una malla válida con coordenadas de punto flotante, a cambio de no
garantizar que todas las caras de entrada queden insertadas, aunque en sus pruebas
siempre lo estuvieron @hu2020fast. Sobre los 10.000 modelos de Thingi10k reportan
tasas de éxito de 99,97~% para fTetWild, 99,89~% para TetWild, 79,00~% para CGAL y
49,50~% para TetGen; la mayoría de los fallos de CGAL y TetGen se clasifican como
limitaciones del algoritmo en la tabla de los autores, y los tiempos promedio, de
49,8~s para fTetWild y 360,0~s para TetWild, se calculan sobre los modelos que cada
método completa y no son directamente comparables @hu2020fast. En un contexto
cercano, la CDT robusta de Diazzi et al. procesa los 4.408 modelos válidos de
Thingi10k en los que TetGen falla en 378 @diazzi2023constrained.

*HXT.* HXT muestra que la construcción de la tetraedralización puede paralelizarse
con gran eficiencia: su núcleo de Delaunay genera tres mil millones de tetraedros en
53~s sobre un procesador AMD EPYC @marot2018one. Su etapa de mejora introduce un
operador local, la _Growing SPR Cavity_, que hace crecer una cavidad y elige una
mejor tetraedralización de ella, y que los autores describen como la madre de todos
los _flips_ @marot2020quality. La recuperación de la frontera se delega todavía en
la implementación de TetGen @marot2020quality: es la única etapa del generador que
no se paralelizó, y en uno de sus casos de prueba ocupa más de un tercio del tiempo
total de mallado con el máximo número de hilos @marot2018one.

#include "04b-mejora.typ"

== Implicancias para esta tesis

La revisión muestra que la malla de entrada no es neutra. Su distribución de
vértices determina qué configuraciones casi cosféricas aparecen; la estrategia de
recuperación de la frontera determina si contiene puntos de Steiner y tetraedros
solo localmente de Delaunay; y su etapa de mejora puede alejarla de la propiedad de
Delaunay. Por ello, evaluar un método indirecto exige controlar el generador y los
parámetros de la malla de entrada, como hicieron los trabajos de la familia Polylla
al comparar distribuciones aleatorias, de Poisson, en retícula y mallas de calidad @salinasfernandez2025exploring, o el estudio de Carrier Baudouin et al.,
que mostró que la tasa de recombinación de tetraedros en hexaedros depende
fuertemente de la ubicación de los vértices @baudouin2014afrontalapproach.
