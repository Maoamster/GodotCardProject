extends Control

# Global variables for targeting system
var selected_card: Card = null
var targeting_line: Line2D = null
var card_targets = {}  # Dictionary to store card -> enemy assignments
var is_executing_turn: bool = false  # Track if turn is currently executing

# Mana system variables
var current_mana: int = 10
var max_mana: int = 10
var mana_per_turn: int = 1

func _ready():
	show_starting_cards()
	setup_enemies()
	
	# Connect the End Turn button
	var end_turn_button = $MainLayout/BattlefieldZone/EndTurnButton
	end_turn_button.pressed.connect(end_turn)
	
	# Initialize UI state
	update_battlefield_counter()
	update_mana_display()

func update_mana_display():
	"""Update the mana display in the UI"""
	var mana_label = $MainLayout/HandZone/ManaLabel
	if mana_label:
		mana_label.text = "Mana: %d/%d" % [current_mana, max_mana]
		print("🔵 Mana display updated: %d/%d" % [current_mana, max_mana])
		
	# Update card affordability visuals
	update_card_affordability_visuals()

func update_card_affordability_visuals():
	"""Update visual state of cards based on mana availability"""
	var hand_container = $MainLayout/HandZone/CardContainer
	var hand_cards = hand_container.get_children()
	
	for card in hand_cards:
		if card.has_method("update_affordability_visual"):
			card.update_affordability_visual(current_mana)
		else:
			# Fallback: Apply visual changes directly
			if current_mana >= card.cost:
				# Can afford - normal appearance
				if not is_executing_turn:  # Don't override execution state
					card.modulate = Color(1.0, 1.0, 1.0, 1.0)
					card.mouse_filter = Control.MOUSE_FILTER_PASS
			else:
				# Can't afford - grayed out appearance
				card.modulate = Color(0.6, 0.6, 0.6, 0.8)
				# Don't disable mouse filter completely - still allow hover for tooltips
				# The mana check in _on_card_played will prevent actual usage
		
	# Update card affordability visuals
	update_card_affordability_visuals()

func setup_enemies():
	# Setup multiple enemies with different names and stats
	var enemies = $MainLayout/EnemyZone/EnemyContainer.get_children()
	
	var enemy_data = [
		{"name": "Fire Goblin", "max_hp": 15, "current_hp": 15},
		{"name": "Ice Warrior", "max_hp": 20, "current_hp": 20},
		{"name": "Shadow Beast", "max_hp": 12, "current_hp": 12}
	]
	
	for i in range(min(enemies.size(), enemy_data.size())):
		var enemy = enemies[i]
		var data = enemy_data[i]
		enemy.enemy_name = data.name
		enemy.max_health = data.max_hp
		enemy.current_health = data.current_hp
		enemy.update_display()
		
		# Make enemies clickable for targeting
		if not enemy.gui_input.is_connected(_on_enemy_clicked):
			if enemy.gui_input.connect(func(event): _on_enemy_clicked(enemy, event)) == OK:
				print("✅ Enemy gui_input connected for:", enemy.enemy_name)
			else:
				print("❌ Failed to connect enemy gui_input for:", enemy.enemy_name)
		else:
			print("⚠️ Enemy gui_input already connected for:", enemy.enemy_name)

func show_starting_cards():
	# Create multiple sample cards to show off the hand system with different rarities and types
	var cards_data = [
		{
			"name": "Flame Imp",
			"cost": 3,
			"rarity": "Uncommon",
			"card_type": "CREATURE",
			"attack_type": "MELEE",
			"description": "A fiery creature that burns enemies when it attacks.",
			"image": "res://Resources/Images/cards/flame_imp.png",
			"effect_func": Callable(self, "flame_imp_effect"),
			"health": 4,
			"attack": 3
		},
		{
			"name": "Ice Shard",
			"cost": 2,
			"rarity": "Common",
			"card_type": "SPELL",
			"attack_type": "SPELL",
			"description": "Deals 3 damage and freezes target for 1 turn.",
			"image": "res://Resources/Images/cards/flame_imp.png",  # Placeholder image
			"effect_func": Callable(self, "ice_shard_effect")
		},
		{
			"name": "Lightning Bolt",
			"cost": 3,
			"rarity": "Rare",
			"card_type": "SPELL",
			"attack_type": "SPELL",
			"description": "Deals 8 damage instantly. Cannot be blocked.",
			"image": "res://Resources/Images/cards/flame_imp.png",  # Placeholder image
			"effect_func": Callable(self, "lightning_bolt_effect")
		},
		{
			"name": "Healing Potion",
			"cost": 1,
			"rarity": "Common",
			"card_type": "ITEM",
			"attack_type": "SUPPORT",
			"description": "Restore 6 health points to target ally.",
			"image": "res://Resources/Images/cards/flame_imp.png",  # Placeholder image
			"effect_func": Callable(self, "healing_potion_effect")
		},
		{
			"name": "Dragon's Fury",
			"cost": 5,
			"rarity": "Epic",
			"card_type": "SPELL",
			"attack_type": "SPELL",
			"description": "Deals 12 damage and applies Burn for 5 turns.",
			"image": "res://Resources/Images/cards/flame_imp.png",  # Placeholder image
			"effect_func": Callable(self, "dragons_fury_effect")
		},
		{
			"name": "Phoenix Rebirth",
			"cost": 7,
			"rarity": "Legendary",
			"card_type": "SPELL",
			"attack_type": "SPELL",
			"description": "Ultimate power! Deals 15 damage and fully heals the caster.",
			"image": "res://Resources/Images/cards/flame_imp.png",  # Placeholder image
			"effect_func": Callable(self, "phoenix_rebirth_effect")
		},
		{
			"name": "Poison Dart",
			"cost": 2,
			"rarity": "Uncommon",
			"card_type": "ITEM",
			"attack_type": "RANGED",
			"description": "Deals 2 damage and applies Poison for 4 turns.",
			"image": "res://Resources/Images/cards/flame_imp.png",  # Placeholder image
			"effect_func": Callable(self, "poison_dart_effect")
		},
		{
			"name": "Iron Golem",
			"cost": 4,
			"rarity": "Rare",
			"card_type": "CREATURE",
			"attack_type": "MELEE",
			"description": "A sturdy construct that defends other creatures.",
			"image": "res://Resources/Images/cards/flame_imp.png",  # Placeholder image
			"effect_func": Callable(self, "iron_golem_effect"),
			"health": 8,
			"attack": 2
		},
		{
			"name": "Archer",
			"cost": 3,
			"rarity": "Common",
			"card_type": "CREATURE",
			"attack_type": "RANGED",
			"description": "A skilled archer that shoots arrows at enemies.",
			"image": "res://Resources/Images/cards/flame_imp.png",  # Placeholder image
			"effect_func": Callable(self, "archer_effect"),
			"health": 3,
			"attack": 4
		}
	]
	
	for card_data in cards_data:
		add_card_to_hand(card_data)

func _on_card_played(card):
	print("🎴 Card clicked in hand:", card.card_name)
	print("🔍 DEBUG: Card type:", card.card_type, "Cost:", card.cost, "Current mana:", current_mana)
	
	# Don't allow hand interaction during turn execution
	if is_executing_turn:
		print("⛔ Hand interaction disabled during turn execution")
		return
	
	# Check mana cost
	if current_mana < card.cost:
		print("⛔ Not enough mana! Need %d, have %d" % [card.cost, current_mana])
		# Add visual feedback for insufficient mana
		var mana_label = $MainLayout/HandZone/ManaLabel
		if mana_label:
			var flash_tween = create_tween()
			flash_tween.tween_property(mana_label, "modulate", Color(1.5, 0.5, 0.5, 1.0), 0.2)
			flash_tween.tween_property(mana_label, "modulate", Color(0.3, 0.6, 1.0, 1.0), 0.2)
		return
	
	# Check if this is an instant cast card (healing items only)
	if card.is_instant_cast():
		print("⚡ Instant cast card detected:", card.card_name)
		# Deduct mana before execution
		current_mana -= card.cost
		update_mana_display()
		execute_instant_card(card)
		return
	
	# Handle spells - they need target selection but execute immediately after
	if card.card_type == "SPELL":
		print("🪄 Spell card detected - requires target selection:", card.card_name)
		select_card_for_spell_targeting(card)
		return
	
	# For creatures and items, use the existing targeting system
	# Check if a card is currently selected for targeting
	if selected_card:
		# If the same card is clicked again, move it to battlefield
		if selected_card == card:
			print("📥 Moving selected card to battlefield:", card.card_name)
			# Deduct mana before moving to battlefield
			current_mana -= card.cost
			update_mana_display()
			clear_card_selection()
			move_card_to_battlefield(card)
		else:
			# Switch selection to the new card
			print("🎯 Switching card selection to:", card.card_name)
			clear_card_selection()
			select_card_for_targeting(card)
	else:
		# No card selected - select this card for targeting
		print("🎯 Selecting card for targeting:", card.card_name)
		select_card_for_targeting(card)

func select_card_for_targeting(card):
	"""Select a card for target assignment"""
	print("🎯 select_card_for_targeting called for:", card.card_name, "Type:", card.card_type)
	
	# Don't allow targeting during turn execution
	if is_executing_turn:
		print("⛔ Targeting disabled during turn execution")
		return
	
	# Clear any existing targeting line before creating a new one
	if targeting_line:
		targeting_line.queue_free()
		targeting_line = null
		print("🧹 Cleared existing targeting line before creating new one")
		
	selected_card = card
	print("✅ Card set as selected_card:", selected_card.card_name)
	
	# Check if the card has the required method
	if card.has_method("show_selected_for_targeting"):
		card.show_selected_for_targeting()
		print("✅ show_selected_for_targeting called")
	else:
		print("❌ Card missing show_selected_for_targeting method")
	
	create_targeting_line()
	print("💡 Click an enemy to assign target, or click this card again to place it on battlefield")

func select_card_for_spell_targeting(card):
	"""Select a spell card for immediate execution after target selection"""
	# Don't allow targeting during turn execution
	if is_executing_turn:
		print("⛔ Spell targeting disabled during turn execution")
		return
	
	# Clear any existing targeting line before creating a new one
	if targeting_line:
		targeting_line.queue_free()
		targeting_line = null
		print("🧹 Cleared existing targeting line before creating new one")
		
	selected_card = card
	card.show_selected_for_targeting()
	create_targeting_line()
	print("🪄 Click an enemy to cast spell immediately, or right-click to cancel")

func move_card_to_battlefield(card):
	# If this card is currently selected, clear selection
	if selected_card == card:
		clear_card_selection()
	
	# Remove from hand
	card.get_parent().remove_child(card)
	# Add to battlefield
	$MainLayout/BattlefieldZone/PlayedCardsContainer.add_child(card)
	
	# Mark as played but keep it interactive for target changes
	card.mark_as_played()
	
	# Re-enable mouse input for battlefield interactions
	card.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Disconnect old signal and connect new battlefield signal
	if card.card_played.is_connected(_on_card_played):
		card.card_played.disconnect(_on_card_played)
	card.card_played.connect(_on_battlefield_card_clicked)
	
	# Update battlefield counter
	update_battlefield_counter()
	
	print("📥 Card moved to battlefield:", card.card_name, "- Click to change target or right-click to remove")

func end_turn():
	print("🔄 ENDING TURN - Executing battlefield cards from left to right...")
	var battlefield_container = $MainLayout/BattlefieldZone/PlayedCardsContainer
	var battlefield_cards = battlefield_container.get_children()
	
	if battlefield_cards.size() == 0:
		print("⚠️ No cards in battlefield to execute")
		return
	
	# Set executing state and disable hand interactions
	is_executing_turn = true
	
	# Force clear all targeting elements (comprehensive cleanup)
	force_clear_all_targeting()
	
	disable_hand_cards_during_execution()
	
	# Disable the End Turn button during execution
	var end_turn_button = $MainLayout/BattlefieldZone/EndTurnButton
	end_turn_button.disabled = true
	end_turn_button.text = "Executing..."
	end_turn_button.modulate = Color(0.6, 0.6, 0.6, 1.0)
	
	# Execute cards from left to right with delays - start with 0.5s base delay
	for i in range(battlefield_cards.size()):
		var card = battlefield_cards[i]
		execute_card_with_delay(card, 0.5 + (i * 1.5))  # 0.5s start + 1.5s between cards
	
	# Schedule turn completion to re-enable button
	schedule_turn_completion(battlefield_cards.size())

func _on_enemy_clicked(enemy: Enemy, event):
	print("🖱️ _on_enemy_clicked called for:", enemy.enemy_name, "Event:", event)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("🎯 Enemy LEFT CLICK processed:", enemy.enemy_name)
		if selected_card:
			print("🎯 Assigning target:", enemy.enemy_name, "to card:", selected_card.card_name)
			
			# Check if this is a spell - execute immediately
			if selected_card.card_type == "SPELL":
				print("🪄 Executing spell immediately:", selected_card.card_name)
				
				# Capture the card reference before clearing selection
				var spell_card = selected_card
				
				# Deduct mana for spell execution
				current_mana -= spell_card.cost
				update_mana_display()
				
				# Show targeting feedback briefly
				enemy.show_target_selected_effect()
				
				# Create spell-specific animation based on spell name
				create_spell_effect_animation(spell_card, enemy)
				
				# Apply spell effect after animation
				var effect_timer = Timer.new()
				add_child(effect_timer)
				effect_timer.wait_time = 1.2  # Slightly longer for spell effects
				effect_timer.one_shot = true
				effect_timer.start()
				effect_timer.timeout.connect(func():
					spell_card.play_card(enemy)
					effect_timer.queue_free()
				)
				
				# Remove card from hand after use
				var burn_timer = Timer.new()
				add_child(burn_timer)
				burn_timer.wait_time = 1.8
				burn_timer.one_shot = true
				burn_timer.start()
				burn_timer.timeout.connect(func():
					spell_card.start_burning_animation()
					burn_timer.queue_free()
				)
				
				# Clear selection
				clear_card_selection()
				return
			
			# For non-spells, assign target to selected card
			card_targets[selected_card] = enemy
			
			# Show assignment feedback
			enemy.show_target_assigned_effect()
			selected_card.show_target_assigned_feedback(enemy.enemy_name)
			
			# AUTOMATICALLY move card to battlefield after target assignment
			var card_to_move = selected_card
			clear_card_selection()
			move_card_to_battlefield(card_to_move)
			
			print("📥 Card automatically moved to battlefield after target assignment")
		else:
			print("🎯 Enemy clicked but no card selected:", enemy.enemy_name)

# Enemy target assignment is handled by _on_enemy_clicked above

func clear_card_selection():
	if selected_card:
		selected_card.hide_selected_for_targeting()
		selected_card = null
	
	# Clear current targeting line
	if targeting_line:
		targeting_line.queue_free()
		targeting_line = null
	
	# Also clear any orphaned targeting lines that might exist
	var children = get_children()
	for child in children:
		if child is Line2D and child != targeting_line:
			print("🧹 Removing orphaned targeting line")
			child.queue_free()

func force_clear_all_targeting():
	"""Force clear all targeting elements - use when turn execution starts"""
	print("🧹 Force clearing all targeting elements")
	
	# Clear card selection
	if selected_card:
		selected_card.hide_selected_for_targeting()
		selected_card = null
		print("✅ Card selection cleared")
	
	# Clear targeting line
	if targeting_line:
		targeting_line.queue_free()
		targeting_line = null
		print("✅ Targeting line cleared")
	
	# Find and remove any orphaned targeting lines
	var children = get_children()
	for child in children:
		if child is Line2D:
			print("🧹 Removing orphaned Line2D:", child)
			child.queue_free()

func create_targeting_line():
	# Don't create targeting lines during turn execution
	if is_executing_turn:
		print("⛔ Targeting line creation blocked - turn is executing")
		return
	
	# Clear any existing targeting line before creating a new one
	if targeting_line:
		targeting_line.queue_free()
		targeting_line = null
		print("🧹 Cleared previous targeting line before creating new one")
		
	# Create a line that follows the mouse when a card is selected
	targeting_line = Line2D.new()
	targeting_line.width = 3.0
	targeting_line.default_color = Color(1.0, 1.0, 0.3, 0.8)  # Yellow targeting line
	targeting_line.z_index = 1000  # Above everything
	# Line2D doesn't block mouse input by default since it's not a Control node
	add_child(targeting_line)
	print("📏 Targeting line created with z_index 1000")

func _input(event):
	# Update targeting line to follow mouse
	if targeting_line and selected_card and event is InputEventMouseMotion:
		var card_center = selected_card.global_position + selected_card.size / 2
		var mouse_pos = event.global_position
		
		targeting_line.clear_points()
		targeting_line.add_point(card_center)
		targeting_line.add_point(mouse_pos)
	
	# Debug key to check card states
	if event is InputEventKey and event.pressed and event.keycode == KEY_F1:
		debug_card_interaction()
	
	# Test card selection key
	if event is InputEventKey and event.pressed and event.keycode == KEY_F2:
		test_card_selection()
	
	# Test mouse input on cards
	if event is InputEventKey and event.pressed and event.keycode == KEY_F3:
		test_mouse_input_on_cards()
		
	# Debug specific card issues
	if event is InputEventKey and event.pressed and event.keycode == KEY_F4:
		debug_specific_card_issue()
		
	# Fix card interaction issues
	if event is InputEventKey and event.pressed and event.keycode == KEY_F5:
		fix_card_interactions()
	
	# Right click to cancel card selection or remove battlefield cards
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		# Check if right-clicking on a battlefield card
		var battlefield_container = $MainLayout/BattlefieldZone/PlayedCardsContainer
		var battlefield_cards = battlefield_container.get_children()
		
		for card in battlefield_cards:
			var card_rect = Rect2(card.global_position, card.size)
			if card_rect.has_point(event.global_position):
				print("🔙 Right-click on battlefield card:", card.card_name)
				move_card_back_to_hand(card)
				return
		
		# If not on a battlefield card, clear selection as before
		if selected_card:
			clear_card_selection()
			print("❌ Card selection cancelled")

func execute_card_with_delay(card, delay_time: float):
	var delay_timer = Timer.new()
	add_child(delay_timer)
	delay_timer.wait_time = delay_time
	delay_timer.one_shot = true
	delay_timer.start()
	delay_timer.timeout.connect(func():
		print("⚡ Executing card:", card.card_name, "Type:", card.card_type)
		
		# Handle different card types
		match card.card_type:
			"CREATURE":
				execute_creature_card(card)
			"SPELL", "ITEM":
				execute_instant_battlefield_card(card)
			_:
				# Default behavior for unknown types
				execute_instant_battlefield_card(card)
		
		delay_timer.queue_free()
	)

func get_alive_enemies():
	"""Get all enemies that are still alive"""
	var enemies = $MainLayout/EnemyZone/EnemyContainer.get_children()
	var alive_enemies = []
	for enemy in enemies:
		# Make sure this is actually an Enemy node with current_health property
		if enemy.has_method("get_script") and enemy.get_script() != null:
			var script = enemy.get_script()
			if script.get_global_name() == "Enemy" and enemy.current_health > 0:
				alive_enemies.append(enemy)
		# Alternative check: see if the node has the current_health property
		elif "current_health" in enemy and enemy.current_health > 0:
			alive_enemies.append(enemy)
	return alive_enemies

func add_card_to_hand(card_data: Dictionary):
	var CardScene = preload("res://Scenes/Card.tscn")
	var card_instance = CardScene.instantiate()
	
	card_instance.card_name = card_data["name"]
	card_instance.cost = card_data["cost"]
	card_instance.rarity = card_data["rarity"]
	card_instance.description = card_data["description"]
	card_instance.image_path = card_data["image"]
	card_instance.effect_func = card_data["effect_func"]
	
	# Handle new card type system
	if "card_type" in card_data:
		card_instance.card_type = card_data["card_type"]
	
	# Set attack type based on card type and specific cards
	if "attack_type" in card_data:
		card_instance.attack_type = card_data["attack_type"]
	else:
		# Auto-assign attack types based on card type and name
		match card_instance.card_type:
			"SPELL":
				card_instance.attack_type = "SPELL"
			"ITEM":
				if card_instance.description.to_lower().contains("heal"):
					card_instance.attack_type = "SUPPORT"
				else:
					card_instance.attack_type = "RANGED"
			"CREATURE":
				# Assign based on creature name/type
				match card_instance.card_name.to_lower():
					"iron golem", "flame imp":
						card_instance.attack_type = "MELEE"
					"archer":
						card_instance.attack_type = "RANGED"
					_:
						card_instance.attack_type = "MELEE"  # Default for creatures
	
	# Initialize creature-specific properties
	if card_instance.card_type == "CREATURE":
		if "health" in card_data and "attack" in card_data:
			card_instance.initialize_creature(card_data["health"], card_data["attack"])
	
	card_instance.update_display()
	
	card_instance.connect("card_played", Callable(self, "_on_card_played"))
	
	# Add some spacing between cards
	var hand_container = $MainLayout/HandZone/CardContainer
	hand_container.add_child(card_instance)
	
	# Add spacing between cards by setting separation
	hand_container.add_theme_constant_override("separation", 10)
	
	return card_instance

func update_battlefield_counter():
	var battlefield_container = $MainLayout/BattlefieldZone/PlayedCardsContainer
	var card_count = battlefield_container.get_child_count()
	var battlefield_label = $MainLayout/BattlefieldZone/BattlefieldLabel
	battlefield_label.text = "Battlefield (" + str(card_count) + ")"
	
	# Also update the End Turn button
	update_end_turn_button()
	
	update_end_turn_button()

func update_end_turn_button():
	var battlefield_container = $MainLayout/BattlefieldZone/PlayedCardsContainer
	var end_turn_button = $MainLayout/BattlefieldZone/EndTurnButton
	var card_count = battlefield_container.get_child_count()
	
	if card_count > 0:
		end_turn_button.disabled = false
		end_turn_button.text = "End Turn (" + str(card_count) + ")"
		end_turn_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		end_turn_button.disabled = true
		end_turn_button.text = "End Turn"
		end_turn_button.modulate = Color(0.6, 0.6, 0.6, 1.0)

func schedule_turn_completion(total_cards: int):
	# Calculate total time needed for all cards to complete
	var total_time = 0.5 + (total_cards * 1.5) + 3.5  # Base delay + execution delays + burning time
	
	var completion_timer = Timer.new()
	add_child(completion_timer)
	completion_timer.wait_time = total_time
	completion_timer.one_shot = true
	completion_timer.start()
	completion_timer.timeout.connect(func():
		print("✅ Turn execution completed!")
		is_executing_turn = false  # Reset execution state
		enable_hand_cards_after_execution()  # Re-enable hand interactions
		
		# Regenerate mana at the end of the turn
		current_mana = min(current_mana + mana_per_turn, max_mana)
		update_mana_display()
		print("🔵 Mana regenerated: %d/%d" % [current_mana, max_mana])
		
		update_battlefield_counter()  # This will re-enable the button
		completion_timer.queue_free()
	)

func create_attack_animation(card: Card, target: Enemy):
	print("✨ Creating attack animation from", card.card_name, "to", target.enemy_name, "- Attack Type:", card.attack_type)
	
	# Route to different attack animations based on attack type
	match card.attack_type:
		"MELEE":
			create_melee_attack_animation(card, target)
		"RANGED":
			create_ranged_attack_animation(card, target)
		"SPELL":
			create_spell_effect_animation(card, target)
		"SUPPORT":
			create_support_animation(card, target)
		_:
			# Default to old projectile animation
			create_ranged_attack_animation(card, target)

func create_melee_attack_animation(card: Card, target: Enemy):
	"""Move the entire card to attack the enemy in melee combat"""
	print("⚔️ Creating melee attack - card will charge at enemy!")
	
	var card_original_pos = card.global_position
	var card_original_scale = card.scale
	var target_pos = target.global_position + target.size / 2
	
	# Bring card to front for dramatic effect
	card.z_index = 600
	
	# Phase 1: Charge preparation (0.0-0.3s) - slight pullback
	var prep_tween = create_tween()
	prep_tween.set_parallel(true)
	
	var pullback_distance = 20
	var pullback_pos = card_original_pos + Vector2(-pullback_distance, 0)
	prep_tween.tween_property(card, "global_position", pullback_pos, 0.2)
	prep_tween.tween_property(card, "scale", card_original_scale * 1.1, 0.2)
	prep_tween.tween_property(card, "modulate", Color(1.2, 1.0, 1.0, 1.0), 0.2)  # Slight red tint
	
	# Phase 2: Charge attack (0.3-0.8s) - rapid movement to enemy
	var charge_tween = create_tween()
	charge_tween.set_parallel(true)
	
	var charge_target = target_pos + Vector2(-card.size.x/2, -card.size.y/2)
	charge_tween.tween_property(card, "global_position", charge_target, 0.4).set_delay(0.3)
	charge_tween.tween_property(card, "scale", card_original_scale * 1.3, 0.2).set_delay(0.3)
	charge_tween.tween_property(card, "scale", card_original_scale * 0.9, 0.2).set_delay(0.5)
	charge_tween.tween_property(card, "rotation", deg_to_rad(15), 0.2).set_delay(0.3)
	charge_tween.tween_property(card, "rotation", deg_to_rad(-10), 0.2).set_delay(0.5)
	
	# Phase 3: Impact effect (0.8s)
	charge_tween.tween_callback(func():
		create_melee_impact_effect(target)
		create_screen_shake()
	).set_delay(0.8)
	
	# Phase 4: Return to position (0.8-1.3s)
	var return_tween = create_tween()
	return_tween.set_parallel(true)
	
	return_tween.tween_property(card, "global_position", card_original_pos, 0.5).set_delay(0.8)
	return_tween.tween_property(card, "scale", card_original_scale, 0.3).set_delay(0.8)
	return_tween.tween_property(card, "rotation", 0, 0.3).set_delay(0.8)
	return_tween.tween_property(card, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3).set_delay(0.8)
	return_tween.tween_property(card, "z_index", 0, 0.1).set_delay(1.3)

func create_ranged_attack_animation(card: Card, target: Enemy):
	"""Create projectile attack animation (original attack animation)"""
	print("🏹 Creating ranged attack - projectile will fly to enemy!")
	
	# Create a projectile representation
	var projectile = ColorRect.new()
	
	# Different projectile styles based on card name
	match card.card_name.to_lower():
		"archer":
			projectile.color = Color(0.6, 0.4, 0.2, 0.9)  # Brown arrow
			projectile.size = Vector2(15, 3)
		_:
			projectile.color = Color(1.0, 0.8, 0.2, 0.8)  # Golden default
			projectile.size = Vector2(25, 25)
	
	projectile.z_index = 500
	
	# Position the projectile at the card's position
	var card_global_pos = card.global_position + card.size / 2
	var target_global_pos = target.global_position + target.size / 2
	
	projectile.global_position = card_global_pos
	get_tree().current_scene.add_child(projectile)
	
	# Create the flying animation
	var attack_tween = create_tween()
	attack_tween.set_parallel(true)
	
	# Fly toward target with a slight arc
	var midpoint = (card_global_pos + target_global_pos) / 2
	midpoint.y -= 30  # Smaller arc for arrows
	
	# First half of arc
	attack_tween.tween_property(projectile, "global_position", midpoint, 0.3)
	# Second half of arc
	attack_tween.tween_property(projectile, "global_position", target_global_pos, 0.3).set_delay(0.3)
	
	# Rotation and scaling
	if card.card_name.to_lower() == "archer":
		# Arrow rotates to point at target
		var direction = (target_global_pos - card_global_pos).normalized()
		var angle = atan2(direction.y, direction.x)
		attack_tween.tween_property(projectile, "rotation", angle, 0.1)
	else:
		# Default spinning projectile
		attack_tween.tween_property(projectile, "rotation", deg_to_rad(720), 0.6)
		attack_tween.tween_property(projectile, "scale", Vector2(1.5, 1.5), 0.3)
		attack_tween.tween_property(projectile, "scale", Vector2(0.5, 0.5), 0.3).set_delay(0.3)
	
	# Clean up after animation
	attack_tween.tween_callback(func():
		projectile.queue_free()
	).set_delay(0.6)

func create_support_animation(card: Card, _target: Enemy):
	"""Create support/healing animation without projectiles"""
	print("✨ Creating support animation - magical aura!")
	
	# Create magical aura around the card
	for i in range(12):
		var sparkle = ColorRect.new()
		sparkle.color = Color(0.8, 1.0, 0.8, 0.7)  # Green healing color
		sparkle.size = Vector2(6, 6)
		sparkle.z_index = 550
		
		# Position sparkles around the card
		var angle = i * PI / 6
		var radius = 40
		var sparkle_pos = card.global_position + card.size / 2 + Vector2(cos(angle) * radius, sin(angle) * radius)
		sparkle.global_position = sparkle_pos
		get_tree().current_scene.add_child(sparkle)
		
		# Animate sparkles
		var sparkle_tween = create_tween()
		sparkle_tween.set_parallel(true)
		
		var delay = i * 0.05
		sparkle_tween.tween_property(sparkle, "scale", Vector2(2.0, 2.0), 0.3).set_delay(delay)
		sparkle_tween.tween_property(sparkle, "scale", Vector2(0.1, 0.1), 0.3).set_delay(delay + 0.3)
		sparkle_tween.tween_property(sparkle, "modulate:a", 0.0, 0.4).set_delay(delay + 0.2)
		sparkle_tween.tween_callback(sparkle.queue_free).set_delay(delay + 0.6)
	
	# Card pulsing effect
	var card_tween = create_tween()
	card_tween.set_parallel(true)
	card_tween.tween_property(card, "modulate", Color(1.2, 1.2, 1.0, 1.0), 0.2)
	card_tween.tween_property(card, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.4).set_delay(0.2)
	card_tween.tween_property(card, "scale", card.scale * 1.1, 0.2)
	card_tween.tween_property(card, "scale", card.scale, 0.4).set_delay(0.2)

func create_melee_impact_effect(target: Enemy):
	"""Create impact effect for melee attacks"""
	print("💥 Creating melee impact effect!")
	
	# Create impact slash marks
	for i in range(8):
		var slash = ColorRect.new()
		slash.color = Color(1.0, 0.8, 0.6, 0.8)
		slash.size = Vector2(randf_range(20, 35), randf_range(3, 8))
		slash.z_index = 400
		
		var target_center = target.global_position + target.size / 2
		slash.global_position = target_center + Vector2(randf_range(-20, 20), randf_range(-20, 20))
		slash.rotation = randf_range(0, 2 * PI)
		get_tree().current_scene.add_child(slash)
		
		var slash_tween = create_tween()
		slash_tween.set_parallel(true)
		
		slash_tween.tween_property(slash, "scale", Vector2(1.5, 0.5), 0.2)
		slash_tween.tween_property(slash, "modulate:a", 0.0, 0.3)
		slash_tween.tween_callback(slash.queue_free).set_delay(0.3)

func create_impact_effect(target: Enemy):
	print("💥 Creating impact effect on", target.enemy_name)
	
	# Create impact particles
	for i in range(15):
		var particle = ColorRect.new()
		
		# Impact colors - bright flash
		var impact_colors = [
			Color(1.0, 1.0, 0.3, 1.0),  # Bright yellow
			Color(1.0, 0.5, 0.1, 0.9),  # Orange
			Color(1.0, 0.2, 0.0, 0.8),  # Red
			Color(1.0, 1.0, 1.0, 0.7),  # White flash
		]
		
		particle.color = impact_colors[i % impact_colors.size()]
		particle.size = Vector2(randf_range(4, 12), randf_range(4, 12))
		particle.z_index = 400  # Above target but below attack card
		
		# Position around the target
		var target_center = target.global_position + target.size / 2
		particle.global_position = target_center + Vector2(
			randf_range(-target.size.x/3, target.size.x/3),
			randf_range(-target.size.y/3, target.size.y/3)
		)
		
		get_tree().current_scene.add_child(particle)
		
		# Animate particles exploding outward
		var particle_tween = create_tween()
		particle_tween.set_parallel(true)
		
		var explode_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		var explode_distance = randf_range(30, 60)
		var duration = randf_range(0.3, 0.8)
		
		particle_tween.tween_property(particle, "global_position", 
			particle.global_position + explode_direction * explode_distance, duration)
		particle_tween.tween_property(particle, "modulate:a", 0.0, duration * 0.8)
		particle_tween.tween_property(particle, "scale", Vector2(0.1, 0.1), duration)
		
		# Remove particle
		particle_tween.tween_callback(particle.queue_free).set_delay(duration + 0.1)
	
	# Screen shake effect for impact
	create_screen_shake()

func create_spell_effect_animation(card: Card, target: Enemy):
	"""Create unique spell effect animations based on spell type"""
	print("🪄 Creating spell effect animation for:", card.card_name, "targeting:", target.enemy_name)
	
	match card.card_name.to_lower():
		"lightning bolt":
			create_lightning_effect(card, target)
		"ice shard":
			create_ice_effect(card, target)
		"dragon's fury":
			create_fire_effect(card, target)
		"phoenix rebirth":
			create_phoenix_effect(card, target)
		_:
			# Default magical effect for unknown spells
			create_generic_magic_effect(card, target)

func create_lightning_effect(card: Card, target: Enemy):
	"""Create dramatic lightning strike effect"""
	print("⚡ Creating lightning strike effect")
	
	var card_pos = card.global_position + card.size / 2
	var target_pos = target.global_position + target.size / 2
	
	# Phase 1: Build-up energy at card (0.0-0.5s)
	create_lightning_buildup(card_pos)
	
	# Phase 2: Lightning strike from above (0.5-0.8s)
	create_lightning_strike_from_sky(target_pos)
	
	# Phase 3: Main lightning bolt from card to target (0.6-1.0s)
	create_main_lightning_bolt(card_pos, target_pos)
	
	# Phase 4: Impact explosion with electrical discharge (1.0-1.5s)
	var impact_timer = Timer.new()
	add_child(impact_timer)
	impact_timer.wait_time = 1.0
	impact_timer.one_shot = true
	impact_timer.start()
	impact_timer.timeout.connect(func():
		create_lightning_impact_explosion(target)
		create_screen_shake()
		impact_timer.queue_free()
	)

func create_lightning_buildup(card_pos: Vector2):
	"""Create energy buildup at the card before lightning strike"""
	for i in range(8):
		var energy_spark = ColorRect.new()
		energy_spark.color = Color(0.8, 0.9, 1.0, 0.8)
		energy_spark.size = Vector2(4, 4)
		energy_spark.z_index = 500
		
		# Position around the card
		var angle = i * PI / 4
		var radius = 25
		energy_spark.global_position = card_pos + Vector2(cos(angle) * radius, sin(angle) * radius)
		get_tree().current_scene.add_child(energy_spark)
		
		# Animate sparks converging to center
		var spark_tween = create_tween()
		spark_tween.set_parallel(true)
		
		var delay = i * 0.05
		spark_tween.tween_property(energy_spark, "global_position", card_pos, 0.4).set_delay(delay)
		spark_tween.tween_property(energy_spark, "scale", Vector2(2.0, 2.0), 0.2).set_delay(delay)
		spark_tween.tween_property(energy_spark, "scale", Vector2(0.1, 0.1), 0.2).set_delay(delay + 0.2)
		spark_tween.tween_property(energy_spark, "modulate", Color(1.0, 1.0, 0.6, 1.0), 0.4).set_delay(delay)
		
		spark_tween.tween_callback(energy_spark.queue_free).set_delay(0.5)

func create_lightning_strike_from_sky(target_pos: Vector2):
	"""Create lightning strike coming down from above the screen"""
	# Main lightning bolt from sky
	var sky_lightning = ColorRect.new()
	sky_lightning.color = Color(1.0, 1.0, 0.9, 0.95)
	sky_lightning.size = Vector2(12, 300)  # Wider and taller
	sky_lightning.z_index = 550
	
	# Start from above the screen
	var sky_start = Vector2(target_pos.x - 6, target_pos.y - 400)
	sky_lightning.global_position = sky_start
	get_tree().current_scene.add_child(sky_lightning)
	
	# Create jagged lightning path with multiple segments
	create_jagged_lightning_segments(sky_start, target_pos)
	
	# Animate the main bolt striking down
	var sky_tween = create_tween()
	sky_tween.set_parallel(true)
	
	# Strike down quickly
	sky_tween.tween_property(sky_lightning, "global_position", 
		Vector2(target_pos.x - 6, target_pos.y - 200), 0.15).set_delay(0.5)
	sky_tween.tween_property(sky_lightning, "size", Vector2(16, 200), 0.15).set_delay(0.5)
	
	# Intense flickering during strike
	for i in range(6):
		sky_tween.tween_property(sky_lightning, "modulate:a", 0.2, 0.05).set_delay(0.5 + i * 0.1)
		sky_tween.tween_property(sky_lightning, "modulate:a", 1.0, 0.05).set_delay(0.5 + i * 0.1 + 0.05)
	
	# Fade out
	sky_tween.tween_property(sky_lightning, "modulate:a", 0.0, 0.2).set_delay(1.1)
	sky_tween.tween_callback(sky_lightning.queue_free).set_delay(1.3)

func create_jagged_lightning_segments(start_pos: Vector2, target_pos: Vector2):
	"""Create jagged lightning segments for more realistic lightning"""
	var segments = 8
	var current_pos = start_pos
	
	for i in range(segments):
		var lightning_segment = ColorRect.new()
		lightning_segment.color = Color(0.9, 0.95, 1.0, 0.8)
		lightning_segment.size = Vector2(6, 35)
		lightning_segment.z_index = 540
		
		# Add random jagged movement
		var next_y = start_pos.y + (float(i + 1) / segments) * (target_pos.y - start_pos.y)
		var jag_x = target_pos.x + randf_range(-25, 25)
		var next_pos = Vector2(jag_x, next_y)
		
		lightning_segment.global_position = current_pos
		lightning_segment.rotation = atan2(next_pos.y - current_pos.y, next_pos.x - current_pos.x) + PI/2
		get_tree().current_scene.add_child(lightning_segment)
		
		# Animate segment appearing
		var segment_tween = create_tween()
		segment_tween.set_parallel(true)
		
		var delay = 0.5 + i * 0.03
		segment_tween.tween_property(lightning_segment, "modulate:a", 0.9, 0.1).set_delay(delay)
		segment_tween.tween_property(lightning_segment, "modulate:a", 0.0, 0.4).set_delay(delay + 0.6)
		segment_tween.tween_callback(lightning_segment.queue_free).set_delay(delay + 1.0)
		
		current_pos = next_pos

func create_main_lightning_bolt(card_pos: Vector2, target_pos: Vector2):
	"""Create the main lightning bolt connecting card to target"""
	var main_bolt = ColorRect.new()
	main_bolt.color = Color(1.0, 1.0, 0.7, 0.9)
	main_bolt.size = Vector2(10, card_pos.distance_to(target_pos))
	main_bolt.z_index = 520
	
	# Position and rotate toward target
	main_bolt.global_position = card_pos
	main_bolt.rotation = atan2(target_pos.y - card_pos.y, target_pos.x - card_pos.x) + PI/2
	get_tree().current_scene.add_child(main_bolt)
	
	# Animate main bolt
	var bolt_tween = create_tween()
	bolt_tween.set_parallel(true)
	
	# Appear and grow
	bolt_tween.tween_property(main_bolt, "scale", Vector2(1.5, 1.0), 0.2).set_delay(0.6)
	bolt_tween.tween_property(main_bolt, "scale", Vector2(0.8, 1.0), 0.2).set_delay(0.8)
	
	# Intense pulsing
	for i in range(4):
		bolt_tween.tween_property(main_bolt, "modulate", Color(1.2, 1.2, 0.8, 1.0), 0.08).set_delay(0.6 + i * 0.16)
		bolt_tween.tween_property(main_bolt, "modulate", Color(1.0, 1.0, 0.7, 0.9), 0.08).set_delay(0.6 + i * 0.16 + 0.08)
	
	# Fade out
	bolt_tween.tween_property(main_bolt, "modulate:a", 0.0, 0.3).set_delay(1.0)
	bolt_tween.tween_callback(main_bolt.queue_free).set_delay(1.3)

func create_lightning_impact_explosion(target: Enemy):
	"""Create dramatic electrical explosion at target"""
	var target_center = target.global_position + target.size / 2
	
	# Main electrical blast
	for i in range(20):
		var electric_spark = ColorRect.new()
		var spark_colors = [
			Color(1.0, 1.0, 0.8, 0.9),  # Bright white-yellow
			Color(0.8, 0.9, 1.0, 0.8),  # Electric blue
			Color(1.0, 1.0, 0.6, 0.7),  # Lightning yellow
		]
		electric_spark.color = spark_colors[i % spark_colors.size()]
		electric_spark.size = Vector2(randf_range(6, 14), randf_range(6, 14))
		electric_spark.z_index = 400
		
		electric_spark.global_position = target_center + Vector2(randf_range(-15, 15), randf_range(-15, 15))
		get_tree().current_scene.add_child(electric_spark)
		
		var explosion_tween = create_tween()
		explosion_tween.set_parallel(true)
		
		var discharge_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		var discharge_distance = randf_range(50, 100)
		
		explosion_tween.tween_property(electric_spark, "global_position", 
			electric_spark.global_position + discharge_direction * discharge_distance, 0.4)
		explosion_tween.tween_property(electric_spark, "modulate:a", 0.0, 0.4)
		explosion_tween.tween_property(electric_spark, "scale", Vector2(0.1, 0.1), 0.4)
		
		# Add electric crackling effect
		if i < 8:
			explosion_tween.tween_property(electric_spark, "rotation", deg_to_rad(720), 0.4)
		
		explosion_tween.tween_callback(electric_spark.queue_free).set_delay(0.4)
	
	# Electric ring expansion
	create_electric_shockwave(target_center)

func create_electric_shockwave(center_pos: Vector2):
	"""Create expanding electric shockwave ring"""
	for ring in range(3):
		var shockwave_ring = ColorRect.new()
		shockwave_ring.color = Color(0.8, 0.9, 1.0, 0.6)
		shockwave_ring.size = Vector2(10, 10)
		shockwave_ring.z_index = 350
		
		# Center the ring
		shockwave_ring.global_position = center_pos - shockwave_ring.size / 2
		get_tree().current_scene.add_child(shockwave_ring)
		
		# Animate ring expansion
		var ring_tween = create_tween()
		ring_tween.set_parallel(true)
		
		var delay = ring * 0.1
		var final_size = Vector2(80 + ring * 20, 80 + ring * 20)
		
		ring_tween.tween_property(shockwave_ring, "size", final_size, 0.5).set_delay(delay)
		ring_tween.tween_property(shockwave_ring, "global_position", 
			center_pos - final_size / 2, 0.5).set_delay(delay)
		ring_tween.tween_property(shockwave_ring, "modulate:a", 0.0, 0.5).set_delay(delay)
		
		ring_tween.tween_callback(shockwave_ring.queue_free).set_delay(delay + 0.5)

func create_ice_effect(card: Card, target: Enemy):
	"""Create ice shard effect"""
	print("❄️ Creating ice effect")
	
	# Create multiple ice shards
	for i in range(8):
		var ice_shard = ColorRect.new()
		ice_shard.color = Color(0.7, 0.9, 1.0, 0.8)
		ice_shard.size = Vector2(6, 15)
		ice_shard.z_index = 500
		
		var card_pos = card.global_position + card.size / 2
		var target_pos = target.global_position + target.size / 2
		
		# Start from card position with slight spread
		ice_shard.global_position = card_pos + Vector2(randf_range(-20, 20), randf_range(-10, 10))
		ice_shard.rotation = deg_to_rad(randf_range(-30, 30))
		get_tree().current_scene.add_child(ice_shard)
		
		# Fly toward target
		var shard_tween = create_tween()
		shard_tween.set_parallel(true)
		
		var delay = i * 0.1  # Stagger the shards
		shard_tween.tween_property(ice_shard, "global_position", 
			target_pos + Vector2(randf_range(-20, 20), randf_range(-20, 20)), 0.6).set_delay(delay)
		shard_tween.tween_property(ice_shard, "rotation", 
			ice_shard.rotation + deg_to_rad(360), 0.6).set_delay(delay)
		
		# Fade out on impact
		shard_tween.tween_property(ice_shard, "modulate:a", 0.0, 0.2).set_delay(delay + 0.6)
		shard_tween.tween_callback(ice_shard.queue_free).set_delay(delay + 0.8)
	
	# Create freeze effect at target
	create_freeze_impact(target)

func create_fire_effect(card: Card, target: Enemy):
	"""Create dragon's fury fire effect"""
	print("🔥 Creating fire effect")
	
	# Create fire projectile
	var fireball = ColorRect.new()
	fireball.color = Color(1.0, 0.4, 0.1, 0.9)
	fireball.size = Vector2(25, 25)
	fireball.z_index = 500
	
	var card_pos = card.global_position + card.size / 2
	var target_pos = target.global_position + target.size / 2
	
	fireball.global_position = card_pos
	get_tree().current_scene.add_child(fireball)
	
	# Create fire trail
	create_fire_trail(fireball)
	
	# Fireball movement with arc
	var fire_tween = create_tween()
	fire_tween.set_parallel(true)
	
	var midpoint = (card_pos + target_pos) / 2
	midpoint.y -= 30  # Arc
	
	fire_tween.tween_property(fireball, "global_position", midpoint, 0.4)
	fire_tween.tween_property(fireball, "global_position", target_pos, 0.4).set_delay(0.4)
	fire_tween.tween_property(fireball, "scale", Vector2(1.5, 1.5), 0.8)
	
	# Explosion at target
	fire_tween.tween_callback(func(): create_fire_explosion(target)).set_delay(0.8)
	fire_tween.tween_callback(fireball.queue_free).set_delay(1.0)

func create_phoenix_effect(card: Card, target: Enemy):
	"""Create phoenix rebirth effect"""
	print("🔥🐦 Creating phoenix effect")
	
	# Create phoenix silhouette
	var phoenix = ColorRect.new()
	phoenix.color = Color(1.0, 0.6, 0.2, 0.8)
	phoenix.size = Vector2(40, 30)
	phoenix.z_index = 500
	
	var card_pos = card.global_position + card.size / 2
	var target_pos = target.global_position + target.size / 2
	
	phoenix.global_position = card_pos
	get_tree().current_scene.add_child(phoenix)
	
	# Phoenix flight with rebirth trail
	var phoenix_tween = create_tween()
	phoenix_tween.set_parallel(true)
	
	# Spiral flight pattern
	var flight_time = 1.0
	for i in range(10):
		var angle = i * PI / 5
		var spiral_pos = card_pos.lerp(target_pos, i / 9.0)
		spiral_pos += Vector2(cos(angle) * 30, sin(angle) * 15)
		phoenix_tween.tween_property(phoenix, "global_position", spiral_pos, flight_time / 10).set_delay(i * flight_time / 10)
	
	# Scale and rotation
	phoenix_tween.tween_property(phoenix, "rotation", deg_to_rad(720), flight_time)
	phoenix_tween.tween_property(phoenix, "scale", Vector2(2.0, 2.0), flight_time)
	
	# Rebirth explosion
	phoenix_tween.tween_callback(func(): create_phoenix_explosion(target)).set_delay(flight_time)
	phoenix_tween.tween_callback(phoenix.queue_free).set_delay(flight_time + 0.2)

func create_generic_magic_effect(card: Card, target: Enemy):
	"""Create generic magical effect for unknown spells"""
	print("✨ Creating generic magic effect")
	
	# Create magical orb
	var magic_orb = ColorRect.new()
	magic_orb.color = Color(0.8, 0.4, 1.0, 0.8)  # Purple magic
	magic_orb.size = Vector2(20, 20)
	magic_orb.z_index = 500
	
	var card_pos = card.global_position + card.size / 2
	var target_pos = target.global_position + target.size / 2
	
	magic_orb.global_position = card_pos
	get_tree().current_scene.add_child(magic_orb)
	
	# Magical floating movement
	var magic_tween = create_tween()
	magic_tween.set_parallel(true)
	
	magic_tween.tween_property(magic_orb, "global_position", target_pos, 0.8)
	magic_tween.tween_property(magic_orb, "scale", Vector2(1.5, 1.5), 0.4)
	magic_tween.tween_property(magic_orb, "scale", Vector2(0.5, 0.5), 0.4).set_delay(0.4)
	
	# Pulsing glow
	var glow_tween = create_tween()
	glow_tween.set_loops(4)
	glow_tween.tween_property(magic_orb, "modulate", Color(1.2, 0.8, 1.4, 1.0), 0.2)
	glow_tween.tween_property(magic_orb, "modulate", Color(0.8, 0.4, 1.0, 0.8), 0.2)
	
	# Impact
	magic_tween.tween_callback(func(): create_impact_effect(target)).set_delay(0.8)
	magic_tween.tween_callback(magic_orb.queue_free).set_delay(1.0)

func create_lightning_impact(target: Enemy):
	"""Create lightning impact effect"""
	for i in range(10):
		var spark = ColorRect.new()
		spark.color = Color(1.0, 1.0, 0.6, 0.9)
		spark.size = Vector2(3, 3)
		spark.z_index = 400
		
		var target_center = target.global_position + target.size / 2
		spark.global_position = target_center + Vector2(randf_range(-25, 25), randf_range(-25, 25))
		get_tree().current_scene.add_child(spark)
		
		var spark_tween = create_tween()
		spark_tween.tween_property(spark, "modulate:a", 0.0, 0.5)
		spark_tween.tween_callback(spark.queue_free).set_delay(0.5)

func create_freeze_impact(target: Enemy):
	"""Create freeze impact effect"""
	for i in range(15):
		var ice_particle = ColorRect.new()
		ice_particle.color = Color(0.7, 0.9, 1.0, 0.8)
		ice_particle.size = Vector2(4, 4)
		ice_particle.z_index = 400
		
		var target_center = target.global_position + target.size / 2
		ice_particle.global_position = target_center + Vector2(randf_range(-20, 20), randf_range(-20, 20))
		get_tree().current_scene.add_child(ice_particle)
		
		var freeze_tween = create_tween()
		freeze_tween.tween_property(ice_particle, "scale", Vector2(0.1, 0.1), 0.6)
		freeze_tween.tween_property(ice_particle, "modulate:a", 0.0, 0.6)
		freeze_tween.tween_callback(ice_particle.queue_free).set_delay(0.6)

func create_fire_trail(fireball: ColorRect):
	"""Create fire trail behind fireball"""
	var trail_timer = Timer.new()
	fireball.add_child(trail_timer)
	trail_timer.wait_time = 0.05
	trail_timer.timeout.connect(func():
		var ember = ColorRect.new()
		ember.color = Color(1.0, 0.6, 0.1, 0.6)
		ember.size = Vector2(8, 8)
		ember.z_index = 450
		ember.global_position = fireball.global_position + Vector2(randf_range(-5, 5), randf_range(-5, 5))
		get_tree().current_scene.add_child(ember)
		
		var ember_tween = create_tween()
		ember_tween.tween_property(ember, "modulate:a", 0.0, 0.3)
		ember_tween.tween_property(ember, "scale", Vector2(0.1, 0.1), 0.3)
		ember_tween.tween_callback(ember.queue_free).set_delay(0.3)
	)
	trail_timer.start()

func create_fire_explosion(target: Enemy):
	"""Create fire explosion at target"""
	for i in range(20):
		var flame = ColorRect.new()
		var flame_colors = [Color(1.0, 0.4, 0.1), Color(1.0, 0.6, 0.2), Color(1.0, 0.8, 0.1)]
		flame.color = flame_colors[i % flame_colors.size()]
		flame.size = Vector2(randf_range(8, 15), randf_range(8, 15))
		flame.z_index = 400
		
		var target_center = target.global_position + target.size / 2
		flame.global_position = target_center
		get_tree().current_scene.add_child(flame)
		
		var explosion_tween = create_tween()
		explosion_tween.set_parallel(true)
		
		var explode_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		explosion_tween.tween_property(flame, "global_position", 
			flame.global_position + explode_dir * randf_range(40, 80), 0.5)
		explosion_tween.tween_property(flame, "modulate:a", 0.0, 0.5)
		explosion_tween.tween_property(flame, "scale", Vector2(0.1, 0.1), 0.5)
		explosion_tween.tween_callback(flame.queue_free).set_delay(0.5)

func create_phoenix_explosion(target: Enemy):
	"""Create phoenix rebirth explosion"""
	for i in range(25):
		var feather = ColorRect.new()
		var feather_colors = [Color(1.0, 0.6, 0.2), Color(1.0, 0.8, 0.4), Color(1.0, 0.4, 0.1)]
		feather.color = feather_colors[i % feather_colors.size()]
		feather.size = Vector2(randf_range(6, 12), randf_range(3, 8))
		feather.z_index = 400
		
		var target_center = target.global_position + target.size / 2
		feather.global_position = target_center
		get_tree().current_scene.add_child(feather)
		
		var rebirth_tween = create_tween()
		rebirth_tween.set_parallel(true)
		
		var float_dir = Vector2(randf_range(-1, 1), randf_range(-0.5, -1)).normalized()
		rebirth_tween.tween_property(feather, "global_position", 
			feather.global_position + float_dir * randf_range(60, 120), 1.0)
		rebirth_tween.tween_property(feather, "rotation", deg_to_rad(randf_range(180, 540)), 1.0)
		rebirth_tween.tween_property(feather, "modulate:a", 0.0, 1.0)
		rebirth_tween.tween_callback(feather.queue_free).set_delay(1.0)

# 🔥 Card Effects
func flame_imp_effect(target):
	target.take_damage(5)
	target.apply_status("Burn", 3)

func ice_shard_effect(target):
	target.take_damage(3)
	target.apply_status("Frozen", 1)

func lightning_bolt_effect(target):
	target.take_damage(8)
	print("⚡ Lightning strikes with unstoppable force!")

func healing_potion_effect(target):
	# Handle the case where target is null (no ally system yet)
	if target == null:
		print("💚 Healing Potion used! (No ally system implemented yet - effect has no target)")
		return
	
	# For now, heal the enemy (later we can add player healing)
	target.heal(6)
	print("💚 Healing magic flows through the target!")

func dragons_fury_effect(target):
	target.take_damage(12)
	target.apply_status("Burn", 5)
	print("🐉 Dragon's fury engulfs the battlefield!")

func phoenix_rebirth_effect(target):
	target.take_damage(15)
	# In a real game, this would heal the player
	print("🔥 Phoenix power unleashed! Ultimate devastation!")

func poison_dart_effect(target):
	target.take_damage(2)
	target.apply_status("Poison", 4)
	print("☠️ Poison courses through the enemy's veins!")

func iron_golem_effect(target):
	# Iron Golem's special ability: defensive/protective effect
	target.take_damage(2)  # Basic attack damage (matches its attack stat)
	print("🛡️ Iron Golem strikes with defensive force!")
	# In the future, this could provide shields to other creatures or have defensive abilities

func archer_effect(target):
	# Archer's basic ranged attack
	target.take_damage(4)  # Matches its attack stat
	print("🏹 Archer fires a precise shot!")

func _on_battlefield_card_clicked(card):
	print("🎯 Battlefield card clicked:", card.card_name)
	
	# Don't allow battlefield card interaction during turn execution
	if is_executing_turn:
		print("⛔ Battlefield card interaction disabled during turn execution")
		return
	
	# Check if a card is currently selected for targeting
	if selected_card:
		# If the same card is clicked, allow target change
		if selected_card == card:
			print("🔄 Same battlefield card clicked - keeping selection for target change")
			return
		else:
			# Switch selection to the new card
			print("🎯 Switching selection to battlefield card:", card.card_name)
			clear_card_selection()
			select_card_for_targeting(card)
	else:
		# No card selected - select this battlefield card for target change
		print("🎯 Selecting battlefield card for target change:", card.card_name)
		select_card_for_targeting(card)

func move_card_back_to_hand(card):
	"""Move a card from battlefield back to hand"""
	print("🔙 Moving card back to hand:", card.card_name)
	
	# Clear any target assignment
	if card in card_targets:
		card_targets.erase(card)
		print("🎯 Target assignment cleared for:", card.card_name)
	
	# Remove from battlefield
	card.get_parent().remove_child(card)
	
	# Add back to hand
	var hand_container = $MainLayout/HandZone/CardContainer
	hand_container.add_child(card)
	
	# Reset card appearance and signals
	card.reset_from_battlefield()
	
	# Reconnect to hand click handler
	if card.card_played.is_connected(_on_battlefield_card_clicked):
		card.card_played.disconnect(_on_battlefield_card_clicked)
	card.card_played.connect(_on_card_played)
	
	# Update battlefield counter
	update_battlefield_counter()
	
	print("✅ Card returned to hand:", card.card_name)

func disable_hand_cards_during_execution():
	"""Disable hand card interactions during turn execution"""
	print("⛔ Disabling all card interactions during turn execution")
	
	var hand_container = $MainLayout/HandZone/CardContainer
	var hand_cards = hand_container.get_children()
	
	for card in hand_cards:
		# Disable mouse input and give visual feedback
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.modulate = Color(0.5, 0.5, 0.5, 0.7)  # Grayed out appearance
		print("🔒 Hand card disabled:", card.card_name)
	
	# Also disable battlefield cards during execution
	var battlefield_container = $MainLayout/BattlefieldZone/PlayedCardsContainer
	if battlefield_container:
		var battlefield_cards = battlefield_container.get_children()
		
		for card in battlefield_cards:
			# Disable mouse input and give visual feedback
			card.mouse_filter = Control.MOUSE_FILTER_IGNORE
			card.modulate = Color(0.5, 0.5, 0.5, 0.7)  # Grayed out appearance
			print("🔒 Battlefield card disabled:", card.card_name)
		
	print("⛔ All cards disabled during execution")

func enable_hand_cards_after_execution():
	"""Re-enable hand card interactions after turn execution"""
	print("✅ Re-enabling all card interactions after turn execution")
	
	var hand_container = $MainLayout/HandZone/CardContainer
	var hand_cards = hand_container.get_children()
	
	for card in hand_cards:
		# Re-enable mouse input and restore appearance
		card.mouse_filter = Control.MOUSE_FILTER_PASS
		card.modulate = Color(1.0, 1.0, 1.0, 1.0)  # Normal appearance
		print("🔓 Hand card enabled:", card.card_name)
	
	# Also re-enable battlefield cards after execution
	var battlefield_container = $MainLayout/BattlefieldZone/PlayedCardsContainer
	if battlefield_container:
		var battlefield_cards = battlefield_container.get_children()
		
		for card in battlefield_cards:
			# Re-enable mouse input and restore appearance
			card.mouse_filter = Control.MOUSE_FILTER_PASS
			card.modulate = Color(1.0, 1.0, 1.0, 1.0)  # Normal appearance
			print("🔓 Battlefield card enabled:", card.card_name)
		
	print("✅ All cards re-enabled after execution")
	
	# Update affordability visuals after re-enabling
	update_card_affordability_visuals()

func execute_instant_card(card):
	"""Execute spells and items immediately without going to battlefield"""
	print("✨ Executing instant card:", card.card_name, "Type:", card.card_type)
	
	# Get valid targets for this card type
	var valid_targets = card.get_valid_targets(get_alive_enemies())
	
	if valid_targets.size() == 0:
		if card.card_type == "ITEM" and card.description.to_lower().contains("heal"):
			print("💚 Healing item with no valid targets - could target player/allies in future")
			# For now, just show the effect without targeting
			card.play_card(null)
		else:
			print("❌ No valid targets for instant card:", card.card_name)
			return
	else:
		# Choose a random target from valid targets
		var target = valid_targets[randi() % valid_targets.size()]
		print("🎯 Instant card targeting:", target.enemy_name)
		
		# Create attack animation
		create_attack_animation(card, target)
		
		# Apply effect after animation
		var effect_timer = Timer.new()
		add_child(effect_timer)
		effect_timer.wait_time = 1.0
		effect_timer.one_shot = true
		effect_timer.start()
		effect_timer.timeout.connect(func():
			card.play_card(target)
			create_impact_effect(target)
			effect_timer.queue_free()
		)
	
	# Remove card from hand after execution
	var removal_timer = Timer.new()
	add_child(removal_timer)
	removal_timer.wait_time = 1.5  # After animation completes
	removal_timer.one_shot = true
	removal_timer.start()
	removal_timer.timeout.connect(func():
		card.start_burning_animation()
		removal_timer.queue_free()
	)

func execute_creature_card(card):
	"""Execute creature cards - they stay on battlefield and attack"""
	print("🐲 Executing creature:", card.card_name, "- Attack Type:", card.attack_type)
	
	# Get target
	var target = get_card_target(card)
	
	if target:
		# Use the new attack type system for creatures
		create_attack_animation(card, target)
		
		# Apply creature attack after animation - timing varies by attack type
		var delay_time = 1.0
		match card.attack_type:
			"MELEE":
				delay_time = 0.8  # Impact happens during charge
			"RANGED":
				delay_time = 0.6  # Projectile hits
			"SPELL":
				delay_time = 1.2  # Spell effect time
			"SUPPORT":
				delay_time = 0.6  # Support magic
		
		var effect_timer = Timer.new()
		add_child(effect_timer)
		effect_timer.wait_time = delay_time
		effect_timer.one_shot = true
		effect_timer.start()
		effect_timer.timeout.connect(func():
			# Creatures deal their attack damage
			target.take_damage(card.attack_power)
			
			# Create impact effect (except for spells which have their own)
			if card.attack_type != "SPELL":
				if card.attack_type == "MELEE":
					# Melee impact already created during animation
					pass
				else:
					create_impact_effect(target)
			
			# Apply any special effects the creature might have
			if card.effect_func and card.effect_func.is_valid():
				card.effect_func.call(target)
			
			print("⚔️ Creature", card.card_name, "attacks for", card.attack_power, "damage")
			effect_timer.queue_free()
		)
		
		# Creatures stay on battlefield, don't burn (unless they die)
		if card.current_health <= 0:
			var burn_timer = Timer.new()
			add_child(burn_timer)
			burn_timer.wait_time = 1.5
			burn_timer.one_shot = true
			burn_timer.start()
			burn_timer.timeout.connect(func():
				card.start_burning_animation()
				burn_timer.queue_free()
			)

func execute_instant_battlefield_card(card):
	"""Execute spells and items that were placed on battlefield"""
	print("✨ Executing instant battlefield card:", card.card_name)
	
	# Get target
	var target = get_card_target(card)
	
	if target:
		# Use spell-specific animations for spells, regular animations for items
		if card.card_type == "SPELL":
			create_spell_effect_animation(card, target)
			var effect_timer = Timer.new()
			add_child(effect_timer)
			effect_timer.wait_time = 1.2  # Slightly longer for spell effects
			effect_timer.one_shot = true
			effect_timer.start()
			effect_timer.timeout.connect(func():
				card.play_card(target)
				effect_timer.queue_free()
			)
		else:
			# For items, use regular attack animation
			create_attack_animation(card, target)
			var effect_timer = Timer.new()
			add_child(effect_timer)
			effect_timer.wait_time = 1.0
			effect_timer.one_shot = true
			effect_timer.start()
			effect_timer.timeout.connect(func():
				card.play_card(target)
				create_impact_effect(target)
				effect_timer.queue_free()
			)
	
	# Spells and items burn after execution
	var burn_timer = Timer.new()
	add_child(burn_timer)
	burn_timer.wait_time = 1.8  # Slightly longer to account for spell animations
	burn_timer.one_shot = true
	burn_timer.start()
	burn_timer.timeout.connect(func():
		card.start_burning_animation()
		burn_timer.queue_free()
	)

func get_card_target(card):
	"""Get the appropriate target for a card"""
	var target = null
	
	# Check if card has a pre-assigned target
	if card in card_targets:
		var assigned_target = card_targets[card]
		# Check if assigned target is still alive
		if assigned_target != null and "current_health" in assigned_target and assigned_target.current_health > 0:
			target = assigned_target
			print("🎯 Using pre-assigned target:", target.enemy_name)
		else:
			if assigned_target != null and "enemy_name" in assigned_target:
				print("💀 Pre-assigned target", assigned_target.enemy_name, "is dead - switching to random alive enemy")
			else:
				print("💀 Pre-assigned target is invalid - switching to random alive enemy")
			# Pre-assigned target is dead - choose random alive enemy
			var alive_enemies = get_alive_enemies()
			if alive_enemies.size() > 0:
				target = alive_enemies[randi() % alive_enemies.size()]
				print("🔄 Switched to random target:", target.enemy_name)
			else:
				print("❌ No alive enemies found!")
	else:
		# No pre-assigned target - choose random alive enemy
		var alive_enemies = get_alive_enemies()
		if alive_enemies.size() > 0:
			target = alive_enemies[randi() % alive_enemies.size()]
			print("🎲 Using random target:", target.enemy_name)
	
	return target

func create_screen_shake():
	"""Create a screen shake effect for dramatic impact"""
	print("💥 Creating screen shake effect")
	
	# Create a camera shake effect by slightly moving the main control node
	var original_pos = position
	var shake_tween = create_tween()
	shake_tween.set_parallel(true)
	
	# Quick shake sequence
	for i in range(8):
		var shake_offset = Vector2(randf_range(-3, 3), randf_range(-3, 3))
		shake_tween.tween_property(self, "position", original_pos + shake_offset, 0.05).set_delay(i * 0.05)
	
	# Return to original position
	shake_tween.tween_property(self, "position", original_pos, 0.1).set_delay(0.4)

func debug_card_interaction(card_name: String = ""):
	"""Debug function to check card interaction state"""
	print("=== CARD INTERACTION DEBUG ===")
	print("is_executing_turn:", is_executing_turn)
	print("selected_card:", selected_card.card_name if selected_card else "None")
	print("targeting_line exists:", targeting_line != null)
	
	var hand_container = $MainLayout/HandZone/CardContainer
	var hand_cards = hand_container.get_children()
	
	for card in hand_cards:
		if card_name == "" or card.card_name == card_name:
			print("Card:", card.card_name)
			print("  - mouse_filter:", card.mouse_filter)
			print("  - modulate:", card.modulate)
			print("  - card_type:", card.card_type)
			print("  - cost:", card.cost)
			print("  - is_instant_cast:", card.is_instant_cast())
			print("  - signals connected:", card.card_played.get_connections().size() > 0)
	
	print("=== END DEBUG ===")

func test_card_selection():
	"""Test function to manually trigger card selection"""
	print("🧪 TESTING CARD SELECTION")
	var hand_container = $MainLayout/HandZone/CardContainer
	var hand_cards = hand_container.get_children()
	
	print("🧪 Total cards in hand:", hand_cards.size())
	
	for i in range(hand_cards.size()):
		var card = hand_cards[i]
		print("🧪 Card", i, ":", card.card_name, "Type:", card.card_type, "Cost:", card.cost)
		print("  - mouse_filter:", card.mouse_filter)
		print("  - modulate:", card.modulate)
		print("  - position:", card.position)
		print("  - size:", card.size)
		
		# Test if the signal is connected
		var connections = card.card_played.get_connections()
		print("  - card_played connections:", connections.size())
		if connections.size() > 0:
			for conn in connections:
				print("    - connected to:", conn.callable.get_object(), "method:", conn.callable.get_method())
	
	if hand_cards.size() > 0:
		var test_card = hand_cards[0]  # Test the first card
		print("🧪 Testing first card:", test_card.card_name)
		
		# Manually call the card played function
		_on_card_played(test_card)
	else:
		print("🧪 No cards in hand to test")

func test_mouse_input_on_cards():
	"""Test if cards are receiving mouse input"""
	print("🖱️ TESTING MOUSE INPUT ON CARDS")
	var hand_container = $MainLayout/HandZone/CardContainer
	var hand_cards = hand_container.get_children()
	
	for card in hand_cards:
		print("🖱️ Card:", card.card_name)
		print("  - Has mouse input:", card.mouse_filter == Control.MOUSE_FILTER_PASS)
		print("  - Size:", card.size)
		print("  - Global position:", card.global_position)
		print("  - Z-index:", card.z_index)
		print("  - Visible:", card.visible)
		print("  - Modulate alpha:", card.modulate.a)
		
		# Check if card has proper collision area
		var rect = Rect2(card.global_position, card.size)
		print("  - Mouse area rect:", rect)

# Add comprehensive card debugging function
func debug_specific_card_issue():
	"""Debug function to identify which specific cards have selection issues"""
	print("=== DEBUGGING CARD SELECTION ISSUES ===")
	
	var hand_container = $MainLayout/HandZone/CardContainer
	var hand_cards = hand_container.get_children()
	
	print("Total cards in hand:", hand_cards.size())
	
	for i in range(hand_cards.size()):
		var card = hand_cards[i]
		print("\n--- CARD", i, ":", card.card_name, "---")
		print("  Type:", card.card_type)
		print("  Cost:", card.cost, "/ Current mana:", current_mana)
		print("  Mouse filter:", card.mouse_filter)
		print("  Position:", card.position)
		print("  Size:", card.size)
		print("  Global position:", card.global_position)
		print("  Visible:", card.visible)
		print("  Modulate:", card.modulate)
		print("  Z-index:", card.z_index)
		print("  Has debug_force_click:", card.has_method("debug_force_click"))
		
		# Check signal connections
		var connections = card.card_played.get_connections()
		print("  Signal connections:", connections.size())
		if connections.size() > 0:
			for conn in connections:
				print("    - Target:", conn.callable.get_object().get_script().get_path() if conn.callable.get_object().get_script() else "No script")
				print("    - Method:", conn.callable.get_method())
		else:
			print("    ❌ NO SIGNAL CONNECTIONS!")
		
		# Test if card can be clicked by forcing a click
		if card.has_method("debug_force_click"):
			print("  🧪 Testing force click on", card.card_name)
			card.debug_force_click()
		
		# Check for overlapping UI elements
		var mouse_pos = card.global_position + (card.size / 2)
		print("  Center mouse position would be:", mouse_pos)
	
	print("\n=== GAME STATE ===")
	print("is_executing_turn:", is_executing_turn)
	print("selected_card:", selected_card.card_name if selected_card else "None")
	print("targeting_line exists:", targeting_line != null)
	
	print("=== END CARD DEBUGGING ===")

# Add function to fix common card interaction issues
func fix_card_interactions():
	"""Attempt to fix common card interaction issues"""
	print("🔧 FIXING CARD INTERACTIONS...")
	
	var hand_container = $MainLayout/HandZone/CardContainer
	var hand_cards = hand_container.get_children()
	
	var fixes_applied = 0
	
	for card in hand_cards:
		print("🔧 Checking card:", card.card_name)
		
		# Fix 1: Ensure mouse filter is set correctly
		if card.mouse_filter != Control.MOUSE_FILTER_PASS:
			print("  - Fixed mouse_filter (was", card.mouse_filter, ")")
			card.mouse_filter = Control.MOUSE_FILTER_PASS
			fixes_applied += 1
		
		# Fix 2: Ensure signal is connected
		var connections = card.card_played.get_connections()
		if connections.size() == 0:
			print("  - Reconnecting card_played signal")
			if card.card_played.connect(_on_card_played) == OK:
				print("  - Signal reconnected successfully")
				fixes_applied += 1
			else:
				print("  - Failed to reconnect signal")
		
		# Fix 3: Reset modulate if it's transparent
		if card.modulate.a < 1.0:
			print("  - Fixed transparency (was", card.modulate.a, ")")
			card.modulate.a = 1.0
			fixes_applied += 1
		
		# Fix 4: Ensure card is visible
		if not card.visible:
			print("  - Made card visible")
			card.visible = true
			fixes_applied += 1
		
		# Fix 5: Reset child mouse filters
		if card.has_method("setup_mouse_filters"):
			card.setup_mouse_filters()
			print("  - Reset child mouse filters")
			fixes_applied += 1
	
	print("🔧 Applied", fixes_applied, "fixes to card interactions")
	
	if fixes_applied > 0:
		print("💡 Try clicking cards again - issues may be resolved!")
	else:
		print("💡 No obvious issues found. Problem may be deeper in the code structure.")
