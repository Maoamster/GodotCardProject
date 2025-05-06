extends Control

func _ready():
	show_starting_cards()

func show_starting_cards():
	var card_data = {
		"name": "Flame Imp",
		"cost": 1,
		"rarity": "Uncommon",
		"description": "Deals 5 damage and applies Burn.",
		"image": "res://Resources/Images/cards/flame_imp.png",
		"effect_func": Callable(self, "flame_imp_effect")
	}

	var CardScene = preload("res://Scenes/Card.tscn")
	var card_instance = CardScene.instantiate()

	card_instance.card_name = card_data["name"]
	card_instance.cost = card_data["cost"]
	card_instance.rarity = card_data["rarity"]
	card_instance.description = card_data["description"]
	card_instance.image_path = card_data["image"]
	card_instance.effect_func = card_data["effect_func"]
	card_instance.update_display()

	card_instance.connect("card_played", Callable(self, "_on_card_played"))

	$CardContainer.add_child(card_instance)

func _on_card_played(card):
	var enemy = $EnemyNode  # Make sure this matches the name of the node!
	print("Card played:", card.card_name)
	card.play_card(enemy)

# 🔥 Card Effects
func flame_imp_effect(target):
	target.take_damage(5)
	target.apply_status("Burn", 3)
