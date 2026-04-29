extends Node

# =========================
# 📂 CONFIGURAÇÃO DE SAVES LOCAIS
# =========================
const SAVE_PATH = "user://local_highscores.json"
const LEADERBOARD_PATH = "user://lan_leaderboard.json" 

# =========================
# 💰 SISTEMA DE STATUS
# =========================
var Gold: int = 20
var Score: int = 0
var Health: int = 100
var Wave: int = 1

# 🗺️ CONTROLE DE MAPAS E RECORDES
var current_map: String = "mapa_1"

# Recordes locais (o seu máximo offline em cada mapa)
var Highscores: Dictionary = {
	"mapa_1": 0,
	"mapa_2": 0,
	"mapa_3": 0
}

# Leaderboard da LAN (pontuação de todo mundo da sala separado por mapa)
var lan_leaderboard: Dictionary = {
	"mapa_1": [],
	"mapa_2": [],
	"mapa_3": []
}

var nome_jogador: String = ""

# =========================
# 📡 SINAIS DO JOGO
# =========================
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


# =========================
# 🔌 DESCONECTAR REDE
# =========================
func desconectar_rede():
	# Fecha a conexão e tira o peer do multiplayer
	if multiplayer.multiplayer_peer != null:
		peer.close()
		multiplayer.multiplayer_peer = null
	
	# Limpa a tabela para não misturar com a próxima sala que ele entrar
	lan_leaderboard = {
		"mapa_1": [],
		"mapa_2": [],
		"mapa_3": []
	}
	print("🔌 Desconectado da rede local.")

# =========================
# ⚙️ INICIALIZAÇÃO
# =========================
func _ready():
	_configurar_nome_dispositivo()
	load_local_scores() 

func _configurar_nome_dispositivo():
	nome_jogador = OS.get_model_name()
	if nome_jogador == "": 
		nome_jogador = OS.get_environment("USERNAME")
	if nome_jogador == "": 
		nome_jogador = OS.get_environment("USER")
	if nome_jogador == "": 
		nome_jogador = "Jogador_River"

# =========================
# 📡 FUNÇÕES DE REDE (HOST / JOIN)
# =========================
func host_lan() -> String:
	var erro = peer.create_server(PORT, 5) 
	if erro == OK:
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_jogador_conectou)
		
		# Busca o IP real da rede (Ex: 192.168.0.10)
		var meu_ip = "127.0.0.1"
		for ip in IP.get_local_addresses():
			if ip.begins_with("192.168.") or ip.begins_with("10."):
				meu_ip = ip
				break
				
		print("✅ Servidor Hospedado! O IP é: ", meu_ip)
		
		# SÓ O HOST CARREGA A LISTA DO RANKING ANTIGO DELE!
		_carregar_leaderboard_do_host() 
		
		# O Host submete os seus recordes atuais para a lista
		submeter_score_lan()
		
		return meu_ip
	else:
		print("❌ Erro ao criar servidor: ", erro)
		return "Erro de Porta"

func join_lan(ip_do_host: String):
	var erro = peer.create_client(ip_do_host, PORT)
	if erro == OK:
		multiplayer.multiplayer_peer = peer
		multiplayer.connected_to_server.connect(_conectado_com_sucesso)
		multiplayer.connection_failed.connect(_falha_na_conexao)
		print("🔄 A tentar conectar ao Host: ", ip_do_host)

func _jogador_conectou(id: int): 
	print("🎮 Jogador conectou! ID: ", id)
	# O Host manda a lista de pontuações atual para quem acabou de entrar
	rpc_id(id, "_receber_leaderboard", lan_leaderboard)

func _conectado_com_sucesso(): 
	print("✅ Entraste na sala do Host!")
	# Assim que o Cliente entra, envia os seus Highscores automaticamente!
	submeter_score_lan()

func _falha_na_conexao(): 
	print("❌ Não foi possível encontrar o Host. Verifique o IP.")

# =========================
# 🏆 SISTEMA DE LEADERBOARD (LAN - RPC)
# =========================
func submeter_score_lan():
	# Envia os recordes de todos os mapas para a LAN
	for mapa in Highscores.keys():
		var pontos = Highscores[mapa]
		if pontos > 0:
			if multiplayer.is_server():
				_processar_nova_pontuacao(nome_jogador, mapa, pontos)
			else:
				rpc_id(1, "_processar_nova_pontuacao", nome_jogador, mapa, pontos)

# Esta função roda APENAS no computador/telemóvel do HOST
@rpc("any_peer", "call_local", "reliable")
func _processar_nova_pontuacao(p_nome: String, p_mapa: String, p_score: int):
	if not multiplayer.is_server(): return 
	
	# Verifica se o mapa existe na tabela
	if not lan_leaderboard.has(p_mapa): return
	
	var mapa_lista = lan_leaderboard[p_mapa]
	var jogador_encontrado = false
	
	for entrada in mapa_lista:
		if entrada.nome == p_nome:
			jogador_encontrado = true
			if p_score > entrada.score:
				entrada.score = p_score # Atualiza apenas se for um recorde maior
			break
			
	if not jogador_encontrado:
		mapa_lista.append({"nome": p_nome, "score": p_score})
	
	# Organiza a lista do mapa em questão (maior para o menor)
	mapa_lista.sort_custom(func(a, b): return a.score > b.score)
	
	# Mantém apenas o Top 10
	if mapa_lista.size() > 10:
		mapa_lista.resize(10)
		
	_salvar_leaderboard_no_host()
	
	# O Host avisa TODOS os jogadores que a lista inteira foi atualizada
	rpc("_receber_leaderboard", lan_leaderboard)

# Esta função roda em todos os Clientes quando o Host atualiza a lista
@rpc("authority", "reliable", "call_local")
func _receber_leaderboard(nova_lista: Dictionary):
	lan_leaderboard = nova_lista
	leaderboard_atualizado.emit() # Avisa o ecrã do menu para se desenhar de novo

# =========================
# 📂 CARREGAMENTO E GRAVAÇÃO (SEGURA)
# =========================
func _salvar_leaderboard_no_host():
	var file = FileAccess.open(LEADERBOARD_PATH, FileAccess.WRITE)
	if file: 
		file.store_line(JSON.stringify(lan_leaderboard))

func _carregar_leaderboard_do_host():
	if FileAccess.file_exists(LEADERBOARD_PATH):
		var file = FileAccess.open(LEADERBOARD_PATH, FileAccess.READ)
		var json_string = file.get_line()
		var json = JSON.new()
		if json.parse(json_string) == OK:
			var data = json.get_data()
			# Garante que é um Dicionário
			if typeof(data) == TYPE_DICTIONARY:
				for key in data.keys():
					if lan_leaderboard.has(key):
						lan_leaderboard[key] = data[key]
				leaderboard_atualizado.emit()
				print("📂 Tabela do Leaderboard carregada pelo Host!")

func save_local_scores():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file: 
		file.store_line(JSON.stringify(Highscores))

func load_local_scores():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var json_string = file.get_line()
		var json = JSON.new()
		if json.parse(json_string) == OK:
			var data = json.get_data()
			if typeof(data) == TYPE_DICTIONARY:
				for key in data.keys():
					if Highscores.has(key):
						Highscores[key] = int(data[key])
				print("📂 Highscores carregados com sucesso!")

# =========================
# 💔 FUNÇÕES DE JOGO (Dano, Dinheiro, Reset)
# =========================
func add_score(amount: int):
	Score += amount
	score_changed.emit()
	if Score > Highscores[current_map]:
		Highscores[current_map] = Score
		save_local_scores() 
		submeter_score_lan() # Atualiza a LAN na mesma hora se você bater recorde jogando!

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