"""Clean the head silhouette, replace the cap by a fitted crest and tidy the mouth."""
import bpy
import bmesh
import json
import math
import random
import sys
from pathlib import Path
from mathutils import Matrix, Vector
from mathutils.bvhtree import BVHTree

root = Path(sys.argv[sys.argv.index('--') + 1])
sources = {p['name']: p for p in json.loads((root / 'head-cleanup-source.json').read_text(encoding='utf-8'))}
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)

def cf(values):
    return Matrix(((values[3], values[4], values[5], values[0]),
                   (values[6], values[7], values[8], values[1]),
                   (values[9], values[10], values[11], values[2]), (0, 0, 0, 1)))

hinge = cf(sources['head_geom']['hinge'])
inverse = hinge.inverted()
pieces = []
stats = {}

def prepare(name):
    source = sources[name]
    points = [Vector(v) for v in source['vertices']]
    lo = Vector(tuple(min(p[k] for p in points) for k in range(3)))
    hi = Vector(tuple(max(p[k] for p in points) for k in range(3)))
    center = (lo + hi) / 2
    scales = [source['size'][k] / (hi[k] - lo[k]) for k in range(3)]
    matrix = inverse @ cf(source['cf'])
    rotation = Matrix.Rotation(math.radians(-8), 4, 'X') if name == 'jaw_geom' else Matrix.Identity(4)
    vertices = [rotation @ matrix @ Vector(tuple((p[k] - center[k]) * scales[k] for k in range(3))) for p in points]
    faces = []
    for face in source['faces']:
        if source['uvs'] and all(abs(source['uvs'][i][0] - .02) < .00002 and
                                  abs(source['uvs'][i][1] - .98) < .00002 for i in face[3:]):
            continue  # Remove the old triangulated closing sheets across the mouth.
        faces.append(face)
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(vertices, [], [f[:3] for f in faces])
    mesh.update()
    if source['uvs']:
        uv = mesh.uv_layers.new(name='UVMap')
        for poly, face in zip(mesh.polygons, faces):
            for loop, index in zip(poly.loop_indices, face[3:]):
                u, v = source['uvs'][index]
                uv.data[loop].uv = (u, 1 - v)
    bm = bmesh.new()
    bm.from_mesh(mesh)
    bmesh.ops.remove_doubles(bm, verts=list(bm.verts), dist=.00004)
    # Remove small disconnected scraps, including fragments below the old lower lip.
    unvisited = set(bm.faces)
    groups = []
    while unvisited:
        group = {unvisited.pop()}
        stack = list(group)
        while stack:
            for edge in stack.pop().edges:
                for other in edge.link_faces:
                    if other in unvisited:
                        unvisited.remove(other)
                        group.add(other)
                        stack.append(other)
        groups.append(group)
    largest = max(groups, key=len)
    skin = bool(source['uvs'])
    discard = [face for group in groups if skin and len(group) < max(20, len(largest) * .025) for face in group]
    bmesh.ops.delete(bm, geom=discard, context='FACES')
    smooth = [v for v in bm.verts if not v.is_boundary]
    for _ in range(3 if skin else 0):
        bmesh.ops.smooth_vert(bm, verts=smooth, factor=.18, use_axis_x=True, use_axis_y=True, use_axis_z=True)
    bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
    bm.to_mesh(mesh)
    bm.free()
    for polygon in mesh.polygons:
        polygon.use_smooth = True
    mesh.update()
    return mesh

skull = prepare('head_geom')
jaw = prepare('jaw_geom')

def tree(mesh):
    return BVHTree.FromPolygons([v.co for v in mesh.vertices], [tuple(p.vertices) for p in mesh.polygons])

skull_bvh, jaw_bvh = tree(skull), tree(jaw)
report = {}
for z in (-13, -11, -9, -7, -5):
    report[z] = []
    for x in (0, 2, 3, 4):
        upper = skull_bvh.ray_cast(Vector((x, -12, z)), Vector((0, 1, 0)), 35)[0]
        lower = jaw_bvh.ray_cast(Vector((x, 12, z)), Vector((0, -1, 0)), 35)[0]
        report[z].append([x, round(upper.y, 3) if upper else None, round(lower.y, 3) if lower else None])
print('LIP_SAMPLES ' + json.dumps(report))
print('HEAD_BOUNDS ' + json.dumps({name: [[min(v.co[k] for v in mesh.vertices), max(v.co[k] for v in mesh.vertices)] for k in range(3)] for name, mesh in [('skull', skull), ('jaw', jaw)]}))

def raw_mesh(name, vertices, faces, smooth=True):
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    for p in mesh.polygons:
        p.use_smooth = smooth
    pieces.append((name, mesh))
    return mesh

pieces.extend([('CleanSkull', skull), ('CleanJaw', jaw)])

# Keep the body/tail feathers, removing the old needle-like fringe around the head.
for source_name, name in [('TRex_PlumesDark', 'CleanBodyPlumesDark'), ('TRex_PlumesSoft', 'CleanBodyPlumesSoft')]:
    mesh = prepare(source_name)
    bm = bmesh.new()
    bm.from_mesh(mesh)
    seen = set()
    remove = []
    for v in bm.verts:
        if v in seen:
            continue
        group, stack = {v}, [v]
        seen.add(v)
        while stack:
            current = stack.pop()
            for e in current.link_edges:
                other = e.other_vert(current)
                if other not in seen:
                    seen.add(other)
                    group.add(other)
                    stack.append(other)
        if min(q.co.z for q in group) < 2.2:
            remove.extend(group)
    bmesh.ops.delete(bm, geom=remove, context='VERTS')
    bm.to_mesh(mesh)
    bm.free()
    pieces.append((name, mesh))

# A narrow surface-following crest with tapered edges, swept back from the brow.
crest_points, crest_faces, rows = [], [], []
rng = random.Random(1351)
for i in range(25):
    z = -4.6 + i * .38
    t = i / 24
    width = .25 + 2.1 * math.sin(math.pi * (.08 + .84 * t))
    row = []
    for j in range(11):
        x = (j / 5 - 1) * width
        hit, normal, _, _ = skull_bvh.ray_cast(Vector((x, 18, z)), Vector((0, -1, 0)), 30)
        if hit is None:
            row.append(None)
            continue
        row.append(len(crest_points))
        crest_points.append(hit + normal * .035)
    rows.append(row)
for a, b in zip(rows, rows[1:]):
    for j in range(10):
        ids = [a[j], a[j + 1], b[j + 1], b[j]]
        if None not in ids:
            crest_faces.append(ids)
raw_mesh('CleanCrestBase', crest_points, crest_faces)
feather_groups = [([], []), ([], [])]
feather_count = 0
for i in range(23):
    z = -4.4 + i * .4
    width = .25 + 2.05 * math.sin(math.pi * (.08 + .84 * i / 22))
    for j in range(9):
        x = ((j - 4) / 4) * width + rng.uniform(-.06, .06)
        hit, normal, _, _ = skull_bvh.ray_cast(Vector((x, 18, z)), Vector((0, -1, 0)), 30)
        if hit is None:
            continue
        length = rng.uniform(.85, 1.35)
        w = rng.uniform(.22, .32)
        direction = (Vector((x * .035, .12, 1)) + normal * .16).normalized()
        across = Vector((1, 0, 0))
        anchor = hit + normal * .055
        vertices = [anchor - across * w * .25, anchor + across * w * .25,
                    anchor + direction * length * .35 - across * w * .55,
                    anchor + direction * length * .35 + across * w * .55,
                    anchor + direction * length * .7 - across * w * .3,
                    anchor + direction * length * .7 + across * w * .3,
                    anchor + direction * length - normal * .05,
                    anchor + direction * length * .4 + normal * .07]
        vs, fs = feather_groups[feather_count % 2]
        offset = len(vs)
        vs.extend(vertices)
        fs.extend(tuple(offset + k for k in f) for f in
                  [(0, 1, 7), (0, 7, 2), (2, 7, 4), (4, 7, 6), (6, 7, 5), (5, 7, 3), (3, 7, 1)])
        feather_count += 1
for name, (vs, fs) in zip(('CleanCrestDark', 'CleanCrestSoft'), feather_groups):
    raw_mesh(name, vs, fs)

# Tooth roots sit inside the actual lips instead of floating on the old cut plane.
def upper_root(x, z):
    hit = skull_bvh.ray_cast(Vector((x, .3, z)), Vector((0, 1, 0)), 12)[0]
    return hit if hit and hit.y < 4.7 else None

def side_width(bvh, z, y):
    hit = bvh.ray_cast(Vector((15, y, z)), Vector((-1, 0, 0)), 18)[0]
    return hit.x if hit else None

upper_roots, lower_roots = [], []
for side in (-1, 1):
    for i in range(8):
        z = -12.6 + i * .82
        width = side_width(skull_bvh, z, 2.8)
        if width:
            p = upper_root(side * max(.9, width - .32), z)
            if p:
                upper_roots.append(p + Vector((0, .12, 0)))
    for i in range(7):
        z = -12.3 + i * .82
        width = side_width(jaw_bvh, z, -.8)
        if width:
            x = side * max(.6, (width - .28) * .58)
            p = jaw_bvh.ray_cast(Vector((x, 9, z)), Vector((0, -1, 0)), 15)[0]
            if p:
                lower_roots.append(p - Vector((0, .1, 0)))
for x in (-1.7, -.85, 0, .85, 1.7):
    p = upper_root(x, -13.1)
    if p:
        upper_roots.append(p + Vector((0, .1, 0)))
for x in (-1.0, -.5, 0, .5, 1.0):
    p = jaw_bvh.ray_cast(Vector((x, 9, -12.75)), Vector((0, -1, 0)), 15)[0]
    if p:
        lower_roots.append(p - Vector((0, .1, 0)))

for name, roots, sign in [('CleanUpperTeeth', upper_roots, -1), ('CleanLowerTeeth', lower_roots, 1)]:
    vs, fs = [], []
    for index, p in enumerate(roots):
        length = (.9 if sign < 0 else .56) * (1 + .12 * math.sin(index * 1.7))
        radius = .22 if sign < 0 else .17
        offset = len(vs)
        for k, fraction in enumerate((0, .27, .63, .87, 1)):
            r = radius * ((1 - fraction) ** .65) + .008
            center = p + Vector((0, sign * length * fraction, .16 * fraction * fraction))
            for a in range(10):
                angle = a * math.tau / 10
                vs.append(center + Vector((math.cos(angle) * r, 0, math.sin(angle) * r)))
        for k in range(4):
            for a in range(10):
                fs.append((offset + k * 10 + a, offset + k * 10 + (a + 1) % 10,
                           offset + (k + 1) * 10 + (a + 1) % 10, offset + (k + 1) * 10 + a))
        fs.append(tuple(offset + a for a in reversed(range(10))))
        fs.append(tuple(offset + 40 + a for a in range(10)))
    raw_mesh(name, vs, fs)

# Small inset amber eyes and nostrils bring back facial detail beneath the brow.
eye_groups = {name: ([], []) for name in ('CleanEyeSockets', 'CleanEyeIris', 'CleanEyePupils', 'CleanNostrils')}
eye_centers = []
def ellipsoid(group, center, normal, radii):
    vs, fs = eye_groups[group]
    outward = normal.normalized()
    up = (Vector((0, 1, 0)) - outward * outward.y).normalized()
    across = up.cross(outward).normalized()
    offset = len(vs)
    for lat in range(9):
        phi = math.pi * lat / 8
        for lon in range(16):
            theta = math.tau * lon / 16
            vs.append(center + up * (math.cos(phi) * radii[1])
                      + across * (math.sin(phi) * math.cos(theta) * radii[0])
                      + outward * (math.sin(phi) * math.sin(theta) * radii[2]))
    for lat in range(8):
        for lon in range(16):
            a = offset + lat * 16 + lon
            b = offset + lat * 16 + (lon + 1) % 16
            fs.append((a, b, b + 16, a + 16))

for side in (-1, 1):
    origin = Vector((side * 18, 5.5, -4.5))
    p, normal, _, _ = skull_bvh.ray_cast(origin, Vector((-side, 0, 0)), 25)
    if p:
        if normal.x * side < 0:
            normal = -normal
        ellipsoid('CleanEyeSockets', p + normal * .025, normal, (.65, .43, .07))
        ellipsoid('CleanEyeIris', p + normal * .09, normal, (.29, .28, .065))
        ellipsoid('CleanEyePupils', p + normal * .148, normal, (.055, .23, .018))
        eye_centers.append(list(p))
    p, normal, _, _ = skull_bvh.ray_cast(Vector((side * 18, 4.25, -12.55)), Vector((-side, 0, 0)), 25)
    if p:
        if normal.x * side < 0:
            normal = -normal
        ellipsoid('CleanNostrils', p + normal * .028, normal, (.28, .14, .035))
for name, (vs, fs) in eye_groups.items():
    if vs:
        raw_mesh(name, vs, fs)

metadata = {'parts': {}, 'hinge': sources['head_geom']['hinge'], 'jawNeutralDeltaDegrees': -8,
            'crestFeathers': feather_count, 'upperTeeth': len(upper_roots), 'lowerTeeth': len(lower_roots),
            'eyes': eye_centers}
for name, mesh in pieces:
    mesh.name = name
    # Convert anatomy coordinates to the main model's world coordinates.
    for vertex in mesh.vertices:
        vertex.co = hinge @ vertex.co
    mesh.update()
    mesh.calc_loop_triangles()
    lo = Vector(tuple(min(v.co[k] for v in mesh.vertices) for k in range(3)))
    hi = Vector(tuple(max(v.co[k] for v in mesh.vertices) for k in range(3)))
    metadata['parts'][name] = {'center': list((lo + hi) / 2), 'size': list(hi - lo),
                               'vertices': len(mesh.vertices), 'triangles': len(mesh.loop_triangles)}
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    obj.select_set(True)
bpy.ops.export_scene.gltf(filepath=str(root / 'TRex_Head_Cleanup.glb'), export_format='GLB',
                          export_yup=False, use_selection=True, export_materials='NONE')
for obj in bpy.context.selected_objects:
    obj.select_set(obj.name == 'CleanLowerTeeth')
bpy.ops.export_scene.gltf(filepath=str(root / 'TRex_Head_LowerTeeth.glb'), export_format='GLB',
                          export_yup=False, use_selection=True, export_materials='NONE')
(root / 'head-cleanup-metadata.json').write_text(json.dumps(metadata, indent=2), encoding='utf-8')
print('RESULT ' + json.dumps(metadata))
