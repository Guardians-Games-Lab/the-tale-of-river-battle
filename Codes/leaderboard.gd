extends Control

# =========================
# 📂 REFERÊNCIAS DE UI
# =========================
@onready var scroll = $M/VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer
var container: VBoxContainer # Resolvido dinamicamente no _ready!

@onready var btn_mapa1 = $M/VBoxContainer/HBoxContainer/Mapa
@onready var btn_mapa2 = $M/VBoxContainer/HBoxContainer/Mapa2
@onready var btn_mapa3 = $M/VBoxContainer/HBoxContainer/Mapa3
@onready var btn_voltar = $M/VBoxContainer/HBoxContainer/Voltar

var score_item_scene = preload("res://Scenes/Menu/score_item.tscn") 
var mapa_atual = "mapa_1"

# =========================
# 🚀 INICIALIZAÇÃO
# =========================
func _ready():
	# 🛡️ BUSCA DINÂMICA: Procura o VBoxContainer dentro do Scroll automaticamente
	for child in scroll.get_children():
		if child is VBoxContainer:
			container = child
			break
			
	# Se não existir na árvore, injeta um via código (Anti-Crash)
	if container == null:
		print("⚠️ VBoxContainer não encontrado. Criando um virtualmente!")
		container = VBoxContainer.new()
		container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		container.size_flags_vertical = Control.SIZE_EXPAND_FILL
		scroll.add_child(container)

	if Game.has_signal("leaderboard_atualizado"):
		Game.leaderboard_atualizado.connect(atualizar_lista)
	
	if btn_mapa1: btn_mapa1.pressed.connect(func(): mudar_mapa("mapa_1"))
	if btn_mapa2: btn_mapa2.pressed.connect(func(): mudar_mapa("mapa_2"))
	if btn_mapa3: btn_mapa3.pressed.connect(func(): mudar_mapa("mapa_3"))
	
	if btn_voltar:
		btn_voltar.pressed.connect(_ao_clicar_em_voltar)
	
	mudar_mapa("mapa_1")

# =========================
# 🛠️ LÓGICA DO RANKING
# =========================
func mudar_mapa(nome: String):
	mapa_atual = nome
	
	# Feedback visual: o botão do mapa atual fica "afundado" (desabilitado)
	if btn_mapa1: btn_mapa1.disabled = (nome == "mapa_1")
	if btn_mapa2: btn_mapa2.disabled = (nome == "mapa_2")
	if btn_mapa3: btn_mapa3.disabled = (nome == "mapa_3")
	
	atualizar_lista()

func atualizar_lista():
	if not container: return

	# 🧹 Limpa os itens antigos
	for n in container.get_children(): 
		n.queue_free()
	
	# 📊 Pega a lista do Game.gd
	var dados = Game.lan_leaderboard[mapa_atual].duplicate()
	
	# 🛡️ PLANO OFFLINE
	if dados.is_empty():
		var meu_recorde_local = Game.Highscores[mapa_atual]
		
		# 👇 O TRUQUE VISUAL: O nome do mapa aparece na string.
		# Assim, mesmo que a pontuação seja 0, você vê a interface mudando de nome!
		var nome_formatado = mapa_atual.replace("_", " ").capitalize()
		
		dados.append({
			"nome": Game.nome_jogador + " (" + nome_formatado + ")", 
			"score": meu_recorde_local
		})
	
	# 🏆 Ordenação
	dados.sort_custom(func(a, b): return a.score > b.score)
	
	# 🎨 Cria as linhas
	for i in range(dados.size()):
		var entrada = dados[i]
		var item = score_item_scene.instantiate()
		container.add_child(item)
		
		if item.has_method("configurar"):
			item.configurar(i + 1, entrada.nome, entrada.score)
		elif item.has_method("configurar_linha"):
			item.configurar_linha(i + 1, entrada.nome, entrada.score)
			


func _ao_clicar_em_voltar():
	self.hide() # Esconde a tela do Leaderboard
	$"../MainMenu".show() # Mostra o Menu Principal
