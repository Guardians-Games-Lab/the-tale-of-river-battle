
extends Node2D

@export var tower_scene: PackedScene

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			
			var game = get_tree().get_first_node_in_group("game")
			game.start_build_mode(tower_scene)
