= Síntesis y alcance de la contribución <sec:co-sintesis>

El trabajo define e implementa una construcción secuencial por cavidades,
distinta de las regiones terminales y de las cavidades de inserción Delaunay.
Su definición operacional combina prioridad de semillas y aceptación de
circuncentros respecto de una esfera fija. La implementación añade desempates,
doble precisión, recorrido iterativo y reconstrucción final de fronteras.
El contrato de pertenencia permite comparar variantes con el mismo verificador
y evaluador, sin exigir que compartan su estructura interna.

La campaña de @sec:ex-alcance procesa 919 combinaciones previstas. Conserva
salidas, fallos y causas, audita las ausencias de kernel y separa incertidumbre
numérica de variación entre mallas. La hipótesis de mejora mínima de kernel no
queda respaldada con el umbral fijado. La contribución empírica es caracterizar
el compromiso entre kernel, reducción, cobertura y recursos de esta estrategia.

= Respuestas a las preguntas de investigación <sec:co-preguntas>

*Pregunta 1: construcción, semillas y refinamiento.* El control de propiedad y
el recorrido por caras producen cobertura exclusiva y conectividad en las
salidas aceptadas; el verificador comprueba sus fronteras. E1 confirma que el
orden importa: frente a radio creciente, radio decreciente aumenta la reducción
mediana unos 10.7 puntos en Random y Poisson, pero disminuye el kernel confirmado.
Grid no distingue esos órdenes en las entradas estudiadas. La reparación de
Cavidades sigue inactiva. Estas comprobaciones no prueban simplicidad de toda
frontera ni kernel no vacío para cualquier cavidad.

*Pregunta 2: representación y unificación.* Un entero de pertenencia por
tetraedro basta para reconstruir y evaluar todas las variantes experimentales.
Face y Edge se integran mediante herramientas y adaptadores; ello no equivale
a incorporar todos los algoritmos a la interfaz pública de la biblioteca.
E6 construye contenedores aplanados y mide sus capacidades, separando entrada,
copia común de salida y auxiliares retenidos. La capacidad de las listas por celda disminuye entre 30.9 % y 51.3 % en
los cuatro casos. Al contabilizar toda la capacidad retenida, el ahorro
estimado baja a 3.4–8.0 % porque se conserva la subdivisión tetraédrica y
sus estructuras comunes. Medir el máximo residente de un backend aplanado
completo queda como extensión.

*Pregunta 3: viabilidad, kernel, reducción y límites.* Cavidades completa las
60 mallas sintéticas principales y 58 de 60 modelos reales estratificados.
En estos últimos alcanza reducción mediana de 76.54 % y medianas de las cotas de
kernel de 99.52–99.93 %. Los dos rechazos por tetraedros degenerados en la
aritmética del lector limitan su cobertura. Face sin reparación cubre los 60;
las variantes reparadas y Edge tienen menor cobertura y no permiten extender
sus comparaciones a todas las entradas previstas.

Frente a Face área, la ventaja conservadora mediana de kernel es 4.93 puntos en
Random, 1.42 en Poisson, cero en Grid y 0.37 en Quality. Frente a Face radio,
solo Random supera cinco puntos; la muestra real tampoco alcanza ese umbral.
Por tanto H3a no se confirma. Las diferencias medianas de reducción satisfacen
el margen descriptivo de diez puntos frente a Face, con excepciones a nivel
individual. Pares y las salidas válidas de Edge conservan más kernel a costa de
menor agregación. La calidad geométrica por sí sola no demuestra aptitud para
VEM; no se midieron error de solución, convergencia ni condicionamiento.

En E5 se completan 700 mediciones nativas. Las dos familias alcanzan cuatro
millones de vértices objetivo. Al intentar ocho millones, Random agota el
presupuesto de asignación de los tres núcleos y Quality alcanza el límite de
tiempo de generación. H3c se cumple en tamaños altos de Quality frente a Face
sin reparación, mientras Random conserva una ventaja temporal para Face.

*Pregunta 4: paralelización.* Se identifica trabajo local en circunsferas y
conteos para salida aplanada, junto con competencia por propiedad durante el
crecimiento. El diseño por rondas de @sec:ac-paralelo requiere definir si busca
equivalencia exacta o una partición alternativa válida, demostrar progreso e
implementar arbitraje. Sin una variante validada no se informa aceleración.

= Trabajo futuro y balance de la hipótesis <sec:co-futuro>

La prioridad es ampliar la robustez numérica sin ocultar los errores observados:
resolver celdas muy delgadas no tetraédricas, estudiar los rechazos del lector y
validar una reparación que preserve cobertura y conectividad. Después procede
repetir las comparaciones con mayor cobertura, manteniendo visibles las
modificaciones del algoritmo y del criterio geométrico de Face.

La evaluación numérica requiere un solver validado y problemas con solución
de referencia. El diseño paralelo requiere un contrato de corrección y medidas
bajo condiciones comunes. La evidencia respalda el compromiso geométrico
observado para la estrategia secuencial en las entradas estudiadas.
