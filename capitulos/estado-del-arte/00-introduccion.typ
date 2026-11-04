= Introducción <sec:ea-intro>

La generación de mallas consiste en descomponer un dominio geométrico en una
colección de celdas que no se superponen y que, en conjunto, lo cubren. Durante
décadas, las celdas preferidas para la simulación numérica en tres dimensiones
han sido los tetraedros y los hexaedros, porque los métodos de elementos finitos
clásicos dependen de elementos de forma fija. La aparición de métodos numéricos
capaces de operar sobre poliedros generales, entre los que destaca el método de
elementos virtuales (VEM, por sus siglas en inglés), ha renovado el interés por
las mallas poliédricas: una celda poliédrica puede ocupar la región de varios
tetraedros y, con ello, reducir el número de incógnitas de una simulación, siempre
que conserve las propiedades geométricas que el método numérico necesita.

Esta tesis estudia una forma _indirecta_ de construir mallas poliédricas: a partir
de una tetraedralización ya disponible, se agrupan tetraedros vecinos en poliedros
sin insertar ni mover vértices. El criterio de agrupación propuesto se basa en las
_circunsferas_ de los tetraedros, es decir, en las esferas que pasan por sus
cuatro vértices: desde un tetraedro semilla, se incorporan los tetraedros vecinos
cuyos circuncentros quedan dentro de la circunsfera de la semilla. El trabajo se
inscribe en la familia de algoritmos Polylla, que construye polígonos y poliedros
uniendo triángulos o tetraedros según criterios geométricos locales, y aborda
cuatro preguntas de investigación: si es posible construir poliedros mediante este
criterio de cavidades y cómo escoger y refinar las regiones; qué estructura de
datos permite representar eficientemente la topología de estas mallas y unificar
la familia de algoritmos; si las mallas resultantes son viables, en particular qué
fracción de sus poliedros posee un _kernel_ no vacío y cuánto se reduce el número
de celdas; y si el algoritmo puede paralelizarse.

== Alcance y metodología de la revisión

El objetivo de este documento es establecer el marco bibliográfico de esas cuatro
preguntas. La revisión se apoya en un corpus de 232 trabajos catalogados durante
la investigación, de los cuales 134 se revisaron a texto completo. La selección de
lo que aquí se discute obedece a un criterio de pertinencia: se incluyen los
trabajos que determinan qué se le exige a una celda poliédrica, cómo se obtiene la
tetraedralización de entrada y qué propiedades geométricas tiene, cómo se generan
hoy las mallas poliédricas, cómo se representan las mallas en memoria y cómo se
paralelizan los algoritmos que, como el de esta tesis, construyen regiones de
tetraedros a partir de pruebas sobre circunsferas. Quedan fuera, salvo mención
puntual, la generación de mallas de superficie, las mallas curvas de alto orden y
la adaptación anisotrópica, que no intervienen en el problema estudiado.

Cada afirmación atribuida a un trabajo se contrastó con su texto. Cuando el
documento propone una interpretación propia, por ejemplo una relación entre
conceptos de trabajos distintos, se señala explícitamente como tal. Del mismo
modo, la afirmación de que el corpus no contiene un método equivalente al
propuesto debe entenderse limitada a ese corpus y no como una prueba de novedad
absoluta.

== Organización del documento

La @sec:ea-numericos revisa los métodos numéricos sobre mallas poliédricas y las
hipótesis geométricas que imponen a las celdas. La @sec:ea-calidad trata las
medidas de calidad, primero para tetraedros y luego para poliedros generales, con
énfasis en el _kernel_ y en la relación entre calidad geométrica y precisión
numérica. La @sec:ea-delaunay presenta los fundamentos geométricos que sustentan
el algoritmo: la tetraedralización de Delaunay, su dualidad con el diagrama de
Voronoi, las cavidades de Bowyer–Watson y la robustez numérica de los predicados
geométricos. La @sec:ea-tetraedricas revisa los métodos y programas que producen
la malla tetraédrica de entrada y las técnicas para mejorarla. La
@sec:ea-poliedros compara los enfoques de generación de mallas poliédricas, desde
los diagramas de Voronoi hasta la aglomeración de celdas y la familia Polylla. La
@sec:ea-estructuras analiza las estructuras de datos para mallas, y la
@sec:ea-paralelo, la paralelización de algoritmos basados en cavidades en CPU y
GPU. Finalmente, la @sec:ea-sintesis integra los hallazgos, compara los enfoques y
delimita el espacio que ocupa la propuesta de esta tesis.

En todo el documento se distingue la _circunsfera_ de un tetraedro, que pasa por
sus cuatro vértices, de su esfera inscrita, tangente a sus cuatro caras. También se
distingue la _cavidad_ en el sentido de la literatura de Delaunay, definida
respecto de un punto que se inserta, de la región que agrupa el algoritmo de esta
tesis a partir de un tetraedro semilla; la diferencia se discute en la
@sec:ea-delaunay.
