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
	died.emit()
	queue_free()
	
func escape():
	if removed:
		return
	
	removed = true
	escaped.emit()
	queue_free()
