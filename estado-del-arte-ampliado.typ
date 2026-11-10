#import "final.typ": capitulo, conf, start-doc
#import "my-metadata.typ": metadata

#show: conf.with(metadata: metadata)
#show: start-doc
#counter(heading).update(1)

#capitulo(title: "Estado del arte", label: <cap:estado-arte>)[




La generación de mallas volumétricas articula tres problemas relacionados, pero
distintos: representar con fidelidad el dominio de entrada, construir una
partición válida y producir elementos adecuados para la simulación numérica. En
el caso de esta tesis se añade un cuarto requisito: la transformación debe ser
indirecta, pues parte de una tetraedralización ya disponible y busca reducirla a
una malla poliédrica. Por ello, el estado del arte se organiza en torno a cinco
ejes: generación tetraédrica robusta, generación poliédrica, aglomeración de
tetraedros, calidad para el método de elementos virtuales y paralelización de
operaciones sobre cavidades.

== Generación tetraédrica como etapa de entrada

=== Qué aporta y qué no aporta una tetraedralización

Una tetraedralización de un dominio tridimensional es una partición en tetraedros con interiores disjuntos y caras compatibles. Su utilidad no se agota en disponer de elementos de cuatro vértices: cada tetraedro induce cuatro caras, cada cara interior identifica una relación de vecindad, y las caras con una sola incidencia representan la frontera del dominio. En esta tesis, esas relaciones son la materia prima de la aglomeración. En una tetraedralización conforme y válida, la unión de tetraedros conectados por caras conserva cobertura de volumen, pero puede producir una frontera geométricamente difícil y no garantiza un poliedro admisible para una formulación numérica concreta. La calidad debe volver a examinarse después de cada unión @si2015tetgen @sorgente2023survey.

La condición de Delaunay se formula para un conjunto de puntos: la circunsfera abierta de cada tetraedro no contiene vértices de la triangulación. En posiciones cosféricas pueden existir varias tetraedralizaciones equivalentes. En un dominio con restricciones geométricas, la recuperación de segmentos y facetas puede requerir operaciones adicionales y la condición global de esfera vacía puede ceder ante las restricciones. Por tanto, «malla de Delaunay» no describe por sí sola ni la fidelidad del borde ni la calidad de cada tetraedro. TetGen documenta precisamente la diferencia entre tetraedralización, recuperación de restricciones y refinamiento de calidad @si2015tetgen. Esta distinción importa al fijar las precondiciones del algoritmo de cavidades: se necesita una malla conforme y relaciones de incidencia fiables; la propiedad de Delaunay es pertinente para interpretar circunsferas, pero la regla de agrupación debe especificarse incluso si algunas celdas provienen de etapas restringidas.

La mala forma de un tetraedro no se captura mediante un solo número. La razón entre circunradio y arista más corta es útil en refinamiento, pero puede aceptar tetraedros casi planos cuyos vértices están próximos a un círculo, conocidos como _slivers_. La presencia de estas configuraciones explica las etapas de optimización posteriores al refinamiento y aconseja registrar la calidad de la entrada al comparar resultados de aglomeración @cheng2000sliver @si2015tetgen. Si un poliedro final tiene una cara pequeña o un núcleo reducido, será necesario distinguir si procede de la regla de unión o de una zona ya deteriorada en la entrada.

=== Tres prioridades de generación: restricciones, rasgos y robustez

TetGen parte de una descripción por complejo lineal por partes y combina construcción de Delaunay, recuperación de restricciones y refinamiento según criterios definidos por el usuario @si2015tetgen. La herramienta expone una ruta reproducible hacia entradas tetraédricas y permite variar tamaños y calidades para estudiar sensibilidad. El costo conceptual para esta tesis es que sus garantías de entrada pertenecen a tetraedros, no a la unión posterior. Una prueba de calidad del tetraedro individual no sustituye la validación de una cavidad que atraviesa decenas de caras.

El paquete Mesh_3 de CGAL representa la geometría mediante un complejo tridimensional: esquinas, curvas, parches de superficie y subdominios reciben protección y criterios de tamaño o forma propios @cgal:mesh. El refinamiento de Delaunay se complementa con optimización para mejorar elementos que una razón simple de radios no detecta. Su organización explicita un punto importante: la malla es una aproximación de un dominio con características semánticas, no solo un conjunto de vértices. Si una frontera de material o un parche etiquetado aparece en la entrada, el agrupamiento debe impedir que una celda final lo cruce indebidamente. Esta condición no se deriva de la conectividad por caras; requiere conservar etiquetas de subdominio y una política de unión.

TetWild atiende superficies de entrada con defectos, intersecciones o inconsistencias y permite una desviación geométrica controlada respecto de ellas. Combina una tetraedralización inicial, una representación de la superficie de referencia y operaciones locales que mantienen la validez de la malla durante la optimización @hu2018tetrahedral. fTetWild persigue un equilibrio distinto entre robustez y costo mediante una estrategia más rápida @hu2020fast. Para un método indirecto, estas rutas amplían los conjuntos de prueba realistas, pero introducen otra variable: el borde tetraedral ya puede diferir de la superficie original. Evaluar «preservación del dominio» exige entonces comparar la salida con la entrada tetraédrica y, cuando corresponda, comparar ambas con la geometría fuente.

La comparación justa entre TetGen, CGAL y TetWild debe controlar qué problema resuelve cada uno. TetGen enfatiza restricciones y calidad de una malla tetraédrica; CGAL ofrece dominios y criterios de protección de rasgos dentro de una biblioteca geométrica; TetWild enfatiza la validez ante entradas superficiales defectuosas @si2015tetgen @cgal:mesh @hu2018tetrahedral. Ninguno decide cómo repartir tetraedros existentes en celdas poliédricas finales. Son proveedores y referentes de calidad de la entrada, no líneas base directas del algoritmo de cavidades.

=== La calidad de entrada como variable experimental

Una malla fina tiene más oportunidades de unir tetraedros, pero también más incidencias que recorrer y más fronteras potenciales. Una malla gruesa reduce el problema de memoria, aunque puede restringir el número de regiones geométricamente aceptables. Por ello, el estudio de sensibilidad debe abarcar al menos refinamientos de una misma geometría y geometrías de distinta complejidad. La práctica de comparar mallas generadas bajo criterios de tamaño y calidad distintos aparece en los estudios de TetGen y de calidad tetraédrica @si2015tetgen @marot2020quality. Aquí se traslada esa práctica a la etapa poliédrica: cualquier ventaja de reducción debe informarse junto con la distribución de calidad de entrada y salida.

El paralelismo de HXT muestra que la construcción tetraédrica puede escalar en memoria compartida, pero también que las fases de recuperación de frontera y mejora final tienen dependencias distintas de la construcción masiva @marot2018one @marot2020quality. Esto anticipa un patrón para la tesis: calcular candidatos de cavidad puede ser regular, mientras validar fronteras y reparar conflictos puede ser irregular. Se trata de una analogía de organización algorítmica, no de una predicción de aceleración para el nuevo método.


Las tetraedralizaciones de Delaunay constituyen una base frecuente para la
generación de mallas no estructuradas. Un tetraedro satisface la condición de
Delaunay cuando el interior de su circunsfera no contiene otro vértice de la
tetraedralización. La esfera mencionada es la *circunsfera*, que pasa por los
cuatro vértices, y no la esfera inscrita, que es tangente a las cuatro caras.
Esta distinción es central para el algoritmo propuesto, ya que las pruebas de
conflicto y el crecimiento de cavidades se formulan mediante circunsferas.

TetGen reúne una implementación madura de inserción incremental,
tetraedralización de Delaunay restringida, recuperación de restricciones,
refinamiento y mejora de calidad @si2015tetgen. El método utiliza predicados
geométricos filtrados y operaciones locales especializadas. Su relevancia para
este trabajo es doble: proporciona una vía robusta para obtener la malla de
entrada y establece una línea base para las decisiones geométricas que dependen
de orientación e *in-sphere*. No obstante, la generación tetraédrica continúa
teniendo dificultades teóricas y prácticas, entre ellas la recuperación de
aristas y caras, la eliminación de vértices y el control de *slivers*.

Los métodos TetWild y fTetWild desplazan el énfasis hacia entradas defectuosas.
TetWild acepta superficies con intersecciones y defectos, y prioriza la robustez
mediante construcciones racionales @hu2018tetrahedral. fTetWild sustituye parte
de ese costo por una estrategia incremental que mantiene una malla válida en
punto flotante durante el proceso y alcanza tiempos comparables con métodos
basados en Delaunay, aunque relaja algunas garantías exactas sobre la presencia
de todas las caras de entrada @hu2020fast. Para esta tesis, tales algoritmos
permiten separar los fallos causados por una superficie problemática de los
fallos propios de la aglomeración poliédrica.

HXT muestra que la construcción y mejora de una tetraedralización pueden
paralelizarse de manera efectiva en memoria compartida @marot2020quality. Su
pipeline todavía identifica la recuperación de la frontera como una etapa
difícil de paralelizar. Este resultado advierte que la aceleración de las fases
regulares no elimina necesariamente un cuello de botella irregular al final del
algoritmo.

== Generación directa e indirecta de mallas poliédricas

=== Celdas construidas desde sitios y celdas construidas desde uniones

La distinción entre método directo e indirecto se refiere a la unidad de decisión. En una construcción de Voronoi, los sitios definen regiones por proximidad; al variar un sitio, pueden cambiar simultáneamente varias caras. En un método de aglomeración, el dominio ya está discretizado y cada decisión añade o retira tetraedros de una región. Las restricciones de entrada y los costos dominantes difieren: la primera ruta debe resolver muestreo del borde y colocación de sitios; la segunda, pertenencia exclusiva, extracción de frontera y calidad de la unión @abdelkader2020vorocrust @si2015tetgen. Este contraste evita interpretar una comparación de cantidad de poliedros como una comparación completa de generadores.

VoroCrust es un caso especialmente claro. Su muestreo superficial construye bolas protectoras y coloca parejas de sitios a ambos lados de la superficie; los sitios interiores completan el diagrama. El objetivo es obtener celdas de Voronoi conformes sin recortar cada celda contra una superficie externa @abdelkader2020vorocrust. El análisis de muestreo anterior estudia condiciones suficientes para conservar la topología de la superficie y controlar la forma de las celdas @abdelkader2018sampling. Las celdas de Voronoi euclídeas son convexas; por ello, el núcleo geométrico de cada celda coincide con toda ella. Esa ventaja geométrica no afirma por sí sola que todas las caras tengan tamaños adecuados ni que una simulación particular tenga mejor tiempo total.

Otros generadores directos o predominantemente geométricos persiguen objetivos distintos, como celdas mayormente hexaédricas o estructuras poliédricas convexas @bukenberger2021atmosthexa @diazzi2021convex. En cambio, los métodos que transforman tetraedros pueden conservar exactamente el borde discreto de entrada si solo eliminan caras interiores y no desplazan vértices. Esta preservación discreta viene acompañada de una restricción: el espacio de poliedros posibles queda limitado por el complejo tetraédrico inicial. Una mala alineación de sus caras con la forma deseada no se corrige mediante unión.

=== Aglomeración como problema de partición

Sea $T$ el conjunto de tetraedros y sea $G = (T,E)$ el grafo de adyacencia por cara. Una aglomeración es una partición $P = {R_1, dots, R_m}$ donde cada $R_i$ contiene tetraedros conectados en $G$, los grupos son disjuntos y su unión es $T$. La definición formal separa tres preguntas: qué relaciones de vecindad permiten expandir una región, qué regla asigna de forma exclusiva un tetraedro a una región y qué criterio acepta el poliedro resultante. Una regla de propagación o de circunsfera responde solo a la primera pregunta. La conformidad y la utilidad numérica dependen de las otras dos. Esta formalización sintetiza los problemas que Polylla trata mediante regiones y reparación y los que la aglomeración para VEM trata mediante indicadores de calidad @salinasfernandez2022polylla @sorgente2024mesh.

La aglomeración en multigrilla geométrica reúne celdas para construir niveles gruesos de una discretización, de modo que la calidad algebraica del nivel resultante importa tanto como la geometría local @antonietti2023agglomeration2. La optimización de mallas para VEM usa un indicador de calidad para seleccionar uniones y presenta resultados en los que la malla resultante es mucho más pequeña sin perder las tasas de convergencia de los problemas estudiados @sorgente2024mesh. En redes de fracturas, otra estrategia de aglomeración reduce elementos y grados de libertad en los casos analizados @sorgente2023mesh. Esos resultados muestran viabilidad en ámbitos específicos; no constituyen una garantía para cualquier tetraedralización tridimensional ni para la regla de circunsfera de esta tesis.

Una decisión por pares puede ser engañosa. Si las uniones de $A$ con $B$ y de $A$ con $C$ son aceptables individualmente, la unión de $A$, $B$ y $C$ puede crear una hendidura profunda o una cara diminuta. La calidad de una región debe calcularse sobre la frontera del conjunto completo; el orden de las uniones también puede importar. Los trabajos de optimización por aglomeración reconocen esta dificultad al equilibrar reducción y calidad @sorgente2024mesh @sorgente2023mesh. Una política de semillas para cavidades debe, por tanto, estimar o comprobar el poliedro entero antes de comprometer sus tetraedros.

=== Polylla como referencia indirecta

Polylla 2D transforma una triangulación mediante caminos de propagación por la arista más larga. La relación entre triángulos determina regiones de arista terminal; luego se extraen polígonos y se reparan casos en que la región no produce un polígono simple @salinasfernandez2022polylla @rivara. Lo transferible a tres dimensiones no es la fórmula «arista más larga» en sí, sino la arquitectura: clasificación local, reunión de elementos, construcción explícita de frontera y reparación. La existencia de la fase de reparación muestra que conectividad de la región y validez de la celda de salida son propiedades distintas.

GPolylla lleva esta organización a GPU mediante arreglos de primitivas y fases masivas de etiquetado y recorrido. El trabajo informa que la reparación posee un perfil de paralelismo diferente, por la escasez y variabilidad de los casos irregulares @salinas2022gpu. Esta observación guía el análisis de una versión paralela de cavidades: una fase acelerada puede dejar el tiempo total dominado por conflictos, validación y construcción de caras. Se requerirán tiempos por fase, además del tiempo global.

La extensión publicada de Polylla 3D explora regiones basadas en aristas y caras de tetraedros @salinasfernandez20233d. El trabajo previo de esta tesis examina sus variantes y detecta celdas sin núcleo en algunos resultados @pol3d. Aquí corresponde extraer la consecuencia para el problema de investigación: una reducción de tetraedros no basta para juzgar la salida, y el criterio local que genera una región debe contrastarse con propiedades del poliedro completo. La definición exhaustiva de Face y Edge, sus criterios de unión y sus experimentos se desarrollan en «Trabajo anterior».

La nota posterior sobre generación desde mallas tetraédricas de Delaunay vuelve a comparar decisiones geométricas de unión y reconoce la importancia de medir calidad poliédrica @salinasfernandez2025exploring. Es un antecedente cercano porque comparte la entrada tetraédrica y la intención de producir poliedros. La contribución que esta tesis propone probar se distingue por la región candidata: está guiada por la circunsfera de un tetraedro semilla, no por una ruta hacia una cara o arista terminal. Es una distinción de mecanismo; la superioridad en calidad o costo permanece como hipótesis.

#figure(
  {
    set par(justify: false)
    set text(size: 9pt)
    table(
    columns: (19%, 19%, 22%, 21%, 19%),
    inset: 4pt,
    align: left,
    [Enfoque], [Entrada], [Unidad de decisión], [Fortaleza documentada], [Límite para esta tesis],
    [TetGen / CGAL / TetWild @si2015tetgen @cgal:mesh @hu2018tetrahedral], [Dominio o superficie], [Inserción y mejora de tetraedros], [Tetraedralización y control de entrada], [No define poliedros aglomerados],
    [VoroCrust @abdelkader2020vorocrust], [Superficie y sitios], [Celda de Voronoi], [Poliedros convexos conformes], [Requiere un problema de entrada diferente],
    [Polylla 2D / 3D @salinasfernandez2022polylla @salinasfernandez20233d], [Malla de símplices], [Región terminal], [Transformación indirecta], [La calidad final requiere evaluación],
    [Aglomeración VEM @sorgente2024mesh], [Malla inicial], [Unión guiada por calidad], [Reduce elementos en casos estudiados], [Objetivo y reglas de selección distintos],
    [Cavidades de esta tesis], [Malla tetraédrica], [Región de semilla], [Hipótesis por evaluar], [Sin resultados propios aún],
    )
  },
  caption: [Comparación de familias de métodos según entrada, decisión local y alcance de sus resultados.],
)<tab:familias>

La tabla @tab:familias ordena enfoques que suelen compararse bajo la etiqueta general de «generación de mallas». Sus salidas pueden tener cantidades de elementos semejantes, pero el costo de preparar la entrada, la fidelidad de frontera y las hipótesis de calidad no son intercambiables. En particular, una comparación experimental entre cavidades y Polylla 3D sí puede usar exactamente la misma tetraedralización; una comparación con VoroCrust necesita documentar la geometría fuente y el costo de muestreo para ser interpretable.


Una malla poliédrica se puede construir directamente desde la geometría o
indirectamente mediante la unión y transformación de celdas de una malla
auxiliar. VoroCrust representa una alternativa directa con garantías fuertes.
El método distribuye semillas a ambos lados de la superficie, protege el borde
mediante una unión de bolas y completa el interior con semillas de Voronoi. De
esta forma produce verdaderas celdas de Voronoi, convexas y conformes, sin el
recorte que utilizan otros métodos @abdelkader2020vorocrust. Bajo condiciones de
muestreo explícitas, la reconstrucción es isotópica a la superficie y las celdas
tienen una cota de *fatness* @abdelkader2018sampling. Sus ventajas —convexidad,
caras planas y dual ortogonal— la convierten en una referencia de calidad, pero
no en un competidor idéntico: exige construir y refinar las semillas y puede
producir aristas interiores cortas que restrinjan el paso temporal de algunos
solvers.

Los métodos indirectos aprovechan que existen generadores tetraédricos robustos
y concentran el problema en decidir qué celdas se deben unir. Polylla sigue esta
estrategia en dos dimensiones. Cada polígono se obtiene desde una región de
arista terminal inducida por el camino de propagación de arista más larga. El
algoritmo separa etiquetado, recorrido y reparación, no inserta nuevos puntos y
reduce el número de elementos frente a la triangulación de entrada y presenta resultados VEM preliminares
@salinasfernandez2022polylla.

La versión paralela de Polylla 2D traduce la triangulación y los estados
intermedios a arreglos indexados en memoria global de GPU. Las fases de
etiquetado y construcción exponen paralelismo por primitivas; la reparación, en
cambio, procesa pocos casos irregulares y no obtiene una ventaja clara frente a
la versión secuencial @salinas2022gpu. Este antecedente sugiere medir cada fase
por separado en 3D: el tiempo total puede ocultar que la corrección de un número
pequeño de celdas domine el costo.

3D Polylla extiende la noción de propagación a aristas y caras de tetraedros.
La variante basada en caras define un criterio que ordena las caras de cada
tetraedro, identifica caras terminales y reúne los tetraedros cuyas rutas terminan
en la misma cara @salinasfernandez20233d. Los resultados más recientes reportan
una reducción cercana al 70%, un promedio de tres tetraedros por poliedro y
alrededor de un 20% de tetraedros que permanecen sin unir. Sin embargo, los
criterios basados en área e inradio de cara producen resultados similares y los
autores señalan la necesidad de incorporar calidad poliédrica y validación VEM
@salinasfernandez2025exploring. Este límite motiva buscar una relación de unión
que no dependa únicamente de una cara local.

== Cavidades como primitiva geométrica

=== La cavidad de inserción y el criterio de esfera

En Bowyer--Watson, dado un punto nuevo $p$, la condición local de conflicto pregunta si $p$ está en el interior de la circunsfera de un tetraedro existente. La cavidad es la unión de todos los tetraedros en conflicto que corresponden a la inserción; sus caras exteriores se conectan con $p$ al retirar los tetraedros interiores @bowyer1981computing @watson1981computing. En presencia de restricciones y dominios no convexos, la visibilidad y la preservación de facetas requieren atención adicional @si2015tetgen @chen2019computing. La operación cambia la tetraedralización y añade un vértice.

La construcción planteada en esta tesis invierte el papel de los objetos. El tetraedro semilla ya pertenece a una malla terminada; su circunsfera fija una prueba geométrica sobre tetraedros vecinos candidatos. La región resultante, si se acepta, se convierte en una celda poliédrica de salida mediante eliminación de caras internas. No se inserta un punto, no se restituye la propiedad de Delaunay y no se vuelven a tetraedralizar las caras de frontera. En consecuencia, cualquier propiedad probada para la inserción Bowyer--Watson no se hereda automáticamente. Llamar «cavidad» a la región de salida es una convención de la tesis que debe acompañarse de una definición operacional inequívoca.

Hay varias pruebas geométricas plausibles y no equivalentes: exigir que todos los vértices de un tetraedro vecino estén en la esfera de la semilla; que su baricentro esté dentro; que el tetraedro interseque la bola; o que su circunsfera satisfaga otra relación. La primera produce conjuntos más restrictivos que la tercera, y las decisiones cerca de la frontera pueden variar con el error numérico. Por eso, la tesis debe fijar exactamente qué punto o cuerpo se prueba y cómo se resuelven empates. Mientras esa decisión no se implemente y evalúe, ninguna de estas opciones constituye un resultado del algoritmo. Los predicados adaptativos son relevantes para evitar decisiones incoherentes cerca de degeneraciones @shewchuk1997adaptive.

La región geométrica también necesita una regla topológica de crecimiento. Seleccionar todos los tetraedros que satisfacen una prueba de esfera podría generar componentes no conectadas en el grafo de adyacencia. Crecer solo por caras desde la semilla evita ese problema de conectividad del conjunto, aunque no certifica que su frontera sea una variedad cerrada. La verificación debe examinar caras, aristas y vértices de frontera, las orientaciones y, si el dominio tiene varias etiquetas, la preservación de interfaces. Este requisito procede de la representación de un complejo volumétrico y de la experiencia de reparación en Polylla @salinasfernandez2022polylla @salinasfernandez20233d.

=== Predicados y degeneración

El signo de la orientación de cuatro puntos determina la orientación de un tetraedro; el predicado _in-sphere_ determina de qué lado de la circunsfera de otros cuatro puntos se encuentra un quinto. Cerca de coplanaridad o cosfericidad, una evaluación ingenua en punto flotante puede cambiar el signo por redondeo y producir resultados dependientes del orden de recorrido. Shewchuk combina un filtro numérico rápido con cálculo adaptativo exacto para certificar los signos cuando el caso es difícil @shewchuk1997adaptive. GPredicates aplica el principio de separar casos fáciles y difíciles a ejecución GPU @qi2019gpredicates. Estos trabajos no prescriben la política de semillas, pero sí una disciplina de robustez para las pruebas geométricas que la política utilice.

La circunsfera de un tetraedro muy plano puede ser grande; si una política privilegia únicamente el número de tetraedros cubiertos, podría seleccionar esas semillas y producir celdas amplias pero mal formadas. Esta es una posibilidad geométrica, no un resultado experimental. Se debe contrastar con datos: distribución de radios de entrada, tamaños de grupos propuestos, proporción de grupos rechazados, volumen del núcleo y calidad final. El análisis de _slivers_ y de indicadores tetraédricos ofrece la razón para no reducir esta decisión a un umbral de radio @cheng2000sliver @sorgente2023survey.

=== Intersección de regiones y partición

Dos semillas pueden reclamar un mismo tetraedro aunque sus propias circunsferas no se corten de forma intuitiva: la región depende de la regla de prueba y de la conectividad de la malla. Conviene construir un grafo de conflictos donde cada vértice es una región candidata y una arista une candidatos con al menos un tetraedro compartido. Un conjunto independiente de ese grafo puede aceptarse simultáneamente; una prioridad fija resuelve solapamientos y vuelve reproducible la selección. Las estrategias de conjuntos independientes aparecen en refinamiento paralelo de Delaunay, pero aquí se aplican a la elección de celdas de salida, con un objetivo diferente @spielman2002parallel @chen2019computing.

El rechazo de una cavidad no debe dejar tetraedros sin dueño. Una partición completa puede obtenerse mediante rondas de selección seguidas de asignación de remanentes, o conservando tetraedros unitarios cuando ninguna unión cumple los criterios. Ambas posibilidades son hipótesis de diseño. La validación final debe demostrar que cada tetraedro original pertenece a exactamente un poliedro y que la unión de los volúmenes de salida reproduce la malla de entrada hasta el error numérico permitido. Este invariante de cobertura es independiente de cuántas celdas se hayan ahorrado.


En un algoritmo incremental de Bowyer–Watson, la inserción de un punto comienza
al localizar los tetraedros cuyas circunsferas contienen ese punto. La unión de
estos tetraedros forma una región de conflicto o *cavidad*. Después de eliminar
su interior, el punto se conecta con las caras visibles de la frontera para
restaurar la tetraedralización. Por lo tanto, la cavidad es un conjunto de
tetraedros y no la circunsfera aislada de uno de ellos.

La literatura ha generalizado esta idea más allá de la inserción elemental.
Loseille, Alauzet y Menier formulan una primitiva de cavidad capaz de expresar
inserción, colapso y cambios locales dentro de un remallado anisotrópico. Al
combinarla con partición jerárquica, balance estático y almacenamiento fuera de
núcleo, generan mallas de más de mil millones de tetraedros en una arquitectura
paralela moderada @loseille2016unique. La contribución para esta tesis no es una
regla de aglomeración poliédrica lista para usar, sino una demostración de que
una primitiva de cavidad bien definida puede unificar operaciones y simplificar
su versión paralela.

La robustez de esta operación depende del signo correcto de predicados casi
degenerados. Shewchuk desarrolla predicados adaptativos que comienzan con punto
flotante ordinario y aumentan la precisión solo cuando el error estimado no
permite certificar el signo @shewchuk1997adaptive. GPredicates adapta este patrón
a GPU separando el filtro rápido de los pocos casos que requieren evaluación
exacta y compactando esos casos antes de procesarlos @qi2019gpredicates. En el
algoritmo propuesto, pertenecer o no a una cavidad no debería decidirse mediante
una tolerancia global arbitraria, especialmente cuando existen vértices casi
cosféricos.

El significado específico de *cavidad* en esta tesis debe declararse de forma
explícita. Si una circunsfera asociada a un tetraedro semilla determina una
región candidata de unión, hay que precisar: qué entidades se prueban contra la
circunsfera; cómo se garantiza que la región sea conexa; cómo se asigna cada
tetraedro a una sola celda; cómo se preserva la frontera; y qué ocurre cuando dos
regiones se solapan. Sin estas reglas, la circunsfera es solamente un criterio
geométrico y no define todavía una partición.

== Aglomeración y requisitos de VEM

=== Flexibilidad geométrica y supuestos de análisis

El método de elementos virtuales construye espacios discretos sobre polígonos y poliedros generales y calcula proyecciones polinomiales sin necesitar una expresión cerrada de todas las funciones de forma en el interior de cada elemento @veiga2012basic @veiga2014hitchhiker. Esa flexibilidad permite ensayar mallas obtenidas por aglomeración, incluidas celdas no convexas bajo formulaciones apropiadas. No implica que una celda arbitraria sea igualmente estable o que cualquier implementación admita caras degeneradas. Los teoremas de aproximación se formulan con hipótesis explícitas sobre las celdas, las caras y la estabilización @veiga2014hitchhiker @brenner2018virtual.

Una hipótesis frecuente exige que el poliedro sea estrellado respecto de una bola de tamaño comparable con su diámetro. Es más fuerte que pedir únicamente que exista un punto desde el cual se vea toda la celda. Las caras suelen requerir condiciones análogas y se controlan relaciones entre tamaños de aristas, caras y volumen. Trabajos posteriores relajan algunos supuestos y analizan aristas o caras pequeñas en formulaciones concretas @brenner2018virtual. La lectura correcta para esta tesis es condicional: el núcleo no vacío es una prueba geométrica útil, pero ni su existencia demuestra todas las condiciones de un VEM particular ni su ausencia invalida por sí sola toda variante posible de VEM.

En aplicaciones tridimensionales, el número y la forma de las caras afectan la construcción de proyecciones y matrices locales. Gain, Talischi y Paulino desarrollan una formulación VEM para elasticidad lineal sobre mallas poliédricas y muestran cómo se calculan las contribuciones locales mediante proyecciones @gain2014virtual. Esa formulación ofrece un contexto numérico para evaluar las mallas, pero sus resultados no se deben trasladar sin más a la física ni a los órdenes de aproximación que no estudia. La decisión de medir convergencia, error o condicionamiento dependerá del problema de referencia acordado para la tesis.

=== Núcleo geométrico y observables de calidad

El núcleo de un poliedro es el conjunto de puntos desde los cuales se ve cualquier punto de la celda mediante un segmento contenido en ella. Para un poliedro con caras planas orientadas de modo coherente, puede obtenerse como intersección de semiespacios asociados a sus caras. La intersección puede estar vacía, ser muy pequeña o tener volumen comparable con el del poliedro. El algoritmo geométrico de Sorgente y colaboradores estudia esta computación y sus casos difíciles @sorgente2022polyhedron. Por ello, informar solo un porcentaje de celdas con núcleo ocultaría una diferencia importante entre núcleos apenas no vacíos y núcleos volumétricamente amplios.

La calidad debe informarse mediante una familia de medidas. Entre las geométricas están volumen positivo, diámetro, relación entre volumen y diámetro al cubo, área y tamaño mínimo de cara, longitud mínima de arista, número de caras, convexidad y proporción de volumen del núcleo. Entre las topológicas están conexión por caras, frontera cerrada y ausencia de incidencias no manifold. Entre las numéricas están error, tasa de convergencia y condicionamiento para un problema VEM especificado. La revisión de indicadores muestra que el ordenamiento de dos mallas puede cambiar según la métrica, por lo que se requieren distribuciones y valores extremos además de promedios @sorgente2023survey @sorgente2022polyhedral.

El indicador específico para VEM de Sorgente y colaboradores reúne propiedades geométricas relacionadas con las hipótesis del método y estudia su correlación con el error en los problemas considerados @sorgente2022polyhedral. Es un instrumento de comparación más cercano a la finalidad de esta tesis que un indicador diseñado solo para tetraedros. Aun así, una correlación publicada no valida por sí sola una nueva familia de mallas. Si se utiliza el indicador, deben documentarse su implementación, normalización y comportamiento en celdas con caras triangulares coplanares o núcleo vacío.

Las caras de un poliedro construido por unión de tetraedros pueden presentarse como triángulos del complejo original. Simplificar facetas coplanares reduce su conteo aparente, pero también cambia la representación de incidencias y puede modificar el valor de indicadores sensibles al número o tamaño de caras. Por ello, la evaluación necesita una convención explícita: medir sobre las facetas triangulares conservadas, sobre caras poligonales simplificadas, o reportar ambas. La pregunta es relevante para comparar un poliedro aglomerado con una celda de Voronoi cuyas caras se generan ya como polígonos planos @abdelkader2020vorocrust @sorgente2023survey.

=== Lectura prudente de los experimentos publicados

Los estudios de aglomeración para VEM informan reducciones significativas de elementos en los conjuntos que evalúan y muestran que la calidad puede mantenerse mediante selección guiada por métricas @sorgente2024mesh @sorgente2023mesh. Esos resultados justifican probar una reducción ambiciosa, pero no fijan un porcentaje meta universal. Las geometrías, las mallas de partida, el problema diferencial y la estabilización afectan el resultado. En el capítulo experimental de esta tesis se deberá usar la misma entrada y el mismo solucionador al comparar cavidades con Polylla 3D, y separar resultados publicados de mediciones reproducidas localmente.

La hipótesis de la tesis contiene dos afirmaciones distintas: la regla de cavidades puede producir una partición válida y puede mejorar alguna combinación de calidad, tiempo y memoria frente a las alternativas. La primera se verifica por invariantes topológicos y geométricos; la segunda exige experimentos controlados y criterios de comparación previos. Una malla con menos poliedros no demuestra menor costo de ensamblaje o solución VEM, porque puede tener más caras por celda o matrices locales más costosas. Esta conclusión se desprende de la formulación VEM y de los estudios de indicadores, y constituye una pregunta experimental para esta investigación @gain2014virtual @sorgente2022polyhedral.


El método de elementos virtuales permite trabajar con celdas poliédricas sin
evaluar explícitamente las funciones de forma en el interior. En elasticidad
lineal tridimensional, las proyecciones locales separan deformaciones rígidas y
deformaciones de tensión constante, lo que permite construir matrices locales a
partir de cantidades geométricas y obtener convergencia de primer orden
@gain2014virtual. Esta flexibilidad no implica que todas las celdas tengan el
mismo desempeño. La estabilidad, el condicionamiento y el error todavía dependen
de la geometría y de la estabilización elegida.

La teoría de VEM suele usar hipótesis de regularidad, como forma estrellada
respecto de una bola, control de caras y aristas pequeñas y número acotado de
entidades de frontera. Existen formulaciones que conservan estimaciones óptimas
en presencia de caras o aristas pequeñas bajo supuestos adicionales
@brenner2018virtual. Más aún, las condiciones habituales son suficientes, pero
no siempre necesarias: ciertas familias que las violan mantienen convergencia
óptima. El indicador de Sorgente et al. transforma las violaciones de esas
hipótesis en funciones geométricas y obtiene una correlación significativa con
el error y la convergencia de VEM en tres dimensiones @sorgente2022polyhedral.

La existencia de un kernel no vacío determina si una celda es estrellada. El
algoritmo geométrico de P063 calcula el kernel mediante recortes sucesivos y
predicados exactos. Sus experimentos muestran ventajas para poliedros pequeños,
con muchas caras coplanares o kernel vacío, escenarios frecuentes al evaluar
una tessellación; el método algebraico resulta preferible para poliedros
estrellados muy grandes y curvos @sorgente2022polyhedron. Así, el porcentaje de
celdas con kernel constituye una métrica necesaria para comparar Polylla 3D y el
nuevo algoritmo, pero no puede sustituir una prueba numérica.

La aglomeración orientada a VEM ofrece evidencia de que unir elementos puede
mejorar simultáneamente tamaño y comportamiento numérico. Una optimización
guiada por calidad reduce hasta 80% de los elementos y conserva las tasas de
convergencia y errores de la malla original; en mallas patológicas incluso
recupera convergencia @sorgente2024mesh. En redes de fracturas, una estrategia
relacionada reduce hasta 65% de los elementos y 50% de los grados de libertad,
manteniendo la convergencia óptima @sorgente2023mesh. Ambos trabajos reconocen
que una decisión por pares no evalúa directamente la calidad de una unión de
tres o más vecinos. Este resultado respalda el objetivo de reducción de la
tesis, pero también exige comparar políticas de semilla que consideren la
calidad final de la cavidad completa.

La revisión de indicadores de malla confirma que no existe una métrica universal
independiente de la aplicación @sorgente2023survey. La evaluación debe separar
al menos tres niveles: geometría de cada celda, desempeño numérico de una familia
de mallas y costo computacional del generador. Reportar solo la reducción de
celdas favorecería cavidades grandes aunque produjeran kernel vacío o mal
condicionamiento; reportar solo una media de calidad ocultaría elementos extremos
que pueden dominar el paso temporal o la estabilidad.

== Estructuras de datos y paralelización

=== Incidencias que necesita un aglomerador volumétrico

Una representación tetraédrica mínima almacena cuatro índices de vértice por tetraedro y las coordenadas de cada vértice. Para crecer regiones en tiempo proporcional al número de caras visitadas conviene almacenar además los cuatro vecinos por cara, con una convención fija que vincule posición local de cara y vértice opuesto. Una cara interior aparece dos veces, una desde cada tetraedro incidente; una cara de frontera aparece una sola vez. La clave canónica formada por sus tres vértices permite construir esa vecindad, pero la orientación local sigue siendo necesaria para extraer correctamente la superficie. La comparación de estructuras para mallas volumétricas expone el intercambio entre almacenar incidencias explícitas y reconstruirlas bajo demanda @garimella2002mesh.

Durante la aglomeración hacen falta estados que no son parte de la geometría original: identificador de región asignada, condición de semilla, prioridad, marcas de visita y estado de aceptación o rechazo. Mantenerlos separados de los arreglos de vértices y tetraedros facilita reiniciar políticas de semillas sobre la misma entrada sin duplicar el complejo. Si se proponen muchas cavidades simultáneas, una matriz densa de pertenencia tendría costo proporcional al producto de semillas por tetraedros y sería inviable para entradas grandes. Una lista compacta de candidatos por semilla, o generación por rondas, debe evaluarse según densidad de conflictos y memoria pico. Esta observación es un análisis de complejidad del diseño, no una medición de la implementación.

La extracción de frontera puede expresarse como una operación sobre incidencias: para cada tetraedro aceptado, una cara pertenece a la frontera de la región si su vecino está fuera de ella o si no existe vecino. De esa condición resultan caras orientadas y una correspondencia directa con las caras tetraédricas de entrada. La salida necesita además desplazamientos e índices para enumerar los tetraedros de cada poliedro y las caras de cada poliedro. Arreglos planos con desplazamientos permiten recorrer regiones de longitud variable sin reservar un bloque del tamaño máximo para cada una, un patrón coherente con representaciones compactas para algoritmos GPU @salinas2022gpu @salinasfernandez2024generation.

Una lista de vértices por poliedro no basta para reconstruir incidencias de caras ni para distinguir una cara interior de una cara de frontera. Si la malla debe exportarse a un formato numérico, también importan los identificadores globales de cara y la relación entre dos poliedros incidentes. Es preferible definir invariantes de representación: una cara interior final tiene dos poliedros incidentes con orientaciones opuestas; una cara del dominio tiene uno; un tetraedro original tiene un solo propietario. Estos invariantes posibilitan pruebas de consistencia y delimitan el costo de memoria que debe incluirse en una comparación.

=== Compacidad, localidad y modificaciones

Garimella compara estructuras que almacenan combinaciones diferentes de vértices, caras, celdas e incidencias y muestra que la rapidez de una consulta no se puede juzgar sin la memoria y el costo de actualización que exige la representación @garimella2002mesh. Para cavidades, el recorrido dominante es vecino por cara y la modificación principal es asignar propietarios, no alterar la geometría tetraédrica. Esto favorece una estructura base relativamente compacta. La reparación de fronteras, sin embargo, puede necesitar relaciones adicionales por arista y vértice; reconstruirlas repetidamente sería costoso. Una solución intermedia es construir esas incidencias solo para regiones sospechosas o para una fase de validación final. La conveniencia concreta requiere perfiles de uso, no una afirmación universal.

RXMesh muestra en superficies triangulares cómo los parches y la localidad de datos pueden facilitar consultas paralelas en GPU @mahmoud2021rxmesh. Su objeto original es una malla de superficie y no ofrece directamente la representación de celdas poliédricas volumétricas requerida aquí. El principio trasladable es organizar recorridos para que vecinos próximos compartan almacenamiento y se reduzcan accesos irregulares. La escala de una cavidad, no obstante, puede desbordar un parche; entonces se necesitan enlaces entre parches y una política para regiones que cruzan sus límites.

La comparación de memoria debe incluir todos los arreglos residentes durante la ejecución: coordenadas, conectividad tetraédrica, vecinos, marcas, listas temporales, grafo de conflictos, fronteras y salida. Informar solo el tamaño de la malla final favorecería artificiosamente una implementación que materializa muchas regiones candidatas. La memoria pico y los bytes por tetraedro de entrada describen mejor la escalabilidad. La misma disciplina se aplica al tiempo: lectura de entrada, construcción de vecinos, generación de candidatos, resolución de conflictos, reparación y escritura deben medirse por separado.

=== Independencia y costo de coordinación

Una operación sobre tetraedros disjuntos puede ejecutarse en paralelo solo si sus lecturas y escrituras sobre estructuras compartidas son compatibles. En la inserción paralela de Delaunay se seleccionan puntos o regiones que no interfieren y se procesan por rondas @spielman2002parallel @chen2019computing. En cavidades de aglomeración, el conflicto esencial es reclamar el mismo tetraedro; puede haber además conflictos al generar o simplificar caras compartidas por regiones distintas. El grafo de conflictos y una prioridad determinista hacen explícito el problema antes de escoger entre bloqueos, operaciones atómicas, coloreo o selección de conjunto independiente.

Los métodos paralelos de tetraedralización muestran distintas fuentes de costo. El trabajo sobre inserción en memoria distribuida estudia comunicación y ocultamiento de latencia @chrisochoides2003parallel; el refinamiento en GPU reorganiza las operaciones para llenar unidades de cómputo y manejar conflictos @chen2019computing; HXT aprovecha paralelismo masivo en etapas de construcción tetraédrica @marot2018one. Ninguna cifra de aceleración de esos artículos debe extrapolarse al aglomerador, porque este conserva la malla de entrada y escribe una partición nueva. Los estudios sirven para formular qué medir: conflictos por ronda, candidatos descartados, trabajo repetido, sincronización, localidad y memoria temporal.

Una versión GPU podría calcular predicados geométricos por semilla en paralelo y compactar las decisiones difíciles, siguiendo el patrón de filtros robustos de GPredicates @qi2019gpredicates. Pero crecer una cavidad exige recorrer vecinos en un orden dependiente de los datos; las longitudes variables generan divergencia y desequilibrio. Si la mayoría de las semillas produce regiones pequeñas, una asignación por semilla puede funcionar; si unas pocas regiones son enormes, se requerirá paralelismo interno o partición del trabajo. El corpus no establece cuál distribución tendrá la nueva regla, de modo que primero debe medirse en la implementación secuencial.

La reproducibilidad merece una métrica propia. Dos ejecuciones paralelas que aceptan semillas en órdenes distintos pueden producir mallas válidas pero diferentes. Una prioridad total estable puede hacer determinista la partición, aunque añada ordenación o rondas. La decisión depende de si el objetivo experimental privilegia reproducibilidad exacta o rendimiento. En cualquiera de los casos, las comparaciones de calidad deben indicar si muestran una sola ejecución o una distribución sobre órdenes y semillas. Los problemas de concurrencia observados en generación paralela justifican documentar esta elección @chen2019computing @marot2018one.


La representación de una malla debe balancear compacidad, costo de consultas y
costo de modificación. Garimella compara diez estructuras para mallas lineales
tetraédricas y hexaédricas y muestra que almacenar todas las incidencias acelera
operaciones, pero aumenta memoria y complejidad de actualización
@garimella2002mesh. Las implementaciones orientadas a GPU favorecen arreglos
contiguos, índices enteros y entidades implícitas. Una representación compacta de Polylla sigue esta dirección y evita almacenar una estructura completa de semiaristas @salinasfernandez2024generation.

Una estructura inicial adecuada para el algoritmo propuesto puede almacenar
coordenadas, cuatro vértices y cuatro vecinos por tetraedro, junto con una
convención fija para orientar caras. Los estados temporales —semilla, frontera,
aceptación y pertenencia— pueden expresarse como bitsets o arreglos compactos.
Las cavidades y celdas de salida se pueden escribir como arreglos planos con
offsets, después de una fase de conteo y prefijos acumulados. Esta opción debe
compararse con una estructura más explícita solo en las consultas que realmente
use el algoritmo: vecino por cara, incidencias necesarias para reparación y
enumeración de la frontera.

RXMesh demuestra que agrupar una malla en parches y administrar explícitamente
la localidad puede acelerar consultas GPU @mahmoud2021rxmesh. No obstante, su
alcance original son mallas triangulares superficiales y estáticas; la topología
dinámica y las consultas no locales aparecen como limitaciones. Por ello, el
trabajo aporta principios de localidad y partición, pero no una estructura que
pueda adoptarse directamente para una malla volumétrica poliédrica.

La independencia entre cavidades ofrece el paralelismo más directo. El análisis
de refinamiento de Delaunay construye conjuntos de puntos independientes e
inserta cada conjunto en rondas, conservando las garantías de los algoritmos
secuenciales @spielman2002parallel. Un kernel Bowyer–Watson tolerante a latencia
oculta más del 90% de la latencia remota y obtiene aceleraciones de ocho a nueve
veces, aunque incrementa la comunicación entre 2% y 20%
@chrisochoides2003parallel. En GPU, el refinamiento restringido regulariza el
trabajo en listas y arreglos y alcanza aceleraciones cercanas a un orden de
magnitud frente a TetGen, con tamaños y calidades comparables
@chen2019computing. En memoria compartida, la partición mediante curvas de
llenado de espacio permite construir tres mil millones de tetraedros en menos de
un minuto, pero deja como desafíos la mejora final, la frontera y la
reproducibilidad entre distintos números de hilos @marot2018one.

Estos antecedentes permiten anticipar cuatro clases de etapas. El etiquetado y
las métricas por tetraedro son paralelismo regular. La selección de semillas y
el crecimiento requieren resolver conflictos mediante prioridades, coloreo,
reservas o rondas de conjuntos independientes. La escritura compacta de salida
puede realizarse con conteos y prefijos. La reparación es irregular y puede
convertirse en el cuello de botella. En consecuencia, una versión paralela debe
diseñarse desde la estructura de datos, pero evaluarse por fase y no únicamente
mediante el tiempo total.

== Tensiones transversales y criterios de evaluación

=== Fidelidad del dominio y libertad de aglomeración

Una transformación por unión de tetraedros retira caras interiores, pero no necesita mover los vértices de la superficie. Bajo esa condición, la frontera externa discreta permanece como unión de las mismas caras triangulares. Esto no garantiza que la representación de salida conserve toda etiqueta de frontera: dos tetraedros adyacentes pueden pertenecer a materiales o subdominios distintos, y su cara común no debería desaparecer si modela una interfaz física. La descripción por complejos de Mesh_3 hace explícita la distinción entre borde geométrico y frontera de subdominio @cgal:mesh. El algoritmo de cavidades debe considerar las etiquetas como restricciones de crecimiento cuando existan.

La decisión también afecta a métodos directos. VoroCrust aproxima la frontera mediante muestreo y genera celdas de Voronoi conformes a la superficie reconstruida bajo sus condiciones @abdelkader2020vorocrust @abdelkader2018sampling. Una aglomeración hereda la frontera de la tetraedralización, pero también hereda cualquier desviación que esta tuviera respecto de la superficie fuente. No sería correcto comparar solo las fronteras de salida y atribuir toda diferencia al paso poliédrico. Si se usan entradas TetWild, hay que separar la tolerancia de reconstrucción y la transformación posterior @hu2018tetrahedral.

La fidelidad de interfaces internas puede comprobarse mediante incidencias: cada cara marcada como interfaz debe permanecer en la frontera de dos poliedros distintos; no basta con que sus vértices sigan presentes. Si la entrada dispone de identificadores de región, una política conservadora prohíbe unir tetraedros de etiquetas distintas. Una política más flexible solo sería justificable si la formulación numérica permite eliminar esa interfaz. Esta decisión pertenece a la especificación del algoritmo y no puede derivarse de una prueba de circunsfera.

=== Escalas geométricas y selección de semillas

El radio de circunsfera depende de la geometría local del tetraedro. En una malla adaptativa, los radios pueden variar varias órdenes de magnitud entre zonas refinadas y gruesas. Una prioridad global por radio podría sesgar la selección hacia las zonas gruesas, mientras una prioridad por número de vecinos favorece regiones densamente subdivididas. Ninguna de las dos equivale a calidad poliédrica. La literatura de calidad tetraédrica y aglomeración sugiere separar tamaño, forma y desempeño numérico al evaluar una regla @si2015tetgen @sorgente2024mesh @sorgente2023survey.

Una normalización local puede comparar el radio de la semilla con la longitud característica de sus tetraedros vecinos, pero introduce otra elección: cómo se define esa longitud y qué sucede en interfaces de refinamiento. Para evitar conclusiones dependientes de una escala arbitraria, los experimentos deberían reportar sensibilidad a los parámetros de semilla. Esto incluye cambios en distribución de tamaños de cavidad, proporción de tetraedros unitarios, número de conflictos y calidad final. El corpus no identifica una normalización óptima para el algoritmo nuevo.

El orden de las semillas puede alterar una partición codiciosa. Una semilla aceptada primero consume tetraedros que quizá habrían formado una celda mejor con otra. El problema se parece a seleccionar conjuntos disjuntos ponderados sobre un grafo de conflictos. Una prioridad por calidad estimada puede ser más informativa que una prioridad por tamaño, pero exige calcular parte de la frontera y del núcleo antes de aceptar, aumentando el costo. En refinamiento paralelo, los conjuntos independientes resuelven compatibilidad de inserciones, no optimización global de calidad @spielman2002parallel. La tesis tendrá que medir el beneficio de una prioridad más cara frente a su costo.

=== Validez de la frontera y reparación

La frontera de una unión se obtiene cancelando las caras compartidas entre tetraedros del grupo. Una región conexa por caras puede producir una superficie con incidencia singular alrededor de una arista si el grupo rodea parcialmente una configuración compleja. Por ello, la aceptación debe verificar que cada arista de la superficie tenga la incidencia esperada y que las orientaciones de caras vecinas sean coherentes. La fase de reparación de Polylla demuestra la relevancia de validar la salida tras aplicar una regla local @salinasfernandez2022polylla @salinasfernandez20233d.

Hay varios niveles posibles de reparación. El menos invasivo rechaza la unión y conserva sus tetraedros para otras semillas o como celdas unitarias. Otro divide una región en componentes válidas o retira tetraedros responsables de la singularidad. Un tercero fusiona con un vecino para eliminar una cara problemática. Cada opción cambia el conteo final, el costo y posiblemente la calidad, de modo que debe registrarse cuántas regiones siguen cada ruta. Los trabajos de aglomeración guiada por calidad ilustran que aceptar la primera unión posible puede comprometer objetivos numéricos @sorgente2024mesh. No hay evidencia en el corpus que determine cuál reparación será mejor para cavidades semilla.

La validez topológica y la forma estrellada son pruebas separadas. Una frontera cerrada, orientada y sin incidencias ambiguas puede encerrar un poliedro cuyo núcleo esté vacío. Inversamente, calcular un punto del núcleo no reemplaza la comprobación de que todas las caras pertenezcan a una superficie consistente. El procedimiento geométrico de cálculo del núcleo y los indicadores VEM permiten evaluar la segunda propiedad después de certificar la primera @sorgente2022polyhedron @sorgente2022polyhedral.

=== Comparabilidad de métricas y costos

La reducción de elementos se puede expresar como $1 - m / n$, donde $n$ es el número de tetraedros iniciales y $m$ el de poliedros finales. Esa razón no informa cuántas caras conserva la salida. Dos métodos con igual $m$ pueden diferir en número total de caras, distribución de grados y costo de integración local. Para un análisis de almacenamiento y VEM conviene acompañarla con recuentos de vértices, caras, incidencias celda-cara y grados de libertad del espacio discreto utilizado @gain2014virtual @sorgente2024mesh.

Los promedios de calidad pueden ocultar un pequeño conjunto de celdas extremas. Una sola celda con volumen casi nulo, núcleo vacío o cara minúscula puede condicionar el comportamiento global de un solucionador. La revisión de indicadores recomienda examinar distribuciones y no depender de un escalar universal @sorgente2023survey. Serían pertinentes percentiles, mínimos y máximos, además de histogramas separados por tamaño de cavidad y por región de la geometría. Al comparar entradas, las cantidades dimensionales deben normalizarse por una escala declarada.

El tiempo debe medirse a partir de una precondición común. Si Polylla 3D y cavidades reciben archivos tetraédricos idénticos, ambos deben incluir o excluir de manera equivalente la lectura, la construcción de vecinos y la exportación. Para una implementación paralela, la transferencia a GPU, la asignación de memoria y el posprocesamiento en CPU son parte del costo extremo a extremo, aunque se reporten por separado. La experiencia de GPolylla muestra que las fases tienen perfiles distintos @salinas2022gpu. Comparar únicamente el etiquetado con un tiempo secuencial total daría una impresión incorrecta de aceleración.

La memoria pico debe observarse en el instante de mayor coexistencia de estructuras. En una política que genera todas las cavidades candidatas antes de resolver conflictos, ese instante puede ocurrir mucho antes de escribir la malla final. La literatura de estructuras volumétricas muestra que almacenar incidencias auxiliares acelera consultas a costa de memoria @garimella2002mesh. Si el objetivo incluye escalabilidad, conviene reportar memoria máxima, memoria por tetraedro y crecimiento de estos valores al refinar una misma geometría.

Una evaluación numérica de VEM debería explicitar la variante, el orden, la estabilización, el problema diferencial y la norma de error. La flexibilidad de VEM frente a poliedros no elimina la dependencia de esos detalles @veiga2012basic @veiga2014hitchhiker. Si una comparación carece de un solucionador común, puede limitarse a calidad geométrica y enunciar esa limitación. La afirmación más fuerte de «malla apta para VEM» requerirá evidencia numérica asociada a una formulación concreta.

== Vacío de investigación y posición de la tesis

=== Protocolo de comparación que se desprende de la revisión

El vacío identificado no equivale a afirmar que nunca se haya usado una esfera en una malla poliédrica. VoroCrust usa bolas para proteger la frontera; Bowyer--Watson usa circunsferas para decidir conflicto de inserción; Polylla usa rutas terminales sobre una malla de símplices; la aglomeración VEM usa indicadores de calidad para decidir uniones @abdelkader2020vorocrust @bowyer1981computing @salinasfernandez20233d @sorgente2024mesh. La combinación que no aparece documentada en el corpus revisado es una partición de tetraedros existentes en poliedros finales mediante regiones conectadas guiadas por la circunsfera de tetraedros semilla, junto con una evaluación común de topología, núcleo, calidad VEM, tiempo, memoria y conflictos. Esta formulación declara el alcance de la búsqueda bibliográfica, sin convertir una ausencia en prueba absoluta de novedad.

La comparación central debe tomar las mismas tetraedralizaciones para la variante de cavidades y para Polylla 3D. Debe registrar las precondiciones, el criterio exacto de pertenencia, la política de semillas, el tratamiento de solapamientos y las reparaciones. Para cada malla final debe informar reducción de celdas, distribución de tetraedros por poliedro, número de caras y vértices, validez de frontera, porcentaje y volumen relativo de núcleos, indicadores geométricos, tiempo por fase y memoria pico. Cuando se afirme aptitud para VEM, debe añadirse al menos un problema numérico con error y convergencia documentados. Estas medidas se derivan de las limitaciones observadas en Polylla y de las hipótesis e indicadores VEM @pol3d @sorgente2022polyhedral @sorgente2023survey.

Los hechos publicados y las hipótesis quedan así separados. Está publicado que existen generadores tetraédricos robustos, construcción directa de Voronoi conforme, Polylla y aglomeración guiada por calidad, así como técnicas de cavidad y de detección de conflictos @si2015tetgen @abdelkader2020vorocrust @salinasfernandez2022polylla @sorgente2024mesh @chen2019computing. El trabajo previo de esta tesis documenta resultados de Polylla 3D, incluidas limitaciones relativas al núcleo, que se analizarán en el capítulo siguiente @pol3d. Es hipótesis de la presente investigación que la regla de circunsfera semilla producirá una mejor relación entre reducción, calidad y costo, y que su organización permitirá una versión paralela eficaz. Solo los capítulos de algoritmo y experimentos pueden decidir esas dos afirmaciones.


Los trabajos revisados resuelven piezas del problema, pero no su combinación
específica. Polylla define una familia indirecta y una referencia experimental;
la aglomeración VEM demuestra que la reducción puede preservar convergencia; los
operadores de cavidad aportan una primitiva robusta; y los algoritmos paralelos
aportan modelos de independencia y representación. No se encontró en el corpus
un método que use una regla de circunsferas asociadas a tetraedros semilla para
generar directamente las celdas poliédricas de salida, repare la partición y la
compare simultáneamente con Polylla 3D en memoria, tiempo, kernel y desempeño
VEM.

Por tanto, la contribución propuesta consiste en: (i) formalizar una relación de
pertenencia entre tetraedros y cavidades semilla que produzca una partición; (ii)
diseñar una estructura indexada compatible con ejecución paralela; (iii) definir
políticas de semilla y reparación; y (iv) evaluar el resultado mediante métricas
geométricas, numéricas y computacionales separadas. La hipótesis solo quedará
respaldada si el método demuestra no solo una reducción de primitivas, sino una
calidad y un costo competitivos frente a las variantes actuales de Polylla 3D.


]

#bibliography(("references.bib", "estado-del-arte-ampliado.bib"), title: "Bibliografía", style: "ieee")
