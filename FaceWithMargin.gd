tool
extends MeshInstance
class_name FaceWithMarginOLD2

export var normal : Vector3

func spherize(pointOnUnitCube : Vector3):
	var x2 := pointOnUnitCube.x * pointOnUnitCube.x
	var y2 := pointOnUnitCube.y * pointOnUnitCube.y
	var z2 := pointOnUnitCube.z * pointOnUnitCube.z
	var sx := pointOnUnitCube.x * sqrt(1.0 - y2 / 2.0 - z2 / 2.0 + y2 * z2 / 3.0)
	var sy := pointOnUnitCube.y * sqrt(1.0 - x2 / 2.0 - z2 / 2.0 + x2 * z2 / 3.0)
	var sz := pointOnUnitCube.z * sqrt(1.0 - x2 / 2.0 - y2 / 2.0 + x2 * y2 / 3.0)			
	return Vector3(sx, sy, sz)
	
func vertex_pos(x : int, y : int, resolution: int):
	var dX = 1.0 * x / (resolution - 1)
	var dY = 1.0 * y / (resolution - 1)
	var posX = dX - 0.5
	var posY = dY - 0.5

	return Vector3(posX, posY, 0)

func generate_mesh():
	var st = SurfaceTool.new()

	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var resolution : int = 11
	var margin : int = 3
	var width : int = resolution + (2 * margin)
	var offset : float = margin / width
	var i : int = 0

	var axisA := Vector3(normal.y, normal.z, normal.x)
	var axisB : Vector3 = normal.cross(axisA)
	for y in range(margin + 1):
		for x in range(width):
			# So, how to calculate position neatly? (flat plane for now)
			# 0 - 3   /   3 - 13   / 13 - 16
			# < margin / x >= margin and x < width - margin   / x >= width - margin
			
			var percent := Vector2(x, y) / (width - 1) # change to resolution when only used for face
			var pointOnUnitCube : Vector3 = normal + (percent.x - 0.5) * 2.0 * axisA + (percent.y - 0.5) * 2.0 * axisB
			
			
			
			# wind 'backwards' for now, so all are visible 'outside' cube
			if x > 0 and y > 0:
				st.add_index(i - width - 1);
				st.add_index(i - 1);
				st.add_index(i);

				st.add_index(i - width - 1);
				st.add_index(i);
				st.add_index(i - width);
			
			if y <= margin:            # top margin
				if x <= margin:
					st.add_uv(Vector2(x / (margin), y / (margin)))
				if x > margin and x < width - margin - 1:
					# x from 1 @ 3 to 0 @ 13
					st.add_uv(Vector2((width - margin - x - 1) / resolution, y / (margin)))
				if x >= width - margin - 1:
					st.add_uv(Vector2((x - resolution + 1) / (margin), y / (margin)))
					
			#elif x < margin:          # left margin
			#elif x >= width - margin: # right margin
			#elif y >= margin:         # bottom margin
			#else:                     # actual face

			st.add_normal(normal)
			st.add_vertex(pointOnUnitCube)
					
			i += 1


	
	call_deferred("_update_mesh", st)
	
func _update_mesh(st):
	mesh = st.commit()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_object_local(Vector3(0, 1, 0), delta/20)
