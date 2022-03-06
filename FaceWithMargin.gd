tool
extends MeshInstance
class_name FaceWithMargin

export var normal : Vector3

func spherize(pointOnUnitCube : Vector3):
	var x2 := pointOnUnitCube.x * pointOnUnitCube.x
	var y2 := pointOnUnitCube.y * pointOnUnitCube.y
	var z2 := pointOnUnitCube.z * pointOnUnitCube.z
	var sx := pointOnUnitCube.x * sqrt(1.0 - y2 / 2.0 - z2 / 2.0 + y2 * z2 / 3.0)
	var sy := pointOnUnitCube.y * sqrt(1.0 - x2 / 2.0 - z2 / 2.0 + x2 * z2 / 3.0)
	var sz := pointOnUnitCube.z * sqrt(1.0 - x2 / 2.0 - y2 / 2.0 + x2 * y2 / 3.0)
	return Vector3(sx, sy, sz)

func displace_vertically(factor : float, step: float):
	var v_offset : float = factor * step * 2.0

	var new_normal := Vector3(0.0, 0.0, 0.0)
	if normal.z > 0.0:
		new_normal = Vector3(0.0, 0.0, normal.z - v_offset)
	elif normal.z < 0.0:
		new_normal = Vector3(0.0, 0.0, normal.z + v_offset)
	elif normal.y > 0.0:
		new_normal = Vector3(0.0, normal.y - v_offset, 0.0)
	elif normal.y < 0.0:
		new_normal = Vector3(0.0, normal.y + v_offset, 0.0)
	elif normal.x > 0.0:
		new_normal = Vector3(normal.x - v_offset, 0.0, 0.0)
	else:
		new_normal = Vector3(normal.x + v_offset, 0.0, 0.0)

	return new_normal

func generate_mesh():
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)

	var vertex_array := PoolVector3Array()
	var uv_array := PoolVector2Array()
	var normal_array := PoolVector3Array()
	var index_array := PoolIntArray()

	var resolution := 12
	var margin := 0
	var step = 1.0 / (resolution - 1) # We can probably lose this.
	var num_vertices : int = resolution * resolution + (margin * (resolution - 1) * 4)
	var num_indices : int = (resolution - 1) * (resolution -1) * 6 + (margin * (resolution - 1) * 24)

	vertex_array.resize(num_vertices)
	uv_array.resize(num_vertices)
	normal_array.resize(num_vertices)
	index_array.resize(num_indices)

	var tri_index : int = 0
	var axisA := Vector3(normal.y, normal.z, normal.x)
	var axisB : Vector3 = normal.cross(axisA)
	var percent := Vector2(0.0, 0.0)
	var pointOnUnitCube := Vector3(0.0, 0.0, 0.0)
	var factor := 0.0
	var i : int = 0
	
	# For reference, the default percent calc:
	# var percent := Vector2(x, y) / (resolution - 1)

	for y in range(resolution):
		for x in range(resolution):
			percent = Vector2(x, y) / (resolution - 1)
			pointOnUnitCube = normal + (percent.x - 0.5) * 2.0 * axisA + (percent.y - 0.5) * 2.0 * axisB
			# Must convert integers to floats!
			uv_array[i] = Vector2((x * 1.0) / (resolution - 1), (y * 1.0) / (resolution - 1))

			#vertex_array[i] = spherize(pointOnUnitCube)
			vertex_array[i] = pointOnUnitCube

			if x != resolution - 1 and y != resolution - 1:
				index_array[tri_index + 2] = i
				index_array[tri_index + 1] = i + resolution + 1
				index_array[tri_index] = i + resolution

				index_array[tri_index + 5] = i
				index_array[tri_index + 4] = i + 1
				index_array[tri_index + 3] = i + resolution + 1
				tri_index += 6

			i += 1

	# Calculate normal for each triangle
	for a in range(0, index_array.size(), 3):
		var b : int = a + 1
		var c : int = a + 2
		var ab : Vector3 = vertex_array[index_array[b]] - vertex_array[index_array[a]]
		var bc : Vector3 = vertex_array[index_array[c]] - vertex_array[index_array[b]]
		var ca : Vector3 = vertex_array[index_array[a]] - vertex_array[index_array[c]]
		var cross_ab_bc : Vector3 = ab.cross(bc) * -1.0
		var cross_bc_ca : Vector3 = bc.cross(ca) * -1.0
		var cross_ca_ab : Vector3 = ca.cross(ab) * -1.0
		normal_array[index_array[a]] += cross_ab_bc + cross_bc_ca + cross_ca_ab
		normal_array[index_array[b]] += cross_ab_bc + cross_bc_ca + cross_ca_ab
		normal_array[index_array[c]] += cross_ab_bc + cross_bc_ca + cross_ca_ab

	# Normalize length of normals
	for j in range(normal_array.size()):
		normal_array[j] = normal_array[j].normalized()

	arrays[Mesh.ARRAY_VERTEX] = vertex_array
	arrays[Mesh.ARRAY_NORMAL] = normal_array
	arrays[Mesh.ARRAY_TEX_UV] = uv_array
	arrays[Mesh.ARRAY_INDEX] = index_array

	print("n vertices {v}".format({"v":vertex_array.size()}))
	print("uv0: {v}".format({"v":uv_array[9]}))
	print("normal: {v}".format({"v":normal}))

	call_deferred("_update_mesh", arrays)#

func _update_mesh(arrays : Array):
	var _mesh := ArrayMesh.new()
	_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	self.mesh = _mesh

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_object_local(Vector3(0, 1, 0), delta/5)

