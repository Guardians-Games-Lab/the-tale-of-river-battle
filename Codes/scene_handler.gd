extends Node

# Muda cena do jogo
func _ready():
	# Dupla garantia de que o menu nasce vivo
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	get_node("MainMenu/M/MenuOptions/NovoJogo").pressed.connect(on_new_game_pressed)
	get_node("MainMenu/M/MenuOptions/Sair").pressed.connect(on_exit_pressed)
	get_node("MainMenu/M/MatchMaking/LanMode").pressed.connect(on_lanmode_pressed)

	get_node("MainMenu/M/MenuOptions/NovoJogo").grab_focus()

func on_new_game_pressed():
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/MainScenes/game_scene.tscn")	

func on_exit_pressed():
	get_tree().quit()
func on_lanmode_pressed():
	var label = $MainMenu/M/MatchMaking/LanMode/Label
	if label.text == "Offline":
		label.text = "Online"
	else:
		label.text = "Offline"
	
