= Alcance y preguntas de evaluación <sec:ex-alcance>

La campaña evalúa particiones de una misma malla tetraédrica, con idéntico
contrato de pertenencia y evaluador geométrico. Se distinguen corrección de la
partición, calidad, reducción y costo. Un fallo no se transforma en una celda
unitaria para completar una salida inválida, y una métrica indefinida no se
sustituye por cero. Los resultados se limitan a geometría y ejecución secuencial;
no constituyen una validación numérica de VEM ni una medición de aceleración
paralela.

#figure(
  table(
    columns: (0.7fr, 2fr, 2fr), inset: 4pt,
    table.header([*Pregunta*], [*Experimento*], [*Observable*]),
    [1], [E0 y E1: corrección y semillas], [Partición, volumen, kernel, reducción y aislados],
    [2], [Evaluador común y E6], [Pertenencia, capacidades por componente y construcción aplanada],
    [3], [E2, E4 y E5], [Calidad sintética y real, fallos, tiempo y memoria],
    [4], [E8 condicionado], [Sin variante paralela validada; no se mide aceleración],
  ), caption: [Preguntas de investigación y alcance efectivo de la campaña.],
) <tab:ex-preguntas>

Los criterios se fijaron antes de las mediciones principales. La partición debe
cubrir cada tetraedro exactamente una vez, contener celdas conexas por caras y
exponer únicamente las caras de multiplicidad uno dentro de cada celda. Se
verifica la conservación de volumen con tolerancia relativa $10^(-9)$ y se
registran rechazos con su causa. Estas condiciones no demuestran simplicidad de
toda frontera ni admisibilidad para un método numérico.

Para la hipótesis de calidad se conservó el umbral propuesto de una ventaja de
al menos cinco puntos porcentuales en la mediana de diferencias pareadas de
$f_K$, con intervalo del 95 % enteramente positivo, en al menos tres familias
sintéticas y en la muestra real. La reducción se contrasta frente a un margen de
diez puntos porcentuales respecto de Face. Estos umbrales no se ajustaron al
observar resultados desfavorables.

= Métricas y reglas de interpretación <sec:ex-metricas>

Para $N_T$ tetraedros y $N_P$ celdas se define $R=1-N_P/N_T$. Se conservan también
la distribución de tetraedros por celda y la fracción de celdas unitarias. Los
identificadores de entrada se remapean sin posiciones ficticias. Todos los
comparadores entregan un entero por tetraedro; ese archivo permite reconstruir
la misma representación y aplicar el mismo verificador y evaluador.

El evaluador común usa coordenadas y acumulaciones en doble precisión. Orienta
cada triángulo exterior mediante el vértice opuesto de su tetraedro incidente.
El volumen de una celda es la suma de valores absolutos de los volúmenes de sus
tetraedros. El kernel se obtiene como intersección de semiespacios exteriores,
con un problema lineal de centro de Chebyshev y construcción geométrica mediante
Qhull. Las coordenadas se trasladan al promedio de los vértices y se normalizan
por la diagonal de la caja de la celda. Un resultado vacío de la construcción
geométrica, por sí solo, no certifica ausencia de kernel.

En celdas de un solo tetraedro numéricamente dudosas se comprueba la orientación
con aritmética racional exacta sobre las coordenadas binarias de entrada. Si no
son coplanares, la convexidad demuestra que el kernel es la propia celda y la
razón de volúmenes vale uno. Se conservan sus cuatro caras, evitando una fusión
por tolerancia que colapse tetraedros muy delgados. Esta resolución analítica
se aplica uniformemente y queda registrada junto a los resultados primarios.

Se exportan cuatro estados:

- *Presente:* kernel tridimensional de volumen positivo, con verificaciones de
  factibilidad y de la razón de volumen.
- *Ausente confirmado:* incompatibilidad de semiespacios con margen negativo
  superior a la tolerancia numérica adoptada.
- *Indeterminado:* margen cercano a cero, posible degeneración del kernel o
  construcción geométrica sin confirmación suficiente.
- *Error:* el cálculo no produjo una métrica utilizable y se conserva su causa.

Toda ausencia primaria se verifica además con una combinación dual no negativa
de los semiespacios. Su cota mínima en la caja normalizada $[-1,1]^d$ debe ser
positiva, descontando el error de acumulación flotante y superando $10^(-8)$.
Se conservan los pesos, el residuo y el margen. Una ausencia no certificada pasa
a indeterminada en un registro derivado, mientras la salida primaria permanece
intacta. Esta auditoría uniforme precede al análisis y no modifica los umbrales
de las hipótesis.

El umbral de margen es $10^(-8)$ en coordenadas normalizadas. Si $N_+$ cuenta
presencias confirmadas y $N_u$ reúne indeterminados y errores, la fracción se
informa mediante

$ f_K^- = N_+ / N_P, quad f_K^+ = (N_+ + N_u) / N_P. $

Estas cotas expresan incertidumbre numérica; no son intervalos de confianza
estadísticos. La comparación de kernel entre dos variantes usa también la
cota conservadora $f_(K,C)^- - f_(K,B)^+$. Los promedios y cuantiles de métricas
parcialmente definidas conservan su número de observaciones válidas.

Se exporta $V(K)/V(P)$ además de la razón histórica inversa, que permanece
indefinida si el kernel tiene volumen nulo. Se calculan arista mínima/máxima,
área de celda/envolvente, diámetros de caras y celda, y números de caras y
aristas. Los conteos y razones se informan tanto sobre la triangulación exterior
como tras unir triángulos coplanares adyacentes y retirar subdivisiones
colineales. Una frontera fusionada con agujeros o ramificaciones deja sus
métricas sin valor; no altera el estado del kernel tridimensional.

Las componentes $rho_1$, $rho_2$ y $rho_3$ siguen las ecuaciones (29)–(31) de
@sorgente2022polyhedral. Se usan el volumen relativo del kernel, las escalas
geométricas y los conteos de frontera. El indicador global sigue su ecuación
(32):

$ rho = sqrt(1/N_P sum_(P) rho_1(P)(rho_2(P)+rho_3(P))/2). $

Cuando hay contribuciones indefinidas se informa una cota para la malla completa
permitiendo que cada contribución faltante pertenezca a $[0,1]$. Los resúmenes
condicionados a celdas resueltas se identifican aparte. La razón de superficies
se conserva como descriptor geométrico, sin convertirla en un criterio suficiente
de aptitud para VEM.

= Conjunto de entradas y comparadores <sec:ex-datos>

Las ocho mallas legadas se usan para regresión: `basic`, `minimal`, `3D_100`,
`socket`, `1000points`, `1000points07`, `mage` y `angel`. No se atribuye procedencia
real a sus nombres. Las familias sintéticas reproducen el diseño general de
@salinasfernandez2025exploring, usando TetGen 1.6.0 como triangulador común en el
cubo unitario y tamaños objetivo de 500, 1000, 5000, 10000 y 50000 vértices.

#figure(
  table(
    columns: (1fr, 2.4fr, 0.8fr), inset: 4pt,
    table.header([*Familia*], [*Construcción*], [*Mallas distintas*]),
    [Random], [Puntos uniformes y ocho esquinas; semillas 1–5], [25],
    [Poisson], [Muestreo Poisson-disk con radio calibrado; semillas 1–5], [25],
    [Grid], [Rejilla regular con $k=ceil(N^(1/3))$], [5],
    [Quality], [Refinamiento PLC del cubo; calidad 1.414 y volumen calibrado], [5],
  ), caption: [Conjunto sintético principal. Se conservan los tamaños efectivos de cada archivo.],
) <tab:ex-datos>

Grid y el refinamiento de Quality son deterministas bajo esta receta. Repetir
cinco veces su parámetro nominal de semilla produciría copias; por ello se usan
60 mallas distintas, sin tratar esas copias como observaciones independientes.
E1 compara radio creciente, decreciente, índice y permutación con semilla en los
tamaños objetivo 1000 y 10000.

Para E4 se parte del subconjunto de 1806 superficies de Thingi10K distribuido con
el estudio de kernel de @sorgente2022polyhedron. Antes de medir calidad se
sortearon 180 candidatos sin reemplazo, con semilla 1, y se añadieron los dos
modelos de referencia del plan. El filtro exige una componente, superficie
cerrada, género cero, ausencia de degeneraciones y tamaño del archivo OFF distribuido inferior a 1 MB. Se
registra la licencia individual y se comprueban intersecciones con TetGen antes
de generar tetraedros. Esta ruta no repara superficies defectuosas.

De 182 candidatos, 142 cumplieron el preprocesamiento. Se formaron terciles por
número efectivo de tetraedros y se sortearon 20 modelos por estrato. Se añadió
una referencia no seleccionada previamente: 61 modelos en total, de los cuales
60 integran las inferencias principales. Los 40 rechazos y sus causas permanecen
en el manifiesto. El preprocesamiento admite entre $10^4$ y $10^6$ tetraedros,
solicitando calidad 1.414, con límite de 150000 puntos Steiner, 600 segundos y 2 GiB de espacio
de direcciones por candidato. La selección describe este subconjunto aceptado,
no todos los modelos de Thingi10K. La opción de calidad solicitada al mallador
no se interpreta como una certificación independiente de la calidad de cada
tetraedro, especialmente bajo el límite de puntos Steiner.

Los comparadores principales son Face por área y radio inscrito geométrico,
antes y después de reparar, Edge como implementación de referencia no
publicada, y una agregación de pares inspirada en @sorgente2022polyhedral. Face
se parametrizó fuera del checkout de referencia y se portó a C++. Se normaliza
su puntuación máxima y se redondea a $10^(-12)$ antes de desempatar por índice
canónico de cara; así se evita que diferencias de redondeo entre lenguajes
resuelvan de forma distinta los empates de Grid.

La expresión histórica de Face para el radio inscrito utiliza lados al cuadrado
en la fórmula de Herón. La comparación principal emplea el radio geométrico y
declara esta corrección; no se identifica silenciosamente con aquella expresión.
La regresión contiene 128 comparaciones C++/Python: 101 particiones idénticas y
27 rechazos coincidentes de reparación. No hubo discrepancias entre particiones
aceptadas. Los fallos de reparación permanecen como resultados de la campaña.

= Protocolo reproducible <sec:ex-protocolo>

La plataforma efectiva es Ubuntu/WSL sobre Windows, en lugar del Mac previsto
inicialmente. El manifiesto conserva CPU y memoria expuestas a WSL, sistema,
compilador, opciones Release, revisiones de dependencias, fuentes congeladas y
SHA-256 de binarios, entradas y pertenencias. Las revisiones de QuickHull y
polyhedron-kernel se fijaron por commit. El código de referencia `3D-Polylla` se
conservó sin modificaciones y TetGen se compiló desde una copia externa.

E0 comprende once pruebas C++ y trece pruebas Python, que abarcan geometría,
CSV, análisis estadístico, certificados duales y preservación de los datos
primarios durante la auditoría. Incluye cubo, dominio en L con kernel
conocido y dominio en U sin kernel. La validación sobre el nivel más grueso del conjunto publicado de
@sorgente2022polyhedral reconstruyó sus 175 tetraedros y 140 agregados,
con volumen total uno y presencia de kernel en todas esas celdas. Se verificó
también la componente de conteo $rho_3=1$ en los tetraedros. Esto verifica la
importación y casos geométricos del conjunto; no reproduce una simulación VEM.
Una validación adicional de 48 casos mantuvo
la partición canónica bajo las cuatro familias, cuatro órdenes, tres escalas y
traslación. Las pruebas y el piloto preceden a las inferencias; no sustituyen
los controles de cada corrida.

Cada pareja de malla y variante se ejecuta dos veces en procesos independientes,
conservando igualdad de partición canónica antes de evaluar calidad. El evaluador
es común a todas las variantes. Se permiten cuatro trabajadores de calidad, con
límite de 1800 segundos por tarea y 3 GiB de espacio de direcciones por proceso.
Esos tiempos concurrentes no se usan como evidencia de eficiencia del núcleo.

E5 se ejecuta después de terminar las etapas de calidad y de forma secuencial.
Por entrada y variante se realiza un calentamiento y diez procesos medidos,
rotando el orden de variantes y dejando dos minutos de reposo entre bloques.
La lectura, construcción con validación, comprobación adicional y escritura de
pertenencia se registran por separado. GNU time mide el máximo residente en
KiB, convertido a MiB al presentar resultados. El presupuesto por proceso es de
30 minutos y 75 % de la memoria de WSL como límite de espacio de direcciones.
No se confunde este límite con el RSS observado. No se controlan la temperatura
ni las cargas ajenas a la campaña del sistema anfitrión.

Para los tamaños núcleo de E5 se mide además una ejecución independiente del
evaluador, separando lectura, estadísticas acumuladas por celda y
agregación/exportación. No se suma ese proceso Python a un tiempo nativo como si
fuera una misma ejecución. Solo se comparan tiempos C++ entre Cavidades y Face;
Edge Python participa en calidad.

Una ejecución del núcleo experimental tiene la forma siguiente, desde
`3D-GPolylla/`, con el directorio de salida creado previamente:

```sh
build/src/exe/GPolyllaExperiment \
  entrada.node entrada.ele cavity-ascending salida/cavity 1
build/src/exe/GPolyllaExperiment \
  entrada.node entrada.ele face-incircle-repair salida/face 1
```

Se exportan pertenencia, tiempos y logs. E6 construye efectivamente listas
aplanadas y compara sus capacidades con las listas actuales, manteniendo
idénticos los arreglos comunes. Un inventario separado distingue entrada, copia
común de salida y auxiliares retenidos. El tiempo de la muestra aplanada incluye reservar, llenar y liberar los
contenedores; no es una comparación de velocidad. Estos conteos no incluyen
metadatos del asignador ni representan el pico del proceso; ese pico se conserva mediante RSS.

La unidad de análisis estadístico es la malla. Se usan diferencias pareadas,
10000 remuestreos bootstrap para intervalos del 95 % de la mediana y una semilla
fija. La prueba de Wilcoxon usa parejas sin estados de kernel indeterminados o
erróneos, con corrección de Holm sobre las cuatro familias y la muestra real
por comparador. Se informa también cobertura de parejas; un resultado sobre un
subconjunto aceptado no se convierte en evidencia de toda la población prevista.
En la muestra real el remuestreo conserva los estratos. En Random y Poisson
se añade una sensibilidad por grupos de semilla entre tamaños, pues reutilizar
la misma semilla puede correlacionar generaciones de distinta densidad. El
contraste principal por malla sigue el plan; la sensibilidad no modifica sus
umbrales y limita la interpretación de los valores p nominales. Grid y Quality
son familias deterministas con cinco tamaños observados, no cinco réplicas
aleatorias por tamaño.
Las razones de tiempos se obtienen de medianas por entrada y variante. Los
fallos nunca se incorporan como tiempos o calidades nulos.

= Resultados y contraste <sec:ex-tablas>

#[
  #set par(justify: false)
  #show figure.where(kind: image): set figure(placement: top)
  #include "resultados-campana.typ"
]

== Corrección, cobertura y fallos

E1/E2 procesaron 492 tareas y E4 otras 427: las 919 combinaciones previstas
recibieron un resultado o un fallo con causa. Tras la auditoría, 662 salidas
quedaron completas, cuatro conservaron errores parciales de métrica y 253
fallaron. Estas últimas comprenden 200 particiones incompletas, 51 particiones
no conexas y dos rechazos de tetraedros degenerados por el lector nativo. Un
fallo no cuenta como una observación geométrica válida.

Cavidades completó las 60 mallas sintéticas principales y las 72 ejecuciones
adicionales de órdenes. En la muestra real aceptó 58 de 60 modelos estratificados,
además de la referencia suplementaria. Rechazó los modelos 37274 y 314440 por
volumen tetraédrico degenerado en la aritmética del lector. Face sin reparación
produjo particiones en los 60 modelos estratificados; esto no elimina la
necesidad de verificar sus métricas. Las reparaciones de Face tuvieron baja
cobertura: 3/60 y 4/60 salidas reales válidas según criterio. Edge produjo 14/60.
No se generalizan sus comparaciones desde ese subconjunto al conjunto previsto.

La auditoría confirmó las 178596 ausencias primarias mediante certificados
duales y resolvió analíticamente 41 tetraedros delgados. No degradó ausencias
por falta de certificado. Permanecen 38 celdas con error de métrica en cuatro
particiones Face de los modelos 106559 y 37274. Las cotas de kernel incluyen
esas celdas y los estados indeterminados. El verificador comprueba hashes,
pertenencias, cobertura de tareas y consistencia entre CSV detallados y JSON;
no convierte los errores restantes en una certificación geométrica completa.

== Órdenes de semillas

E1 compara cada orden con radio creciente sobre diez entradas Random, diez
Poisson, dos Grid y dos Quality. En Random, el radio decreciente aumenta la
reducción una mediana de 10.67 puntos porcentuales, pero su diferencia de
fracción de kernel queda acotada por medianas de −6.69 y −4.26 puntos. En
Poisson, el aumento de reducción es 10.66 puntos y las medianas de las cotas de
diferencia de kernel son −2.11 y −0.51 puntos. El orden por índice y la
permutación también aumentan la reducción a costa de menor kernel confirmado
en esas familias. Grid conserva ambas magnitudes para todos los órdenes.

Estos resultados apoyan el radio creciente como compromiso operativo para
priorizar kernel en las entradas aleatorias evaluadas. No prueban optimalidad
del orden, ni que una cavidad siempre sea estrellada. Los resultados por malla
permiten distinguir el efecto de semillas de un cambio de algoritmo.

== Calidad y reducción frente a comparadores

Las medianas de reducción de Cavidades son 80.18 %, 78.06 %, 83.33 % y 77.21 %
en Random, Poisson, Grid y Quality. Las medianas de las cotas de kernel son,
respectivamente, 98.58–99.43 %, 99.16–99.73 %, 100–100 % y 99.60–99.90 %.
En los 58 modelos reales aceptados, la reducción mediana es 76.54 % y las
medianas de las cotas de kernel son 99.52–99.93 %. Las medianas de las dos
cotas no constituyen un intervalo de confianza de un parámetro poblacional.

La hipótesis H3a exige una ventaja mediana conservadora de cinco puntos
porcentuales, con intervalo positivo, en tres de cuatro familias y en datos
reales. Frente a Face por área, las ventajas conservadoras son 4.93, 1.42, 0 y
0.37 puntos en las cuatro familias: ninguna alcanza cinco. Frente a Face por
radio, Random alcanza 5.08 puntos, con IC95 % de 4.68–6.56; Poisson, Grid y
Quality quedan en 1.99, 0 y 0.55 puntos. Por ello H3a no queda respaldada con el
umbral fijado, aun cuando varias diferencias son positivas.

En las 58 parejas reales disponibles, la ventaja conservadora frente a Face
área es 1.93 puntos, IC95 % de 0.98–2.79, y frente a Face radio es 1.76 puntos,
IC95 % de 1.04–2.91. Ninguna cumple el efecto exigido; además faltan dos parejas
respecto del diseño. Los intervalos bootstrap describen las parejas observadas,
condicionados al preprocesamiento y a la aceptación de ambos procedimientos.
La sensibilidad agrupada por semilla no revierte el signo de las ventajas en
Random y Poisson. El contraste de Wilcoxon queda sin estimar cuando ninguna
pareja tiene kernel completamente resuelto; un valor ausente no se interpreta
como aceptación de igualdad.

El compromiso aparece en la reducción. Frente a Face área, Cavidades pierde
medianas de 7.19 puntos en Random, 4.73 en Poisson y 2.39 en Quality, y gana
33.33 en Grid. Frente a Face radio, las diferencias son −4.66, −2.34, +33.33 y
−1.41 puntos. Las medianas satisfacen el margen descriptivo de −10 puntos de
H3b. Sin embargo, frente a Face área solo 76 % y 92 % de las mallas Random y
Poisson cumplen ese margen individualmente; no se afirma no inferioridad
uniforme. En las parejas reales las diferencias medianas son −4.02 y −2.64
puntos, con cumplimiento individual del margen en 70.69 % y 81.03 %.

Edge y Pares alcanzan kernel confirmado en todas las celdas de sus salidas
válidas, con menor reducción que Cavidades salvo el empate Grid de Edge.
Pares reduce aproximadamente 20 % por construcción y no persigue el mismo
nivel de agregación. Estos resultados muestran que una fracción alta de kernel
no basta para elegir una estrategia sin considerar reducción, cobertura y costo.

== Recursos y representación

E5 produjo 700 mediciones en 70 grupos de diez. La pertenencia fue estable en
cada grupo y coincidió con calidad en las 34 comparaciones que compartieron una
partición de referencia. @tab:ex-recursos muestra los mayores tamaños del
conjunto núcleo por variante. La lectura, el algoritmo con validación, la
comprobación adicional y la escritura se conservan por separado.

La ventaja temporal de H3c depende de la familia. En Quality, el primer tamaño
con intervalo de la razón Cavidades/Face completamente bajo uno fue un millón
de vértices objetivo para Face radio y dos millones para Face área. A cuatro
millones objetivo, Cavidades tomó 67.11 s de algoritmo, frente a 71.24 s y
72.34 s de Face. Las razones fueron 0.942 (IC95 % 0.936–0.952) y 0.928
(IC95 % 0.922–0.937). En Random, las razones no mostraron ventaja de Cavidades
frente a Face sin reparación. En su mayor entrada, Cavidades tomó 64.95 s
frente a 39.77 s y 39.98 s, con razones de 1.633 y 1.625. Las reparaciones
exitosas de entradas pequeñas fueron más lentas y los rechazos limitaron su
cobertura a tamaños bajos.

A cuatro millones objetivo, la lectura dominó el tiempo nativo total. Cavidades
leyó la entrada Random en 461.69 s de una mediana total de 554.05 s. Las 34
mediciones independientes del evaluador permiten separar ese costo de las
estadísticas. En Random de 50000 vértices, las estadísticas por celda de
Cavidades sumaron 112.62 s en la ejecución Python instrumentada.

#figure(
  table(
    columns: (0.9fr, 1fr, 1fr, 1.7fr), inset: 4pt,
    table.header([*Familia*], [*Vértices efectivos*], [*Tetraedros*], [*Límite al intentar 8 millones objetivo*]),
    [Random], [4000000], [27021939], [Fallo de asignación en los tres calentamientos nativos],
    [Quality], [3984891], [24249602], [Generación y calibración superaron 1800 s],
  ), caption: [Mayor tamaño con diez repeticiones por algoritmo principal y primer límite de escala bajo el presupuesto de E5.],
) <tab:ex-limites>

Cavidades alcanzó un RSS máximo de 10.55 GiB en Random y 9.35 GiB en Quality
para esos tamaños. Random de ocho millones produjo una malla con 54063945
tetraedros. El recolector original de metadatos agotó memoria al leer entero
el archivo de elementos. Se recuperaron encabezados y hashes por flujo y se
usó la malla generada. En los calentamientos posteriores los tres binarios
reportaron `std::bad_alloc` bajo el límite de espacio de direcciones. En
Quality, el límite se alcanzó antes de disponer de una entrada calibrada.
Estos son límites operacionales del entorno y la receta de campaña.

En E6, aplanar las listas por celda redujo su capacidad entre 30.9 % y 51.3 %
según familia. Al incluir entrada, copia común y auxiliares, la reducción del
inventario retenido fue entre 3.4 % y 8.0 % (@tab:ex-memoria). La reserva,
llenado y liberación de los contenedores adicionales tomó entre 1.01 y 1.67 ms
por caso. Esta medición aísla el costo de construir el contenedor. El ahorro
en el total retenido se calcula sustituyendo las capacidades de las listas.
Un backend que use solo esa representación requiere su propia medición de RSS.

Durante E5 el sistema de archivos WSL pasó a solo lectura mientras se generaba
la entrada Random de dos millones de vértices objetivo. Se conservaron las 290
repeticiones terminadas y se retomaron las tareas pendientes tras recuperar la
escritura. Ese incidente de infraestructura no se cuenta como un fallo de
Cavidades o Face. El manifiesto registra la interrupción; el estado del sistema
anfitrión limita la interpretación de pequeñas diferencias temporales.


= Extensiones y límites del alcance

#figure(
  table(
    columns: (0.6fr, 1.2fr, 2.6fr), inset: 4pt,
    table.header([*ID*], [*Extensión*], [*Estado y consecuencia*]),
    [E3], [Voronoi], [Extensión opcional excluida del núcleo; no se presenta como comparador medido],
    [E7], [VEM], [Sin solver validado al cierre de E2; no se afirma convergencia ni aptitud numérica],
    [E8], [Paralelismo], [Sin implementación paralela validada; no se calcula aceleración],
  ), caption: [Extensiones excluidas conforme a las condiciones del plan.],
) <tab:ex-paralelo>

Los datos geométricos no verifican por sí solos la convergencia de VEM. La
selección real excluye modelos que no superaron el preprocesamiento y la
reparación de Face puede excluir otras parejas; ambas condiciones limitan la
generalización. Los manifiestos y registros detallados permiten separar una
hipótesis no respaldada, un cálculo indeterminado y una ejecución fallida.
