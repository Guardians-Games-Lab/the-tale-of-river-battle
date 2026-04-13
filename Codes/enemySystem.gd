extends CharacterBody2D

# =========================
# 📡 SINAIS
# =========================
signal died
signal escaped

# =========================
# ❤️ ATRIBUTOS DO INIMIGO
# =========================
@export var hp: int = 10
var max_hp: int # Guarda a vida total inicial
var removed := false # Trava de segurança para não processar morte/fuga duas vezes

# =========================
# 🖥️ REFERÊNCIAS DA UI
# =========================
@onready var barra_vida: ProgressBar = $BarraDeVida
@onready var texto_vida: Label = $BarraDeVida/TextoVida

@export var deathPoints: int;

# =========================
# ⚙️ INICIALIZAÇÃO
# =========================
func _ready():
	add_to_group("enemy")
	
	# 1. Configura a matemática da barra de vida
	max_hp = hp 
	barra_vida.max_value = max_hp
	barra_vida.value = hp
	
	# 2. Esconde a barra para a tela nascer limpa
	barra_vida.hide()
	
	# 3. Força a primeira atualização do texto
	_atualizar_texto_vida()


# =========================
# 💥 RECEBER DANO
# =========================
func take_damage(amount: int):
	hp -= amount
	
	# Só revela a barra de vida depois de tomar a primeira pancada
	if not barra_vida.visible:
		barra_vida.show()
	
	# Atualiza o visual da barra e o texto numérico
	barra_vida.value = hp
	_atualizar_texto_vida()
	
	# Checa se o machado foi fatal
	if hp <= 0:
		die()


# =========================
# 📝 ATUALIZAR UI DA VIDA
# =========================
func _atualizar_texto_vida():
	if texto_vida:
		texto_vida.text = str(hp) + " / " + str(max_hp)


# =========================
# 💀 MORTE (DERROTADO PELAS TORRES)
# =========================
func die():
	if removed: return
	removed = true
	
	# Recompensas para o jogador! 💰📈
	Game.add_gold(5) 
	Game.add_score(deathPoints) 
	
	died.emit()
	get_parent().queue_free() # Destrói o "carrinho" (PathFollow2D) que carrega o inimigo


# =========================
# 🏃 FUGA (CHEGOU NA LAGOA)
# =========================
func escape():
	if removed: return
	removed = true
	
	# Punições para o jogador! 📉💔
	Game.add_score(-20) 
	Game.take_damage(hp) # A lagoa toma de dano o HP que o inimigo ainda tinha!
	
	escaped.emit()
	get_parent().queue_free()
