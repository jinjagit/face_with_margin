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

func displace_vertically(factor : float, resolution: int):
	var v_offset : float = factor * (1.0 / (resolution - 1)) * 2.0

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
	
func set_triangle_indices(index_ary : PoolIntArray, tri_index : int, a : int, b : int, c : int, d : int, e : int, f: int):
	index_ary[tri_index + 2] = a
	index_ary[tri_index + 1] = b
	index_ary[tri_index] = c

	index_ary[tri_index + 5] = d
	index_ary[tri_index + 4] = e
	index_ary[tri_index + 3] = f
	
	return index_ary

func vertex_posn(face_normal : Vector3, percent : Vector2, axisA : Vector3, axisB : Vector3, spherized):
	var pointOnUnitCube = face_normal + (percent.x - 0.5) * 2.0 * axisA + (percent.y - 0.5) * 2.0 * axisB
	return spherize(pointOnUnitCube) if spherized else pointOnUnitCube
			
func generate_mesh():		
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)

	var vertex_array := PoolVector3Array()
	var uv_array := PoolVector2Array()
	var normal_array := PoolVector3Array()
	var index_array := PoolIntArray()

	var resolution := 128
	var margin := 3
	var res_sq = resolution * resolution
	var res_sq2 = resolution * (resolution -1)
	var num_vertices : int = res_sq + (margin * (resolution - 1) * 4)
	var num_indices : int = ((resolution - 1) * (resolution -1) * 6) + (margin * (resolution - 1) * 24)

	var spherized = false

	vertex_array.resize(num_vertices)
	uv_array.resize(num_vertices)
	normal_array.resize(num_vertices)
	index_array.resize(num_indices)

	var tri_index : int = 0
	var axisA := Vector3(normal.y, normal.z, normal.x)
	var axisB : Vector3 = normal.cross(axisA)
	var percent := Vector2(0.0, 0.0)
	var i : int = 0

	# ----------- The actual cube face mesh: --------------

	for y in range(resolution):
		for x in range(resolution):
			percent = Vector2(x, y) / (resolution - 1)
			vertex_array[i] = vertex_posn(normal, percent, axisA, axisB, spherized)
			uv_array[i] = Vector2((x * 1.0) / (resolution - 1), (y * 1.0) / (resolution - 1))

			if x != resolution - 1 and y != resolution - 1:
				index_array = set_triangle_indices(index_array, tri_index, i, i + resolution + 1, i + resolution, i, i + 1, i + resolution + 1)
				tri_index += 6

			i += 1

	# ----------- The margin mesh: --------------

	for m in range(margin):
		# Calculate 'vertical' offset.
		var new_normal : Vector3 = displace_vertically((m + 1) * 1.0, resolution)

		# 'Top' edge margin:
		for x in range(resolution - 1):
			percent = Vector2((x * 1.0) / (resolution - 1), 0.0)
			vertex_array[i] = vertex_posn(new_normal, percent, axisA, axisB, spherized)
			
			# Margin row
			if x != resolution - 2:
				if m == 0:
					index_array = set_triangle_indices(index_array, tri_index, x, i, i + 1, x, i + 1, x + 1)
				else:
					index_array = set_triangle_indices(index_array, tri_index, i - ((resolution -1) * 4), i, i + 1, i - ((resolution -1) * 4), i + 1, i - ((resolution -1) * 4) + 1)
				tri_index += 6

			i += 1

		# 'Right' edge margin:
		for x in range(resolution - 1):
			percent = Vector2(1.0, (x * 1.0) / (resolution - 1))
			vertex_array[i] = vertex_posn(new_normal, percent, axisA, axisB, spherized)
			
			# Connect with end of previous margin row
			if x == 0:
				if m == 0:
					index_array = set_triangle_indices(index_array, tri_index, resolution - 2, i - 1, i, resolution - 2, i, resolution -1)
				else:
					index_array = set_triangle_indices(index_array, tri_index, i - ((resolution -1) * 4) - 1, i - 1, i, i - ((resolution -1) * 4) - 1, i, i - ((resolution -1) * 4))
				tri_index += 6

			# Margin row
			if x != resolution - 2:
				if m == 0:
					index_array = set_triangle_indices(index_array, tri_index, (resolution - 1) + (x * resolution), i, i + 1, (resolution - 1) + (x * resolution), i + 1, (resolution - 1) + ((x  + 1) * resolution))
				else:
					index_array = set_triangle_indices(index_array, tri_index, i - ((resolution -1) * 4), i, i + 1, i - ((resolution -1) * 4), i + 1, i - ((resolution -1) * 4) + 1)
				tri_index += 6

			i += 1

		# 'Bottom' edge margin:
		for x in range(resolution - 1):
			percent = Vector2(((resolution - 1 - x) * 1.0) / (resolution - 1), 1.0)
			vertex_array[i] = vertex_posn(new_normal, percent, axisA, axisB, spherized)

			# Connect with end of previous margin row
			if x == 0:
				if m == 0:
					index_array = set_triangle_indices(index_array, tri_index, res_sq - resolution - 1, i - 1, i, res_sq - resolution - 1, i, res_sq - 1)
				else:
					index_array = set_triangle_indices(index_array, tri_index, i - ((resolution -1) * 4) - 1, i - 1, i, i - ((resolution -1) * 4) - 1, i, i - ((resolution -1) * 4))
				tri_index += 6

			# Margin row
			if x != resolution - 2:
				if m == 0:
					index_array = set_triangle_indices(index_array, tri_index, res_sq - 1 - x, i, i + 1, res_sq - 1 - x, i + 1, res_sq - 2 - x)
				else:
					index_array = set_triangle_indices(index_array, tri_index, i - ((resolution -1) * 4), i, i + 1, i - ((resolution -1) * 4), i + 1, i - ((resolution -1) * 4) + 1)
				tri_index += 6

			i += 1

		# 'Left' edge margin:
		for x in range(resolution - 1):
			percent = Vector2(0.0, ((resolution - 1 - x) * 1.0) / (resolution - 1))
			vertex_array[i] = vertex_posn(new_normal, percent, axisA, axisB, spherized)

			# Connect with end of previous margin row
			if x == 0:
				if m == 0:
					index_array = set_triangle_indices(index_array, tri_index, res_sq2 + 1, i - 1, i, res_sq2 + 1, i, res_sq2)
				else:
					index_array = set_triangle_indices(index_array, tri_index, i - ((resolution -1) * 4) - 1, i - 1, i, i - ((resolution -1) * 4) - 1, i, i - ((resolution -1) * 4))
				tri_index += 6

			# Margin row
			if x != resolution - 2:
				if m == 0:
					index_array = set_triangle_indices(index_array, tri_index, res_sq2 - (x * resolution), i, i + 1, res_sq2 - (x * resolution), i + 1, res_sq2 - ((x + 1) * resolution))
				else:
					index_array = set_triangle_indices(index_array, tri_index, i - ((resolution -1) * 4), i, i + 1, i - ((resolution -1) * 4), i + 1, i - ((resolution -1) * 4) + 1)
				tri_index += 6
				
			# Connect with start of margin row
			if x == resolution - 2:
				if m == 0:
					index_array = set_triangle_indices(index_array, tri_index, resolution, i, i - ((resolution - 1) * 4) + 1, resolution, i - ((resolution - 1) * 4) + 1, 0)
				else:
					index_array = set_triangle_indices(index_array, tri_index, i - ((resolution - 1) * 4), i, i - ((resolution - 1) * 4) + 1, i - ((resolution - 1) * 4), i - ((resolution - 1) * 4) + 1, i - ((resolution - 1) * 8) + 1)
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
	print("n triangles {t}".format({"t":index_array.size() / 3.0}))
	var pc_vertices : float = (margin * 1.0 * (resolution - 1) * 4) / (res_sq + (margin * (resolution - 1) * 4)) * 100
	print("percent vertices in margin {pcv}".format({"pcv":pc_vertices}))
	var pc_triangles : float = ((margin * 1.0 * (resolution - 1) * 24) / (((resolution - 1) * (resolution -1) * 6) + (margin * (resolution - 1) * 24))) / 3.0 * 100.0
	print("percent triangles in margin {pct}".format({"pct":pc_triangles}))

	call_deferred("_update_mesh", arrays)#

func _update_mesh(arrays : Array):
	var _mesh := ArrayMesh.new()
	_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	self.mesh = _mesh

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_object_local(Vector3(0, 1, 0), delta/5)
