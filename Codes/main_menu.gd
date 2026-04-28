extends Node

@onready var menu_ui = $MainMenu
@onready var game_instancia = $SelecaoDeFases

# Nós de Rede Local (LAN)
@onready var label_lan = $MainMenu/M/MatchMaking/LanMode/Label
@onready var btn_host = $MainMenu/M/MatchMaking/Host 
@onready var btn_join = $MainMenu/M/MatchMaking/Join
@onready var input_ip = $MainMenu/M/MatchMaking/InputIP 

func _ready():
	menu_ui.show()
	game_instancia.hide()

	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Conexão dos botões básicos
	get_node("MainMenu/M/MenuOptions/NovoJogo").pressed.connect(on_new_game_pressed)
	get_node("MainMenu/M/MenuOptions/Sair").pressed.connect(on_exit_pressed)
	get_node("MainMenu/M/MatchMaking/LanMode").pressed.connect(on_lanmode_pressed)

	# Conexão dos botões de Rede
	if btn_host and btn_join:
		btn_host.pressed.connect(on_host_pressed)
		btn_join.pressed.connect(on_join_pressed)
		
		# Oculta as opções de rede ao iniciar
		btn_host.hide()
		btn_join.hide()
		input_ip.hide()
		input_ip.text = "127.0.0.1" # IP Padrão para testes no mesmo PC

	get_node("MainMenu/M/MenuOptions/NovoJogo").grab_focus()

func on_new_game_pressed():
	menu_ui.hide()
	game_instancia.show()
	Game.reset_stats()

func on_exit_pressed():
	get_tree().quit()

# =========================
# 🌐 CONTROLES DE REDE (LAN)
# =========================
func on_lanmode_pressed():
	if label_lan.text == "Offline":
		label_lan.text = "Online"
		btn_host.show()
		btn_join.show()
		input_ip.show()
	else:
		label_lan.text = "Offline"
		btn_host.hide()
		btn_join.hide()
		input_ip.hide()

func on_host_pressed():
	Game.criar_servidor_local()

func on_join_pressed():
	var ip_digitado = input_ip.text
	if ip_digitado != "":
		Game.conectar_ao_servidor(ip_digitado)