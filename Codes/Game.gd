extends Node

# =========================
# 📂 CONFIGURAÇÃO DE SAVES LOCAIS
# =========================
const SAVE_PATH = "user://highscore.save"
const LEADERBOARD_PATH = "user://lan_leaderboard.json" 

# =========================
# 💰 SISTEMA DE STATUS
# =========================
var Gold: int = 20
var Score: int = 0
var Highscore: int = 0
var Health: int = 100
var Wave: int = 1
var nome_jogador: String = "Davi" # O teu nome padrão

signal gold_changed
signal score_changed
signal health_changed
signal wave_changed
signal game_over
signal leaderboard_atualizado # Sinal para atualizar a tabela

# =========================
# 📡 SISTEMA DE REDE LOCAL (LAN)
# =========================
const PORT = 8910
var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var lan_scores: Array = [] 

# =========================
# ⚙️ INICIALIZAÇÃO
# =========================
func _ready():
	# Carrega apenas o recorde pessoal ao iniciar o jogo
	load_highscore() 

# =========================
# 📡 FUNÇÕES DE REDE (HOST / JOIN)
# =========================
func criar_servidor_local():
	var erro = peer.create_server(PORT, 2) 
	if erro == OK:
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_jogador_conectou)
		print("✅ Servidor Hospedado! IPs: ", IP.get_local_addresses())
		
		# SÓ O HOST CARREGA A LISTA DO RANKING!
		_carregar_leaderboard_do_host() 
		
		# O Host submete logo o seu próprio recorde para a lista
		submeter_score_lan()
	else:
		print("❌ Erro ao criar servidor: ", erro)

func conectar_ao_servidor(ip_do_host: String):
	var erro = peer.create_client(ip_do_host, PORT)
	if erro == OK:
		multiplayer.multiplayer_peer = peer
		multiplayer.connected_to_server.connect(_conectado_com_sucesso)
		multiplayer.connection_failed.connect(_falha_na_conexao)
		print("🔄 A tentar conectar ao Host: ", ip_do_host)

func _jogador_conectou(id: int): 
	print("🎮 Jogador conectou! ID: ", id)
	# O Host manda a lista de pontuações atual para quem acabou de entrar
	rpc_id(id, "_receber_leaderboard", lan_scores)

func _conectado_com_sucesso(): 
	print("✅ Entraste na sala do Host!")
	# Assim que o Cliente entra, envia o seu Highscore automaticamente!
	submeter_score_lan()

func _falha_na_conexao(): 
	print("❌ Não foi possível encontrar o Host.")

# =========================
# 🏆 SISTEMA DE LEADERBOARD (LAN - RPC)
# =========================
func submeter_score_lan():
	# Usa sempre o Highscore (Recorde Máximo)
	if Highscore > 0:
		print("📡 A enviar RECORDE (", Highscore, ") pela rede local...")
		if multiplayer.is_server():
			_processar_nova_pontuacao(nome_jogador, Highscore)
		else:
			rpc_id(1, "_processar_nova_pontuacao", nome_jogador, Highscore)

# Esta função roda APENAS no computador/telemóvel do HOST
@rpc("any_peer", "call_local", "reliable")
func _processar_nova_pontuacao(p_nome: String, p_score: int):
	if not multiplayer.is_server(): return 
	
	# Verifica se o jogador já está na lista para atualizar
	var jogador_encontrado = false
	for entrada in lan_scores:
		if entrada.player_name == p_nome:
			jogador_encontrado = true
			if p_score > entrada.score:
				entrada.score = p_score # Atualiza apenas se for um recorde maior
			break
			
	if not jogador_encontrado:
		lan_scores.append({"player_name": p_nome, "score": p_score})
	
	# Organiza do maior para o menor
	lan_scores.sort_custom(func(a, b): return a.score > b.score)
	
	# Mantém apenas o Top 10
	if lan_scores.size() > 10:
		lan_scores.resize(10)
		
	_salvar_leaderboard_no_host()
	
	# O Host avisa TODOS os jogadores que a lista foi atualizada
	rpc("_receber_leaderboard", lan_scores)

# Esta função roda em todos os Clientes quando o Host atualiza a lista
func _receber_leaderboard(nova_lista: Array):
	lan_scores = nova_lista
	leaderboard_atualizado.emit() # Avisa o ecrã do menu para se desenhar de novo

# =========================
# 📂 CARREGAMENTO E GRAVAÇÃO (SEGURA)
# =========================
func _salvar_leaderboard_no_host():
	var file = FileAccess.open(LEADERBOARD_PATH, FileAccess.WRITE)
	if file: 
		file.store_line(JSON.stringify(lan_scores))

func _carregar_leaderboard_do_host():
	if FileAccess.file_exists(LEADERBOARD_PATH):
		var file = FileAccess.open(LEADERBOARD_PATH, FileAccess.READ)
		var json_string = file.get_line()
		
		var json = JSON.new()
		if json.parse(json_string) == OK:
			var data = json.get_data()
			# Trava de segurança: Garante que é uma Lista (Array) antes de ler
			if typeof(data) == TYPE_ARRAY:
				lan_scores = data
				leaderboard_atualizado.emit()
				print("📂 Tabela do Leaderboard carregada pelo Host!")

func save_highscore():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file: 
		file.store_line(JSON.stringify({"highscore": Highscore}))

func load_highscore():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var json_string = file.get_line()
		
		var json = JSON.new()
		if json.parse(json_string) == OK:
			var data = json.get_data()
			# Trava de segurança: Garante que é um Dicionário antes de ler
			if typeof(data) == TYPE_DICTIONARY and data.has("highscore"):
				Highscore = data["highscore"]
				print("📂 Highscore carregado com sucesso: ", Highscore)

# =========================
# 💔 FUNÇÕES DE JOGO (Dano, Dinheiro, Reset)
# =========================
func add_score(amount: int):
	Score += amount
	score_changed.emit()
	if Score > Highscore:
		Highscore = Score
		save_highscore() 

func take_damage(amount: int):
	Health -= amount 
	if Health <= 0:
		Health = 0
		game_over.emit()
	health_changed.emit()	

func add_gold(amount: int):
	Gold += amount
	gold_changed.emit()

func spend_gold(amount: int) -> bool:
	if Gold >= amount:
		Gold -= amount
		gold_changed.emit()
		return true
	return false

func reset_stats():
	Health = 100
	Gold = 20
	Score = 0
	Wave = 1       
	health_changed.emit()
	gold_changed.emit()
	score_changed.emit()
	wave_changed.emit()

func set_wave(nova_wave: int):
	Wave = nova_wave
	wave_changed.emit()
	print("🌊 Iniciando Wave: ", Wave)