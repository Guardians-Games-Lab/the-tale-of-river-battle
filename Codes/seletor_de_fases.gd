extends Control


func _ready():
	get_node("B/M/MenuOptions/Mapa1").pressed.connect(_on_map1_pressed)

func _on_map1_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/MainScenes/map1_game_scene.tscn")	
