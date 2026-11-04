= Generación de mallas poliédricas <sec:ea-poliedros>

La generación de mallas poliédricas es un área menos madura que la generación de
tetraedros. Los autores de VoroCrust lo expresan así: mientras la generación de
mallas tetraédricas basada en refinamiento de Delaunay u optimización variacional
está bien establecida, la investigación en mallas poliédricas lo está menos
@vorocrust. Esta sección organiza los enfoques existentes según una distinción
habitual en el área: los métodos _directos_ construyen la malla a partir de la
geometría del dominio, mientras que los métodos _indirectos_ parten de una malla
inicial, típicamente de triángulos o tetraedros, y la transforman @polylla. La
ventaja de los indirectos es que pueden apoyarse en generadores simpliciales
robustos y de libre acceso @polylla. Dentro de los indirectos se distinguen, a su
vez, tres estrategias: dualizar la malla de entrada, subdividir sus elementos y
unir sus elementos. La @tab:ea-taxonomia resume esta clasificación, que estructura
el resto de la sección.

#figure(
  {
    set text(size: 9.5pt)
    set par(justify: false, first-line-indent: 0pt)
    table(
      columns: (1.05fr, 1.5fr, 1.35fr, 1.3fr),
      align: left,
      inset: 4.5pt,
      stroke: 0.5pt,
      table.header([*Estrategia*], [*Mecanismo*], [*Celdas resultantes*], [*Trabajos*]),
      [Directa: Voronoi recortado], [Diagrama de Voronoi de semillas, recortado contra el dominio], [Convexas en el interior; recortadas en la frontera], [@yan2011efficient],
      [Directa: Voronoi conforme], [Unión de bolas y pares de semillas a ambos lados de la frontera], [Convexas, sin recorte], [@vorocrust @abdelkader2018sampling],
      [Directa: fondo recortado], [Octree recortado contra la superficie], [Generales, estrelladas desde un centro], [@liu2016automatic @ya2021anopensource],
      [Indirecta: dualización], [Dual de una tetraedralización, con corrección de concavidades], [Generales; caras posiblemente curvas], [@garimella2013polyhedral @lee2015polyhedral],
      [Indirecta: subdivisión], [Partición de tetraedros con los planos de la entrada], [Convexas], [@diazzi2021convex],
      [Indirecta: recombinación], [Patrones de tetraedros que forman hexaedros u otros elementos], [Hexaedros, prismas, pirámides y tetraedros], [@owen2000h @baudouin2014afrontalapproach],
      [Indirecta: aglomeración], [Partición del grafo de elementos u optimización de un criterio], [Generales, posiblemente no estrelladas], [@sorgente2024mesh @sorgente2023mesh @antonietti2024polytopal @fu2024particle],
      [Indirecta: regiones locales], [Unión de elementos según un criterio geométrico local], [Generales, no necesariamente convexas; estrellamiento no evaluado], [@polylla @salinasfernandez2025exploring],
    )
  },
  caption: [Taxonomía de los métodos de generación de mallas poliédricas revisados.],
) <tab:ea-taxonomia>

== Métodos directos basados en diagramas de Voronoi

Las mallas de Voronoi–Delaunay son la realización geométrica por defecto de muchas
formulaciones numéricas, y sus celdas tienen propiedades deseables que se siguen
de su definición: convexidad, caras planas y una malla dual ortogonal dada por la
tetraedralización de Delaunay de las semillas @vorocrust. Su dificultad central es
ajustarse a la frontera del dominio. La estrategia más común consiste en truncar
las celdas que cruzan la frontera. Yan et al. @yan2011efficient calculan de forma
exacta el diagrama de Voronoi recortado en dominios no convexos, representados
mediante una malla tetraédrica: deducen las celdas interiores directamente de la
triangulación de Delaunay de las semillas, detectan las de frontera por
propagación y recortan cada una contra los tetraedros que la intersectan. El
método alimenta la construcción de teselaciones de Voronoi centroidales para
generar mallas tetraédricas, y su costo es proporcional al número de pares
celda–tetraedro incidentes @yan2011efficient. Para superficies, el mismo grupo
calcula el diagrama de Voronoi restringido intersectando cada celda con los
triángulos de la superficie; como ambos son convexos, su intersección es un
polígono convexo @yan2009isotropic.

El recorte, sin embargo, sacrifica propiedades importantes. Según el análisis de
VoroCrust, dualizar una malla tetraédrica y truncar sus celdas contra la superficie
sacrifica la convexidad y la conexidad de las celdas @abdelkader2018sampling. En
los experimentos de Abdelkader et al. @vorocrust, el diagrama restringido de un
trabajo posterior de Yan et al. produjo numerosas facetas de mala calidad en la
superficie y una proporción de celdas no convexas que varió entre 3~% y 96~%
según la curvatura de la entrada y las semillas elegidas. VoroCrust evita el
recorte: cubre la superficie con una unión de bolas, coloca pares de semillas en
las intersecciones de estas bolas para capturar y aislar la frontera, y luego
siembra el interior @vorocrust. Es el primer algoritmo demostrablemente correcto
para mallas de Voronoi conformes en dominios no convexos y no _manifold_, con
garantías sobre la calidad de los elementos de superficie y de volumen
@vorocrust. Su versión abstracta, para superficies cerradas y suaves, demuestra que
la superficie reconstruida es isotópica a la original bajo condiciones de
muestreo explícitas y acota la _gordura_ de las celdas interiores y de frontera,
aunque deja fuera los rasgos agudos @abdelkader2018sampling. Ambos trabajos
reconocen una limitación pertinente para esta tesis: las aristas de Voronoi cortas
en el interior, que pueden restringir algunos _solvers_ y que surgen cuando un
sitio queda cerca de la esfera de Delaunay centrada en un vértice de Voronoi
@vorocrust @abdelkader2018sampling.

== Métodos directos sobre un fondo recortado

Un segundo grupo de métodos directos parte de una subdivisión de fondo
independiente de la geometría. Liu et al. @liu2016automatic construyen un octree
balanceado que encierra un modelo STL, lo refinan según la curvatura de la
superficie y lo recortan contra ella de abajo hacia arriba, primero aristas, luego
caras y luego celdas. La entrada puede contener triángulos degenerados,
autointersecciones y facetas superpuestas. Las celdas resultantes se analizan con
el método de elementos finitos de frontera escalada (SBFEM), que exige un _centro
de escala_ desde el cual sea visible toda la frontera del subdominio y que, por lo
tanto, admite poliedros cóncavos estrellados @liu2016automatic. El método recupera
siempre los rasgos agudos paralelos a los ejes, pero no los oblicuos, que requieren
fusionar celdas; los autores reconocen que esta fusión no garantiza que la
frontera forme siempre una curva cerrada y que, en los casos difíciles, es
razonable descartar la celda problemática @liu2016automatic. Implementaciones
posteriores del SBFEM en ABAQUS y en un _solver_ explícito masivamente paralelo
reiteran el requisito: la frontera de cada celda debe ser visible desde el centro
de escala, es decir, la celda debe ser estrellada @ya2021anopensource
@zhang2021amassivelyparallel. Esta condición es, en esencia, la misma que la no
vacuidad del _kernel_ discutida en la @sec:ea-numericos.

== Mallas duales de tetraedralizaciones

La dualización produce celdas poliédricas a partir de una tetraedralización: cada
vértice de la malla primal origina una celda formada por los circuncentros, o por
otros puntos centrales, de los tetraedros que lo contienen. Garimella et al.
@garimella2013polyhedral aplican esta idea a dominios no _manifold_ y muestran que,
si la malla de entrada es de Delaunay y bien centrada, el resultado es una malla de
Voronoi con caras planas, mientras que en general las caras pueden ser curvas. El
obstáculo es que, en la frontera, los tetraedros de Delaunay pueden ser muy planos
y tener su circuncentro fuera del dominio; construir una malla de Voronoi válida
exige que cada tetraedro de frontera contenga su circuncentro, condición muy
difícil de lograr salvo en geometrías simples @garimella2013polyhedral. Los autores
exigen, además, que cada celda supere una prueba conservadora de estrellamiento y
optimizan la malla, pero en sus ejemplos persisten elementos inválidos en
concavidades agudas @garimella2013polyhedral.

Lee @lee2015polyhedral estudia el origen de esas concavidades: las celdas cóncavas
aparecen a lo largo de las aristas geométricas cóncavas del modelo. Compara tres
remedios: insertar superficies no _manifold_ a lo largo de esas aristas, que es
prometedor pero pocos generadores lo soportan; descomponer las celdas en conos,
que produce celdas típicamente un orden de magnitud más pequeñas que sus vecinas; y
cortarlas a lo largo de las aristas cóncavas, que considera la alternativa más
viable @lee2015polyhedral. La validación es cualitativa, con un _solver_ de fluidos
incompresibles. Lee corrige las concavidades cortando las celdas, mientras que Garimella et al. optimizan la malla para que sus celdas superen una prueba de estrellamiento; en ambos casos, la no convexidad cerca de la frontera se trata como un defecto que corregir, mientras que los métodos numéricos poliédricos modernos admiten celdas no convexas estrelladas.

== Subdivisión de tetraedros en celdas convexas

Diazzi y Attene @diazzi2021convex recorren el camino inverso a la unión de
tetraedros. Calculan la tetraedralización de Delaunay de los vértices de una
superficie triangulada, posiblemente defectuosa; asignan a cada tetraedro los
triángulos de entrada que lo cruzan; lo subdividen con los planos de esos
triángulos mediante una partición binaria del espacio; y clasifican las celdas en
interiores y exteriores con un corte mínimo de grafo. Gracias a predicados
indirectos, garantizan que la superficie de entrada quede representada exactamente
como unión de facetas de la malla de salida, sin recurrir a aritmética racional, y
que cada celda sea convexa, aunque no necesariamente estrictamente convexa
@diazzi2021convex. Sobre Thingi10k procesan 9.999 de 10.000 modelos con un tiempo
medio de 4,34~s y 225~MB por modelo. Reconocen, sin embargo, que la salida puede
ser innecesariamente compleja y contener facetas de forma arbitrariamente mala
@diazzi2021convex. El contraste con esta tesis es ilustrativo: aquí la convexidad
se garantiza, pero la forma de las celdas la dictan los planos de la entrada y no
un criterio de calidad.

== Recombinación de tetraedros en elementos de forma fija

La unión de tetraedros tiene una larga tradición en la generación de mallas
hexaédricas. H-Morph parte de una malla tetraédrica y avanza un frente de
cuadriláteros desde la superficie: para cada hexaedro recupera sus seis caras en la
malla tetraédrica, elimina los tetraedros que quedan en su interior y mantiene en
todo momento una malla mixta válida; los tetraedros restantes se conectan con los
hexaedros mediante pirámides @owen2000h. Carrier Baudouin et al.
@baudouin2014afrontalapproach identifican, mediante tres patrones de ensamblaje, todas las combinaciones de tetraedros que forman hexaedros, las ordenan por calidad y crean primero las de mayor calidad, y
luego aplican el mismo procedimiento a los prismas. Muestran que la tasa de
recombinación depende fuertemente de la ubicación de los vértices: con vértices
aleatorios, menos del 50~% de los tetraedros se combina en hexaedros, por lo que
proponen colocarlos previamente en una estructura de tipo retícula mediante un
frente de avance; aun así, no hay garantías sobre el porcentaje alcanzado
@baudouin2014afrontalapproach. El trabajo de Bukenberger et al.
@bukenberger2021atmosthexa señala que, en trabajos recientes, las mallas
hex-dominantes se obtienen fusionando tetraedros en poliedros más complejos, que a
menudo, pero no siempre, son hexaedros, y propone una clase restringida de mallas
cuyas celdas no tienen más de seis caras ni caras de más de cuatro lados, aunque
sus caras no son necesariamente planas.

H-Morph y la recombinación de Carrier Baudouin et al. comparten con la propuesta de esta tesis dos rasgos: la unión de
tetraedros existentes y la selección codiciosa de las uniones según una prioridad.
Difieren en que persiguen una topología de salida fija, mientras que en una malla
poliédrica general la forma de la celda es libre.

== Aglomeración de celdas para métodos poliédricos

En el contexto de los métodos numéricos poliédricos, la unión de elementos se
denomina _aglomeración_. Como señalan Antonietti et al.
@antonietti2023agglomeration, la aglomeración ha sido poco explorada porque no es
posible desarrollar estrategias de este tipo dentro de los métodos de elementos
finitos clásicos. Los trabajos recientes pueden agruparse según el alcance de la
decisión de unión.

*Aglomeración global por partición.* Sorgente et al. @sorgente2024mesh
optimizan mallas poligonales y poliédricas para el VEM representando la malla
mediante su grafo dual, ponderando nodos y arcos con un indicador de calidad
específico para el VEM y particionando ese grafo con METIS; cada parte se
reemplaza por la unión de sus elementos. Logran eliminar hasta un 80~% de los
elementos preservando las tasas de convergencia, e incluso recuperan la
convergencia en mallas patológicas; sus conjuntos de prueba tridimensionales
incluyen mallas generadas con TetGen @sorgente2024mesh. Un trabajo previo de los
mismos autores, aplicado a las mallas poligonales de cada fractura de una red de
fracturas discretas, minimiza mediante cortes de grafo una energía cuyo término de
datos es uno menos la calidad de la unión de dos elementos adyacentes, y reduce
hasta un 65~% los elementos y un 50~% los grados de libertad @sorgente2023mesh.
Ambos trabajos reconocen la misma limitación: el algoritmo evalúa la calidad de
las uniones de a pares, de modo que no anticipa la calidad de la unión de tres o
más elementos, y algunos elementos pequeños persisten
@sorgente2024mesh @sorgente2023mesh. Antonietti et al. reformulan la aglomeración
como un problema de partición de grafos resuelto con redes neuronales sobre
grafos, primero para mallas poligonales @antonietti2023agglomeration y luego para
mallas tetraédricas de dominios heterogéneos @antonietti2024polytopal. En este
último trabajo, una malla de 12.175 tetraedros con elementos severamente
distorsionados, que no produce una solución numérica estable, se aglomera en 170
poliedros sobre los que el método de Galerkin discontinuo sí converge
@antonietti2024polytopal. Ninguno de estos métodos garantiza convexidad ni
estrellamiento: la calidad se mide _a posteriori_ o se incorpora como peso.

*Aglomeración local alrededor de elementos defectuosos.* Sukumar y Tupek
@sukumar2022virtual unen tetraedros y prismas mal formados con un vecino para
formar elementos virtuales poliédricos, posiblemente no convexos, con el fin de
aumentar el paso de tiempo crítico en elastodinámica explícita; en una viga cónica
el paso de tiempo resulta hasta $4,5 times 10^4$ veces mayor que el de los
elementos finitos. Observan, sin embargo, que para tetraedros de tipo _spire_ el
resultado es deficiente cuando el volumen del poliedro aglomerado tiende a cero,
recomiendan elegir el vecino de modo que ese volumen no se anule, y dejan como
trabajo futuro un procedimiento automático y robusto de aglomeración
@sukumar2022virtual. Fu et al. @fu2024particle proponen precisamente un
procedimiento automático de este tipo dentro del método de partículas de elementos
finitos: los tetraedros cuyo paso de tiempo local es menor que una fracción del
promedio se unen de forma codiciosa con el vecino que maximiza el paso de tiempo
del agregado, hasta superar el umbral, sin mover nodos. Como el remallado de
Delaunay tridimensional genera elementos de volumen nulo o casi nulo, esta
aglomeración permite manejar los _slivers_ @fu2024particle. Su criterio controla
el paso de tiempo, pero no la convexidad ni la forma de las celdas.

Un dato adicional muestra que las uniones de tetraedros ya forman parte del banco
de pruebas del VEM: para estudiar su indicador de calidad, Sorgente et al.
@sorgente2022polyhedral construyen mallas poliédricas agregando pares de
tetraedros vecinos, eligiendo los de mayor volumen y uniéndolos con el vecino que
comparte la cara más amplia; las celdas resultantes son no convexas pero
estrelladas.

== La familia Polylla

Polylla es el antecedente directo de esta tesis: une elementos según regiones definidas por caminos de propagación sobre la propia triangulación. En dos dimensiones, el algoritmo construye polígonos a partir de
_regiones de arista terminal_ @polylla. Estas se basan en el _camino de
propagación de la arista más larga_ (Lepp), introducido por Rivara @rivara como la
lista ordenada de triángulos vecinos sucesivos cuya arista más larga es mayor que
la del triángulo anterior en el camino. Una arista es _terminal_ si es la más
larga de los dos triángulos que la comparten, y una región de arista terminal está
formada por todos los triángulos cuyos Lepp terminan en la misma arista terminal
@polylla (@fig:pol). El algoritmo clasifica las aristas según su longitud, recorre
cada región para construir su polígono y repara los polígonos no simples, que
contienen _aristas barrera_ en su interior, dividiéndolos en polígonos simples
@polylla. No inserta puntos, tiene costo lineal en tiempo y memoria, y produce
mallas con tres veces menos polígonos y la mitad de los puntos que las mallas de
Voronoi con restricciones generadas a partir de la misma entrada, con precisión y
costo del VEM similares en pruebas preliminares @polylla. Como el algoritmo no
divide ningún triángulo, el menor ángulo de la triangulación de entrada es una
cota inferior del menor ángulo interior de la malla poligonal @polylla.

#figure(
  grid(
    columns: 3,
    column-gutter: 2em,
    row-gutter: 0.6em,
    image("../../imagenes/pol1.png", width: 4.2cm),
    image("../../imagenes/pol2.png", width: 4.2cm),
    image("../../imagenes/pol3.png", width: 4.2cm),

    [(a)], [(b)], [(c)],
  ),
  caption: [Construcción de una región de arista terminal en Polylla: los
    triángulos cuyos Lepp terminan en la misma arista terminal (rojo) se unen en un
    único polígono.],
) <fig:pol>

La familia se ha extendido en tres direcciones. En paralelismo, la versión para
GPU implementa las tres fases como _kernels_ sobre arreglos indexados @gpolylla;
sus resultados se discuten en la @sec:ea-paralelo. En memoria, la versión compacta
reemplaza los arreglos por una estructura _half-edge_ sucinta
@salinasfernandez2024generation, discutida en la @sec:ea-estructuras. En dimensión,
la versión preliminar de Polylla 3D presentó dos variantes, una basada en regiones
de arista terminal y otra en una noción nueva de _regiones de cara terminal_
@salinasfernandez20233d.

La variante basada en caras, publicada posteriormente, necesita responder qué es
la «cara más grande» de un tetraedro. Para ello introduce un _criterio de unión_
que ordena las caras de cada tetraedro, como el área o el radio de la
circunferencia inscrita en la cara, y define a partir de él la _cara terminal_
(la mayor de los dos tetraedros que la comparten), el _camino de propagación de la
cara mayor_ y la _región de cara terminal_, formada por los tetraedros cuyos caminos
terminan en la misma cara @salinasfernandez2025exploring. Las regiones de cara
terminal no se superponen, de modo que forman una partición de la malla. El
algoritmo conserva las tres fases: el etiquetado marca las caras frontera y escoge
un tetraedro semilla por región; el recorrido construye cada poliedro con una
búsqueda en profundidad desde su semilla; y la reparación divide los poliedros no
simples, que contienen _caras barrera_, a partir de las _puntas de barrera_
@salinasfernandez2025exploring. En pruebas con cuatro distribuciones de puntos en
un cubo, con mallas de 500 a 50.000 vértices, el algoritmo reduce el número de
celdas en cerca de un 70~%, une en promedio tres tetraedros por poliedro, alrededor
de un quinto de los poliedros contiene caras barrera y en torno al 18,6~% de los
elementos permanece como tetraedro @salinasfernandez2025exploring.

Los autores destacan tres limitaciones que motivan directamente esta tesis. Los
resultados son casi independientes del criterio de unión escogido, lo que indica
que el concepto de región de cara terminal debe mejorarse con estrategias que
consideren la calidad de los poliedros; los poliedros generados están muy lejos de
ser convexos; y aún falta verificar su utilidad en simulaciones con el VEM
@salinasfernandez2025exploring. El análisis detallado de la familia, incluidas sus
variantes tridimensionales y los criterios de unión, corresponde al capítulo de
trabajo previo de esta tesis.

== Balance

La revisión de esta sección permite ubicar con precisión la propuesta de la tesis.
Las celdas de Voronoi sin recorte son convexas, pero los métodos basados en ellas exigen construir y ubicar semillas, presentan aristas cortas, y el recorte contra dominios no convexos pierde la convexidad. Los métodos duales parten de tetraedros, pero deben corregir las celdas cerca de la frontera, y la subdivisión garantiza convexidad a costa de celdas cuya forma no se controla. Los métodos de recombinación y de
aglomeración unen tetraedros, pero persiguen formas fijas o deciden mediante
particiones globales, optimización o criterios ligados a la estabilidad temporal, como el paso de tiempo del agregado. Polylla une elementos con un criterio local,
pero su versión tridimensional no controla la calidad de las celdas. Ninguno de los
trabajos revisados usa como regla de unión la posición de los circuncentros
respecto de la circunsfera de un tetraedro semilla; las circunsferas aparecen solo
de forma auxiliar, como en la construcción de duales @garimella2013polyhedral o en
el filtrado de elementos por su radio circunscrito en el método de partículas
@fu2024particle.
