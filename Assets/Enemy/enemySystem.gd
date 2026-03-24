extends CharacterBody2D

signal died
signal escaped

@export var hp: int = 10

func _ready():
	add_to_group("enemy")

func take_damage(amount: int):
	hp -= amount
	
	if hp <= 0:
		die()

func die():
	died.emit()
	queue_free()
