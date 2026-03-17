extends Node

# Muda cena do jogo
func _ready():
	get_node("MainMenu/M/MenuOptions/NovoJogo").pressed.connect(on_new_game_pressed)
	get_node("MainMenu/M/MenuOptions/Sair").pressed.connect(on_exit_pressed)
	get_node("MainMenu/M/MatchMaking/LanMode").pressed.connect(on_lanmode_pressed)

func on_new_game_pressed():
	get_node("MainMenu").queue_free();
	var game_scene = load("res://Scenes/MainScenes/game_scene.tscn").instantiate()
	add_child(game_scene)
	
func on_exit_pressed():
	get_tree().quit()
func on_lanmode_pressed():
	var label = $MainMenu/M/MatchMaking/LanMode/Label
	if label.text == "Offline":
		label.text = "Online"
	else:
		label.text = "Offline"
	
