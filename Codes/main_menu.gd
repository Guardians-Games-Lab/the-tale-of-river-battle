extends Node


@onready var menu_ui = $MainMenu
@onready var game_instancia = $SelecaoDeFases
# Muda cena do jogo
func _ready():

	# Garante o estado inicial
	menu_ui.show()
	game_instancia.hide()

	# Dupla garantia de que o menu nasce vivo
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	get_node("MainMenu/M/MenuOptions/NovoJogo").pressed.connect(on_new_game_pressed)
	get_node("MainMenu/M/MenuOptions/Sair").pressed.connect(on_exit_pressed)
	get_node("MainMenu/M/MatchMaking/LanMode").pressed.connect(on_lanmode_pressed)

	get_node("MainMenu/M/MenuOptions/NovoJogo").grab_focus()

func on_new_game_pressed():
	# 🟢 O TRUQUE: Esconde um e mostra o outro
	menu_ui.hide()
	game_instancia.show()
	
	# 🚀 IMPORTANTE: Resetar os stats para começar uma partida limpa
	Game.reset_stats()

func on_exit_pressed():
	get_tree().quit()
func on_lanmode_pressed():
	var label = $MainMenu/M/MatchMaking/LanMode/Label
	if label.text == "Offline":
		label.text = "Online"
	else:
		label.text = "Offline"

func _on_leaderboard_button_pressed():
	# Troca para a cena do ranking
	get_tree().change_scene_to_file("res://Leaderboard.tscn")
