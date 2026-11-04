= Métodos numéricos sobre mallas poliédricas <sec:ea-numericos>

La razón de ser de una malla poliédrica es un método numérico capaz de usarla.
Esta sección revisa los métodos que admiten celdas poliédricas generales, con
énfasis en el método de elementos virtuales, y examina con detalle las hipótesis
geométricas que imponen a las celdas, porque son ellas las que definen qué
significa que una malla generada por unión de tetraedros sea útil.

== Motivación: más allá de los elementos de forma fija

Los métodos de elementos finitos clásicos dependen de funciones de base definidas
explícitamente sobre elementos de forma fija. Beirão da Veiga et al.
@veiga2015virtual señalan que los elementos finitos poligonales, que construyen
funciones de base explícitas sobre polígonos, sufren serias dificultades en el
caso tridimensional y con elementos no convexos, y que el método de elementos
virtuales está libre de esos problemas. Las mallas poliédricas permiten, además,
estrategias de refinamiento adaptativo y de unión de mallas que serían imposibles
con tetraedros @frittelli2023virtualelementmethod, y la flexibilidad de forma
puede reducir el costo de ciertos problemas: un elemento finito conforme de clase
$C^1$ sobre tetraedros requiere 220 grados de libertad por elemento, mientras que un
método virtual de clase $C^1$ sobre poliedros usa cuatro por vértice
@veiga2019ac1virtual. Desde el punto de vista de la generación de mallas, la
motivación es que una celda poliédrica puede cubrir la región de varios tetraedros
y, con ello, reducir el número de elementos.

== El método de elementos virtuales

El VEM fue introducido como una generalización del método de elementos finitos a
mallas poligonales y poliédricas @veiga2012basic. Su rasgo distintivo es que las
funciones de base no se evalúan explícitamente dentro de cada elemento: se
definen como soluciones de problemas diferenciales locales y se denominan
_virtuales_ porque nunca se calculan. El método trabaja con proyecciones
polinomiales de estas funciones, computables a partir de los grados de libertad, y
añade un término de estabilización que garantiza la buena definición del esquema
@veiga2012basic @sorgente2022polyhedral. La guía de implementación de Beirão da
Veiga et al. @veiga2014hitchhiker admite elementos de forma muy general, convexos
o no, y destaca que para problemas de difusión o reacción-difusión en dos y tres
dimensiones el método no requiere fórmulas de cuadratura ni expresiones
aproximadas de las funciones de base; en tres dimensiones, el método se construye
usando en cada cara un espacio virtual bidimensional. Los autores resumen su
actitud hacia la geometría con una frase elocuente: casi todo poliedro será
aceptable, salvo los que provengan de la mente de un matemático dispuesto a
construir contraejemplos @veiga2014hitchhiker.

El método se ha extendido en múltiples direcciones relevantes para mallas
tridimensionales. Gain et al. @gain2014virtual lo formulan para elasticidad lineal
sobre poliedros arbitrarios y señalan que su construcción no requiere convexidad.
Beirão da Veiga et al. @veiga2017high presentan la primera validación numérica
sistemática del VEM tridimensional de orden alto, con grados de uno a cinco, y
observan que hasta entonces los experimentos tridimensionales se limitaban al orden
más bajo. Otros trabajos lo extienden a problemas no lineales e inelásticos,
evaluando la ley constitutiva una vez por elemento @veiga2015virtual; a problemas
de cuarto orden con un espacio de clase $C^1$ @veiga2019ac1virtual; a ecuaciones
acopladas entre el volumen y su superficie en dominios curvos
@frittelli2023virtualelementmethod; a formulaciones de Stokes robustas respecto de
la presión @veiga2022arbitraryorderpressure; a problemas de autovalores
@certk2018thevirtualelement; y a estimaciones de error a posteriori que permiten
refinamiento adaptativo con nodos colgantes y caras coplanares consecutivas sin
posprocesar la malla @cangiani2017aposteriorierror.

== Otros métodos politopales

El VEM no es el único método capaz de operar sobre poliedros generales. Los
métodos esqueléticos discontinuos, entre ellos los métodos _Hybrid High-Order_
(HHO), usan incógnitas en celdas y caras, admiten órdenes arbitrarios sobre mallas
politopales y permiten eliminar las incógnitas interiores mediante condensación
estática @pietro2017discontinuousskeletalgradient. Boffi y Di Pietro
@boffi2016unifiedformulationand muestran que HHO, los volúmenes finitos híbridos,
las diferencias finitas miméticas, el VEM mixto y los elementos de Raviart–Thomas y
Crouzeix–Raviart pueden expresarse en una formulación unificada. El complejo
discreto de De Rham extiende estas ideas a espacios compatibles de orden
arbitrario @pietro2021anarbitraryorder, el método de Galerkin débil define un
gradiente débil discreto sobre mallas politopales con conservación local de masa
@mu2012weakgalerkinfinite, y los métodos de Galerkin discontinuo con penalización
interior operan sobre polígonos y poliedros con caras degeneradas
@dong2018discontinuousgalerkinmethods. La aglomeración de elementos es, además, la
base de métodos multinivel para estos esquemas: las mallas gruesas se obtienen
uniendo elementos de la malla fina @antonietti2014multigridalgorithmsfor
@antonietti2023agglomeration2 @pan2021agglomeration.

Desde el punto de vista de la implementación, Cicuttin et al.
@cicuttin2017implementationofdiscontinuous describen una biblioteca genérica para
HHO sobre politopos no necesariamente convexos con caras planas, en la que las
integrales sobre politopos estrellados respecto de su baricentro se calculan
dividiéndolos en símplices; observan que la forma de los elementos influye en el
tiempo de cálculo justamente por esa subdivisión, y que no pudieron ejecutar el
_solver_ sobre las mallas poliédricas por restricciones de memoria. En la misma
línea, Pan y Persson @pan2021agglomeration integran sobre elementos aglomerados
sumando las contribuciones de los subelementos originales, sin costo adicional de
cuadratura.

== Hipótesis geométricas sobre las celdas

La flexibilidad de estos métodos respecto de la forma de las celdas no es
irrestricta. La @tab:ea-hipotesis resume las hipótesis que imponen los trabajos
revisados. En el trabajo fundacional del VEM, el análisis de error supone que cada
elemento es un polígono simple (A0.1), que existe $gamma > 0$ tal que cada
elemento $K$ es estrellado respecto de una bola de radio mayor o igual a $gamma
h_K$, donde $h_K$ es su diámetro (A0.2), y que la distancia entre dos vértices
cualesquiera de $K$ es al menos $gamma h_K$ (A0.3) @veiga2012basic. Los propios
autores advierten que la condición de estrellamiento puede debilitarse a la de ser
unión de un número finito y uniformemente acotado de dominios estrellados, cada
uno de los cuales satisface A0.2 @veiga2012basic. En tres dimensiones, las
hipótesis estándar exigen que cada poliedro sea estrellado respecto de una bola de
radio comparable a su diámetro, que cada cara sea estrellada respecto de un disco
de radio comparable al de la cara, y que las aristas y caras no sean pequeñas
respecto del poliedro @veiga2014hitchhiker @veiga2017high @veiga2019ac1virtual.
Estas condiciones implican que el número de aristas y caras de cada elemento está
uniformemente acotado @certk2018thevirtualelement @sorgente2022polyhedral. Varios
trabajos suponen explícitamente caras planas
@certk2018thevirtualelement @pietro2021anarbitraryorder
@cicuttin2017implementationofdiscontinuous.

#figure(
  {
    set text(size: 9.5pt)
    set par(justify: false, first-line-indent: 0pt)
    table(
      columns: (1.45fr, 2.4fr, 1.15fr),
      align: left,
      inset: 4.5pt,
      stroke: 0.5pt,
      table.header([*Trabajo*], [*Hipótesis principales sobre las celdas*], [*Evidencia numérica*]),
      [VEM fundacional @veiga2012basic], [Polígono simple; estrellado respecto de una bola de radio $gamma h_K$; vértices separados al menos $gamma h_K$], [Sin experimentos],
      [VEM 3D, guía y orden alto @veiga2014hitchhiker @veiga2017high], [Celdas y caras estrelladas respecto de bolas y discos; aristas no pequeñas], [Voronoi aleatorio, CVT y estructurado (3D)],
      [Brenner y Sung @brenner2018virtual], [Estrellado respecto de una bola; número acotado de caras; caras regulares en 2D; admite caras pequeñas], [Sin experimentos nuevos],
      [Huang y Yu @huang2022some], [Estrellado; caras con triangulaciones virtuales regulares y cuasiuniformes], [Tetraedros y CVT (orden 1)],
      [Cao y Chen @cao2018anisotropicerrorestimates @cao2019anisotropicerrorestimates], [Número acotado de aristas o caras; condiciones locales de altura; subconjunto convexo y envolventes convexas con solapamiento acotado], [Sin experimentos],
      [Cangiani et al. @cangiani2017aposteriorierror], [Estrellado respecto de una bola; extensible a uniones de subelementos que la cumplen], [2D, incluye celdas no convexas],
      [Sorgente et al. @sorgente2022polyhedral], [Hipótesis G1–G3 como condiciones suficientes], [Tetraedros, hexaedros, Voronoi y pares de tetraedros (3D)],
      [HHO y DDR @boffi2016unifiedformulationand @pietro2021anarbitraryorder], [Submalla simplicial de buena forma, con símplices de tamaño comparable a la celda; caras planas], [Tetraedros, cubos y Voronoi (3D)],
      [DG con aglomeración @antonietti2014multigridalgorithmsfor @dong2018discontinuousgalerkinmethods], [Cubrimiento por símplices; sin cota sobre el número ni el tamaño de las caras], [2D, incluye celdas aglomeradas],
    )
  },
  caption: [Hipótesis geométricas sobre las celdas en los métodos politopales
    revisados, y tipo de mallas usadas en su validación.],
) <tab:ea-hipotesis>

Los métodos esqueléticos y el complejo de De Rham formulan la regularidad de otro
modo: exigen que la malla admita una submalla simplicial de buena forma en la que
cada celda se divide en símplices de tamaño uniformemente comparable al de la celda
@boffi2016unifiedformulationand @pietro2021anarbitraryorder. Esta formulación es
particularmente pertinente para esta tesis, porque una celda obtenida por unión de
tetraedros trae consigo, por construcción, una subdivisión simplicial. En el mismo
sentido, Beirão da Veiga et al. observan que, bajo sus hipótesis, cada poliedro es
la unión de tetraedros de buena forma que comparten un vértice central
@veiga2019ac1virtual.

== Relajación de las hipótesis y evidencia de robustez

Una línea de trabajo teórico ha buscado debilitar estas condiciones. Brenner y Sung
@brenner2018virtual demuestran estimaciones de error para mallas con aristas o caras
pequeñas: en tres dimensiones, si cada poliedro es estrellado respecto de una bola
de diámetro comparable al suyo, su número de caras está acotado y las caras
satisfacen las condiciones bidimensionales, las cotas son óptimas salvo un factor
logarítmico que depende de la razón entre la arista más larga y la más corta. Huang
y Yu @huang2022some obtienen desigualdades inversas, equivalencia de normas y
estimaciones de interpolación para poliedros estrellados cuyas caras admiten
triangulaciones virtuales regulares y cuasiuniformes. Cao y Chen
@cao2018anisotropicerrorestimates @cao2019anisotropicerrorestimates reemplazan el
estrellamiento uniforme por condiciones locales: en su análisis bidimensional, el
estrellamiento se requiere para la aproximación y la ausencia de aristas cortas
para la estabilidad, y la convexidad de la envolvente convexa del elemento permite
prescindir de su regularidad de forma; en tres dimensiones admiten caras pequeñas o
anisotrópicas siempre que el elemento sea isotrópico en un sentido que se expresa
mediante un subconjunto convexo de tamaño comparable. Cangiani et al.
@cangiani2017aposteriorierror extienden su análisis a elementos que son unión
finita y simplemente conexa de subelementos que satisfacen las hipótesis, y Antonietti
et al. @antonietti2023agglomeration2 suponen que cada elemento aglomerado es unión
de un número acotado de dominios estrellados. Para los métodos de Galerkin
discontinuo, las hipótesis de Antonietti et al. @antonietti2014multigridalgorithmsfor
no restringen el número ni la medida de las caras, condición necesaria porque, al
aglomerar, el número de caras crece y su medida puede degenerar.

La evidencia numérica es, en general, más favorable que la teoría. Beirão da Veiga
et al. @veiga2017high obtienen las tasas de convergencia teóricas para todos los
órdenes en mallas de Voronoi aleatorias con poliedros estirados, aunque con errores
mayores que en mallas estructuradas. Dassi y Mascotto @dassi2018exploring no imponen
hipótesis geométricas y prueban el método con elementos que colapsan; identifican dos causas de curvas de convergencia subóptimas o erróneas: el mal condicionamiento de la matriz de rigidez, que hace crecer el error en la prueba de parche y depende de la base elegida para los momentos, y elecciones poco adecuadas de la estabilización. Beirão da Veiga et al. @veiga2022arbitraryorderpressure observan que
el deterioro de la regularidad de una familia de mallas de Voronoi no parece afectar
sus esquemas, y usan bases ortonormalizadas para mejorar el condicionamiento en
presencia de caras o elementos alargados. Sorgente et al. @sorgente2022polyhedral
construyen familias de mallas tetraédricas, hexaédricas, de Voronoi y poliédricas,
estas últimas agregando pares de tetraedros vecinos, lo que produce celdas no
convexas pero estrelladas; todas las familias cumplen G1 y varias violan G2 o G3.
Observan que el VEM sigue convergiendo en mallas de Voronoi aleatorias que violan
G2 y G3, pero se deteriora en mallas fuertemente anisotrópicas que violan G2 de
manera severa, y concluyen que las restricciones actuales son probablemente más
severas de lo necesario. El estrellamiento mismo también parece admitir
excepciones: en los conjuntos bidimensionales optimizados por aglomeración de
Sorgente et al. @sorgente2024mesh, una cantidad significativa de elementos no es
convexa o ni siquiera estrellada, y aun así se preservan las tasas de convergencia.
Debe notarse, sin embargo, que buena parte de la evidencia que relaja las
hipótesis es bidimensional o de orden bajo
@cao2018anisotropicerrorestimates @cangiani2017aposteriorierror
@antonietti2023agglomeration2.

== Implicancias para esta tesis

La revisión muestra que muchos de los análisis citados suponen que cada celda es estrellada respecto de una bola de tamaño comparable a su diámetro, mientras que otros admiten celdas que son unión de un número acotado de subdominios estrellados @veiga2012basic @cangiani2017aposteriorierror @antonietti2023agglomeration2. Si un poliedro es estrellado respecto de una bola, todos los puntos de esa bola pertenecen a su _kernel_, el conjunto de puntos desde los que todo el poliedro es visible, de modo que el _kernel_ es no vacío y tiene volumen positivo. Para el primer grupo de análisis, la no vacuidad del _kernel_ es, por tanto, una condición necesaria, aunque no suficiente; una medida más fiel exigiría comparar el tamaño de la mayor bola contenida en el _kernel_ con el diámetro de la celda. Para el segundo grupo, una celda puede tener _kernel_ vacío y aun así satisfacer las hipótesis si se descompone en pocos subdominios estrellados, de modo que el _kernel_ es una medida conservadora. Esta observación motiva el uso del _kernel_ como métrica central en este
trabajo, complementado con medidas de forma.

La revisión sugiere además tres consideraciones específicas para celdas formadas
por unión de tetraedros. Primero, estas celdas traen una subdivisión simplicial, lo
que encaja con las formulaciones que exigen una submalla simplicial de buena forma
o que admiten uniones de subelementos, siempre que los tetraedros sean de buena
forma y de tamaño comparable a la celda @boffi2016unifiedformulationand
@cangiani2017aposteriorierror; esa misma subdivisión permite integrar sin costo
adicional @pan2021agglomeration. Segundo, la frontera entre dos celdas es una unión
de triángulos que no necesariamente forman una cara plana, y tratar cada triángulo
como una cara multiplica el número de caras pequeñas; algunos análisis admiten caras coplanares consecutivas @cangiani2017aposteriorierror o un número no acotado de caras pequeñas, representando las interfaces mediante triángulos coplanares @antonietti2014multigridalgorithmsfor, lo que sugiere tratar cada triángulo, o cada grupo de triángulos coplanares, como una cara plana; la evidencia tridimensional al respecto es escasa. Tercero, la medida basada
en la envolvente convexa tiene un respaldo teórico en los análisis de Cao y Chen,
que usan subconjuntos convexos y envolventes convexas para reemplazar el
estrellamiento uniforme @cao2018anisotropicerrorestimates
@cao2019anisotropicerrorestimates.
