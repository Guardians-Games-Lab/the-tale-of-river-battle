extends CharacterBody2D

signal died
signal escaped

@export var hp: int = 10
var removed := false

func _ready():
	add_to_group("enemy")

func take_damage(amount: int):
	hp -= amount
	
	if hp <= 0:
		die()

func die():
	if removed:
		return
	
	
	
	removed = true
	
	Game.add_gold(5)
	Game.add_score(10)
	print(Game.Score)
	
	died.emit()
	queue_free()
	
func escape():
	if removed:
		return
	
	removed = true
	
	Game.add_score(-20)
	Game.take_damage(hp)
	escaped.emit()
	queue_free()
