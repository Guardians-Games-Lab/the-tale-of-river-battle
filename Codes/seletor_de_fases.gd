extends Control

var cena_map1 = preload("res://Scenes/MainScenes/map1_game_scene.tscn")

func _ready():
	get_node("B/M/MenuOptions/Mapa1").pressed.connect(_on_map1_pressed)

func _on_map1_pressed() -> void:
	Game.reset_stats()
	get_tree().change_scene_to_packed(cena_map1)