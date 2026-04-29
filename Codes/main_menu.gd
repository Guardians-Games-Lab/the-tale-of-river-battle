extends Node

# =========================
# 📂 REFERÊNCIAS DE UI
# =========================
@onready var menu_ui = $MainMenu
@onready var game_instancia = $SelecaoDeFases
@onready var learderboard = $LeaderboardMenu

# 🌐 Referências da LAN (Baseado na estrutura que você enviou)
@onready var container_matchmaking = $MainMenu/M/MatchMaking
@onready var label_ip_host = $MainMenu/M/MatchMaking/IPHost
@onready var input_ip = $MainMenu/M/MatchMaking/InputIP
@onready var btn_host = $MainMenu/M/MatchMaking/BotoesLAN/BtnHost
@onready var btn_join = $MainMenu/M/MatchMaking/BotoesLAN/BtnJoin
@onready var btn_sair = $MainMenu/M/MatchMaking/BotoesLAN/BtnSair

# =========================
# 🚀 INICIALIZAÇÃO
# =========================
func _ready():
	menu_ui.show()
	game_instancia.hide()

	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	# 🔌 Conexão dos botões básicos
	get_node("MainMenu/M/MenuOptions/NovoJogo").pressed.connect(on_new_game_pressed)
	get_node("MainMenu/M/MenuOptions/Sair").pressed.connect(on_exit_pressed)
	get_node("MainMenu/M/MenuOptions/Leaderboard").pressed.connect(on_leaderboard_pressed)

	# 🔌 Conexões da LAN
	if btn_host: btn_host.pressed.connect(on_host_pressed)
	if btn_join: btn_join.pressed.connect(on_join_pressed)
	if btn_sair: btn_sair.pressed.connect(on_sair_pressed)
	
	# (Opcional) Se você criar um botão "BtnModoLan" no futuro para abrir/fechar essa caixa de rede, o código já está pronto aqui:
	var btn_modo_lan = get_node_or_null("MainMenu/M/MenuOptions/BtnModoLan")
	if btn_modo_lan:
		btn_modo_lan.pressed.connect(func(): container_matchmaking.visible = !container_matchmaking.visible)

	get_node("MainMenu/M/MenuOptions/NovoJogo").grab_focus()

# =========================
# 🌐 LÓGICA DA REDE (LAN)
# =========================
func on_host_pressed():
	# 1. Chama a função no Autoload e recebe o IP da máquina
	var meu_ip = Game.host_lan()
	
	# 2. Mostra o IP na Label para o jogador copiar e enviar pro amigo
	label_ip_host.text = "IP da Sala: " + meu_ip
	
	# 3. Limpa a tela das opções que ele não precisa mais
	btn_join.hide()
	btn_host.hide()
	input_ip.hide()
	
	# 4. Desabilita o botão para ele não clicar duas vezes (Como é TextureButton, ele não tem texto)
	btn_host.disabled = true
	print("📡 Sala criada no IP: ", meu_ip)

func on_join_pressed():
	# 1. Pega o IP digitado na caixa (ou usa o Localhost se tiver vazio)
	var ip_alvo = input_ip.text
	if ip_alvo == "": 
		ip_alvo = "127.0.0.1"
		
	# 2. Pede para o Game tentar conectar neste IP
	Game.join_lan(ip_alvo)
	
	# 3. Atualiza a UI para o jogador
	btn_join.disabled = true
	btn_join.hide()
	btn_host.hide()
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
	# 1. Desliga o servidor ou cliente no motor do jogo
	Game.desconectar_rede()
	
	# 2. Restaura toda a UI da LAN para o estado original
	if btn_join:
		btn_join.disabled = false
		btn_join.show()
		
	if btn_host:
		btn_host.disabled = false
		btn_host.show()
		input_ip.show()
		
	if input_ip:
		input_ip.show()
		input_ip.text = "" # Limpa o IP que estava digitado
		
	if label_ip_host:
		label_ip_host.text = "IP da Sala: " # Reseta a mensagem do Host
	
	
	
