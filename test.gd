tool
extends MeshInstance
class_name FaceWithMarginOLD

export var normal : Vector3

func generate_mesh():
	var st = SurfaceTool.new()

	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	st.add_normal(normal)
	st.add_uv(Vector2(0.0, 0.0))
	st.add_vertex(Vector3(-1.0, 0.0, 1.0))
	
	st.add_normal(normal)
	st.add_uv(Vector2(1.0, 0.0))
	st.add_vertex(Vector3(0.0, 0.0, 1.0))
	
	st.add_normal(normal)
	st.add_uv(Vector2(0.0, 1.0))
	st.add_vertex(Vector3(-1.0, 0.0, -0.0))
	
	st.add_normal(normal)
	st.add_uv(Vector2(1.0, 1.0))
	st.add_vertex(Vector3(-0.0, 0.0, -0.0))
			

	st.add_index(0);
	st.add_index(3);
	st.add_index(2);

	st.add_index(0);
	st.add_index(1);
	st.add_index(3);


	st.add_normal(normal)
	st.add_uv(Vector2(0.0, 0.0))
	st.add_vertex(Vector3(1.0, 0.0, 1.0))
	
	st.add_normal(normal)
	st.add_uv(Vector2(0.0, 1.0))
	st.add_vertex(Vector3(1.0, 0.0, 0.0))

	st.add_index(1);
	st.add_index(5);
	st.add_index(3);

	st.add_index(1);
	st.add_index(4);
	st.add_index(5);	


	st.add_normal(normal)
	st.add_uv(Vector2(0.0, 0.0))
	st.add_vertex(Vector3(-1.0, 0.0, -1.0))
	
	st.add_normal(normal)
	st.add_uv(Vector2(1.0, 0.0))
	st.add_vertex(Vector3(0.0, 0.0, -1.0))
			
	st.add_index(2);
	st.add_index(7);
	st.add_index(6);

	st.add_index(2);
	st.add_index(3);
	st.add_index(7);

	
	
	st.add_normal(normal)
	st.add_uv(Vector2(0.0, 0.0))
	st.add_vertex(Vector3(1.0, 0.0, -1.0))
	
	st.add_index(3);
	st.add_index(8);
	st.add_index(7);

	st.add_index(3);
	st.add_index(5);
	st.add_index(8);
	
	call_deferred("_update_mesh", st)
	
func _update_mesh(st):
	mesh = st.commit()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_object_local(Vector3(0, 1, 0), delta/20)
