extends Control

var cena_map1 = preload("res://Scenes/MainScenes/map_1_game_scene.tscn")
var cena_map2 = preload("res://Scenes/MainScenes/map_2_game_scene.tscn")
var cena_map3 = preload("res://Scenes/MainScenes/map_3_game_scene.tscn")

func _ready():
	get_node("B/M/MenuOptions/Mapa1").pressed.connect(_on_map1_pressed)
	get_node("B/M/MenuOptions/Mapa2").pressed.connect(_on_map2_pressed)
	get_node("B/M/MenuOptions/Mapa3").pressed.connect(_on_map3_pressed)

func _on_map1_pressed() -> void:
	Game.reset_stats()
	get_tree().change_scene_to_packed(cena_map1)

func _on_map2_pressed() -> void:
	Game.reset_stats()
	get_tree().change_scene_to_packed(cena_map2)

func _on_map3_pressed() -> void:
	Game.reset_stats()
	get_tree().change_scene_to_packed(cena_map3)