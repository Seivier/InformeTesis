"""Genera las figuras conceptuales 2D del capítulo de estado del arte.

Uso: python3 generar_figuras.py  (escribe los SVG en este mismo directorio)
Sólo usa la biblioteca estándar: triangulación de Delaunay por Bowyer-Watson.
"""

import math
import random
from pathlib import Path

OUT = Path(__file__).resolve().parent
W, H, S, M = 10.0, 7.0, 40.0, 12.0  # dominio, escala px/unidad, margen px


def circumcircle(a, b, c):
    d = 2 * (a[0] * (b[1] - c[1]) + b[0] * (c[1] - a[1]) + c[0] * (a[1] - b[1]))
    ux = ((a[0] ** 2 + a[1] ** 2) * (b[1] - c[1]) + (b[0] ** 2 + b[1] ** 2) * (c[1] - a[1])
          + (c[0] ** 2 + c[1] ** 2) * (a[1] - b[1])) / d
    uy = ((a[0] ** 2 + a[1] ** 2) * (c[0] - b[0]) + (b[0] ** 2 + b[1] ** 2) * (a[0] - c[0])
          + (c[0] ** 2 + c[1] ** 2) * (b[0] - a[0])) / d
    return (ux, uy), math.dist((ux, uy), a)


def delaunay(points):
    """Bowyer-Watson: inserta cada punto, borra la cavidad y la re-triangula."""
    big = [(-100.0, -100.0), (100.0, -100.0), (0.0, 100.0)]
    pts = points + big
    n = len(points)
    tris = [(n, n + 1, n + 2)]
    for i, p in enumerate(points):
        bad = [t for t in tris if math.dist(circumcircle(*(pts[k] for k in t))[0], p)
               < circumcircle(*(pts[k] for k in t))[1]]
        edges = {}
        for t in bad:
            for e in ((t[0], t[1]), (t[1], t[2]), (t[2], t[0])):
                key = tuple(sorted(e))
                edges[key] = edges.get(key, 0) + 1
        tris = [t for t in tris if t not in bad]
        tris += [(a, b, i) for (a, b), cnt in edges.items() if cnt == 1]
    return [t for t in tris if max(t) < n]


def edge_map(tris):
    m = {}
    for ti, t in enumerate(tris):
        for e in ((t[0], t[1]), (t[1], t[2]), (t[2], t[0])):
            m.setdefault(tuple(sorted(e)), []).append(ti)
    return m


def xy(p):
    return M + p[0] * S, M + (H - p[1]) * S


def svg(body):
    w, h = W * S + 2 * M, H * S + 2 * M
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{w:.0f}" height="{h:.0f}" '
            f'viewBox="0 0 {w:.0f} {h:.0f}">\n<rect width="100%" height="100%" fill="white"/>\n'
            + "\n".join(body) + "\n</svg>\n")


def poly(pts, fill, stroke="#333", sw=1.0, extra=""):
    coords = " ".join(f"{x:.1f},{y:.1f}" for x, y in map(xy, pts))
    return f'<polygon points="{coords}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}" {extra}/>'


def seg(a, b, stroke, sw=1.0, extra=""):
    (x1, y1), (x2, y2) = xy(a), xy(b)
    return f'<line x1="{x1:.1f}" y1="{y1:.1f}" x2="{x2:.1f}" y2="{y2:.1f}" stroke="{stroke}" stroke-width="{sw}" {extra}/>'


def circ(c, r, stroke, fill="none", sw=1.0, extra=""):
    x, y = xy(c)
    return f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{r * S:.1f}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}" {extra}/>'


def dot(p, fill, r=3.0, stroke="none"):
    x, y = xy(p)
    return f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{r}" fill="{fill}" stroke="{stroke}" stroke-width="1"/>'


def clip_rect():
    return ('<defs><clipPath id="dom"><rect x="{:.1f}" y="{:.1f}" width="{:.1f}" height="{:.1f}"/></clipPath></defs>'
            .format(M, M, W * S, H * S))


def main():
    rng = random.Random(11)
    pts = [(0, 0), (W, 0), (W, H), (0, H)]
    pts += [(W * k / 4, 0) for k in (1, 2, 3)] + [(W * k / 4, H) for k in (1, 2, 3)]
    pts += [(0, H / 2), (W, H / 2)]
    for i in range(5):
        for j in range(3):
            pts.append((1.0 + i * 2.0 + rng.uniform(-0.6, 0.6), 1.2 + j * 2.3 + rng.uniform(-0.6, 0.6)))
    tris = delaunay(pts)
    cc = [circumcircle(*(pts[k] for k in t)) for t in tris]
    em = edge_map(tris)

    def mesh(fill_of=lambda ti: "none"):
        return [poly([pts[k] for k in t], fill_of(ti), "#444", 0.9) for ti, t in enumerate(tris)]

    # (a) Delaunay + Voronoi dual (aristas entre circuncentros de triángulos adyacentes)
    interior = [ti for ti, t in enumerate(tris) if all(0 < c < W for c in (cc[ti][0][0],)) and 0 < cc[ti][0][1] < H]
    probe = min(interior, key=lambda ti: math.dist(cc[ti][0], (W / 2, H / 2)))
    body = [clip_rect()] + mesh(lambda ti: "#dbe8f5" if ti == probe else "none")
    for e, ts in em.items():
        if len(ts) == 2:
            body.append(seg(cc[ts[0]][0], cc[ts[1]][0], "#c0392b", 1.2, 'clip-path="url(#dom)"'))
    body.append(circ(*cc[probe], "#1f4e79", sw=1.4, extra='stroke-dasharray="5,3" clip-path="url(#dom)"'))
    body += [dot(c, "#c0392b", 2.2) for c, _ in cc if 0 <= c[0] <= W and 0 <= c[1] <= H]
    body += [dot(p, "#111", 2.6) for p in pts]
    (OUT / "delaunay-voronoi.svg").write_text(svg(body), encoding="utf-8")

    # (b) cavidad de Bowyer-Watson de un punto p
    def cavity(q):
        return {ti for ti in range(len(tris)) if math.dist(cc[ti][0], q) < cc[ti][1]}

    grid = [(2.5 + 0.1 * i, 1.8 + 0.1 * j) for i in range(51) for j in range(35)]
    grid = [q for q in grid if min(math.dist(q, v) for v in pts) > 0.7]
    p = max(grid, key=lambda q: (len(cavity(q)), -math.dist(q, (W / 2, H / 2))))
    cav = cavity(p)
    body = [clip_rect()] + mesh(lambda ti: "#f6d7a7" if ti in cav else "none")
    for e, ts in em.items():
        inside = [t for t in ts if t in cav]
        if len(inside) == 1 or (len(ts) == 1 and ts[0] in cav):
            body.append(seg(pts[e[0]], pts[e[1]], "#b9770e", 2.2))
            body.append(seg(p, pts[e[0]], "#b9770e", 1.0, 'stroke-dasharray="4,3"'))
            body.append(seg(p, pts[e[1]], "#b9770e", 1.0, 'stroke-dasharray="4,3"'))
    body += [circ(*cc[ti], "#b9770e", sw=0.8, extra='stroke-opacity="0.55" clip-path="url(#dom)"') for ti in cav]
    body += [dot(q, "#111", 2.6) for q in pts]
    body.append(dot(p, "#c0392b", 4.0, "#7b241c"))
    (OUT / "cavidad-bowyer-watson.svg").write_text(svg(body), encoding="utf-8")

    # (c) región inducida por la circunsfera de un triángulo semilla (análogo 2D)
    def grow(seed):
        owner, stack, region = {seed}, [seed], [seed]
        while stack:
            cur = stack.pop()
            t = tris[cur]
            for e in ((t[0], t[1]), (t[1], t[2]), (t[2], t[0])):
                for nb in em[tuple(sorted(e))]:
                    if nb in owner:
                        continue
                    if math.dist(cc[nb][0], cc[seed][0]) < cc[seed][1]:
                        owner.add(nb)
                        stack.append(nb)
                        region.append(nb)
        return region

    contained = [ti for ti in interior
                 if cc[ti][1] < min(cc[ti][0][0], W - cc[ti][0][0], cc[ti][0][1], H - cc[ti][0][1])]
    seed = max(contained, key=lambda ti: (len(grow(ti)), -cc[ti][1]))
    region = set(grow(seed))
    body = [clip_rect()] + mesh(lambda ti: "#2e86c1" if ti == seed else ("#aed6f1" if ti in region else "none"))
    body.append(circ(*cc[seed], "#1f4e79", sw=1.6, extra='stroke-dasharray="6,3" clip-path="url(#dom)"'))
    for ti, (c, _) in enumerate(cc):
        if not (0 <= c[0] <= W and 0 <= c[1] <= H):
            continue
        inside = math.dist(c, cc[seed][0]) < cc[seed][1]
        body.append(dot(c, "#1f4e79" if inside else "white", 2.6, "#1f4e79"))
    body += [dot(q, "#111", 2.4) for q in pts]
    (OUT / "region-circunsfera-semilla.svg").write_text(svg(body), encoding="utf-8")

    # (d) conflicto entre cavidades concurrentes: p y q comparten triángulos, r es independiente
    cands = sorted(grid, key=lambda q: -len(cavity(q)))
    pq = None
    for a in cands:
        for b in cands:
            inter = cavity(a) & cavity(b)
            if 1 <= len(inter) <= 2 and math.dist(a, b) > 1.2 and len(cavity(a) | cavity(b)) >= 7:
                pq = (a, b)
                break
        if pq:
            break
    pa, pb = pq
    used = cavity(pa) | cavity(pb)
    pr = max((q for q in grid if not (cavity(q) & used) and not any(
        e in [tuple(sorted(x)) for t in used for x in ((tris[t][0], tris[t][1]), (tris[t][1], tris[t][2]), (tris[t][2], tris[t][0]))]
        for t2 in cavity(q) for e in [tuple(sorted(x)) for x in ((tris[t2][0], tris[t2][1]), (tris[t2][1], tris[t2][2]), (tris[t2][2], tris[t2][0]))])),
             key=lambda q: len(cavity(q)))
    ca, cb, cr = cavity(pa), cavity(pb), cavity(pr)

    def fill(ti):
        if ti in ca and ti in cb:
            return "#c0392b"
        if ti in ca:
            return "#f6d7a7"
        if ti in cb:
            return "#aed6f1"
        if ti in cr:
            return "#c8e6c9"
        return "none"

    body = [clip_rect()] + mesh(fill)
    body += [dot(q, "#111", 2.4) for q in pts]
    body += [dot(pa, "#b9770e", 4.0, "#5a3a07"), dot(pb, "#1f4e79", 4.0, "#0b2238"), dot(pr, "#2e7d32", 4.0, "#1b4d1e")]
    (OUT / "conflicto-cavidades.svg").write_text(svg(body), encoding="utf-8")

    # (e) kernel de polígonos: convexo, estrellado no convexo y no estrellado
    def clip(poly_pts, a, b):
        """Recorta un polígono convexo con el semiplano a la izquierda de la arista a->b."""
        def side(p):
            return (b[0] - a[0]) * (p[1] - a[1]) - (b[1] - a[1]) * (p[0] - a[0])
        out = []
        for i, p in enumerate(poly_pts):
            q = poly_pts[(i + 1) % len(poly_pts)]
            sp, sq = side(p), side(q)
            if sp >= 0:
                out.append(p)
            if (sp >= 0) != (sq >= 0):
                t = sp / (sp - sq)
                out.append((p[0] + t * (q[0] - p[0]), p[1] + t * (q[1] - p[1])))
        return out

    def kernel(poly_pts):
        k = [(-50, -50), (50, -50), (50, 50), (-50, 50)]
        for i, a in enumerate(poly_pts):
            k = clip(k, a, poly_pts[(i + 1) % len(poly_pts)])
            if len(k) < 3:
                return []
        return k

    shapes = [
        [(0.6, 0.8), (2.6, 0.5), (3.1, 2.4), (1.6, 3.4), (0.3, 2.3)],
        [(0.4, 0.4), (3.2, 0.4), (3.2, 1.3), (1.4, 1.5), (1.6, 3.4), (0.4, 3.4)],
        [(0.3, 0.4), (3.3, 0.4), (3.3, 3.4), (2.4, 3.4), (2.4, 1.2), (1.2, 1.2), (1.2, 3.4), (0.3, 3.4)],
    ]
    for name, shp in zip(("convexo", "estrellado", "no-estrellado"), shapes):
        ker = kernel(shp)
        w, h = 3.6 * S + 2 * M, 3.8 * S + 2 * M

        def kxy(p):
            return M + p[0] * S, M + (3.8 - p[1]) * S

        def kpoly(ps, fill, stroke, sw, extra=""):
            c = " ".join(f"{x:.1f},{y:.1f}" for x, y in map(kxy, ps))
            return f'<polygon points="{c}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}" {extra}/>'

        body = [kpoly(shp, "#eef2f7", "#333", 1.6)]
        if ker:
            body.append(kpoly(ker, "#2e86c1", "#1f4e79", 1.2, 'fill-opacity="0.55"'))
        doc = (f'<svg xmlns="http://www.w3.org/2000/svg" width="{w:.0f}" height="{h:.0f}" '
               f'viewBox="0 0 {w:.0f} {h:.0f}">\n<rect width="100%" height="100%" fill="white"/>\n'
               + "\n".join(body) + "\n</svg>\n")
        (OUT / f"kernel-{name}.svg").write_text(doc, encoding="utf-8")

    print(f"{len(pts)} puntos, {len(tris)} triángulos; cavidad={len(cav)}; región semilla={len(region)}; "
          f"conflicto={len(ca & cb)}; independiente={len(cr)}")


if __name__ == "__main__":
    main()
