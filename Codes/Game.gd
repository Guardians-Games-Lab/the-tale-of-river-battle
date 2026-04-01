extends Node

#Sistema de Gold
var Gold: int = 20 # dinheiro inicial

signal gold_changed


func add_gold(amount: int):
	Gold += amount
	gold_changed.emit()


func spend_gold(amount: int) -> bool:
	if Gold >= amount:
		Gold -= amount
		gold_changed.emit()
		return true
	
	return false
	
#Sistema de Pontos
var Score: int = 0

signal score_changed


func add_score(amount: int):
	Score += amount
	score_changed.emit()
