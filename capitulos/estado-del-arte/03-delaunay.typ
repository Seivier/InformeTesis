= Fundamentos geométricos: Delaunay, Voronoi y cavidades <sec:ea-delaunay>

El algoritmo estudiado en esta tesis opera sobre una tetraedralización y decide
qué tetraedros unir comparando circuncentros con circunsferas. Su comportamiento
depende, por lo tanto, de las propiedades de las circunsferas en las
tetraedralizaciones que recibe, que normalmente son de Delaunay o de Delaunay con
restricciones. Esta sección revisa esas propiedades: la definición y unicidad de la
tetraedralización de Delaunay, su dualidad con el diagrama de Voronoi, la posición
de los circuncentros, la construcción incremental mediante cavidades, las
tetraedralizaciones con restricciones que producen los generadores prácticos y los
problemas de robustez numérica asociados.

== La tetraedralización de Delaunay

Sea $V$ un conjunto finito de puntos en $RR^3$. Un símplice con vértices en $V$ es
de Delaunay si existe una esfera circunscrita a él que no encierra ningún vértice
de $V$, y es _fuertemente_ de Delaunay si, además, ningún vértice de $V$ distinto de
los suyos está sobre esa esfera @shewchuk2008generaldimensionalconstrained. Si $V$
está en posición general, es decir, si no hay cinco puntos de $V$ sobre una misma
esfera, la tetraedralización de Delaunay de $V$ es única @si2009constrained
@tetgen. Su tamaño puede ser cuadrático en el número de puntos: una
tetraedralización de Delaunay de $n$ puntos puede tener $O(n^2)$ tetraedros
@tetgen.

Una caracterización clásica explica la estructura de estas tetraedralizaciones.
Si cada punto se eleva a $RR^4$ añadiéndole como cuarta coordenada el cuadrado de
su norma, un símplice es de Delaunay si y solo si su elevación está contenida en
alguna cara de la parte inferior de la envolvente convexa de los puntos elevados
@shewchuk2008generaldimensionalconstrained. Cuando cinco o más puntos elevados quedan sobre un mismo hiperplano no vertical que soporta la parte inferior de la envolvente, lo que ocurre cuando los puntos originales están sobre una esfera vacía común, algunas caras de esa envolvente no son símplices, y pueden rellenarse con cualquier triangulación compatible
@shewchuk2008generaldimensionalconstrained. En otras palabras, la tetraedralización
de Delaunay deja de ser única: todo subconjunto afínmente independiente de los
vértices cosféricos define un símplice de Delaunay, algunos de esos símplices se
superponen y distintas elecciones producen distintas tetraedralizaciones
@shewchuk2008generaldimensionalconstrained. Spielman et al. @spielman2002parallel
describen el mismo fenómeno al definir la triangulación de Delaunay como un
complejo lineal por partes que contiene todos los símplices de Delaunay, y que es un
complejo simplicial cuando los puntos están en posición general.

Esta observación es pertinente para esta tesis. Cuando cinco o más vértices
comparten una esfera vacía, los tetraedros que los unen son solo una de varias
subdivisiones posibles del poliedro convexo inscrito en esa esfera, de modo que
unirlos elimina una elección arbitraria y recupera una celda canónica de la
estructura de Delaunay. En la práctica, los generadores resuelven estas
degeneraciones mediante perturbaciones simbólicas que simulan la posición general
sin mover los vértices @si2009constrained @yang2005algorithm, o
desempatando según el orden en que los vértices están almacenados en memoria
@diazzi2023constrained. En ambos casos la elección entre las posibles
subdivisiones es convencional, no geométrica.

== Dualidad con el diagrama de Voronoi y posición de los circuncentros

La tetraedralización de Delaunay es dual del diagrama de Voronoi de los mismos
puntos. Unir los centros de las circunsferas de los símplices de Delaunay produce
el diagrama de Voronoi @elshakhs2024acomprehensivesurvey: el circuncentro de cada
tetraedro es un vértice de Voronoi, la celda de Voronoi de un vértice se obtiene
conectando los circuncentros de los tetraedros que lo contienen
@garimella2013polyhedral, y la arista de Voronoi asociada a una cara es el
segmento que une los circuncentros de los dos tetraedros que la comparten
@engwirda2017jigsawgeo1 (@fig:ea-delaunay, panel a). Esta dualidad permite leer las
configuraciones casi degeneradas en términos de Voronoi: según Abdelkader et al.
@vorocrust, aparecen aristas de Voronoi cortas cuando la distancia de un vértice de
Voronoi a sus $d + 1$ semillas más cercanas es apenas menor que la distancia a la
siguiente, es decir, cuando una semilla queda cerca de la esfera de Delaunay
centrada en ese vértice. Así, dos tetraedros adyacentes con circuncentros muy
próximos corresponden a una arista de Voronoi corta y a una configuración cercana a
la cosfericidad.

#figure(
  grid(
    columns: 2,
    column-gutter: 1em,
    row-gutter: 0.6em,
    image("../../imagenes/estado-del-arte/delaunay-voronoi.svg", width: 100%),
    image("../../imagenes/estado-del-arte/cavidad-bowyer-watson.svg", width: 100%),

    [(a)], [(b)],
  ),
  caption: [Análogo bidimensional de los conceptos de esta sección (elaboración
    propia). (a) Triangulación de Delaunay (negro) y diagrama de Voronoi dual
    (rojo): cada vértice de Voronoi es el circuncentro de un triángulo, y la
    circunferencia circunscrita destacada no contiene vértices en su interior.
    (b) Cavidad de Bowyer–Watson de un punto $p$ (rojo): los triángulos cuyas
    circunferencias circunscritas contienen a $p$ forman una región estrellada
    respecto de $p$, que se re-triangula uniendo $p$ con su frontera (líneas
    segmentadas).],
) <fig:ea-delaunay>

La posición de un circuncentro respecto de su tetraedro no está garantizada. Un
símplice es _bien centrado_ si contiene su circuncentro en su interior, y una
triangulación de Delaunay no es necesariamente bien centrada; a la inversa, una
malla completamente bien centrada de un dominio convexo es de Delaunay
@vanderzee2010well. VanderZee et al. @vanderzee2010well caracterizan esta propiedad
mediante bolas ecuatoriales, muestran que en tres dimensiones cada vértice interior debe tener al menos siete aristas incidentes para admitir una malla bien centrada, y
reconocen que sus resultados tridimensionales son rudimentarios y que los obstáculos
topológicos no se comprenden del todo. Engwirda @engwirda2017jigsawgeo1 observa
que exigir que todos los vértices de Voronoi duales estén dentro de sus triángulos
es particularmente oneroso, porque requiere que todos los elementos sean agudos, y
lo persigue mediante optimización. En la frontera del dominio el problema se
agrava: los tetraedros de Delaunay pueden ser muy planos y tener su circuncentro
fuera del dominio @garimella2013polyhedral, y varios métodos optan por descartar o
desactivar esos elementos, como los que solo conservan los tetraedros cuyo
circuncentro está dentro del dominio @guo2016tetrahedral @feng2018curvedoptimaldelaunay.
Cheng y Poon @cheng2006three recuerdan condiciones suficientes, basadas en esferas
diametrales y ecuatoriales vacías, para que el circuncentro de un tetraedro quede
dentro del dominio.

Para esta tesis, estas observaciones tienen consecuencias directas. Un criterio
que compara circuncentros con circunsferas opera sobre puntos que pueden estar
fuera del tetraedro al que pertenecen e incluso fuera del dominio, especialmente
cerca de la frontera. Por otra parte, para dos tetraedros de Delaunay adyacentes,
que el circuncentro del vecino quede dentro de la circunsfera de una semilla
equivale a que la arista de Voronoi dual a la cara compartida sea más corta que el
radio de esa circunsfera; en el límite cosférico, los circuncentros coinciden y la
arista de Voronoi tiene longitud nula. Esta lectura, que se desarrolla en la
@sec:ea-sintesis, es una interpretación propia derivada de la dualidad.

== Construcción incremental y cavidades de Bowyer–Watson

Los algoritmos incrementales de Bowyer @tetgen:bowyer y Watson @tetgen:watson
construyen la triangulación de Delaunay insertando los puntos uno a uno. Al
insertar un punto $p$, la _cavidad de Delaunay_ es el conjunto de todos los
tetraedros cuya circunsfera contiene a $p$; esos tetraedros se eliminan y el hueco
poliédrico resultante se rellena con nuevos tetraedros que unen $p$ con las caras
de su frontera @marot2018one. Si @tetgen precisa que esta cavidad es un poliedro
simplicial estrellado respecto de $p$, lo que permite re-tetraedralizarla de esa
manera, y que la tetraedralización resultante vuelve a ser de Delaunay
(@fig:ea-delaunay, panel b). En el núcleo de inserción de HXT, la construcción de la
cavidad representa cerca de un tercio del tiempo total de ejecución en las
implementaciones disponibles @marot2018one.

El análisis de estos algoritmos se apoya en la aleatoriedad. Guibas et al.
@guibas1992randomized definen el _alcance_ de un triángulo como el número de sitios
contenidos en el interior de su circunferencia circunscrita, de modo que los
triángulos de alcance cero son exactamente los de Delaunay, y demuestran que la
inserción en orden aleatorio, con un historial de todas las versiones de la
triangulación para localizar los puntos, construye la triangulación de Delaunay
plana en tiempo esperado $O(n log n)$. En tres dimensiones acotan por $O(n^2)$ el
número esperado de tetraedros que aparecen durante la construcción, pero dejan
abierto el diseño de un algoritmo eficiente; registran, además, el resultado de
Joe según el cual el procedimiento incremental de _flips_ de tetraedros siempre
produce la tetraedralización de Delaunay @guibas1992randomized. En cambio, partiendo
de una triangulación arbitraria, el algoritmo de _flips_ puede quedar atrapado antes
de alcanzar la de Delaunay en tres o más dimensiones @elshakhs2024acomprehensivesurvey.
En la práctica, la eficiencia depende del orden de inserción: TetGen agrupa los
puntos según un orden aleatorizado sesgado y, dentro de cada grupo, los ordena a lo
largo de una curva de Hilbert, para preservar la localidad sin perder el carácter
aleatorio @tetgen. Mavriplis @mavriplis1995anadvancingfront, que combina el frente
de avance con la conectividad de Delaunay en dos dimensiones, ofrece una idea útil
para esta tesis: para encontrar rápidamente qué circunferencias contienen un punto,
representa cada una como un punto $(x, y, r)$ de un espacio tridimensional y la
busca con un octree, aunque reconoce que esa búsqueda sigue consumiendo una parte
significativa del tiempo.

El término _cavidad_ requiere precisión en esta tesis. En la literatura de Delaunay
designa una región definida respecto de un punto que se desea insertar. El
algoritmo estudiado en este trabajo, en cambio, agrupa tetraedros existentes a
partir de la circunsfera de un tetraedro semilla, sin insertar puntos. Ambas
nociones comparten la herramienta geométrica, la prueba de pertenencia a una
circunsfera, pero no su significado; en particular, la región de la tesis no hereda
automáticamente el estrellamiento respecto de un punto que caracteriza a la
cavidad de Bowyer–Watson.

== Tetraedralizaciones con restricciones

Los generadores prácticos no triangulan nubes de puntos, sino dominios descritos por
un _complejo lineal por partes_ (PLC): un conjunto de vértices, aristas, polígonos y
poliedros que describe el dominio y sus fronteras internas @tetgen
(@fig:ea-plc). Como la tetraedralización de Delaunay de los vértices no respeta, en
general, las aristas y caras del PLC, se recurre a la _tetraedralización de
Delaunay con restricciones_ (CDT), en la que se exige que exista una circunsfera de
cada símplice tal que ningún vértice dentro de ella sea visible desde el interior
relativo del símplice, considerando que las caras del PLC bloquean la visibilidad
@shewchuk2008generaldimensionalconstrained @delaunay. Una CDT contiene tetraedros
que no son globalmente de Delaunay, aunque sí localmente, y conserva propiedades
cercanas a las de una tetraedralización de Delaunay @si2009constrained.

#figure(
  image("../../imagenes/Piecewise Linear.gif", width: 55%),
  caption: [Ejemplo de PLC con un polígono no convexo con un agujero y un polígono
    interior que separa dos subdominios. Extraído de @tetgen (Figura 1a).],
) <fig:ea-plc>

A diferencia del caso plano, donde una colección de segmentos que no se cruzan
siempre admite una CDT, en tres dimensiones la CDT puede no existir
@diazzi2023constrained, y decidir si un PLC no genérico la tiene es un problema
NP-completo @shewchuk2008generaldimensionalconstrained. Shewchuk demuestra que todo
PLC cuyas aristas son fuertemente de Delaunay tiene una CDT, condición suficiente
pero no necesaria @shewchuk2008generaldimensionalconstrained. Por ello, los
generadores agregan puntos de Steiner. TetGen construye primero la
tetraedralización de Delaunay de los vértices, luego recupera las aristas del PLC
insertando puntos de Steiner y finalmente recupera las caras mediante cavidades
@si2009constrained; su autor reconoce que aún no se conoce una cota polinomial para
el número de puntos de Steiner que agrega la recuperación de aristas
@si2009constrained. Diazzi et al. @diazzi2023constrained muestran que la expansión
de cavidades de ese procedimiento puede fallar con independencia de los errores
numéricos, aunque en la práctica ocurrió en solo dos de 4.408 modelos, y reportan que
TetGen falla en 378 de esos 4.408 modelos de Thingi10k, mientras que su método
robusto los procesa todos.

Para esta tesis, la consecuencia es que la malla de entrada producida por un
generador con restricciones puede contener puntos de Steiner y tetraedros que solo
son localmente de Delaunay. Las propiedades de las circunsferas descritas en esta
sección valen, por lo tanto, de forma local, y las caras del PLC son restricciones
que una región formada por unión de tetraedros no debería atravesar si se desea
preservar las fronteras internas del dominio.

== Refinamiento de Delaunay y calidad

El refinamiento de Delaunay mejora una tetraedralización insertando los
circuncentros de los tetraedros de mala calidad @si2009constrained @delaunay. La
medida que controla es la razón radio-arista, cociente entre el radio de la
circunsfera y la arista más corta del tetraedro @cheng2006three. Cheng y Poon
@cheng2006three resumen sus límites: el algoritmo de Shewchuk puede no terminar
cuando algún ángulo de entrada es menor que $pi slash 2$, y, aunque acota la razón
radio-arista, pueden quedar _slivers_, que son la única clase de tetraedros malos
que persiste cuando esa razón está acotada. Su propio algoritmo garantiza una malla
de Delaunay conforme con razón radio-arista acotada fuera de una zona de protección
alrededor de los ángulos pequeños, pero reconocen como problema abierto construir
mallas conformes con razón de aspecto acotada en presencia de ángulos pequeños
@cheng2006three. Si @si2009constrained precisa que un _sliver_ puede tener una
razón radio-arista tan baja como $sqrt(2) slash 2 approx 0,707$ y que no está
demostrado que su refinamiento los elimine; además, como el circuncentro de un
tetraedro puede caer fuera del dominio, solo se considera para inserción si está
dentro de él. Labelle y Shewchuk @labelle2007isosurface señalan que las cotas
demostrables sobre ángulos diedros de los métodos de Delaunay y de octree son
menores que $0,1 degree$, y que la exudación de _slivers_ suele eliminar la mayoría
de los tetraedros malos de una malla de Delaunay, pero rara vez todos.

== Robustez numérica

Las decisiones de un generador dependen de predicados geométricos como `orient3d`,
que determina de qué lado de un plano está un punto, e `insphere`, que determina si
un punto está dentro de la esfera definida por otros cuatro; ambos se calculan como
el signo de un determinante, y su evaluación en punto flotante puede producir
resultados incorrectos o hacer fallar el programa @tetgen. Shewchuk
@shewchuk1997adaptive propuso predicados adaptativos que evalúan primero una
aproximación con una cota de error y solo aumentan la precisión cuando el signo es
incierto, de modo que los casos regulares terminan rápidamente y los degenerados
llegan al cálculo exacto; TetGen y Gmsh usan predicados de este tipo
@tetgen @geuzaine2009gmsh.

Estas garantías tienen un límite importante para esta tesis. Diazzi et al.
@diazzi2023constrained advierten que los predicados exactos no bastan cuando
algunos de los puntos involucrados son construidos por el algoritmo, porque sus
coordenadas se redondean y los predicados dejan de garantizar la respuesta
correcta. Los circuncentros son, precisamente, puntos construidos: se obtienen
dividiendo por un determinante proporcional al volumen del tetraedro, de modo que
en los _slivers_, cuyo volumen es casi nulo, su posición es numéricamente inestable.
Boissonnat et al. @boissonnat2015anisotropicdelaunaymeshes muestran, en otro
contexto, que las inconsistencias de sus mallas anisotrópicas provienen solo de
configuraciones casi cosféricas y que insertar puntos en los centros de las esferas
circunscritas puede llevar a una sucesión interminable de ellas. Un criterio de
pertenencia basado en circuncentros es, por lo tanto, sensible justamente en las
configuraciones casi cosféricas y casi degeneradas, y una tolerancia fija no
resuelve el problema de fondo.

== Implicancias para esta tesis

La revisión de esta sección fundamenta tres ideas que orientan el trabajo. Primero,
la estructura de Delaunay contiene, en el caso degenerado, celdas poliédricas
convexas cuya subdivisión en tetraedros es arbitraria, lo que da un sentido
geométrico a unir tetraedros con circunsferas coincidentes o cercanas. Segundo, los
circuncentros pueden quedar fuera de sus tetraedros y del dominio, y la malla de
entrada de un generador con restricciones solo es localmente de Delaunay, de modo
que cualquier interpretación global de las circunsferas debe tomarse con cautela.
Tercero, las configuraciones que el algoritmo tendería a unir, las casi cosféricas,
son también las más sensibles numéricamente.
