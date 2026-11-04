// Se incluye bajo #capitulo con heading(offset: 1).
// Las fuentes y sus líneas se registran junto a cada grupo de afirmaciones.
#import "pendiente.typ": pendiente

La propuesta de esta tesis se sitúa dentro de la familia Polylla, cuyo principio
es construir celdas mediante la unión de elementos de una malla simplicial
preexistente. En dos dimensiones, las regiones se definen a partir de aristas
terminales; en la extensión basada en caras, se agrupan tetraedros según una
noción de cara terminal @polylla @salinasfernandez2025exploring. El panorama de
la @sec:ea-poliedros permite ubicar esta estrategia entre los métodos indirectos.
Aquí se desarrolla su mecanismo: cómo se delimitan las regiones, cómo se extrae
su frontera y qué problemas resuelve la reparación. El propósito es distinguir
las propiedades que estos procedimientos establecen de las que permanecen como
preguntas de investigación para el algoritmo de cavidades.
// P001:184-234; P005:29-120.

= Polylla en dos dimensiones <sec:ta-polylla-2d>

== Caminos de propagación y regiones terminales <sec:ta-lepp>

Sea $cal(T)$ una triangulación y sea $ell(t)$ la arista seleccionada como la más
larga del triángulo $t$. El camino de propagación de la arista más larga
(_longest-edge propagation path_, Lepp) de un triángulo $t_0$ es una sucesión de
triángulos vecinos: cada paso cruza $ell(t_i)$ para alcanzar el siguiente
triángulo. En el caso interior, el camino termina al alcanzar dos triángulos que
comparten su arista más larga. Esa arista es una _arista terminal_ y ambos
triángulos son terminales @polylla. Por tanto, la propagación no selecciona un
vecino cualquiera: la elección de salida depende del triángulo actualmente
visitado.
// P001:184-195.

La _región de arista terminal_ asociada a una arista $e$ reúne todos los
triángulos cuyos Lepp terminan en $e$. Con una notación de conjuntos, la
definición del artículo se puede expresar como
$ R_e = union_(t in cal(T): "terminal"("Lepp"(t)) = e) t. $
Varios caminos pueden converger a la misma arista; su unión define una sola
región. Las regiones cubren el dominio sin superponerse y están delimitadas por
aristas frontera. Cuando su contorno incluye aristas del borde del dominio, el
artículo distingue una región terminal de borde @polylla.
// P001:213-234.

Para una arista interior compartida por $t_a$ y $t_b$, el etiquetado distingue
tres casos: es terminal si ambos triángulos la seleccionan; es frontera si
ninguno la selecciona; y es interna si la selecciona exactamente uno. Las
aristas del borde del dominio se tratan como frontera. Cuando existen longitudes
iguales, el método escoge un orden entre ellas para disponer de una única arista
seleccionada por triángulo @polylla. Conviene separar esta elección local de la
construcción de la región: la primera proporciona las etiquetas; la segunda
recupera los elementos conectados por ellas.
El artículo advierte un caso degenerado: con triángulos equiláteros y ciertas
selecciones de aristas iguales puede aparecer una región sin arista terminal.
Propone corregirla seleccionando una misma arista como mayor en sus dos
triángulos incidentes @polylla. Por ello, el desempate local no debe entenderse
como una garantía suficiente para evitar toda degeneración.
// P001:190-216,298-309,417-427.

== Etiquetado y construcción de polígonos <sec:ta-construccion-2d>

Polylla organiza el proceso en tres fases: etiquetado, recorrido y reparación.
El etiquetado comienza por almacenar la arista más larga de cada triángulo.
Luego recorre las aristas para marcar las fronteras y reconocer las terminales.
Para cada terminal interior se guarda como semilla el triángulo incidente de
menor índice; para una terminal de borde se guarda su único triángulo. Esta
semilla permite iniciar la construcción del polígono correspondiente sin
necesidad de construir explícitamente todos los Lepp @polylla.
// P001:324-334,417-434.

Durante el recorrido se navega entre triángulos de la región y se almacenan las
aristas frontera como una polilínea cerrada, con sus vértices en orden
antihorario @polylla. La @fig:pol del capítulo anterior ilustra la convergencia
de los caminos; aquí interesa la consecuencia operativa: el etiquetado permite
extraer el contorno a partir de una semilla. La salida de esta fase todavía
puede contener polígonos no simples, por lo que no constituye por sí sola el
resultado definitivo @polylla.
// P001:328-334,430-434,502-514.

== Aristas barrera y reparación <sec:ta-reparacion-2d>

Una región puede contener aristas etiquetadas como frontera en su interior. El
artículo las denomina _aristas barrera_: aunque pertenecen al sistema de
fronteras, no forman parte del contorno exterior de la región. Su presencia
origina polígonos no simples. Una _punta de barrera_ es un extremo de una arista
barrera que no es compartido por otra arista barrera o frontera @polylla. En
consecuencia, «no simple» describe aquí un problema específico de la
representación y de la partición, y no debe emplearse como sinónimo de «no
convexo».
// P001:225-226,246-261.

La reparación divide estos polígonos aprovechando aristas ya existentes. Para
cada punta se ordenan las aristas internas incidentes dentro de la región y se
elige la central; cuando hay dos candidatas centrales, se escoge una de ellas.
La arista seleccionada se convierte en frontera y sus dos triángulos incidentes
se incorporan a una lista de nuevas semillas. Después se repite el recorrido
para construir los polígonos resultantes. Un arreglo de marcas evita que varias
semillas reconstruyan el mismo polígono @polylla.
// P001:568-591.

El objetivo de esta operación es conservar los vértices iniciales. El artículo
descarta simplemente borrar las barreras porque ello exigiría eliminar sus
extremos, que considera relevantes para la entrada. Además, la selección de
aristas centrales busca producir piezas de tamaño similar @polylla. La
reparación es, por ello, una subdivisión de la región inicial; su finalidad no
es imponer convexidad a todas las piezas.
// P001:553-579.

#pendiente[Figura: representar una región bidimensional con una arista barrera,
  su punta y la arista interna elegida para dividirla. Preparar un esquema propio
  basado en las figuras 4 y 11 de P001, con etiquetas en español y referencia al
  artículo; comprobar que se distingan frontera exterior y barrera interior.]

= GPolylla y la representación compacta <sec:ta-gpolylla>

La adaptación a GPU conserva las tres fases y utiliza una representación
indexada de la triangulación. Cuatro arreglos almacenan coordenadas, vértices de
cada triángulo, vecinos y un triángulo incidente por vértice. Este último es
opcional y acelera la reparación. Los polígonos de salida se almacenan mediante
un arreglo que contiene sus longitudes y secuencias de vértices, acompañado por
otro con la posición de inicio de cada polígono @gpolylla. Estos detalles
complementan la discusión general de paralelismo en la @sec:ea-paralelo.
// P002:95-146.

El etiquetado y el recorrido aprovechan la independencia de los elementos y de
las regiones; la reparación requiere repetir subdivisiones hasta absorber las
puntas de barrera en las fronteras. El artículo emplea operaciones atómicas
para gestionar el almacenamiento concurrente de los polígonos @gpolylla. La
existencia de regiones independientes facilita distribuir el trabajo, pero la
reparación exige un tratamiento distinto al de las fases iniciales.
// P002:78-85,149-174.

En sus pruebas, los autores comparan versiones secuencial, paralela y mixta con
triangulaciones de uno a ocho millones de puntos. La versión mixta ejecuta
etiquetado y recorrido en GPU, y reparación secuencial; cada prueba se repite
cinco veces. El etiquetado es la fase de mayor tiempo y el recorrido la de menor
tiempo. La reparación paralela no presenta una ventaja significativa frente a
la secuencial para esos casos. Aunque los resultados muestran aceleración, los
autores indican que necesitan más experimentos antes de calcular el
_speedup_ @gpolylla. Por ello, este antecedente respalda la viabilidad del
paralelismo bidimensional, pero no proporciona un factor definitivo de mejora
transferible a tres dimensiones.
// P002:441-475,504-514,537-546.

Una segunda línea de trabajo aborda la representación compacta. La versión de
Polylla basada en la estructura sucinta _pemb_ reduce la representación de la
conectividad a operaciones sobre tres vectores de bits estáticos. El artículo
utiliza siete de las diecisiete consultas disponibles y deja como trabajo futuro
explorar operaciones adicionales, como inserción de vértices y cambios de
aristas; también plantea el uso futuro en GPU
@salinasfernandez2024generation. Este antecedente se distingue de GPolylla:
estudia otra representación y no debe interpretarse como evidencia de que esa
representación compacta ya esté ejecutándose en GPU.
// P004:862-878.

= Extensión tridimensional <sec:ta-polylla-3d>

== Alcance de Face y Edge <sec:ta-face-edge>

La distinción entre una extensión basada en aristas y otra basada en caras
requiere cautela documental. P001 anuncia como trabajo en desarrollo una
extensión tridimensional mediante regiones de arista terminal @polylla. Sin
embargo, el texto local de P003, correspondiente a la versión v2, presenta un
algoritmo de regiones de cara terminal @salinasfernandez20233d. Por ello, se
desarrolla a continuación la variante Face con el respaldo publicado de P005,
sin extrapolar a Edge las definiciones bidimensionales ni los pasos de Face.
// P001:1010-1014; P003:1-15,81-126.

#pendiente[Polylla 3D Edge: obtener el texto primario de la variante basada en
  regiones de arista terminal, comprobando si corresponde a la versión anterior
  de P003 o al trabajo de Magdalena Álvarez citado en la propuesta. Incorporar
  una copia local y verificar la definición de camino entre tetraedros, las
  reglas de pertenencia a una región, las fases de construcción y reparación y
  sus resultados. El P003 local v2 no permite reconstruir esos pasos con rigor.]

== Cara terminal y camino de propagación <sec:ta-lfpp>

En Face, un _criterio de unión_ ordena las caras de cada tetraedro y selecciona
una sola como mayor; los empates se resuelven escogiendo una de ellas. La palabra
«mayor» depende del criterio elegido. Una cara interior es _terminal_ cuando es
la seleccionada por ambos tetraedros incidentes. Si es la mayor de un tetraedro
y pertenece al borde, se denomina cara terminal de borde
@salinasfernandez2025exploring.
// P005:36-61.

El _camino de propagación de la cara mayor_ (_largest-face propagation path_,
Lfpp) parte de un tetraedro y pasa sucesivamente al vecino a través de la cara
mayor del tetraedro actual. La región de cara terminal asociada a $f$ se define
como la unión de los tetraedros cuyos caminos terminan en esa misma cara:
$ R_f = union_(t in cal(T): "terminal"("Lfpp"(t)) = f) t. $
Esta expresión adapta a tres dimensiones la notación de la @sec:ta-lepp. P005
establece que las regiones de cara terminal no se superponen
@salinasfernandez2025exploring. La selección de una sola cara por tetraedro es,
por tanto, parte de la definición del método y no un detalle de presentación.
// P005:62-70,97-102.

El etiquetado operativo considera frontera una cara que no es seleccionada por
ninguno de los dos tetraedros incidentes, así como toda cara del borde del
dominio. Las caras restantes permiten recorrer los tetraedros del agregado. Al
igual que en dos dimensiones, una cara marcada como frontera puede quedar
dentro de la región: se denomina _cara barrera_. Una _punta de barrera_ es ahora
una arista incidente a una sola cara frontera, mientras las otras caras
incidentes son internas @salinasfernandez2025exploring. El cambio de dimensión
transforma así las puntas desde vértices en aristas.
// P005:103-113,145-155.

== Etiquetado, recorrido y reparación de Face <sec:ta-pasos-face>

La primera fase calcula las caras seleccionadas por el criterio, identifica las
terminales y escoge un tetraedro semilla por región. También construye un vector
de bits de caras frontera. La salida auxiliar consiste en ese vector y un
arreglo de semillas, que se emplean en las fases siguientes
@salinasfernandez2025exploring.
// P005:127-155.

La segunda fase realiza una búsqueda en profundidad desde cada semilla. El
recorrido avanza a través de las caras que no son frontera y registra las caras
frontera como parte de la representación del poliedro. P005 representa la
salida como una lista de poliedros, cada uno descrito por una lista de caras.
Si una cara aparece repetida en la lista de un poliedro, el método reconoce una
barrera y envía el elemento a reparación @salinasfernandez2025exploring.
// P005:121-125,160-172,188-193.

La tercera fase busca las aristas que son puntas de barrera. Para una arista
candidata, se cuenta cuántas caras frontera son incidentes a ella; una sola
incidencia identifica una punta en la configuración considerada. Se ordenan
entonces las caras internas alrededor de esa arista, partiendo de la cara
barrera, y se convierte la cara interna central en una nueva frontera. Los dos
tetraedros incidentes a esa cara se guardan como semillas para volver a ejecutar
el recorrido. Un arreglo de uso evita reconstruir varias veces un mismo
poliedro @salinasfernandez2025exploring.
// P005:194-245.

Este procedimiento separa dos decisiones: la formación inicial de regiones por
propagación y su subdivisión para resolver barreras. En particular, el criterio
que seleccionó las caras no se sustituye, durante la reparación descrita, por
una prueba del kernel. La reparación de P005 se formula en términos de
incidencias, nuevas fronteras y recorridos, mientras la utilidad de los elementos
para simulaciones permanece como trabajo futuro
@salinasfernandez2025exploring.
// P005:194-245,300-319. Interpretación del alcance del procedimiento.

#pendiente[Figura: construir un esquema de Face que muestre una cara terminal,
  los tetraedros de su región y una cara barrera; añadir una segunda vista con
  una punta y la nueva cara frontera elegida durante la reparación. Basar las
  incidencias en las definiciones y el procedimiento de P005, secciones 2 y 3.]

= Criterios de unión y resultados publicados <sec:ta-resultados>

== Criterios investigados <sec:ta-criterios>

P005 estudia dos métricas para seleccionar la cara mayor: el área de la cara y
el radio de su circunferencia inscrita. En ambos casos se selecciona el máximo
de las cuatro caras @salinasfernandez2025exploring. El radio inscrito se
calcula sobre una cara triangular; no corresponde al radio de una esfera del
tetraedro. Esta distinción importa al introducir la propuesta de cavidades,
cuya definición en la introducción utiliza la circunsfera del tetraedro semilla.
// P005:36-52. Última oración: alcance definido en main.typ.

Ambos criterios seleccionan una interfaz local de unión. Como interpretación
del procedimiento, escoger la mayor cara según una métrica no equivale a
optimizar directamente la forma de toda la región resultante. Los propios
autores concluyen que las estrategias de unión deberían incorporar criterios
de calidad del poliedro generado @salinasfernandez2025exploring.
// P005:300-315.

== Resultados bidimensionales y alcance de su transferencia <sec:ta-resultados-2d>

En P001 se estudian conjuntos de puntos aleatorios dentro de un cuadrado,
variando entre cien y un millón de puntos. Para entradas de más de diez mil
puntos, el artículo informa promedios de 6,5 triángulos por polígono y 8,5
vértices por polígono @polylla. Sus simulaciones preliminares comparan mallas
Polylla y de Voronoi y encuentran precisión y costo computacional similares
para la solución con VEM @polylla. Estos resultados corresponden a las pruebas
bidimensionales del artículo; no resuelven la evaluación de los poliedros de
Face.
// P001:775-787,1002-1007.

En conjunto, estos antecedentes motivan conservar la separación entre
construcción, reparación y evaluación. Que la salida tenga menos elementos es
una propiedad distinta de su comportamiento numérico, y que GPolylla acelere
algunas fases no establece la escalabilidad del algoritmo tridimensional de
esta tesis. Ambas comparaciones deberán realizarse bajo un protocolo propio.

== Experimentos de Face <sec:ta-resultados-face>

P005 evalúa cuatro tipos de malla tetraédrica en un cubo, denominados Random,
Poisson, Grid y Quality. Cada tipo considera tamaños de 500, 1.000, 5.000,
10.000 y 50.000 vértices. El texto resume una unión de aproximadamente tres
tetraedros por poliedro, una reducción del número de elementos cercana al
70~% y una proporción próxima a un quinto de poliedros con caras barrera
@salinasfernandez2025exploring. Son resultados preliminares sobre esas entradas,
no garantías del algoritmo para cualquier dominio.
// P005:251-265.

La @tab:ta-face recoge los valores totales de la tabla publicada para evitar
reemplazar la comparación por un único promedio redondeado. La fila de barreras
se conserva como estadística del artículo: no representa una medición del
kernel ni permite deducir cuántas celdas son estrelladas.
// P005:283-294.

#figure(
  table(
    columns: (2fr, 1fr, 1fr),
    inset: 6pt,
    align: left,
    table.header([*Indicador*], [*Radio inscrito*], [*Área máxima*]),
    [Reducción de elementos], [67,4~%], [69,5~%],
    [Tetraedros por poliedro], [3,0], [3,0],
    [Poliedros con barreras], [21,0~%], [20,1~%],
  ),
  caption: [Valores totales reportados en la tabla 1 de
    @salinasfernandez2025exploring para los dos criterios de Face.],
) <tab:ta-face>

El artículo concluye que los resultados son casi independientes del criterio
escogido y propone mejorar la definición de región con estrategias que
consideren la calidad del agregado. También señala que las celdas están lejos
de ser convexas y que aún debe evaluarse su utilidad para simulaciones con VEM
@salinasfernandez2025exploring. Por ello, el balance experimental ofrece una
referencia de reducción y composición de las celdas, pero deja abierta su
adecuación numérica.
// P005:19-24,300-319.

= Limitaciones y motivación del algoritmo de cavidades <sec:ta-motivacion>

La distinción de la @sec:ea-calidad entre convexidad y estrellamiento es
fundamental para interpretar estos resultados. P003 v2 destaca la relevancia de
que el kernel no sea vacío en las celdas destinadas al VEM
@salinasfernandez20233d.
#pendiente[Bibliografía de P003: la entrada `salinasfernandez20233d` describe
  la v1 (2023, dos autores), pero el contenido citado corresponde a la v2
  (arXiv:2310.03665v2, 2025, tres autores). Actualizar `literatura/papers.json`
  para identificar la versión consultada y regenerar `references.bib`.]
Sin embargo, los resultados de P005 aquí revisados
cuantifican reducción, tamaño de los agregados y barreras; no presentan una
medición del porcentaje de poliedros con kernel vacío. Por tanto, que las
celdas sean no convexas no permite concluir que carezcan de kernel, y la
frecuencia de caras barrera tampoco sustituye esa medición.
// P003:63-74; P005:251-319. Distinción conceptual: sec:ea-calidad.

#pendiente[Diagnóstico de kernel en Polylla 3D: localizar el estudio primario al
  que alude la introducción cuando menciona ausencia de kernel. Verificar en
  él la variante evaluada, las entradas, el procedimiento de cálculo y los
  resultados exactos. Si no hay resultados publicados verificables, mantenerlo
  como pregunta abierta y diseñar, para ejecución posterior por el autor, una
  evaluación de Face y Edge que mida fracción de kernels no vacíos y razón
  entre volumen del kernel y volumen de la celda, distinguiendo las mallas
  antes y después de reparar barreras.]

El límite que se desprende de estos antecedentes es preciso: la unión por una
cara seleccionada y la reparación de barreras no constituyen una validación de
la calidad geométrica o numérica del agregado completo. Esta lectura coincide
con la necesidad de incorporar calidad y realizar simulaciones que explicita
P005 @salinasfernandez2025exploring. No se dispone aquí de evidencia para
afirmar que Face sea inutilizable, ni para atribuir a las cavidades una mejora
ya demostrada.
// P005:194-245,300-319. Síntesis del alcance de la evidencia.

En esta tesis se plantea cambiar la definición de la región candidata,
utilizando la circunsfera de un tetraedro semilla como referencia para las
cavidades. El capítulo siguiente deberá precisar la pertenencia a esas regiones,
la selección de semillas y la resolución de conflictos entre candidatos. La
motivación no es únicamente reducir primitivas: es investigar si otra regla de
agrupación permite obtener celdas cuya calidad pueda verificarse explícitamente.
La existencia de kernel, la reducción de elementos, el tiempo y la memoria
permanecen como dimensiones de evaluación, de acuerdo con las preguntas de
investigación de la introducción. Se trata de una propuesta que debe contrastarse,
no de un resultado que pueda inferirse de los antecedentes de Polylla.

// Propuesta de esta tesis y dimensiones de evaluación: main.typ:143-147,156-167,175-190.
