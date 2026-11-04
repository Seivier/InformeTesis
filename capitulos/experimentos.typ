#import "pendiente.typ": pendiente

= Alcance y preguntas de evaluación <sec:ex-alcance>

Este capítulo establece un diseño experimental para contrastar la hipótesis de
la introducción. Los guiones de las tablas indican ausencia
de medición, nunca un valor nulo. El objeto de evaluación será la construcción
secuencial descrita en @sec:ac-algoritmo; la reparación y el diseño paralelo
requieren desarrollos adicionales antes de incorporarse como variantes. Las cuatro preguntas requieren, respectivamente, validar la construcción,
comparar representaciones, evaluar viabilidad y comprobar el diseño paralelo.
La @tab:ex-preguntas establece sus observables.

#figure(
  table(
    columns: (0.6fr, 2fr, 2fr), inset: 5pt,
    table.header([*Pregunta*], [*Observables propuestos*], [*Comparación necesaria*]),
    [1], [Partición, conectividad y kernel],
    [Órdenes de semillas; con y sin reparación validada],
    [2], [Memoria y tiempos por fase],
    [Vectores actuales frente a listas aplanadas futuras],
    [3], [Reducción, calidad, fallos y recursos],
    [Cavidades, Face y Edge; igual entrada],
    [4], [Corrección, tiempo y conflictos],
    [Secuencial frente a paralela futura],
  ), caption: [Relación entre preguntas y verificaciones propuestas.],
) <tab:ex-preguntas>

Se distinguirán validez topológica, calidad y costo. Reducir celdas no bastará
para sostener la hipótesis si aumentan los fallos o se pierde calidad. La aptitud
para VEM requerirá validación numérica, según @sec:ea-numericos.

Antes de medir se propone fijar criterios de aceptación: cada tetraedro válido
pertenecerá a una sola celda, cada celda será conexa por caras y su frontera se
contrastará con las incidencias del conjunto de tetraedros. Se comprobará la
conservación del dominio mediante volúmenes con orientación controlada. Los
casos que incumplan estas verificaciones se registrarán como fallos; no se
incorporarán silenciosamente a promedios de calidad.

#pendiente[Validación inicial: implementar un verificador de cobertura,
  exclusividad, conectividad y frontera; contrastarlo con mallas pequeñas de
  solución inspeccionable. Definir con el autor tolerancias y criterios de
  aceptación antes de procesar el conjunto completo. Registrar entradas
  rechazadas y causa de rechazo.]

= Métricas y reglas de interpretación <sec:ex-metricas>

Para una entrada con $N_T$ tetraedros válidos y una salida con $N_P$ poliedros,
se propone medir la reducción $R = 1 - N_P / N_T$ y la razón $N_T / N_P$,
siempre que ambos conteos sean positivos. Se registrarán mínimo, mediana y máximo
de tetraedros por celda y la fracción de celdas con un único tetraedro. Los
conteos se obtendrán de elementos válidos, sin confundirlos con posiciones
reservadas de los vectores. El lector actual puede insertar un elemento ficticio
para numeración desde uno; esta condición deberá resolverse antes de medir. Para el kernel se propone registrar $f_K = N_K / N_P$, donde $N_K$ cuenta
celdas con kernel calculado no vacío, acompañado por la cantidad de cálculos
fallidos o indeterminados. La implementación representa la presencia de kernel
mediante un registro opcional que depende de los vértices devueltos por la
biblioteca externa. Por ello, $f_K$ describirá inicialmente ese procedimiento,
cuya validación con casos analíticos es un requisito previo. Las razones disponibles son las de @sec:ac-metricas: arista mínima sobre máxima,
volumen del poliedro sobre volumen del kernel y área del poliedro sobre área de
su envolvente convexa. La razón volumétrica no mide volumen del poliedro sobre
volumen de la envolvente. Se propone informar sus distribuciones por malla,
separando celdas sin kernel, denominadores nulos y valores no finitos. No se
promediará el cero que el código usa como sustituto de kernel ausente junto con
razones volumétricas definidas. El ejecutable cronometra lectura, algoritmo y escritura en milisegundos; su suma
no incluye el cálculo de estadísticas. Se propone conservar esos tres tiempos
y añadir tiempo completo del proceso y tiempo de estadísticas por separado.
La memoria se evaluará mediante el máximo residente del proceso y un inventario
de contenedores, distinguiendo entrada, salida, auxiliares y copias. Para comparar
representaciones, se conservarán idénticos algoritmo, entrada y opciones. Se informará mediana e intervalo intercuartílico temporal por entrada. La calidad
se resumirá por malla para no confundir variabilidad de ejecución y geométrica.

#pendiente[Instrumentación: corregir `createStats` y verificar encabezados,
  separadores y valores; añadir conteos por celda y memoria máxima. Validar
  orientación, kernel y razones con casos analíticos. Probar un lector del CSV
  detallado que descarte la columna vacía final y separe estados inválidos.]

= Conjunto de entradas y comparadores <sec:ex-datos>

La @tab:ex-datos transcribe exclusivamente el primer campo de los encabezados
`.node` y `.ele` locales. Son cantidades declaradas de entrada, no mediciones de
salida ni evidencia de validez de los archivos. El nombre de un archivo no se
utiliza para inferir su distribución espacial o su procedencia.

#figure(
  table(
    columns: (2fr, 1fr, 1fr), inset: 4pt,
    table.header([*Prefijo en `data/`*], [*Vértices*], [*Tetraedros*]),
    [basic], [8], [5],
    [minimal], [8], [5],
    [3D_100], [100], [535],
    [socket], [836], [2285],
    [1000points], [1000], [4374],
    [1000points07], [1000], [6274],
    [mage], [3881], [19211],
    [angel], [24979], [90087],
  ), caption: [Inventario declarado en los pares locales de archivos TetGen.],
) <tab:ex-datos>

Los casos pequeños servirán para inspección. Los restantes no constituyen una
serie de escalabilidad, pues cambian tamaño y geometría. Se propone generar
familias con dominio fijo, densidad creciente y semillas registradas; sus tamaños
se fijarán mediante un piloto. Como extensión se proponen distribuciones aleatorias, Poisson y regulares en un
cubo, junto con entradas con criterios de calidad controlados. P005 emplea esas
familias en su evaluación de Face @salinasfernandez2025exploring; ello justifica
considerarlas como diseño comparativo, sin afirmar que los archivos locales
pertenezcan a esas categorías. Se añadirían dominios no convexos y casos de
radios iguales, reescalamiento y tetraedros próximos a degeneración para estudiar
robustez. Cada entrada nueva deberá incluir origen, licencia, generador, opciones,
semilla, encabezados y huella del archivo. Los comparadores serán Face con área máxima y radio inscrito máximo de la cara,
según @sec:ta-criterios, y Edge una vez resuelto el pendiente documental de
@sec:ta-face-edge. Se evaluará la salida antes y después de reparar únicamente
cuando ambas rutas estén verificadas. El programa actual invoca directamente
`CavityAlgorithm`; no dispone de una opción de línea de comandos que seleccione
Face o Edge. Los resultados publicados del capítulo 3 serán contexto, no filas
comparables a mediciones locales realizadas con otro equipo o conjunto de datos.

#pendiente[Entradas y baselines: verificar índices y orientación de los ocho
  pares, registrar procedencia y huellas; preparar las familias controladas.
  Obtener la fuente primaria de Edge e integrar adaptadores Face y Edge con
  idéntico contrato de salida y evaluación. Documentar sus comandos reales solo
  cuando existan; no hay un comando de selección de variante en la CLI actual.]

= Protocolo reproducible <sec:ex-protocolo>

Se propone fijar la revisión del código,
las revisiones de dependencias, el compilador, sus opciones de optimización y la
configuración de construcción. El registro de hardware contendrá modelo de CPU,
núcleos físicos y lógicos, RAM, sistema operativo y almacenamiento. Si se
implementa una variante GPU se añadirán dispositivo, memoria, controlador y
entorno de compilación. Se propone realizar una ejecución de calentamiento y
diez repeticiones medidas
por combinación de entrada y variante, cada una en un proceso independiente.
Se alternará el orden de variantes y se mantendrán equipo, estado energético y
carga de fondo controlados. Se conservarán todas las observaciones; cualquier
exclusión deberá justificarse por una causa registrada. Los fallos y límites de
recursos se reportarán aunque impidan completar las repeticiones.

La CLI recibe `-n`, `-e` y `-o`; `--detail-stats` requiere además
`--make-stats` para producir detalle. Tras localizar el binario construido y
crear el directorio de salida, una ejecución futura desde `3D-GPolylla/` tendrá
la siguiente forma. La ruta del binario es la esperada para una construcción
CMake con directorio `build`; deberá comprobarse en el equipo final.

```sh
mkdir -p resultados/basic/r01
build/src/exe/GPolyllaExe \
  -n data/basic.node -e data/basic.ele \
  -o resultados/basic/r01/cavity.visf \
  --make-stats --detail-stats
```

El programa deriva `cavity.csv`, `cavity_detail/details.csv` y archivos OFF por
celda del nombre de salida. El tiempo externo incluirá esas exportaciones.
Se propone anteponer `/usr/bin/time -l` en macOS o `/usr/bin/time -v` en Linux,
verificando las unidades de memoria del equipo. Las ejecuciones sin estadísticas
se identificarán como otra configuración.

#pendiente[Campaña reproducible: el autor deberá fijar el equipo, resolver los
  requisitos de compilación de @sec:ac-arquitectura y validar las exportaciones.
  Después, ejecutar el comando indicado para cada prefijo y repetición, usando
  carpetas distintas, conservar salida estándar y errores, recursos y manifiesto
  de versiones. No iniciar la campaña antes de validar entradas y métricas.]

= Tablas previstas y criterio de contraste <sec:ex-tablas>

Las siguientes tablas fijan el formato de presentación. Cada fila se desagregará
por malla, variante, criterio y estado de reparación. Todas las celdas de
resultados permanecen vacías; no se extrapolan cifras de otros trabajos.

#figure(
  table(
    columns: (1.5fr, 1fr, 1fr, 1fr, 1fr), inset: 5pt,
    table.header([*Variante / malla*], [*$N_P$*], [*$R$*], [*$f_K$*], [*Aislados*]),
    [Cavidades / malla], [—], [—], [—], [—],
    [Face área / malla], [—], [—], [—], [—],
    [Face radio / malla], [—], [—], [—], [—],
    [Edge / malla], [—], [—], [—], [—],
  ), caption: [Plantilla de reducción y calidad; sin resultados.],
) <tab:ex-calidad>

#pendiente[Resultado de calidad (@tab:ex-calidad): definir, implementar y validar
  estados de kernel por celda —presente, ausente confirmado, indeterminado y
  error— y exportarlos en `details.csv`. Tras validar cada variante y su CSV,
  obtener conteos de pertenencia y contabilizar los cuatro estados exportados. Calcular reducción desde los
  conteos válidos y adjuntar distribuciones de las tres razones, con mínimos,
  medianas, máximos y casos excluidos explícitos.]

#figure(
  table(
    columns: (1.4fr, 1fr, 1fr, 1fr, 1fr), inset: 5pt,
    table.header([*Variante / malla*], [*Lectura*], [*Algoritmo*], [*Escritura*], [*RAM máx.*]),
    [Cavidades / malla], [—], [—], [—], [—],
    [Face / por criterio], [—], [—], [—], [—],
    [Edge / malla], [—], [—], [—], [—],
  ), caption: [Plantilla de recursos: tiempos en ms y memoria en MiB.],
) <tab:ex-recursos>

#pendiente[Resultado de recursos (@tab:ex-recursos): ejecutar la campaña de
  @sec:ex-protocolo, agregar mediana e intervalo intercuartílico por fase y
  memoria máxima; añadir tiempo completo y de estadísticas en una tabla
  complementaria. Para límites de tamaño, aumentar densidad dentro de cada
  familia y registrar el primer fallo, causa y último caso completado.]

#figure(
  table(
    columns: (1.5fr, 1fr, 1fr, 1fr), inset: 5pt,
    table.header([*Configuración futura*], [*Tiempo núcleo*], [*Tiempo completo*], [*Aceleración*]),
    [Secuencial / misma entrada], [—], [—], [—],
    [Paralela / hilos fijados], [—], [—], [—],
  ), caption: [Plantilla condicionada a implementar y validar paralelismo.],
) <tab:ex-paralelo>

#pendiente[Resultado paralelo (@tab:ex-paralelo): completar el contrato y la
  implementación de @sec:ac-paralelo, comprobar sus invariantes y ejecutar con
  tamaño fijo y creciente. Calcular aceleración como tiempo secuencial dividido
  por paralelo bajo el mismo alcance temporal; registrar hilos, rondas,
  conflictos y transferencias. No calcular aceleración sin una variante válida.]

