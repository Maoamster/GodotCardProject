extends Control
class_name Enemy

var enemy_name: String = "Fire Dummy"
var max_health: int = 20
var current_health: int = 20
var statuses = {}

func _ready():
	update_display()

func take_damage(amount: int):
	print(enemy_name, "takes", amount, "damage.")
	current_health -= amount
	current_health = max(current_health, 0)
	update_display()

func apply_status(status: String, turns: int):
	print(enemy_name, "is afflicted with", status, "for", turns, "turn(s).")
	statuses[status] = turns

func heal(amount: int):
	current_health = min(current_health + amount, max_health)
	print(enemy_name, "heals", amount, "HP.")
	update_display()

func update_display():
	$EnemyNameLabel.text = enemy_name
	$HealthLabel.text = "HP: %d / %d" % [current_health, max_health]
