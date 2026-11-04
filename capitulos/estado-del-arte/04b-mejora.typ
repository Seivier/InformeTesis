== Mejora de mallas tetraédricas <sec:ea-mejora>

Los generadores suelen complementar la construcción de la malla con una etapa de
mejora que modifica la posición de los vértices, la conectividad o ambas. Esta
etapa es relevante para esta tesis porque altera las circunsferas sobre las que
opera el algoritmo y, en algunos casos, la propiedad de Delaunay de la malla.

*Suavizado e intercambios locales.* Freitag y Ollivier-Gooch
@freitag1997tetrahedral comparan intercambios de caras y de aristas con varias
formas de suavizado sobre mallas aleatorias y de aplicaciones. Observan que el
suavizado laplaciano puede producir mallas inválidas, con elementos invertidos, y
que el óptimo alcanzado por los intercambios es casi con seguridad local. Su primera
recomendación es no usar el criterio de la esfera vacía en la pasada final de
intercambios, porque rinde mal respecto de los ángulos extremos; proponen
comenzar con intercambios según ese criterio y continuar con intercambios que
maximicen el seno mínimo de los ángulos diedros @freitag1997tetrahedral. Este
resultado tiene una consecuencia directa para un algoritmo basado en circunsferas:
mejorar los ángulos diedros mediante intercambios puede alejar la malla de la
propiedad de Delaunay. Dassi et al. @dassi2017tetrahedralmeshimprovement combinan
un suavizado basado en ecuaciones diferenciales de movimiento de malla, que
mantiene la malla no singular si lo es inicialmente, con una búsqueda perezosa y
reversible de _flips_; reconocen que esta última es compleja y difícil de
paralelizar.

*Optimización basada en circuncentros.* La triangulación de Delaunay óptima (ODT)
minimiza una energía que alterna una triangulación de Delaunay global, que es la
conectividad óptima para esa energía, con la reubicación de cada vértice interior en el promedio de los circuncentros de sus tetraedros incidentes ponderado por volumen, tratando por separado los vértices de frontera @alliez2005variational. Tournois et al. @tournois2009interleaving intercalan este
paso con refinamiento de Delaunay por lotes, en el que el punto de Steiner de un
tetraedro malo es su circuncentro, y observan que, cuando los vecinos de un vértice
están sobre una esfera, el vértice se mueve al centro de esa esfera. En sus
experimentos, tras cien iteraciones su variante reduce los tetraedros con ángulos
diedros menores que $5 degree$ de 35, con refinamiento solo, y de 23, con Lloyd, a
cero, aunque reconocen que no pueden garantizar la ausencia total de _slivers_ y que
las cadenas de _slivers_ incidentes entre sí empeoran significativamente el
resultado @tournois2009interleaving. Du y Wang @du2003tetrahedral optimizan
globalmente una malla de Delaunay mediante iteraciones de Lloyd hasta obtener una
teselación de Voronoi centroidal restringida, seguida de intercambios locales, y
elevan la calidad mínima de la malla de un cubo de 0,012 a 0,237; Alliez et al.
sostienen, en cambio, que la energía de Voronoi centroidal no penaliza los
_slivers_ @alliez2005variational. Ninguno de estos métodos ofrece cotas teóricas
sobre la calidad de los tetraedros resultantes @alliez2005variational.

*Mejora en paralelo.* Las implementaciones paralelas de la mejora comparten un
patrón: procesar simultáneamente solo elementos o vértices independientes. D'Amato
y Vénere @damato2013cpugpu reconectan grupos de tetraedros cuyos vecindarios no se
intersectan, de modo que pueden procesarse sin bloqueos, ordenándolos para tratar
primero los peores elementos y aceptando solo cambios que no empeoren la peor
calidad; obtienen aceleraciones de 2,81 a 6,61 veces respecto de su versión secuencial, según la malla y la configuración, pero la asignación de grupos
y la actualización de estructuras, que permanecen secuenciales, se convierten en el
nuevo cuello de botella. Ströter et al. @stroter2022fastharmonictetrahedral
colorean los vértices en conjuntos independientes para paralelizar en GPU, sin
conflictos ni operaciones atómicas, una optimización armónica de la malla, y
resuelven los _flips_ en conflicto eligiendo el localmente más beneficioso; reportan
aceleraciones de hasta dos órdenes de magnitud respecto de una CPU secuencial y
observan que sus _flips_ preservan bien el porcentaje de tetraedros localmente de
Delaunay. Xi et al. @xi2021designing implementan en GPU un suavizado laplaciano que
solo acepta un movimiento si mejora la calidad local, con una aceleración máxima
de 22,6 veces sobre su versión secuencial, aunque reconocen que su variante de
múltiples bloques no garantiza la ausencia de conflictos de datos.
