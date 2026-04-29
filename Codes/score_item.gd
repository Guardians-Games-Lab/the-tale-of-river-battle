extends HBoxContainer

# =========================
# 📂 REFERÊNCIAS DE UI (MODO SEGURO)
# =========================
@onready var label_posicao = get_node_or_null("Posicao")
@onready var label_nome = get_node_or_null("NomeJogador")
@onready var label_pontuacao = get_node_or_null("Pontuacao")

# =========================
# 🛠️ PREENCHIMENTO DOS DADOS
# =========================
func configurar_linha(pos: int, nome: String, pontos: int):
	# O if garante que o jogo não feche se você mudar o nome do Label sem querer
	if label_posicao:
		label_posicao.text = str(pos) + "º"
		
	if label_nome:
		label_nome.text = str(nome)
		
	if label_pontuacao:
		label_pontuacao.text = str(pontos) + " pts"