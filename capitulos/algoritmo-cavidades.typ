#import "pendiente.typ": pendiente

// Fuentes de implementación: rutas relativas a 3D-GPolylla/.
// La tabla de trazabilidad al final de este archivo conserva los localizadores
// sin introducir referencias bibliográficas ajenas al catálogo.

= Generalización y alcance <sec:ac-generalizacion>

Este capítulo distingue el algoritmo secuencial implementado en `3D-GPolylla`,
sus herramientas de inspección y la propuesta paralela. La hipótesis de calidad
y eficiencia permanece por evaluar.

Como organización conceptual de este capítulo, se caracteriza la familia Polylla
tridimensional mediante dos ejes: la forma de unión de las primitivas y el criterio que decide cuáles
unir. La revisión de @sec:ea-poliedros sitúa los antecedentes de esta familia;
la variante de
cavidades utiliza vecinos por cara para recorrer la malla, pero decide su
incorporación comparando circuncentros con la circunsfera de una semilla. Por
consiguiente, la conectividad usada para recorrer y la condición geométrica de
aceptación son componentes distintos.

Esta separación no equivale a disponer de una biblioteca que combine libremente
cualquier forma y cualquier criterio. La interfaz `Algorithm` recibe una `Mesh`
y devuelve una `PolyMesh`, mientras que `CavityAlgorithm` concreta ese contrato.
En el código activo, tanto el orden por radio como la condición de inclusión
están escritos directamente en `cavity.cpp`; no se reciben como estrategias
intercambiables. La adaptación de Polylla Face y Edge permanece en la lista de
trabajo del `README.md`. Así, la generalización es una dirección de organización
del software, con una interfaz común inicial, y no una cobertura implementada de
toda la familia.

El borrador de rediseño en `docs/superpowers/specs/` propone representar mallas,
construir poliedros y medir resultados como capacidades permanentes. Se considera
una especificación, no una implementación. La propuesta original priorizaba
regiones de cara terminal y consideraba después cavidades; este capítulo sigue
el alcance vigente de la introducción.

#pendiente[Justificación de diseño: precisar con el autor qué parte de la
  separación «forma de unión × criterio» constituye una contribución de la tesis.
  Completar el contrato común con las precondiciones y salidas exigidas a Face,
  Edge y Cavity antes de afirmar que el ecosistema quedó unificado.]

= Definiciones operacionales <sec:ac-definiciones>

Sea $M = (V, F, T)$ la malla de entrada representada por el programa: $V$ contiene
las coordenadas de los vértices, $F$ las caras triangulares y $T$ los tetraedros.
Cada tetraedro almacena cuatro índices de vértice y cuatro índices de cara. Cada
cara conserva tres índices de vértice y hasta dos tetraedros incidentes; el valor
`-1` representa una incidencia ausente. Estas son propiedades de la
representación, que presupone una entrada compatible con esas capacidades.

Un *tetraedro candidato a semilla* es cualquier tetraedro de entrada. Una *semilla
efectiva* es un candidato que todavía no tiene propietario cuando llega su turno
en la secuencia de procesamiento. Esta distinción es necesaria porque
`seeds()` conserva la lista ordenada de todos los candidatos, aunque algunos
hayan sido absorbidos antes de iniciar una región propia.

Para un tetraedro no degenerado $t$, se denotan por $c_t$ y $r_t$ el centro y el
radio calculados por `circumsphere`. La circunsfera es la esfera que pasa por sus
cuatro vértices; el radio se obtiene como la distancia entre el centro calculado
y el primer vértice. No se trata de la esfera inscrita definida en la
introducción. La función forma matrices de orden cuatro, calcula determinantes
y divide por dos veces el determinante de la matriz de coordenadas homogéneas.
No contiene una comprobación previa de determinante nulo.

Para una semilla $s$, la condición operacional de aceptación de un vecino $t$ es

$ norm(c_t - c_s) < r_s + epsilon, quad epsilon = 10^(-8). $

El valor de $epsilon$ corresponde a `TOLERANCE` en `utils.h`. Aunque el radio se
almacena como `double` y los determinantes se calculan con `Matrix4d`, `Vertex`
hereda de `Eigen::Vector3f`: las coordenadas del centro se almacenan en precisión
simple. La desigualdad reproduce la función `Cavity::isInside`, incluida su
tolerancia absoluta.

La *cavidad construida* $C_s$ es el conjunto de tetraedros alcanzados desde $s$
por el recorrido de vecinos por cara, aceptados con esa condición y todavía sin
propietario al ser visitados. La semilla se incorpora directamente; el test
geométrico se aplica a sus vecinos. Debe distinguirse la esfera de referencia de
la región discreta que finalmente se construye. Tampoco se exige que los
vértices del vecino estén dentro de la esfera, que su circunsfera esté contenida
en ella ni que el volumen del tetraedro completo esté contenido en la bola.

La cavidad de Bowyer–Watson responde a otra consulta: reúne tetraedros cuyas
circunsferas contienen un punto de inserción, para sustituir esa región durante
la actualización de la tetraedralización @tetgen. En el procedimiento aquí
estudiado se fija la esfera de una semilla y se consultan los circuncentros de
los vecinos. No se inserta un punto ni se vuelve a tetraedralizar la región.
Los fundamentos de la primera construcción se desarrollan en @sec:ea-delaunay;
la coincidencia del nombre no transfiere sus garantías a esta segunda operación.

El *poliedro resultante* se representa mediante la unión de los tetraedros de
$C_s$, una lista de caras de frontera y una lista de vértices únicos. Esta última
se forma con todos los vértices de los tetraedros incorporados, no únicamente
con los vértices de las caras externas. La frontera continúa triangulada: la
construcción no fusiona triángulos coplanares en caras poligonales mayores.

#pendiente[Figura: preparar, a partir de una malla pequeña elegida por el autor,
  una vista con semilla, circunsfera, circuncentros aceptados y rechazados, y caras
  de frontera. Mostrar un tetraedro cuyo circuncentro sea aceptado sin que se exija
  contener todos sus vértices; contrastar con la cavidad de Bowyer–Watson de
  @fig:ea-delaunay. No representar esta figura como un resultado experimental.]

= Selección de semillas y construcción <sec:ac-algoritmo>

== Preparación y prioridad

La entrada del algoritmo es `CavityAlgorithm::operator()`. La primera fase,
`labelCavities`, calcula una circunsfera por tetraedro, incorpora su índice a la
lista de candidatos y ordena esa lista por radio creciente. Inicializa además
`owners` con `-1`. No hay un filtro previo por calidad, volumen o posición
espacial: todos los tetraedros participan como candidatos.

El orden induce una prioridad secuencial. Cuando un tetraedro ya pertenece a una
región anterior, `buildCavities` omite su candidatura. Por ello no basta con
definir la condición geométrica para especificar el resultado: también se debe
conservar el orden de las semillas. El comparador de `std::sort` solo evalúa la
desigualdad entre radios y no incluye un desempate por índice. El código no
especifica, por tanto, una prioridad total entre candidatos de igual radio.

#pendiente[Justificación de diseño: documentar por qué se eligió comenzar por el
  menor radio. Contrastar, cuando el autor autorice los experimentos, orden
  creciente, decreciente y un desempate explícito por índice, registrando número
  de poliedros, tetraedros aislados y presencia de kernel. La implementación
  actual demuestra la elección, pero no su superioridad.]

== Recorrido y propiedad exclusiva

La segunda fase copia los arreglos de vértices, caras y tetraedros al resultado.
Para cada semilla efectiva crea tres contenedores: un conjunto ordenado de
vértices únicos, una lista de caras y una lista de tetraedros. El recorrido
`DepthFirstSearch::operator()` asigna inmediatamente el tetraedro visitado a la
semilla y lo añade a la lista. Luego incorpora sus vértices al conjunto y examina
sus cuatro caras.

Si la cara no tiene un tetraedro al otro lado, se incorpora a la frontera. Si el
vecino ya tiene propietario, se añade la cara solo cuando ese propietario es
otra semilla. Cuando el vecino está libre, se compara su circuncentro con la
esfera de la semilla inicial: si satisface la condición, se continúa
recursivamente; en caso contrario, se registra la cara de frontera. La esfera
usada no cambia al avanzar por el recorrido.

#figure(
  block(width: 100%, inset: 8pt, stroke: 0.5pt)[
    #set text(size: 9pt)
    ```text
    construir(M):
      para cada tetraedro t:
        esfera[t] = circumsphere(t, M)
        candidatos.agregar(t)
      ordenar candidatos por esfera[t].radio creciente
      dueño[t] = -1 para todo t
      R.vértices, R.caras, R.tetraedros = copias de M
      para s en candidatos:
        si dueño[s] != -1: continuar
        U = conjunto vacío; B = []; C = []
        visitar(s, s, U, B, C)
        para t en C: R.tetraedros[t].poliedro = |R.celdas|
        R.celdas.agregar(Poliedro(U, B, C))
      devolver R
    ```
  ],
  caption: [Preparación y construcción secuencial. Corresponde a
    `labelCavities`, `buildCavities` y `CavityAlgorithm::operator()` en
    `src/cavity.cpp`.],
) <alg:ac-construccion>

#figure(
  block(width: 100%, inset: 8pt, stroke: 0.5pt)[
    #set text(size: 9pt)
    ```text
    visitar(t, s, U, B, C):
      dueño[t] = s; C.agregar(t)
      insertar en U los cuatro vértices de t
      para f en caras(t):
        u = tetraedro al otro lado de f
        si u == -1:
          B.agregar(f); continuar
        si dueño[u] != -1:
          si dueño[u] != s: B.agregar(f)
          continuar
        si esfera[s].contiene(esfera[u].centro):
          visitar(u, s, U, B, C)
        en otro caso:
          B.agregar(f)
    ```
  ],
  caption: [Recorrido recursivo de `DepthFirstSearch::operator()` en
    `src/cavity.cpp`. La pertenencia se evalúa siempre respecto de la semilla.],
) <alg:ac-recorrido>

Los identificadores de propietario tienen dos significados distintos. En
`owners`, el valor es el índice del tetraedro semilla. En
`Tetrahedron::polyhedron`, asignado después de completar el recorrido, es el
índice de la celda en `result.cells`. No deben intercambiarse al consultar una
región o exportar resultados. Los accesores de `CavityAlgorithm` permiten
consultar las esferas, los candidatos y los propietarios después de la ejecución.

== Propiedades deducibles y límites

Bajo una conectividad válida y un cálculo geométrico definido, cada tetraedro
adquiere propietario a lo sumo una vez: el recorrido solo entra en vecinos
libres y los marca antes de explorar sus caras. También obtiene propietario al
menos una vez, porque todos los tetraedros aparecen como candidatos y cualquiera
que permanezca libre inicia su propia región. De ambas observaciones se deduce
una partición de los índices de tetraedros. Cada región es conexa por caras,
pues toda incorporación posterior a la semilla ocurre desde un vecino ya
incorporado. Estas son deducciones del control de flujo, no mediciones.

La exclusividad y la conectividad no constituyen por sí solas una demostración
de simplicidad topológica, convexidad o existencia de kernel. El predicado no
consulta esas propiedades y la construcción no rechaza una región por carecer
de ellas. Las métricas se calculan después, mediante otro módulo. La lectura
correcta de la hipótesis es, por tanto, que esas propiedades deben evaluarse,
no que el crecimiento las garantice.

Para $N$ tetraedros, $F$ caras y $V$ vértices almacenados, el cálculo de
circunsferas efectúa una cantidad fija de operaciones matriciales por tetraedro.
La ordenación requiere $O(N log N)$ comparaciones. En el recorrido, cada
tetraedro se visita una vez y examina cuatro caras; sus cuatro inserciones en
`std::set` tienen costo logarítmico en el tamaño del conjunto. Así, para esta
construcción y las copias de entrada se deduce una cota superior
$O(V + F + N log N)$, sin incluir lectura, escritura ni estadísticas. Se supone
costo constante para las operaciones geométricas de tamaño fijo y los accesos
por índice.

Los contenedores auxiliares, la salida y las copias requieren espacio
$O(V + F + N)$ bajo esas mismas condiciones. La profundidad de la recursión puede
crecer con el número de tetraedros de una región; la cota asintótica no evita un
agotamiento de pila en recorridos grandes. Estas cotas describen la estructura
del programa, no su escalabilidad observada.

#pendiente[Robustez y validación: definir precondiciones de entrada y tratamiento
  de tetraedros degenerados, centros no finitos, radios iguales y cambios de
  escala. Añadir casos de prueba para cada situación y justificar una tolerancia
  acorde con la precisión de las coordenadas. Sustituir la recursión por una pila
  explícita si se necesita controlar su memoria; verificar que conserve el orden
  de visita y la partición.]

= Reparación y cobertura de pruebas <sec:ac-reparacion>

Existe una función `fixCavities`, pero su llamada está comentada en el operador
principal. En consecuencia, la salida descrita en @sec:ac-algoritmo no incluye
una fase activa de reparación ni de refinamiento. Una celda formada por un solo
tetraedro permanece como tal. Tampoco se añaden vértices ni se subdividen los
tetraedros durante las fases activas.

El código inactivo ensaya incorporar los tetraedros aislados al vecino que
minimice la distancia entre circuncentros dividida por el radio del vecino.
Actualiza una lista de tetraedros y el identificador de poliedro, pero no
reconstruye en ese paso las listas de vértices y caras. Después genera una lista
nueva de poliedros iterando sobre tetraedros y copiando sus celdas propietarias,
sin una deduplicación explícita por poliedro. La propia función se presenta como
provisional y enumera validación, identificación de frontera y controles de
calidad como tareas por completar. No corresponde describirla como reparación
terminada ni suponer que basta con habilitar su llamada.

`test/cavity_test.cpp` contiene una prueba de ejecución que comprueba que los
contenedores del resultado no estén vacíos y que se conserve la cantidad de
vértices, además de una comparación con una malla poliédrica de referencia. Hay
pruebas adicionales para lectura TetGen y escritura VisF. La inspección de esas
pruebas aporta ejemplos del contrato esperado; no equivale a ejecutarlas ni a
validar exhaustivamente las propiedades geométricas anteriores. En particular,
la prueba de lectura aún referencia `mesh.cells`, mientras que `Mesh` expone
`tetras`; esa prueba requiere actualización antes de emplearla como validación
de la interfaz vigente.

#pendiente[Reparación: decidir si conservar tetraedros aislados es admisible para
  el uso previsto. Si se requiere absorberlos, definir el criterio de aceptación,
  reconstruir frontera y vértices del agregado y mantener una correspondencia
  única entre tetraedro y poliedro. Probar conservación de volumen con orientación
  controlada, exclusividad de pertenencia y ausencia de caras internas en la
  frontera; evaluar el kernel antes y después de cada modificación.]

= Representación de la malla y objetivo paralelo <sec:ac-estructura>

La representación pública emplea índices enteros y arreglos dinámicos. `Mesh`
agrupa vectores de vértices, caras y tetraedros; `PolyMesh` extiende esa clase con
un vector de `Polyhedron`. Este último contiene vectores de índices de vértices,
caras y tetraedros constituyentes. La malla de salida conserva, por tanto, la
subdivisión tetraédrica además de la agrupación poliédrica. La reducción del
número de celdas expuestas no implica eliminar del almacenamiento los
tetraedros originales.

La vecindad se obtiene indirectamente: un tetraedro referencia una cara, y esta
contiene las dos incidencias que permiten escoger el tetraedro del otro lado.
No existe en `Tetrahedron` un arreglo adicional de cuatro vecinos. En la lectura,
`buildFaces` genera las caras de cada tetraedro y elimina duplicados con un
conjunto de dispersión; luego las ordena por sus índices de vértice ordenados.
`buildConnectivity` usa un mapa de caras a posiciones locales para completar
ambas direcciones de incidencia. El archivo `neighbours.cpp` conserva código
comentado, por lo que no representa una segunda construcción activa.

La capacidad fija de dos incidencias por cara presupone que no se intentará
registrar una tercera. El bucle que completa esa información no comprueba
explícitamente el límite antes de escribir. Además, la numeración de entrada
requiere atención: los lectores insertan un elemento ficticio si el primer
índice es uno, tanto para vértices como para tetraedros. Los recorridos
posteriores comienzan en cero. Esto identifica una condición que debe revisarse
antes de aceptar de manera general entradas con numeración desde uno.

Para el objetivo específico 2, los índices y las incidencias fijas ofrecen una
base para separar topología inmutable y asignaciones. Sin embargo, los vectores
por poliedro, el conjunto ordenado, la recursión y las escrituras secuenciales en
`owners` requieren adaptación. No constituyen una implementación masivamente
paralela. Las representaciones alternativas se revisan en @sec:ea-estructuras.

#pendiente[Estructura de datos: validar numeración, referencias y multiplicidad
  de incidencias durante la lectura. Para el objetivo paralelo, especificar una
  representación aplanada de las listas de cada poliedro con desplazamientos y
  tamaños; comparar memoria total, copias y accesos con la representación actual,
  incluyendo la subdivisión tetraédrica retenida. Registrar el costo de construir
  esa representación, no solo el de recorrerla.]

= Arquitectura y flujo de datos <sec:ac-arquitectura>

El proyecto define una biblioteca C++20, `GPolyllaLib`, accesible también mediante
el alias `GPolylla::gpolylla`. CMake permite habilitar por separado el ejecutable,
las pruebas y el renderer. Las interfaces `Reader`, `Algorithm` y `Writer`
separan lectura, transformación y escritura; las realizaciones aquí utilizadas
son `TetgenReader`, `CavityAlgorithm` y `VisFWriter`. Se dispone así de un núcleo
reutilizable por las dos aplicaciones, aunque la interfaz pública mantiene
geometría, conectividad y comportamiento en un mismo encabezado.

`TetgenReader` recibe rutas a archivos `.node` y `.ele`, lee coordenadas y
cuádruplas de vértices y construye las caras y su conectividad. No se debe
confundir este lector con una invocación del generador TetGen: el flujo procesa
una malla ya disponible. `VisFWriter` escribe el encabezado ASCII de malla de
poliedros, las coordenadas, las caras dirigidas y la pertenencia de caras a
celdas. El bloque de vecindad entre polígonos se escribe como cero. No hay en
estas interfaces una lectura VisF ni una escritura TetGen implementadas.

La orientación de las caras de salida se determina respecto del vértice opuesto
del tetraedro incidente. El escritor recorre los tetraedros de cada poliedro,
selecciona sus caras de frontera y revierte el orden de sus vértices cuando lo
indica el predicado de orientación. La exportación mantiene caras triangulares
y registra las incidencias dirigidas por celda; no construye una representación
compacta de caras poligonales compartidas entre poliedros.

El ejecutable admite las rutas de entrada y salida y las opciones
`--make-stats` y `--detail-stats`. Mide por separado lectura, ejecución del
algoritmo y escritura mediante un reloj de alta resolución, con duraciones en
milisegundos. Las estadísticas se calculan después de esas fases. Su suma,
exportada como tiempo total, no incluye el cálculo de estadísticas ni la
exportación detallada. La opción de detalle se procesa dentro de la rama de
generación de estadísticas y produce archivos OFF por poliedro y `details.csv`.

El logger declara el nivel `INFO` y escribe en la salida estándar con ese
prefijo; no configura archivos de trazas ni mide memoria.

#pendiente[Reproducibilidad del software: fijar revisiones de las dependencias
  QuickHull y polyhedron-kernel, actualmente referidas a ramas en CMake, y eliminar
  la inclusión de ImGui desde una ruta de compilación en `stat.cpp`. Documentar
  una configuración reproducible antes de asociar mediciones a esta versión.
  La compilación y ejecución del programa quedan a cargo del autor.]

= Métricas implementadas y su interpretación <sec:ac-metricas>

El módulo `stat` construye un registro `PolyStat` por poliedro. Almacena una
envolvente convexa, un kernel opcional y tres razones escalares. Estas medidas
permiten instrumentar la pregunta sobre calidad, pero no establecen por sí
solas la admisibilidad de una malla para un método numérico. Las condiciones de
uso de las celdas se discuten en @sec:ea-calidad y @sec:ea-numericos.

== Área, volumen y envolvente convexa

El área de una cara triangular se calcula como la mitad de la norma del producto
cruzado de dos de sus lados. `Polyhedron::area` suma esas áreas sobre las caras
de frontera. Para el volumen, `Tetrahedron::volume` divide por seis el producto
mixto de tres aristas desde un mismo vértice; `Polyhedron::volume` suma esos
valores sobre los tetraedros constituyentes. No aplica valor absoluto por
tetraedro ni al total. La orientación de la entrada condiciona, por tanto, el
signo y las posibles cancelaciones de esta magnitud.

`Hull` entrega a QuickHull las coordenadas referenciadas por `poly.vertices` y
construye caras triangulares a partir de los índices devueltos. Sus métodos de
área y volumen operan sobre esa superficie. En particular, `generalVolume`
utiliza el primer vértice como referencia, suma productos mixtos asociados a
las caras, toma el valor absoluto de la suma y divide por seis. Es una ruta de
cálculo diferente de la suma tetraédrica usada para el poliedro original.

La envolvente calculada constituye información para estudiar convexidad, pero
`PolyStat` no contiene un indicador booleano de poliedro convexo ni calcula una
razón entre volumen del poliedro y volumen de su envolvente. No se deben
atribuir esas definiciones al campo `volumeRatio`.

== Kernel y razones de calidad

`Kernel` remapea los índices de vértice a una numeración local, orienta las caras
mediante `getDirectedFaces` y delega el cálculo a `PolyhedronKernel`. Las caras
devueltas con más de tres vértices se triangulan en abanico. `empty()` comprueba
si el vector de vértices obtenido está vacío; `computeStats` representa ese caso
con `std::nullopt`. Así, la presencia de kernel registrada por el programa es
operacionalmente la presencia de vértices en la salida de esa dependencia.

Para un poliedro $P$, su envolvente $H(P)$ y el kernel calculado $K(P)$, las tres
razones implementadas son:

$ q_e(P) = ell_min slash ell_max, quad
  q_v(P) = V(P) slash V(K(P)), quad
  q_a(P) = A(P) slash A(H(P)). $

Los extremos $ell_min$ y $ell_max$ se obtienen recorriendo las tres aristas de
cada triángulo de frontera. Por tanto, incluyen las aristas de la triangulación
de la superficie y no solo las de una eventual representación con caras
poligonales fusionadas. El campo `edgeRatio` almacena $q_e$; `surfaceRatio`
almacena $q_a$. Para `volumeRatio`, el programa asigna cero si no hay kernel y
usa $q_v$ en caso contrario. No invierte esa fracción: el numerador es el
volumen del poliedro.

Esta convención mezcla ausencia de kernel con un valor numérico especial en el
mismo campo. Además, las divisiones no comprueban explícitamente volumen de
kernel, área de envolvente o longitud máxima nulos. El cálculo de volumen
superficial accede al primer vértice, por lo que requiere una colección no
vacía. Estas condiciones delimitan cómo deben interpretarse estadísticas de
entradas degeneradas o resultados incompletos.

#pendiente[Métricas: justificar las tres razones respecto de los requisitos del
  método numérico que se utilizará. Separar «sin kernel» de cero numérico, definir
  el manejo de denominadores nulos y verificar orientación y volumen con casos
  analíticos. Si se incorpora una medida de convexidad volumétrica, definirla y
  probarla como una métrica nueva, sin renombrar silenciosamente `volumeRatio`.]

== Agregación y archivos de salida

El renderer cuenta poliedros de un solo tetraedro y calcula mínimo, máximo y
promedio del número de tetraedros por celda y de las tres razones. También
calcula la fracción de celdas cuyo registro contiene kernel, y cuenta los
vértices usados por las caras de frontera. Son cálculos presentes en el código;
este capítulo no proporciona valores obtenidos sobre mallas concretas.

El ejecutable usa otra definición para `points coverage`: marca los vértices
incluidos en `poly.vertices` y divide su cantidad por el tamaño del vector de
vértices de entrada. Como la construcción incorpora los vértices de todos los
tetraedros asignados, esta medida no cuenta exclusivamente los vértices de la
superficie poliédrica. Tampoco es la razón de reducción de tetraedros a
poliedros. Los conteos de ambas clases de celdas se exportan por separado.

La función `createStats` presenta inconsistencias visibles en la serialización:
faltan separadores después de algunos promedios y se vuelven a escribir los
extremos de superficie donde el encabezado anuncia extremos de arista. En
cambio, la salida detallada enumera por celda las tres razones, presencia de
kernel y áreas y volúmenes de poliedro, envolvente y kernel. La existencia de
esa ruta no valida automáticamente todos sus valores.

#pendiente[Exportación: corregir y probar la correspondencia entre columnas y
  valores de `createStats`, incluidos separadores y extremos de arista. Definir
  por separado reducción de celdas y uso de vértices de frontera. Antes del
  capítulo experimental, contrastar cada fila con el registro detallado y
  registrar por separado el tiempo de estadísticas y exportaciones auxiliares.]

= Visualización y trabajo de integración <sec:ac-visualizacion>

El renderer combina OpenGL, GLFW e ImGui en una aplicación con visor y paneles
de información y herramientas. Su acción `Start`, para la opción Cavity,
ejecuta `CavityAlgorithm`, recupera los propietarios, actualiza los colores y
calcula estadísticas. Las opciones Face y Edge están visibles, pero muestran
`Not implemented`. La disponibilidad de controles en pantalla no equivale,
por tanto, a disponer de las tres variantes.

Las acciones para centrar la vista, mostrar vecinos o circunsfera, aislar una
celda y añadir un plano contienen solo comentarios. El panel de memoria muestra
`N/A`. Esos controles no son funcionalidades terminadas, y la visualización no
prueba que la construcción se ejecute en GPU.

El `README.md` mantiene como tareas abiertas añadir mallas de prueba, visualizar
la envolvente convexa, las cavidades y los tetraedros aislados, centrar la cámara
en un poliedro, corregir los controles de zoom y clic, y adaptar Face y Edge.
Marca como completados el cálculo de volumen, el cálculo de envolvente convexa
y la incorporación de cálculos a la visualización. Esa lista expresa el estado
de seguimiento del repositorio; los detalles y limitaciones de las funciones
se han descrito aquí desde el código.

#pendiente[Integración y visualización: incorporar las tareas abiertas del README
  a una verificación funcional. Conectar cada acción del visor con una operación
  comprobable; añadir vistas de cavidad, envolvente y celdas aisladas; revisar
  cámara y selección. Incorporar nuevas mallas de prueba y completar adaptadores
  Face y Edge antes de ofrecer comparaciones entre variantes desde la interfaz.]

= Propuesta de versión paralela <sec:ac-paralelo>

Esta sección es un diseño propuesto para el objetivo específico 5 y la cuarta
pregunta de investigación. No describe una implementación paralela disponible.
El esquema conceptual se apoya en la separación entre cálculos locales,
crecimiento con conflictos y construcción de salida revisada en
@sec:ea-paralelo. No se trasladan al algoritmo de esta tesis garantías de las
cavidades de inserción de Delaunay, porque aquí la operación es una asignación
de tetraedros existentes.

Se propone comenzar por los cálculos de circunsfera: cada tarea leería los
cuatro vértices de un tetraedro y escribiría su centro y radio en una posición
propia. La ordenación produciría prioridades globales, con un desempate por
índice especificado explícitamente. Esta adición sería una decisión nueva:
antes de comparar salidas se debería fijar el mismo desempate en la referencia
secuencial.

Para sustituir la recursión se propone una lista de trabajo de pares
`(semilla, tetraedro)`. Cada ronda examinaría las caras vecinas y generaría
propuestas de incorporación con el predicado ya definido. Las propuestas pueden
coincidir en un mismo tetraedro; ejecutar en paralelo la escritura ordinaria de
`owners` no resuelve esa competencia. Se propone separar la producción de
candidaturas de su aceptación, arbitrar las coincidentes con prioridades y
publicar después el estado de propiedad aceptado.

La prioridad por sí sola no demuestra equivalencia con el recorrido secuencial.
Un tetraedro reclamado puede ser el acceso que otra región necesita para
alcanzar vecinos posteriores. Por ello, un diseño que permita reemplazar
propietarios tendría que retirar o recalcular las expansiones dependientes;
uno que solo acepte propietarios definitivos tendría que demostrar que su
selección no contradice las prioridades pendientes. Se propone estudiar primero
un esquema por lotes de regiones sin tetraedros candidatos compartidos,
posponiendo las regiones en conflicto. La equivalencia, la terminación y el
costo de descubrir esos lotes quedan por establecer.

Para generar las listas de salida se propone contar por región los tetraedros y
caras aceptados, calcular desplazamientos mediante sumas prefijas y llenar
arreglos aplanados. Los vértices podrían deduplicarse mediante pares
`(región, vértice)` ordenados, en lugar de mantener un `std::set` por tarea. Esta
representación debe distinguir caras internas, interfaces entre regiones y
frontera exterior. La propuesta reutiliza los índices de entrada, pero requiere
implementar la compactación y definir quién escribe cada incidencia.

Se propone validar primero propiedad exclusiva y reproducibilidad en memoria
compartida, antes de abordar transferencias y granularidad en GPU. La evaluación
debería distinguir tiempo del núcleo y tiempo de extremo a extremo, incluyendo
lectura y transferencias. Es una secuencia de desarrollo propuesta.

#pendiente[Diseño paralelo: escoger con el autor el contrato de corrección:
  igualdad de partición con la referencia secuencial o partición válida bajo una
  nueva prioridad por rondas. Formalizar progreso y resolución de conflictos;
  implementar casos con regiones superpuestas y comprobar cobertura, exclusividad,
  conectividad y reproducibilidad al variar hilos. Solo después medir tiempo por
  fase, trabajo repetido, rondas, memoria máxima y transferencias, con tamaño de
  problema fijo y creciente. No se han ejecutado estas mediciones.]

// Trazabilidad factual (fuentes relativas a la raíz del workspace):
// A01 Alcance e hipótesis: InformeTesis/main.typ:147-211, 240-248;
//     propuesta.pdf, secciones 4-8 (antecedente de planificación).
// A02 Interfaz y tipos: 3D-GPolylla/include/gpolylla/polylla.h:15-148.
// A03 Generalización proyectada: 3D-GPolylla/README.md:11-21;
//     docs/superpowers/specs/2026-07-28-gpolylla-redesign-design.md:5-23.
// A04 Circunsfera y aceptación: 3D-GPolylla/src/cavity.cpp:9-45;
//     3D-GPolylla/src/utils.h:18-25; polylla.h:15-18,123-129.
// A05 Bowyer-Watson: literatura/texto/P070-si2015tetgen.txt:561-577.
// A06 Semillas y prioridad: 3D-GPolylla/src/cavity.cpp:104-144.
// A07 DFS, frontera, unicidad y conectividad: src/cavity.cpp:63-100,119-144.
// A08 Flujo activo y accesores: src/cavity.cpp:235-250; polylla.h:132-148.
// A09 Cotas deducidas: src/cavity.cpp:63-144 (no mediciones).
// A10 Reparación inactiva/provisional: src/cavity.cpp:147-205,241.
// A11 Pruebas existentes: test/cavity_test.cpp:11-31;
//     test/tetgen_test.cpp:11-20; test/visf_writer_test.cpp:31-109.
// A12 Lectura y conectividad: src/reader.cpp:15-162,186-195;
//     src/neighbours.cpp:1-44 (comentado).
// A13 Biblioteca/opciones/dependencias: CMakeLists.txt:1-29;
//     src/CMakeLists.txt:2-81; src/stat.cpp:4.
// A14 Exportación VisF: src/writer.cpp:14-119; utils.h:60-121.
// A15 CLI/tiempos: src/exe/main.cpp:247-342; OFF/detalle:130-250.
// A16 Logger: src/logger.h:1-10; src/logger.cpp:10-25.
// A17 Áreas y volumen firmado: src/mesh.cpp:172-216; utils.h:50-58.
// A18 Hull/área/volumen superficial: src/stat.cpp:17-75.
// A19 Kernel/ausencia: src/stat.cpp:77-149,165-179.
// A20 Razones y denominadores: src/stat.cpp:181-201; stat.h:36-43.
// A21 Agregados visor: src/renderer/main.cpp:1318-1368.
// A22 Cobertura y errores CSV: src/exe/main.cpp:27-125; detalle:194-241.
// A23 Visor/acciones pendientes: src/renderer/main.cpp:1557-1670;
//     README.md:11-21. Paralelismo: diseño propuesto, sin resultados.
