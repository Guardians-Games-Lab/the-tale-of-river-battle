extends Node

# Muda cena do jogo
func _ready():
	get_node("MainMenu/M/VB/NovoJogo").pressed.connect(on_new_game_pressed)
	get_node("MainMenu/M/VB/Sair").pressed.connect(on_exit_pressed)


func on_new_game_pressed():
	get_node("MainMenu").queue_free();
	var game_scene = load("res://Assets/map_1.tscn").instantiate()
	add_child(game_scene)
	
func on_exit_pressed():
	get_tree().quit()
