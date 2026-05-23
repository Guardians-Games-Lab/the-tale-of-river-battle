extends Node

# =========================
# 📂 REFERÊNCIAS DE UI DA REDE E MENU
# =========================
@onready var menu_ui = $MainMenu
@onready var game_instancia = $SelecaoDeFases
@onready var learderboard = $LeaderboardMenu

@onready var btn_som = $MainMenu/MuteButton
@onready var container_matchmaking = $MainMenu/M/MatchMaking
@onready var label_ip_host = $MainMenu/M/MatchMaking/IPHost
@onready var input_ip = $MainMenu/M/MatchMaking/InputIP
@onready var btn_host = $MainMenu/M/MatchMaking/BotoesLAN/BtnHost
@onready var btn_join = $MainMenu/M/MatchMaking/BotoesLAN/BtnJoin
@onready var btn_sair = $MainMenu/M/MatchMaking/BotoesLAN/BtnSair
@onready var btn_online = $MainMenu/M/MatchMaking/BotoesLAN/BtnOnline

# =========================
# 📝 REFERÊNCIAS DO MENU DE NOME
# =========================
@onready var label_nome_dispositivo = $MainMenu/DeviceNameLabel
@onready var painel_renomear = $MainMenu/NicknameSwitcher
@onready var input_novo_nome = $MainMenu/NicknameSwitcher/LineEdit
@onready var btn_trocar_nome = $MainMenu/NicknameSwitcher/HBoxContainer/SwitchBtn
@onready var btn_cancelar_nome = $MainMenu/NicknameSwitcher/HBoxContainer/CancelBtn

# =========================
# 🚀 INICIALIZAÇÃO
# =========================
func _ready():
	menu_ui.show()
	game_instancia.hide()

	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	Game.tocar_musica("menu")
	
	# 🔌 Conexão dos botões básicos
	get_node("MainMenu/M/MenuOptions/NovoJogo").pressed.connect(on_new_game_pressed)
	get_node("MainMenu/M/MenuOptions/Sair").pressed.connect(on_exit_pressed)
	get_node("MainMenu/M/MenuOptions/Leaderboard").pressed.connect(on_leaderboard_pressed)
	
	if btn_som:
		btn_som.pressed.connect(_on_btn_som_pressed)
		_atualizar_visual_do_botao_som() # Ajusta o botão ao abrir a tela
		
	# 🔌 Conexões da LAN
	if btn_host: btn_host.pressed.connect(on_host_pressed)
	if btn_join: btn_join.pressed.connect(on_join_pressed)
	if btn_sair: btn_sair.pressed.connect(on_sair_pressed)
	
	# 👇 CORREÇÃO: Estava checando btn_sair antes!
	if btn_online: btn_online.pressed.connect(on_online_pressed) 
	
	# 👇 CORREÇÃO PRO MOBILE: Força o teclado a abrir quando tocar no input de IP
	if input_ip:
		input_ip.gui_input.connect(_on_input_ip_gui_input)
	
	# 📝 SETUP DO SISTEMA DE NOME
	if label_nome_dispositivo:
		label_nome_dispositivo.text = Game.nome_jogador
		label_nome_dispositivo.gui_input.connect(_on_label_nome_clicada)
		
	if painel_renomear:
		painel_renomear.hide() 
		
	if btn_trocar_nome:
		btn_trocar_nome.pressed.connect(_on_btn_trocar_nome_pressed)
		
	if btn_cancelar_nome:
		btn_cancelar_nome.pressed.connect(func(): painel_renomear.hide())

	get_node("MainMenu/M/MenuOptions/NovoJogo").grab_focus()

# =========================
# ⌨️ FORÇAR TECLADO NO IP (NOVO)
# =========================
func _on_input_ip_gui_input(event):
	if (event is InputEventScreenTouch or event is InputEventMouseButton) and event.pressed:
		input_ip.grab_focus()

# =========================
# 📝 LÓGICA DE TROCA DE NOME
# =========================
func _on_label_nome_clicada(event):
	if (event is InputEventScreenTouch or event is InputEventMouseButton) and event.pressed:
		if painel_renomear:
			painel_renomear.show()
			if input_novo_nome:
				input_novo_nome.placeholder_text = Game.nome_jogador
				input_novo_nome.text = "" 
				input_novo_nome.grab_focus()

func _on_btn_trocar_nome_pressed():
	if input_novo_nome and input_novo_nome.text.strip_edges() != "":
		var novo_nome = input_novo_nome.text.strip_edges()
		Game.nome_jogador = novo_nome 
		
		if label_nome_dispositivo:
			label_nome_dispositivo.text = novo_nome 
			
	if painel_renomear:
		painel_renomear.hide()

# =========================
# 🌐 LÓGICA DA REDE (LAN)
# =========================
func on_host_pressed():
	var meu_ip = Game.host_lan()
	label_ip_host.show()
	label_ip_host.text = "IP da Sala: " + meu_ip
	
	btn_join.hide()
	btn_host.hide()
	input_ip.hide()
	btn_sair.show()
	
	btn_host.disabled = true
	print("📡 Sala criada no IP: ", meu_ip)

func on_join_pressed():
	var ip_alvo = input_ip.text
	if ip_alvo == "": 
		ip_alvo = "127.0.0.1"
		
	Game.join_lan(ip_alvo)
	
	btn_join.disabled = true
	btn_join.hide()
	btn_host.hide()
	btn_sair.show()
	print("🔄 Tentando entrar na sala: ", ip_alvo)

# =========================
# 🎮 AÇÕES DOS BOTÕES BÁSICOS
# =========================
func on_new_game_pressed():
	menu_ui.hide()
	game_instancia.show()
	Game.reset_stats()

func on_exit_pressed():
	get_tree().quit()

func on_leaderboard_pressed():
	menu_ui.hide()
	learderboard.show()

func on_sair_pressed():
	Game.desconectar_rede()
	btn_sair.hide()
	label_ip_host.hide()

	if btn_join:
		btn_join.disabled = false
		btn_join.show()
		
	if btn_host:
		btn_host.disabled = false
		btn_host.show()
		input_ip.show()
		
	if input_ip:
		input_ip.show()
		input_ip.text = "" 
		
	if label_ip_host:
		label_ip_host.text = "IP da Sala: "

func _on_btn_som_pressed():
	Game.toggle_mute() 
	_atualizar_visual_do_botao_som()

func _atualizar_visual_do_botao_som():
	if not btn_som: return

func on_online_pressed():
	btn_online.hide()
	btn_host.show()
	btn_join.show()
	input_ip.show()
