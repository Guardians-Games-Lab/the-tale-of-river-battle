extends HBoxContainer

@onready var label_posicao = $Posicao
@onready var label_nome = $NomeJogador
@onready var label_pontuacao = $Pontuacao

func configurar_linha(pos: int, nome: String, pontos: int):
	label_posicao.text = str(pos) + "º"
	label_nome.text = nome
	label_pontuacao.text = str(pontos)