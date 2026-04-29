extends Control

# =========================
# 📂 REFERÊNCIAS DE UI
# =========================
@onready var container = $M/VBoxContainer/ScrollContainer
@onready var btn_mapa1 = $M/VBoxContainer/HBoxContainer/Mapa
@onready var btn_mapa2 = $M/VBoxContainer/HBoxContainer/Mapa2
@onready var btn_mapa3 = $M/VBoxContainer/HBoxContainer/Mapa3
@onready var btn_voltar = $M/VBoxContainer/HBoxContainer/Voltar

# =========================
# ⚙️ CONFIGURAÇÕES
# =========================
# ⚠️ Certifique-se que o caminho da cena do item está correto!
var score_item_scene = preload("res://Scenes/Menu/score_item.tscn") 
var mapa_atual = "mapa_1"

# =========================
# 🚀 INICIALIZAÇÃO
# =========================
func _ready():
	# 🔌 Conecta ao sinal do Game.gd para atualizar a lista sempre que a rede mudar
	if Game.has_signal("leaderboard_atualizado"):
		Game.leaderboard_atualizado.connect(atualizar_lista)
	
	# 🔘 Conectando os botões de seleção de mapa
	if btn_mapa1: btn_mapa1.pressed.connect(func(): mudar_mapa("mapa_1"))
	if btn_mapa2: btn_mapa2.pressed.connect(func(): mudar_mapa("mapa_2"))
	if btn_mapa3: btn_mapa3.pressed.connect(func(): mudar_mapa("mapa_3"))
	
	# 🔙 Botão de Voltar ao Menu Principal
	if btn_voltar:
		btn_voltar.pressed.connect(func(): get_tree().change_scene_to_file("res://main_menu.tscn"))
	
	# Carrega a lista inicial
	atualizar_lista()

# =========================
# 🛠️ LÓGICA DO RANKING
# =========================
func mudar_mapa(nome: String):
	mapa_atual = nome
	print("📍 Mudando para o Ranking do: ", nome)
	atualizar_lista()

func atualizar_lista():
	# 🧹 Limpa os itens antigos da tela para não duplicar
	for n in container.get_children(): 
		n.queue_free()
	
	# 📊 Pega a lista sincronizada via LAN do Game.gd
	var dados = Game.lan_leaderboard[mapa_atual].duplicate()
	
	# 🛡️ PLANO B: Se a LAN estiver vazia, mostramos apenas o seu recorde pessoal
	if dados.is_empty():
		var meu_recorde_local = Game.Highscores[mapa_atual]
		dados.append({
			"nome": Game.nome_jogador + " (Pessoal)", 
			"score": meu_recorde_local
		})
	
	# 🏆 Ordenação: Quem tem mais pontos fica no topo
	dados.sort_custom(func(a, b): return a.score > b.score)
	
	# 🎨 Cria as linhas visualmente
	for i in range(dados.size()):
		var entrada = dados[i]
		var item = score_item_scene.instantiate()
		container.add_child(item)
		
		# 🔌 Envia a Posição (Rank), Nome e Pontos para o script do item
		if item.has_method("configurar"):
			item.configurar(i + 1, entrada.nome, entrada.score)
		elif item.has_method("configurar_linha"): # Caso você use este nome de função
			item.configurar_linha(i + 1, entrada.nome, entrada.score)
