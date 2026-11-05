// Generado desde resultados medidos; regenerar con tools/export_thesis.py.

#figure(table(columns: (1.1fr, 2.6fr), inset: 4pt,
  [CPU expuesta a WSL], [Intel(R) Core(TM) Ultra 5 245KF],
  [CPU lógicas], [14],
  [RAM expuesta a WSL], [15.48 GiB],
  [Plataforma], [Ubuntu/WSL2; Linux-6.18.33.2-microsoft-standard-WSL2-x86\_64],
  [Compilador], [c++ (Ubuntu 15.2.0-16ubuntu1) 15.2.0],
  [Construcción], [-O3 -DNDEBUG -std=gnu++20],
  [NumPy / SciPy], [2.5.4 / 1.18.1],
), caption: [Equipo y configuración efectivos; los recursos corresponden a WSL.]) <tab:ex-equipo>

#figure(
  table(
    columns: (1.8fr, 0.7fr, 0.8fr, 1.4fr, 0.8fr), inset: 4pt,
    table.header([*Variante*], [*Válidas*], [*$R$*], [*$f_K$ acotado*], [*Aislados*]),
    [Cavidades], [25/25], [80.2 %], [98.6 % – 99.4 %], [14.8 %],
    [Face área], [25/25], [87.4 %], [92.8 % – 93.6 %], [0.0 %],
    [Face radio], [25/25], [84.8 %], [92.4 % – 93.5 %], [0.0 %],
    [Face área + reparación], [1/25], [71.1 %], [93.1 % – 94.6 %], [24.8 %],
    [Face radio + reparación], [7/25], [71.3 %], [93.3 % – 94.9 %], [20.0 %],
    [Edge (referencia)], [25/25], [41.6 %], [100.0 % – 100.0 %], [54.1 %],
    [Pares], [25/25], [20.0 %], [100.0 % – 100.0 %], [75.0 %],
  ), caption: [Calidad en Random. Medianas por malla; el intervalo de $f_K$ separa incertidumbre numérica. Aislados: fracción de celdas unitarias.],
) <tab:ex-calidad>

#figure(
  table(
    columns: (1.8fr, 0.7fr, 0.8fr, 1.4fr, 0.8fr), inset: 4pt,
    table.header([*Variante*], [*Válidas*], [*$R$*], [*$f_K$ acotado*], [*Aislados*]),
    [Cavidades], [25/25], [78.1 %], [99.2 % – 99.7 %], [13.8 %],
    [Face área], [25/25], [83.0 %], [97.2 % – 97.7 %], [0.0 %],
    [Face radio], [25/25], [80.4 %], [96.3 % – 97.1 %], [0.0 %],
    [Face área + reparación], [5/25], [66.8 %], [96.5 % – 97.6 %], [23.2 %],
    [Face radio + reparación], [8/25], [68.0 %], [95.8 % – 97.1 %], [19.5 %],
    [Edge (referencia)], [25/25], [48.5 %], [100.0 % – 100.0 %], [44.6 %],
    [Pares], [25/25], [20.0 %], [100.0 % – 100.0 %], [75.0 %],
  ), caption: [Calidad en Poisson. Medianas por malla; el intervalo de $f_K$ separa incertidumbre numérica. Aislados: fracción de celdas unitarias.],
) <tab:ex-calidad-poisson>

#figure(
  table(
    columns: (1.8fr, 0.7fr, 0.8fr, 1.4fr, 0.8fr), inset: 4pt,
    table.header([*Variante*], [*Válidas*], [*$R$*], [*$f_K$ acotado*], [*Aislados*]),
    [Cavidades], [5/5], [83.3 %], [100.0 % – 100.0 %], [0.0 %],
    [Face área], [5/5], [50.0 %], [100.0 % – 100.0 %], [0.0 %],
    [Face radio], [5/5], [50.0 %], [100.0 % – 100.0 %], [0.0 %],
    [Face área + reparación], [5/5], [50.0 %], [100.0 % – 100.0 %], [0.0 %],
    [Face radio + reparación], [5/5], [50.0 %], [100.0 % – 100.0 %], [0.0 %],
    [Edge (referencia)], [5/5], [83.3 %], [100.0 % – 100.0 %], [0.0 %],
    [Pares], [5/5], [20.0 %], [100.0 % – 100.0 %], [75.0 %],
  ), caption: [Calidad en Grid. Medianas por malla; el intervalo de $f_K$ separa incertidumbre numérica. Aislados: fracción de celdas unitarias.],
) <tab:ex-calidad-grid>

#figure(
  table(
    columns: (1.8fr, 0.7fr, 0.8fr, 1.4fr, 0.8fr), inset: 4pt,
    table.header([*Variante*], [*Válidas*], [*$R$*], [*$f_K$ acotado*], [*Aislados*]),
    [Cavidades], [5/5], [77.2 %], [99.6 % – 99.9 %], [11.5 %],
    [Face área], [5/5], [79.5 %], [98.8 % – 99.2 %], [3.2 %],
    [Face radio], [5/5], [78.4 %], [98.5 % – 99.0 %], [3.3 %],
    [Face área + reparación], [1/5], [66.7 %], [98.4 % – 98.8 %], [21.8 %],
    [Face radio + reparación], [1/5], [67.3 %], [98.6 % – 99.1 %], [19.5 %],
    [Edge (referencia)], [2/5], [51.7 %], [100.0 % – 100.0 %], [42.9 %],
    [Pares], [5/5], [20.0 %], [100.0 % – 100.0 %], [75.0 %],
  ), caption: [Calidad en Quality. Medianas por malla; el intervalo de $f_K$ separa incertidumbre numérica. Aislados: fracción de celdas unitarias.],
) <tab:ex-calidad-quality>

#figure(
  table(
    columns: (1.8fr, 0.7fr, 0.8fr, 1.4fr, 0.8fr), inset: 4pt,
    table.header([*Variante*], [*Válidas*], [*$R$*], [*$f_K$ acotado*], [*Aislados*]),
    [Cavidades], [58/60], [76.5 %], [99.5 % – 99.9 %], [10.6 %],
    [Face área], [60/60], [80.9 %], [96.9 % – 97.3 %], [5.7 %],
    [Face radio], [60/60], [79.8 %], [96.5 % – 97.1 %], [6.0 %],
    [Face área + reparación], [3/60], [65.1 %], [99.3 % – 99.8 %], [18.4 %],
    [Face radio + reparación], [4/60], [65.9 %], [98.8 % – 99.4 %], [18.4 %],
    [Edge (referencia)], [14/60], [50.5 %], [100.0 % – 100.0 %], [43.6 %],
    [Pares], [60/60], [20.0 %], [100.0 % – 100.0 %], [75.0 %],
  ), caption: [Calidad en Thingi10K. Medianas por malla; el intervalo de $f_K$ separa incertidumbre numérica. Aislados: fracción de celdas unitarias.],
) <tab:ex-calidad-real>

#figure(
  table(
    columns: (0.8fr, 1.5fr, 0.7fr, 1.5fr, 0.9fr), inset: 4pt,
    table.header([*Familia*], [*Variante*], [*Vértices*], [*Algoritmo: mediana (Q1; Q3), ms*], [*RSS máx., MiB*]),
    [Random], [Cavidades], [50000], [483.28 (481.80; 489.45)], [132.02],
    [Random], [Face área], [50000], [392.59 (389.58; 394.96)], [132.02],
    [Random], [Face radio], [50000], [389.78 (385.46; 392.61)], [132.03],
    [Random], [Face radio + reparación], [1000], [18.99 (18.89; 19.26)], [7.20],
    [Quality], [Cavidades], [49206], [375.99 (372.44; 377.24)], [114.03],
    [Quality], [Face área], [49206], [348.82 (345.13; 352.28)], [114.04],
    [Quality], [Face radio], [49206], [349.95 (349.67; 352.25)], [114.03],
    [Quality], [Face área + reparación], [476], [5.76 (5.68; 5.82)], [5.38],
    [Quality], [Face radio + reparación], [476], [5.70 (5.59; 5.85)], [5.43],
  ), caption: [Recursos del mayor tamaño núcleo con diez repeticiones completas por variante. La escritura corresponde a pertenencia, no VISF.],
) <tab:ex-recursos>

#figure(
  table(
    columns: (1fr, 1fr, 1fr, 1fr, 1fr), inset: 4pt,
    table.header([*Familia*], [*Listas actuales, MiB*], [*Aplanadas, MiB*], [*Retenido actual, MiB*], [*Retenido aplanado, MiB*]),
    [Random], [9.99], [6.90], [90.28], [87.19],
    [Poisson], [14.57], [7.09], [93.58], [86.10],
    [Grid], [9.13], [5.70], [83.04], [79.61],
    [Quality], [9.63], [6.59], [83.62], [80.58],
  ), caption: [E6: capacidades efectivamente reservadas. El total retenido incluye entrada, copia común de salida y auxiliares persistentes; no es el RSS ni incluye metadatos del asignador.],
) <tab:ex-memoria>

#figure(image("../resultados/campana-20261103/quality-and-timing.svg", width: 100%),
  caption: [Reducción y fracción confirmada de kernel por malla sintética; tiempos de algoritmo por tamaño objetivo.],
) <fig:ex-campana>
