extends Control
class_name Card

signal card_played(card)

var card_name: String = "Default"
var cost: int = 1
var rarity: String = "COMMON"
var description: String = "No Description"
var image_path: String = ""
var effect_func = null  # No type to prevent null errors

func _ready():
	update_display()
	print("Card Ready:", card_name)
	connect("gui_input", Callable(self, "_on_gui_input"))

func update_display():
	if $VBoxContainer/CardNameLabel:
		$VBoxContainer/CardNameLabel.text = card_name
	if $VBoxContainer/CostLabel:
		$VBoxContainer/CostLabel.text = "Cost: " + str(cost)
	if $VBoxContainer/RarityLabel:
		$VBoxContainer/RarityLabel.text = "Rarity: " + rarity
	if $VBoxContainer/DescriptionLabel:
		$VBoxContainer/DescriptionLabel.text = description
	if $VBoxContainer/CardImage and image_path != "":
		var tex = load(image_path)
		$VBoxContainer/CardImage.texture = tex

func _on_gui_input(event):
	print("[Card] GUI Input Received:", event)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Card clicked:", card_name)
		emit_signal("card_played", self)
