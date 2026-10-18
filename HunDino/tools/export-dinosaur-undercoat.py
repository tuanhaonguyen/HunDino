"""Bake the three feather undercoats to uploaded meshes instead of transient CSG."""
import bpy
import bmesh
import json
import sys
from pathlib import Path
from mathutils import Matrix, Vector

root = Path(sys.argv[sys.argv.index('--') + 1])
sources = json.loads((root / 'undercoat-source.json').read_text(encoding='utf-8'))
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
metadata = {}
for source in sources:
    name = source['name']
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(source['vertices'], [], source['faces'])
    mesh.update()
    bm = bmesh.new()
    bm.from_mesh(mesh)
    bmesh.ops.remove_doubles(bm, verts=list(bm.verts), dist=0.00003)
    minimum = Vector(tuple(min(v.co[k] for v in bm.verts) for k in range(3)))
    maximum = Vector(tuple(max(v.co[k] for v in bm.verts) for k in range(3)))
    center = (minimum + maximum) / 2
    extent = maximum - minimum
    scale = Vector(tuple(source['size'][k] / extent[k] for k in range(3)))
    for vertex in bm.verts:
        delta = vertex.co - center
        vertex.co = Vector(tuple(delta[k] * scale[k] * 1.004 for k in range(3)))
    cutoff = source['size'][1] / 2 - source['depth']
    bmesh.ops.bisect_plane(bm, geom=list(bm.verts) + list(bm.edges) + list(bm.faces),
                          dist=0.00001, plane_co=(0, cutoff, 0), plane_no=(0, 1, 0),
                          clear_inner=True)
    edges = [e for e in bm.edges if e.is_boundary and
             all(abs(v.co.y - cutoff) < 0.0002 for v in e.verts)]
    if edges:
        bmesh.ops.holes_fill(bm, edges=edges, sides=0)
    bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
    cf = source['cf']
    matrix = Matrix(((cf[3], cf[4], cf[5], cf[0]),
                     (cf[6], cf[7], cf[8], cf[1]),
                     (cf[9], cf[10], cf[11], cf[2]), (0, 0, 0, 1)))
    for vertex in bm.verts:
        vertex.co = matrix @ vertex.co
    bm.to_mesh(mesh)
    bm.free()
    for polygon in mesh.polygons:
        polygon.use_smooth = True
    mesh.update()
    mesh.calc_loop_triangles()
    points = [v.co for v in mesh.vertices]
    lower = Vector(tuple(min(p[k] for p in points) for k in range(3)))
    upper = Vector(tuple(max(p[k] for p in points) for k in range(3)))
    metadata[name] = {'center': list((lower + upper) / 2), 'size': list(upper - lower),
                      'triangles': len(mesh.loop_triangles)}
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    obj.select_set(True)

bpy.ops.export_scene.gltf(filepath=str(root / 'TRex_Undercoat_Persistent.glb'),
                          export_format='GLB', export_yup=False,
                          use_selection=True, export_materials='NONE')
(root / 'undercoat-metadata.json').write_text(json.dumps(metadata, indent=2), encoding='utf-8')
print(json.dumps(metadata))
