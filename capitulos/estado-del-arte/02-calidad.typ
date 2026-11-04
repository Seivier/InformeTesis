= Calidad de mallas <sec:ea-calidad>

La calidad de una malla interviene dos veces en esta tesis. Primero, la calidad de
la tetraedralización de entrada condiciona la posición de las circunsferas y, por
lo tanto, las regiones que forma el algoritmo. Segundo, la calidad de los
poliedros resultantes determina si la malla es útil para un método numérico. Esta
sección revisa ambas dimensiones: las medidas de calidad para tetraedros, el
problema particular de los _slivers_, la relación entre calidad geométrica y error
numérico, y las medidas disponibles para poliedros generales.

== Medidas de calidad para tetraedros

Knupp @knupp2001algebraic define una medida de calidad de elementos como una
función escalar de las posiciones de los nodos que mide alguna propiedad
geométrica del elemento, y construye una teoría algebraica de estas medidas a
partir de la matriz jacobiana $A$, cuyas columnas son las aristas que salen de un
nodo. Comparando $A$ con la matriz $W$ de un elemento ideal de referencia, muestra
que orientación, volumen, forma, razón de longitudes y sesgo forman una lista
completa de las propiedades contenidas en la matriz jacobiana; otras propiedades,
como la curvatura o las relaciones entre elementos adyacentes, no lo están
@knupp2001algebraic. Dentro de este marco, el _mean ratio_ y la razón de radios
son medidas de forma, mientras que el ángulo diedro mínimo y la razón de aristas no
lo son, y el número de condición mide la distancia de un elemento al conjunto de
elementos degenerados @knupp2001algebraic. Un trabajo posterior del mismo autor da fórmulas explícitas de tamaño y forma para triángulos, tetraedros, cuadriláteros y hexaedros, y de sesgo solo para cuadriláteros y hexaedros, porque en triángulos y tetraedros no es posible cambiar el sesgo sin cambiar la forma; todas toman valores en $[0, 1]$, iguales a uno solo para
la configuración ideal y a cero solo para elementos degenerados
@knupp2002algebraic. Knupp advierte, sin embargo, que estas medidas a priori no
garantizan que la malla sea adecuada para una simulación concreta, y que los
elementos mal formados pueden producir matrices mal condicionadas que retardan o
impiden la convergencia de los _solvers_ iterativos @knupp2002algebraic. Para la
optimización de mallas volumétricas, Knupp recomienda el número de condición
$kappa(A) = |A| |A^(-1)|$ y muestra que las funciones objetivo con barrera mantienen
la validez de una malla que parte siendo válida, mientras que las que no tienen
barrera no lo hacen de forma consistente @knupp2000achieving2.

En la literatura de Delaunay predomina otra medida. La _razón radio-arista_ es el
cociente entre el radio $R$ de la circunsfera y la arista más corta $ell$ del
tetraedro; vale al menos $sqrt(6) slash 4 approx 0,612$, valor que alcanza el
tetraedro regular, y es grande para la mayoría de los tetraedros mal formados
@tetgen. Su ventaja es que los algoritmos de refinamiento de Delaunay pueden
acotarla. Su debilidad es que no detecta una clase de elementos degenerados:
Alliez et al. @alliez2005variational señalan que la razón radio-arista no es una
medida justa porque no tiende a cero para los _slivers_, mientras que la _razón de
radios_, cociente entre los radios de las esferas inscrita y circunscrita
multiplicado por tres, sí detecta cualquier tipo de degeneración. Finalmente, los
ángulos diedros tienen un efecto directo sobre el método numérico: cuando son
demasiado grandes aumenta el error de discretización, y cuando son demasiado
pequeños aumenta el número de condición de la matriz del elemento
@freitag1997tetrahedral.

== El problema de los _slivers_

Un _sliver_ es un tetraedro cuyos cuatro vértices están cerca de un plano y cuya
proyección ortogonal sobre ese plano es un cuadrilátero convexo sin aristas cortas
@cheng2000sliver; dicho de otro modo, sus cuatro vértices están cerca de un círculo
máximo de una esfera y aproximadamente equiespaciados sobre él
@alliez2005variational. A diferencia del caso bidimensional, incluso vértices bien
espaciados pueden producir estos elementos degenerados @alliez2005variational, y
son notoriamente frecuentes en tetraedralizaciones de Delaunay tridimensionales
@cheng2000sliver. La literatura identifica varias razones por las que son
difíciles de eliminar. El refinamiento de Delaunay acota la razón radio-arista,
pero puede generar _slivers_ @alliez2005variational. Las energías basadas en
teselaciones de Voronoi centroidales optimizan la compacidad de las celdas de
Voronoi duales, pero no la de los símplices, de modo que la presencia de un
_sliver_ no se penaliza @alliez2005variational. Los tetraedros de mala calidad
tienden a agruparse, y en esos grupos el intercambio de caras falla porque la
reconexión local no es legal y el suavizado falla porque mejorar un tetraedro
empeora a su vecino @freitag1997tetrahedral. Cheng et al. @cheng2000sliver
demuestran que, para conjuntos de puntos periódicos cuya triangulación de Delaunay tiene acotada la razón radio-arista, existe una asignación de pesos a sus vértices tal que la triangulación ponderada
resultante no contiene _slivers_, sin mover ni insertar puntos.

Para esta tesis, los _slivers_ tienen una consecuencia adicional: como sus cuatro
vértices son casi cosféricos y casi coplanares, el volumen que aparece en el
denominador del cálculo de su circuncentro es casi nulo, y la posición del
circuncentro es numéricamente inestable. La @sec:ea-delaunay vuelve sobre este
punto.

== Calidad geométrica y error numérico

La relación entre calidad y precisión ha sido estudiada empíricamente a gran
escala. Schneider et al. @schneider2018decoupling usan una estimación a priori del
error de elementos finitos que depende explícitamente de la forma del elemento,
mediante el cociente $sigma$ entre su inradio y su arista más larga, en la que el
error en norma $L^2$ escala como $h^(k+1) slash sigma^2$; concluyen que los
elementos mal formados producen errores grandes en la solución misma y no solo en
sus derivadas. Advierten, además, que ningún método tridimensional conocido
garantiza, para una superficie de entrada general, una cota sobre la razón entre
arista máxima e inradio, y que, si debe preservarse la frontera, algunos elementos
tendrán necesariamente mala forma @schneider2018decoupling. Su propuesta es elevar
localmente el grado polinomial de los elementos de mala calidad. En un estudio
posterior que compara pipelines completos de elementos finitos sobre miles de
modelos, los mismos autores encuentran que los tetraedros lineales rinden mal,
mientras que los tetraedros cuadráticos igualan o superan a los hexaedros, y que
el refinamiento en grado puede compensar los elementos mal formados que
introducen los generadores @schneider2022alargescale. Estos resultados confirman
que la calidad geométrica importa, pero también que su efecto depende del método
numérico.

== Calidad de polígonos y poliedros

Para celdas generales, la noción de calidad se vuelve difusa. Knupp señala que la
forma de un elemento no simplicial no puede definirse a partir de una única matriz
jacobiana, y deja la extensión de sus medidas a prismas, pirámides, poliedros y
elementos de alto orden como trabajo futuro, advirtiendo que probablemente
requerirá ir más allá de la matriz jacobiana @knupp2002algebraic @knupp2001algebraic.
En su revisión de indicadores, Sorgente et al. @sorgente2023survey precisan que la
matriz jacobiana en un vértice de un poliedro solo está definida si este tiene tres
aristas incidentes, y en general no lo está para politopos no convexos. Huang y
Wang @huang2020anisotropic proponen medidas de alineación y equidistribución para
polígonos convexos y muestran que un polígono de buena calidad puede contener
triángulos de mala calidad, por lo que recomiendan evaluar las celdas poligonales y
no sus triangulaciones; reconocen, sin embargo, que su extensión a tres
dimensiones no es trivial, entre otras razones porque algunos poliedros no
convexos, como el de Schönhardt, no admiten una subdivisión simplicial. Para
delimitar el problema y excluir configuraciones poco probables, la mayoría de los
generadores de mallas y de los esquemas numéricos restringen las celdas a formas
convexas o estrelladas @sorgente2023survey.

En ese contexto, el _kernel_ se ha convertido en la herramienta central. El
_kernel_ de un poliedro es el conjunto de puntos desde los que todo el poliedro es
visible; coincide con el poliedro si este es convexo, y es vacío si el poliedro no
es estrellado @sorgente2022polyhedron @sorgente2023survey (@fig:ea-kernel). Los
indicadores basados en él, como la razón entre el volumen del _kernel_ y el de la
celda, valen uno para celdas convexas, un valor en $(0, 1)$ para celdas cóncavas
estrelladas y cero para celdas no estrelladas @sorgente2024mesh @sorgente2023mesh.
Este cociente es el núcleo del indicador de calidad para el VEM de Sorgente et al.
@sorgente2022polyhedral, que lo combina con la relación entre los tamaños de
aristas y caras y con el número de caras para medir el grado de violación de las
hipótesis G1–G3 descritas en la @sec:ea-numericos. En experimentos con el problema
de Poisson sobre familias de mallas tetraédricas, hexaédricas, de Voronoi y
poliédricas, el indicador predice la tendencia del error en las normas $L^2$ y
$H^1$, aunque captura con menos precisión las oscilaciones de la norma $L^infinity$
@sorgente2022polyhedral. En las versiones posteriores, la componente volumétrica
multiplica la razón del _kernel_ de la celda por la de cada una de sus caras, de
modo que basta una cara no estrellada para anular el indicador @sorgente2024mesh.

#figure(
  grid(
    columns: 3,
    column-gutter: 2.5em,
    row-gutter: 0.5em,
    image("../../imagenes/estado-del-arte/kernel-convexo.svg", width: 3.6cm),
    image("../../imagenes/estado-del-arte/kernel-estrellado.svg", width: 3.6cm),
    image("../../imagenes/estado-del-arte/kernel-no-estrellado.svg", width: 3.6cm),

    [(a)], [(b)], [(c)],
  ),
  caption: [_Kernel_ (azul) de tres polígonos, como análogo bidimensional del
    _kernel_ de un poliedro (elaboración propia). (a) En un polígono convexo, el
    _kernel_ coincide con el polígono. (b) Un polígono no convexo estrellado tiene
    _kernel_ no vacío. (c) Un polígono que no es estrellado tiene _kernel_ vacío.
    El _kernel_ se obtiene intersectando los semiplanos interiores de todas las
    aristas.],
) <fig:ea-kernel>

El cálculo del _kernel_ es, por lo tanto, una operación básica para evaluar mallas
poliédricas. En dos dimensiones se resuelve intersectando los semiplanos definidos
por las aristas, y existe un algoritmo óptimo de costo lineal
@sorgente2022polyhedron. En tres dimensiones, la extensión directa de esa idea fue
descartada tempranamente por razones de complejidad, y el enfoque establecido es
algebraico: transforma la intersección de semiespacios en el cálculo de una
envolvente convexa mediante dualidad, con costo $O(n log n)$, y es el que puede
implementarse con CGAL @sorgente2022polyhedron. Sorgente et al.
@sorgente2022polyhedron retoman el enfoque geométrico: parten de la caja envolvente
alineada con los ejes del poliedro y la recortan sucesivamente con el plano de
cada cara, usando predicados geométricos exactos, precalculando las comparaciones
de vértices y terminando apenas el _kernel_ se vuelve vacío. Aunque el método es
cuadrático en general, resulta más rápido que el algebraico cuando el poliedro es
pequeño, cuando tiene muchas caras coplanares o cuando su _kernel_ es vacío; los
autores sitúan el límite práctico en torno a $10^3$ vértices, recomiendan el
método para analizar teselaciones volumétricas con elementos no convexos y
reportan que calculó correctamente el _kernel_ de todos los poliedros probados
@sorgente2022polyhedron. Las celdas producidas por la unión de unos pocos
tetraedros son, precisamente, poliedros pequeños.

== Implicancias para esta tesis

La revisión deja tres conclusiones. Primero, las medidas basadas en la matriz
jacobiana, maduras para tetraedros, no se extienden a poliedros generales, por lo
que la evaluación de celdas obtenidas por unión de tetraedros debe apoyarse en
medidas definidas para politopos, como las basadas en el _kernel_, en la
envolvente convexa o en relaciones entre longitudes. Segundo, la existencia del
_kernel_ y la razón entre su volumen y el de la celda son las medidas más
directamente vinculadas con las hipótesis del VEM, y existe un algoritmo de cálculo
adecuado para celdas pequeñas. Tercero, la calidad de la tetraedralización de
entrada no es un dato menor: los _slivers_ son frecuentes, difíciles de eliminar y
problemáticos precisamente para un criterio basado en circuncentros.
