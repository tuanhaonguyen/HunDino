"""Preserve UVs while separating the jaw and refining the reference silhouette.

Run with Blender --background --python this_file -- path/to/assets/dinosaur01.
Input vertices are in their MeshPart's rendered local coordinates, in studs.
Output OBJ coordinates are Studio world coordinates; metadata restores placement.
"""
import bpy
import bmesh
import json
import math
import random
from pathlib import Path
import sys
from mathutils import Matrix, Vector
from mathutils.bvhtree import BVHTree

root = Path(sys.argv[sys.argv.index('--') + 1])
head = json.loads((root / 'head-source.json').read_text(encoding='utf-8'))
body = json.loads((root / 'body-source.json').read_text(encoding='utf-8'))

def cframe(values):
    return Matrix(((values[3], values[4], values[5], values[0]),
                   (values[6], values[7], values[8], values[1]),
                   (values[9], values[10], values[11], values[2]),
                   (0, 0, 0, 1)))

hcf, bcf = cframe(head['headCF']), cframe(body['partCF'])
forward = -(hcf.to_3x3() @ Vector((0, 0, 1)))
forward.y = 0
forward.normalize()
head_shift = forward * 0.9 + Vector((0, -1.6, 0))
hinge = Vector((0, -1.75, 5))
jaw_rotation = Matrix.Rotation(math.radians(10), 3, 'X')

def source_mesh(data, name):
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(data['vertices'], [], [tuple(i - 1 for i in f[:3]) for f in data['faces']])
    mesh.update()
    uv = mesh.uv_layers.new(name='UVMap')
    for poly, face in zip(mesh.polygons, data['faces']):
        for loop_id, uv_id in zip(poly.loop_indices, face[3:]):
            u, v = data['uvs'][uv_id - 1]
            uv.data[loop_id].uv = (u, 1 - v)
    return mesh

base = source_mesh(head, 'HeadSource')
pieces = []
for name, upper in [('TRex_Skull', True), ('TRex_Jaw', False)]:
    bm = bmesh.new()
    bm.from_mesh(base)
    bmesh.ops.remove_doubles(bm, verts=list(bm.verts), dist=0.00003)
    plane_co = Vector((0, -2.5, 0))
    plane_no = Vector((0, 1, -0.15)).normalized()
    bmesh.ops.bisect_plane(bm, geom=list(bm.verts) + list(bm.edges) + list(bm.faces),
                          dist=0.00001, plane_co=plane_co, plane_no=plane_no,
                          clear_inner=upper, clear_outer=not upper)
    cut_edges = [e for e in bm.edges if e.is_boundary and
                 all(abs((v.co - plane_co).dot(plane_no)) < 0.0002 for v in e.verts)]
    if cut_edges:
        filled = bmesh.ops.holes_fill(bm, edges=cut_edges, sides=0).get('faces', [])
        uv_layer = bm.loops.layers.uv.active
        for face in filled:
            for loop in face.loops:
                loop[uv_layer].uv = (0.02, 0.02)
    for v in bm.verts:
        local = v.co.copy()
        if not upper:
            local = hinge + jaw_rotation @ (local - hinge)
        v.co = hcf @ local + head_shift
    bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
    mesh = bpy.data.meshes.new(name)
    bm.to_mesh(mesh)
    bm.free()
    mesh.update()
    pieces.append((name, mesh))

def smooth(value):
    value = max(0.0, min(1.0, value))
    return value * value * (3 - 2 * value)

mesh = source_mesh(body, 'TRex_Body')
local_delta = bcf.to_3x3().transposed() @ head_shift
for v in mesh.vertices:
    p = v.co.copy()
    neck = smooth((-p.z - 4) / 7) * smooth((p.y + 4) / 8)
    trunk = 1 - smooth((-p.z - 5) / 6)
    p.x *= 1 + 0.07 * trunk
    p.y = -1 + (p.y + 1) * (1 + 0.045 * trunk)
    p += local_delta * neck
    v.co = bcf @ p
mesh.update()
pieces.append(('TRex_Body', mesh))

for _, mesh in pieces:
    bm = bmesh.new()
    bm.from_mesh(mesh)
    bmesh.ops.remove_doubles(bm, verts=list(bm.verts), dist=0.00003)
    bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
    bm.to_mesh(mesh)
    bm.free()
    for poly in mesh.polygons:
        poly.use_smooth = True
    mesh.update()

# Build a dense layered coat against the actual triangle surfaces, not hulls.
tail = json.loads((root / 'tail-surface.json').read_text(encoding='utf-8'))
points, triangles = [], []
for name, mesh in pieces:
    if name == 'TRex_Jaw':
        continue
    mesh.calc_loop_triangles()
    start_index = len(points)
    points.extend(v.co.copy() for v in mesh.vertices)
    triangles.extend(tuple(start_index + i for i in tri.vertices) for tri in mesh.loop_triangles)
start_index = len(points)
points.extend(Vector(v) for v in tail['vertices'])
triangles.extend(tuple(start_index + i - 1 for i in face) for face in tail['faces'])
surface = BVHTree.FromPolygons(points, triangles, all_triangles=True)
rng = random.Random(20261015)
side = Vector((-forward.z, 0, forward.x))
start = Vector(tail['center']) - forward * tail['size'][2] * 0.4
finish = hcf.translation + head_shift - forward * 2.0
coat = [([], []), ([], [])]
feathers = 0
for row in range(96):
    t = row / 95
    center = start.lerp(finish, t)
    spread = 0.3 + 3.7 * math.sin(math.pi * t) ** 0.6
    for col in range(-5, 6):
        sample = center + side * (col / 5 * spread + rng.uniform(-0.14, 0.14)) + forward * rng.uniform(-0.22, 0.22)
        hit, normal, _, _ = surface.ray_cast(Vector((sample.x, 90, sample.z)), Vector((0, -1, 0)), 115)
        if hit is None:
            continue
        if normal.y < 0:
            normal = -normal
        if normal.y < 0.25:
            continue
        length = (0.9 + 2.7 * math.sin(math.pi * t) ** 0.7) * rng.uniform(0.8, 1.18)
        width = length * rng.uniform(0.17, 0.23)
        direction = (-forward * 0.93 + normal * (0.5 if t > 0.72 else 0.32) + side * rng.uniform(-0.13, 0.13)).normalized()
        across = (side - direction * side.dot(direction)).normalized()
        crest = direction.cross(across).normalized()
        if crest.dot(normal) < 0:
            crest = -crest
        anchor = hit - normal * 0.09
        vertices = [anchor - across * width * 0.2, anchor + across * width * 0.2,
                    anchor + direction * length * 0.28 - across * width * 0.55 + crest * length * 0.04,
                    anchor + direction * length * 0.28 + across * width * 0.55 + crest * length * 0.04,
                    anchor + direction * length * 0.68 - across * width * 0.32,
                    anchor + direction * length * 0.68 + across * width * 0.32,
                    anchor + direction * length - crest * length * 0.06,
                    anchor + direction * length * 0.40 + crest * width * 0.18]
        group_vertices, group_faces = coat[feathers % 2]
        offset = len(group_vertices)
        group_vertices.extend(vertices)
        group_faces.extend(tuple(offset + i for i in face) for face in
                           [(0, 1, 7), (0, 7, 2), (2, 7, 4), (4, 7, 6), (6, 7, 5), (5, 7, 3), (3, 7, 1)])
        feathers += 1
for name, (vertices, faces) in zip(('TRex_PlumesDark', 'TRex_PlumesSoft'), coat):
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    pieces.append((name, mesh))

lines = ['# HunDino full-body reference refinement; units: studs; Y up', 's 1']
offset_v, offset_uv = 0, 0
metadata = {'parts': {}, 'headShift': list(head_shift), 'jawAngleDegrees': 10,
            'feathers': feathers,
            'jawPivot': list(hcf @ hinge + head_shift),
            'headCF': head['headCF'], 'bodyCF': body['partCF']}
for name, mesh in pieces:
    mesh.calc_loop_triangles()
    lines.append(f'o {name}')
    for v in mesh.vertices:
        lines.append('v %.8f %.8f %.8f' % tuple(v.co))
    uv_layer = mesh.uv_layers.active.data if mesh.uv_layers.active else None
    for loop in mesh.loops:
        uv = uv_layer[loop.index].uv if uv_layer else Vector((0, 0))
        lines.append('vt %.8f %.8f' % (uv.x, uv.y))
    for tri in mesh.loop_triangles:
        corners = [f'{offset_v + mesh.loops[i].vertex_index + 1}/{offset_uv + i + 1}' for i in tri.loops]
        lines.append('f ' + ' '.join(corners))
    points = [v.co for v in mesh.vertices]
    minimum = Vector(tuple(min(p[k] for p in points) for k in range(3)))
    maximum = Vector(tuple(max(p[k] for p in points) for k in range(3)))
    metadata['parts'][name] = {'center': list((minimum + maximum) / 2),
                               'size': list(maximum - minimum),
                               'vertices': len(mesh.vertices), 'triangles': len(mesh.loop_triangles)}
    offset_v += len(mesh.vertices)
    offset_uv += len(mesh.loops)

(root / 'TRex_Reference_Refined.obj').write_text('\n'.join(lines) + '\n', encoding='utf-8')
(root / 'refinement-metadata.json').write_text(json.dumps(metadata, indent=2), encoding='utf-8')
for obj in list(bpy.context.selected_objects):
    obj.select_set(False)
for name, mesh in pieces:
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    obj.select_set(True)
bpy.ops.export_scene.gltf(filepath=str(root / 'TRex_Reference_FinalSmooth.glb'),
                          export_format='GLB', export_yup=False,
                          use_selection=True, export_materials='NONE')
print(json.dumps(metadata))
