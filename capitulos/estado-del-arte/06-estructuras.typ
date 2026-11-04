= Estructuras de datos para mallas <sec:ea-estructuras>

Un algoritmo que agrupa tetraedros recorre la malla por adyacencia, consulta
incidencias entre caras y celdas, y produce una nueva malla cuyas celdas son
listas de caras. La estructura de datos que soporta estas operaciones determina
tanto el costo en memoria como el costo de cada consulta, y condiciona la
posibilidad de paralelizar el algoritmo. Esta sección revisa los criterios
generales de diseño y las soluciones adoptadas por los generadores y sistemas
relevantes para esta tesis.

== Representaciones completas y reducidas

La referencia clásica para elegir una estructura de datos de mallas volumétricas
es el estudio de Garimella @garimella2002mesh, que parte de la constatación de que
el diseño de una base de datos de mallas debe equilibrar dos requisitos
contradictorios: compacidad y eficiencia computacional. El trabajo analiza diez
representaciones para mallas de tetraedros y hexaedros. Las representaciones
_completas_ almacenan explícitamente todas las entidades topológicas (vértices,
aristas, caras y regiones) y un subconjunto de sus adyacencias; las _reducidas_
omiten algunas entidades, como las aristas o las caras, y las crean bajo demanda
cuando una consulta las necesita. Las reducidas ahorran memoria, pero encarecen
ciertas consultas y obligan a resolver un problema que las completas no tienen:
si una entidad temporal se crea dos veces, ambas instancias tienen direcciones
distintas y su igualdad debe establecerse comparando sus vértices, por ejemplo
ordenándolos según sus identificadores @garimella2002mesh.

La representación reducida más simple, R1, almacena solo regiones y vértices con
enlaces en ambos sentidos, y es un refinamiento de la clásica estructura
elemento-nodo. R2 añade a cada región información sobre sus regiones adyacentes.
R3 representa explícitamente vértices, caras y regiones, pero no aristas, y R4
agrega a R3 información de vecindad entre vértices @garimella2002mesh. Para
comparar estas alternativas, el autor cuenta el número de operaciones de cada
consulta de adyacencia y de cada operación de creación, y pondera esos costos con
frecuencias de uso medidas en un generador de mallas real. Concluye que R2, R4 y F4
(una representación completa con dos de las tres adyacencias ascendentes) ofrecen
un buen compromiso entre almacenamiento y costo: recomienda F4 si se necesitan
caras y aristas explícitas, R4 si solo se necesitan caras explícitas y R2 en otro
caso, y advierte que la clasificación depende de la carga de trabajo usada para
ponderarla @garimella2002mesh. Esta última advertencia es metodológicamente
importante: la elección de una estructura no se resuelve en abstracto, sino a
partir de las consultas que efectivamente realiza el algoritmo.

== Estructuras de los generadores tetraédricos

Los generadores de tetraedros han convergido hacia estructuras mínimas, centradas
en el tetraedro y en la adyacencia por cara. TetGen representa una
tetraedralización con una estructura basada en tetraedros, que según su autor es
fácil de mantener y requiere menos memoria que las estructuras basadas en aristas
o en pares cara-arista @tetgen. Cada tetraedro guarda cuatro referencias a sus
vecinos y cuatro a sus vértices; para distinguir la cara o arista común con cada
vecino añade un entero de 4 bits por vecino, y un entero de 16 bits para marcar
estados de caras, aristas y del propio tetraedro, de modo que un tetraedro ocupa
básicamente ocho punteros y 32 bits. Cada vértice guarda sus coordenadas y una
referencia a un tetraedro que lo contiene @tetgen. La navegación se hace mediante
_handles_ formados por un tetraedro y una de sus doce aristas dirigidas, cuya
codificación permite moverse dentro de una misma cara con aritmética modular.
Además, TetGen mantiene tetraedros ficticios que unen las caras de frontera con un
punto en el infinito, de modo que toda cara pertenezca a exactamente dos
tetraedros, lo que simplifica las operaciones de modificación @tetgen.

HXT lleva esta idea a su forma más austera. Su implementación, escrita en C,
almacena la malla en arreglos planos de números de punto flotante y enteros: para
cada tetraedro $t$ y cada índice local $j$, la posición $4t + j$ guarda el vértice
$j$ y la posición en la que está almacenada la adyacencia inversa, de modo que
dividir esta última por cuatro entrega el tetraedro vecino opuesto al vértice $j$
@marot2018one. La única conectividad que se almacena explícitamente es la
adyacencia entre tetraedros, porque basta para recorrer la malla con consultas
locales, y los autores sostienen que este estilo de programación, aparentemente
anticuado, facilita la optimización y la paralelización porque obliga a usar
algoritmos simples @marot2018one. El costo de esta austeridad se concentra en la
actualización de adyacencias después de cada inserción, que según sus mediciones
es la etapa más cara de la inserción incremental y que optimizan con operaciones
especializadas para la cavidad @marot2018one.

== Estructuras en la familia Polylla

En dos dimensiones, Polylla emplea una estructura indexada con adyacencias:
arreglos de vértices, de triángulos y de vecinos, en la que las posiciones
$3i$, $3i + 1$ y $3i + 2$ del arreglo de vecinos guardan los vecinos del triángulo
$i$, con costo de memoria lineal @polylla. La versión para GPU adopta la misma
representación porque las GPU y sus modelos de programación están diseñados para
trabajar eficientemente con arreglos, y almacena la malla de salida en un arreglo
plano de polígonos acompañado de un arreglo de posiciones que indica dónde comienza
cada polígono @gpolylla. La versión compacta, en cambio, implementa la estructura
_half-edge_ sobre pemb, una representación sucinta de grafos planares basada en
vectores de bits, y reduce en un 99~% la memoria de la información topológica
respecto de una _half-edge_ no compacta; como contrapartida, las consultas son más
lentas, y en la triangulación compacta las coordenadas de los vértices, que no se
pueden comprimir fácilmente, pasan a ocupar cerca del 89~% de la memoria
@salinasfernandez2024generation. Los autores argumentan que la versión compacta
puede ser más rápida cuando la no compacta no cabe en memoria principal, por efecto
de la jerarquía de memoria, y proponen extender la estructura _half-edge_ a tres
dimensiones como trabajo futuro @salinasfernandez2024generation.

== Estructuras para procesamiento masivamente paralelo

En GPU, el problema dominante no es solo el volumen de memoria, sino la localidad
de los accesos. RXMesh divide mallas triangulares de superficie en parches que se
representan de forma compacta mediante matrices, ampliados con franjas de
elementos vecinos (_ribbons_) que eliminan la necesidad de comunicación entre
bloques de hilos, de modo que las consultas se resuelvan en la memoria compartida
de cada bloque @mahmoud2021rxmesh. Su modelo de programación oculta esta
complejidad al usuario e induce balance de carga incluso en mallas irregulares,
pero sus autores limitan el trabajo a aplicaciones estáticas que no modifican la
topología de la malla @mahmoud2021rxmesh. En el refinamiento paralelo de mallas no
estructuradas se ha usado la representación _array-based half-facet_ (AHF), que
unifica las estructuras _half-vertex_, _half-edge_ y _half-face_ para mallas de una,
dos y tres dimensiones, incluso no _manifold_. AHF almacena solo dos mapas: el de
_half-facets_ hermanas, que enlaza en una lista circular las caras orientadas de
los elementos que comparten una misma faceta, y el que asocia a cada vértice una
_half-facet_ incidente; las entidades de dimensión intermedia no se almacenan, sino
que se referencian implícitamente @ray2016array. Ray et al. extienden esta
representación para soportar jerarquías de refinamiento y recorridos eficientes
@ray2016array.

== Implicancias para esta tesis

Los trabajos revisados coinciden en tres principios. Primero, la relación
topológica primaria para recorrer una malla de tetraedros es la adyacencia por
cara, que TetGen y HXT almacenan explícitamente @tetgen @marot2018one. Segundo, las
representaciones basadas en índices dentro de arreglos contiguos son las que
permiten implementaciones paralelas, tanto en CPU como en GPU @marot2018one
@gpolylla. Tercero, las entidades que no participan en las consultas frecuentes
pueden omitirse y reconstruirse bajo demanda, a cambio de resolver la identidad de
las entidades temporales @garimella2002mesh. Ninguna de estas estructuras fue
diseñada para mallas poliédricas obtenidas por unión de tetraedros, cuyo resultado
natural es una partición de los tetraedros en regiones y una lista de caras de
frontera por región. En esa clasificación, una estructura que almacena vértices,
caras y tetraedros, pero no aristas, corresponde a la familia de representaciones
reducidas del tipo R3 descrita por Garimella @garimella2002mesh, y la decisión de
derivar las aristas solo cuando una consulta lo requiera debe evaluarse con la
carga de trabajo real del algoritmo, como recomienda ese mismo estudio.
