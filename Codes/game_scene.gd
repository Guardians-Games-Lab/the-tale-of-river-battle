extends Node2D

var selected_tower_scene: PackedScene
var preview = null

func start_build_mode(scene):
	selected_tower_scene = scene
	
	if preview:
		preview.queue_free()
	
	preview = selected_tower_scene.instantiate()
	add_child(preview)
	preview.modulate = Color(1,1,1,0.5)


func _process(delta):
	if preview:
		preview.global_position = get_global_mouse_position()


func _input(event):
	if preview and event is InputEventMouseButton and event.pressed:
		
		# evita clicar na UI
		if get_viewport().gui_get_hovered_control():
			return
		
		var tower = selected_tower_scene.instantiate()
		tower.global_position = get_global_mouse_position()
		$Towers.add_child(tower)
		
		preview.queue_free()
		preview = null
