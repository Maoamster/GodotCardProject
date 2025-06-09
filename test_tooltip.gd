extends Control

# Test script to verify tooltip sizing logic works correctly

func _ready():
	print("Testing tooltip sizing logic...")
	
	# Test different text lengths
	var test_texts = [
		"Short",
		"Medium length card name",
		"This is a very long card name that should cause text wrapping in the tooltip",
		"Epic Ultra Legendary Super Duper Long Card Name That Definitely Needs Multiple Lines"
	]
	
	var test_descriptions = [
		"Simple effect.",
		"Deal 3 damage to target enemy. If the enemy dies, draw a card.",
		"This card has an extremely long description that explains in great detail exactly what it does when played, including all the various conditions and edge cases that might apply during gameplay.",
		"An incredibly verbose description that goes on and on about the card's effects, its lore, its history, and every possible interaction it might have with other cards in the game, making it necessary for the tooltip to expand to accommodate all this text without cutting anything off or going outside the borders."
	]
	
	for i in range(test_texts.size()):
		test_tooltip_sizing(test_texts[i], test_descriptions[i])
	
	print("Tooltip sizing tests completed!")

func test_tooltip_sizing(card_name: String, description: String):
	print("\n--- Testing tooltip for: '%s' ---" % card_name)
	
	# Simulate the sizing calculation from the show_tooltip function
	var min_width = 200
	var max_width = 400
	var required_width = min_width
	
	# Test with default font
	var font = ThemeDB.fallback_font
	var font_size_18 = 18  # Card name
	var font_size_12 = 12  # Description and info
	
	# Calculate text widths
	var name_width = font.get_string_size(card_name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size_18).x
	var desc_width = font.get_string_size(description, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size_12).x
	var info_width = font.get_string_size("Cost: 5 | Type: Creature | Legendary", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size_12).x
	
	print("Name width: %d" % name_width)
	print("Description width: %d" % desc_width)
	print("Info width: %d" % info_width)
	
	required_width = max(required_width, name_width + 20)
	required_width = max(required_width, desc_width + 20)
	required_width = max(required_width, info_width + 20)
	
	# Clamp to bounds
	required_width = min(max_width, required_width)
	
	print("Final tooltip width: %d" % required_width)
	
	# Calculate estimated height with wrapping
	var content_width = required_width - 16  # Account for margins
	var total_height = 16  # Margins
	
	# Name height
	var name_lines = max(1, ceil(name_width / float(content_width)))
	total_height += name_lines * font.get_height(font_size_18) + 4
	
	# Info height  
	var info_lines = max(1, ceil(info_width / float(content_width)))
	total_height += info_lines * font.get_height(font_size_12) + 4
	
	# Description height
	var desc_lines = max(1, ceil(desc_width / float(content_width)))
	total_height += desc_lines * font.get_height(font_size_12) + 4
	
	print("Estimated tooltip height: %d" % total_height)
	print("Final tooltip size: %dx%d" % [required_width, total_height])
