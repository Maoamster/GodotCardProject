extends Control
class_name Card

signal card_played(card)

var card_name: String = "Default"
var cost: int = 1
var rarity: String = "COMMON"
var description: String = "No Description"
var image_path: String = ""
var effect_func = null  # No type to prevent null errors
var is_hovered: bool = false
var original_scale: Vector2
var original_position: Vector2
var rarity_tween: Tween
var pulse_tween: Tween  # For selection pulsing animation

# Creature-specific properties
var card_type: String = "CREATURE"  # Default to creature for this example
var max_health: int = 10
var current_health: int = 10
var attack_power: int = 5

# Attack type for different combat animations
var attack_type: String = "MELEE"  # MELEE, RANGED, SPELL, SUPPORT

# Tooltip system
var tooltip_timer: Timer
var tooltip_popup: Control
var tooltip_delay: float = 0.5

func _ready():
	original_scale = scale
	original_position = position
	update_display()
	print("Card Ready:", card_name)
	
	# Ensure the card can receive mouse input over its entire area
	mouse_filter = Control.MOUSE_FILTER_PASS
	print("🖱️ Card mouse_filter set to PASS for:", card_name)
	
	# Make sure all child controls don't block mouse input
	setup_mouse_filters()
	
	# Connect signals with error checking
	if connect("gui_input", Callable(self, "_on_gui_input")) == OK:
		print("✅ gui_input connected for:", card_name)
	else:
		print("❌ Failed to connect gui_input for:", card_name)
		
	if connect("mouse_entered", Callable(self, "_on_mouse_entered")) == OK:
		print("✅ mouse_entered connected for:", card_name)
	else:
		print("❌ Failed to connect mouse_entered for:", card_name)
		
	if connect("mouse_exited", Callable(self, "_on_mouse_exited")) == OK:
		print("✅ mouse_exited connected for:", card_name)
	else:
		print("❌ Failed to connect mouse_exited for:", card_name)
	
	# Start rarity-based animations
	start_rarity_effects()

func setup_mouse_filters():
	# Ensure all child nodes pass mouse events to the card
	for child in get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
			setup_child_mouse_filters(child)

func setup_child_mouse_filters(node):
	# Recursively set mouse filters for all descendant controls
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
			setup_child_mouse_filters(child)

func start_rarity_effects():
	match rarity.to_lower():
		"legendary":
			start_legendary_glow()
		"epic":
			start_epic_pulse()
		"rare":
			start_rare_shimmer()
		"uncommon":
			start_uncommon_glow()
		"common":
			pass  # No special effects for common cards

func start_legendary_glow():
	# Continuous golden glow animation
	if rarity_tween:
		rarity_tween.kill()
	rarity_tween = create_tween()
	rarity_tween.set_loops()
	rarity_tween.tween_property($Panel, "modulate", Color(1.3, 1.2, 0.8, 1.0), 1.0)
	rarity_tween.tween_property($Panel, "modulate", Color(1.0, 0.9, 0.6, 1.0), 1.0)

func start_epic_pulse():
	# Purple pulsing effect
	if rarity_tween:
		rarity_tween.kill()
	rarity_tween = create_tween()
	rarity_tween.set_loops()
	rarity_tween.tween_property($Panel, "modulate", Color(1.2, 1.0, 1.3, 1.0), 0.8)
	rarity_tween.tween_property($Panel, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.8)

func start_rare_shimmer():
	# Blue shimmer effect
	if rarity_tween:
		rarity_tween.kill()
	rarity_tween = create_tween()
	rarity_tween.set_loops()
	rarity_tween.tween_property($Panel, "modulate", Color(0.9, 1.0, 1.3, 1.0), 1.2)
	rarity_tween.tween_property($Panel, "modulate", Color(1.0, 1.0, 1.0, 1.0), 1.2)

func start_uncommon_glow():
	# Subtle green glow
	if rarity_tween:
		rarity_tween.kill()
	rarity_tween = create_tween()
	rarity_tween.set_loops()
	rarity_tween.tween_property($Panel, "modulate", Color(0.9, 1.1, 0.9, 1.0), 1.5)
	rarity_tween.tween_property($Panel, "modulate", Color(1.0, 1.0, 1.0, 1.0), 1.5)

func _on_mouse_entered():
	print("Card mouse entered: ", card_name)
	is_hovered = true
	
	# Make hover effect more visible for debugging
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", original_scale * 1.15, 0.2)
	tween.tween_property(self, "z_index", 10, 0.2)
	
	# Add a visible color change for debugging
	var panel = get_node("Panel")
	if panel:
		var style = panel.get_theme_stylebox("panel").duplicate()
		style.border_color = Color.YELLOW
		style.border_width_left = 5
		style.border_width_top = 5
		style.border_width_right = 5
		style.border_width_bottom = 5
		panel.add_theme_stylebox_override("panel", style)
	
	# Start tooltip timer
	start_tooltip_timer()

func _on_mouse_exited():
	print("Card mouse exited: ", card_name)
	is_hovered = false
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", original_scale, 0.2)
	tween.tween_property(self, "z_index", 0, 0.2)
	
	# Reset color for debugging
	var panel = get_node("Panel")
	if panel:
		var style = panel.get_theme_stylebox("panel").duplicate()
		style.border_color = Color(0.3, 0.3, 0.3, 1)
		style.border_width_left = 3
		style.border_width_top = 3
		style.border_width_right = 3
		style.border_width_bottom = 3
		panel.add_theme_stylebox_override("panel", style)
	
	# Cancel tooltip and hide if shown
	cancel_tooltip_timer()
	hide_tooltip()

func update_display():
	if $VBoxContainer/HeaderContainer/CardNameLabel:
		$VBoxContainer/HeaderContainer/CardNameLabel.text = card_name
	if $VBoxContainer/HeaderContainer/CostPanel/CostLabel:
		$VBoxContainer/HeaderContainer/CostPanel/CostLabel.text = str(cost)
	if $VBoxContainer/RarityLabel:
		$VBoxContainer/RarityLabel.text = rarity.to_upper()
	if $VBoxContainer/DescriptionContainer/DescriptionLabel:
		# For creatures, show basic description (stats are now displayed separately)
		$VBoxContainer/DescriptionContainer/DescriptionLabel.text = description
	if $VBoxContainer/ImageContainer/CardImage and image_path != "":
		var tex = load(image_path)
		$VBoxContainer/ImageContainer/CardImage.texture = tex
	
	# Update stat displays
	update_stat_displays()
	
	# Enhanced visual styling based on rarity
	apply_rarity_styling()

func update_stat_displays():
	"""Update health and attack stat displays"""
	# Show/hide stats container based on card type
	if $VBoxContainer/StatsContainer:
		var stats_container = $VBoxContainer/StatsContainer
		
		if card_type == "CREATURE":
			stats_container.visible = true
			
			# Update attack display
			if $VBoxContainer/StatsContainer/AttackPanel/AttackLabel:
				$VBoxContainer/StatsContainer/AttackPanel/AttackLabel.text = str(attack_power)
			
			# Update health display
			if $VBoxContainer/StatsContainer/HealthPanel/HealthLabel:
				$VBoxContainer/StatsContainer/HealthPanel/HealthLabel.text = str(current_health)
				
				# Color health based on current vs max health
				var health_label = $VBoxContainer/StatsContainer/HealthPanel/HealthLabel
				var health_percentage = float(current_health) / float(max_health)
				
				if health_percentage > 0.6:
					health_label.modulate = Color(1.0, 1.0, 1.0, 1.0)  # White for healthy
				elif health_percentage > 0.3:
					health_label.modulate = Color(1.0, 1.0, 0.7, 1.0)  # Yellow tint for wounded
				else:
					health_label.modulate = Color(1.0, 0.7, 0.7, 1.0)  # Red tint for critical
					
		elif card_type == "SPELL":
			stats_container.visible = true
			
			# Show damage value for spells
			var damage_value = get_spell_damage_value()
			if $VBoxContainer/StatsContainer/AttackPanel/AttackLabel:
				$VBoxContainer/StatsContainer/AttackPanel/AttackLabel.text = str(damage_value)
				# Color damage values red for spells and ensure white text
				$VBoxContainer/StatsContainer/AttackPanel/AttackLabel.modulate = Color(1.0, 1.0, 1.0, 1.0)  # White text
				# Color the panel background red instead
				if $VBoxContainer/StatsContainer/AttackPanel:
					$VBoxContainer/StatsContainer/AttackPanel.modulate = Color(1.0, 0.4, 0.4, 1.0)
			
			# Hide health display for spells
			if $VBoxContainer/StatsContainer/HealthPanel:
				$VBoxContainer/StatsContainer/HealthPanel.visible = false
				
		elif card_type == "ITEM":
			stats_container.visible = true
			
			# For healing items, show healing amount
			if card_name.to_lower().contains("heal") or description.to_lower().contains("heal"):
				var heal_value = get_item_heal_value()
				if $VBoxContainer/StatsContainer/HealthPanel/HealthLabel:
					$VBoxContainer/StatsContainer/HealthPanel/HealthLabel.text = "+" + str(heal_value)
					# Ensure white text on green background for healing
					$VBoxContainer/StatsContainer/HealthPanel/HealthLabel.modulate = Color(1.0, 1.0, 1.0, 1.0)
					if $VBoxContainer/StatsContainer/HealthPanel:
						$VBoxContainer/StatsContainer/HealthPanel.modulate = Color(0.4, 1.0, 0.4, 1.0)
				
				# Hide attack display for healing items
				if $VBoxContainer/StatsContainer/AttackPanel:
					$VBoxContainer/StatsContainer/AttackPanel.visible = false
			else:
				# For damage items, show damage value
				var damage_value = get_item_damage_value()
				if $VBoxContainer/StatsContainer/AttackPanel/AttackLabel:
					$VBoxContainer/StatsContainer/AttackPanel/AttackLabel.text = str(damage_value)
					# Ensure white text on red background for damage items
					$VBoxContainer/StatsContainer/AttackPanel/AttackLabel.modulate = Color(1.0, 1.0, 1.0, 1.0)
					if $VBoxContainer/StatsContainer/AttackPanel:
						$VBoxContainer/StatsContainer/AttackPanel.modulate = Color(1.0, 0.4, 0.4, 1.0)
				
				# Hide health display for damage items
				if $VBoxContainer/StatsContainer/HealthPanel:
					$VBoxContainer/StatsContainer/HealthPanel.visible = false
		else:
			# Hide stats for unknown card types
			stats_container.visible = false

func apply_rarity_styling():
	if $VBoxContainer/HeaderContainer/CostPanel:
		var cost_panel = $VBoxContainer/HeaderContainer/CostPanel
		var style_box = cost_panel.get_theme_stylebox("panel").duplicate()
		
		match rarity.to_lower():
			"common":
				style_box.bg_color = Color(0.5, 0.5, 0.5, 1)  # Gray
				style_box.border_color = Color(0.3, 0.3, 0.3, 1)
			"uncommon":
				style_box.bg_color = Color(0.2, 0.7, 0.2, 1)  # Green
				style_box.border_color = Color(0.1, 0.5, 0.1, 1)
			"rare":
				style_box.bg_color = Color(0.2, 0.4, 0.8, 1)  # Blue
				style_box.border_color = Color(0.1, 0.2, 0.6, 1)
			"epic":
				style_box.bg_color = Color(0.6, 0.2, 0.8, 1)  # Purple
				style_box.border_color = Color(0.4, 0.1, 0.6, 1)
			"legendary":
				style_box.bg_color = Color(0.9, 0.6, 0.2, 1)  # Orange/Gold
				style_box.border_color = Color(0.7, 0.4, 0.1, 1)
		
		cost_panel.add_theme_stylebox_override("panel", style_box)
	
	# Update main card border based on rarity
	if $Panel:
		var main_style = $Panel.get_theme_stylebox("panel").duplicate()
		
		match rarity.to_lower():
			"common":
				main_style.border_color = Color(0.4, 0.4, 0.4, 1)
				main_style.border_width_left = 2
				main_style.border_width_right = 2
				main_style.border_width_top = 2
				main_style.border_width_bottom = 2
			"uncommon":
				main_style.border_color = Color(0.2, 0.8, 0.2, 1)
				main_style.border_width_left = 3
				main_style.border_width_right = 3
				main_style.border_width_top = 3
				main_style.border_width_bottom = 3
			"rare":
				main_style.border_color = Color(0.2, 0.5, 1.0, 1)
				main_style.border_width_left = 4
				main_style.border_width_right = 4
				main_style.border_width_top = 4
				main_style.border_width_bottom = 4
			"epic":
				main_style.border_color = Color(0.8, 0.2, 1.0, 1)
				main_style.border_width_left = 5
				main_style.border_width_right = 5
				main_style.border_width_top = 5
				main_style.border_width_bottom = 5
			"legendary":
				main_style.border_color = Color(1.0, 0.8, 0.2, 1)
				main_style.border_width_left = 6
				main_style.border_width_right = 6
				main_style.border_width_top = 6
				main_style.border_width_bottom = 6
		
		$Panel.add_theme_stylebox_override("panel", main_style)
	
	# Update rarity label color
	if $VBoxContainer/RarityLabel:
		var rarity_label = $VBoxContainer/RarityLabel
		match rarity.to_lower():
			"common":
				rarity_label.modulate = Color(0.6, 0.6, 0.6, 1)
			"uncommon":
				rarity_label.modulate = Color(0.2, 0.8, 0.2, 1)
			"rare":
				rarity_label.modulate = Color(0.2, 0.5, 1.0, 1)
			"epic":
				rarity_label.modulate = Color(0.8, 0.2, 1.0, 1)
			"legendary":
				rarity_label.modulate = Color(1.0, 0.8, 0.2, 1)

func _on_gui_input(event):
	print("🖱️ Card GUI input received:", card_name, "Event:", event)
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("🎯 Card LEFT CLICK detected:", card_name)
			
			# Add click feedback before playing
			var click_tween = create_tween()
			click_tween.set_parallel(true)
			click_tween.tween_property(self, "scale", original_scale * 0.95, 0.1)
			click_tween.tween_property(self, "modulate", Color(1.5, 1.5, 0.8, 1.0), 0.1)
			
			# Create separate tween for the expansion and return to normal
			var expand_tween = create_tween()
			expand_tween.set_parallel(true)
			expand_tween.tween_property(self, "scale", original_scale * 1.05, 0.1).set_delay(0.1)
			expand_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1).set_delay(0.1)
			
			# Emit signal after click animation
			expand_tween.tween_callback(func(): emit_signal("card_played", self)).set_delay(0.2)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			print("🎯 Card RIGHT CLICK detected:", card_name)
			# Don't handle right-click here - let it bubble up to Main._input()
			# This allows Main to handle battlefield card removal

func play_card(target):
	if effect_func and effect_func.is_valid():
		effect_func.call(target)
		print("🎴 Card effect applied:", card_name)
	else:
		print("No effect function defined for", card_name)

func start_burning_animation():
	# Create a spectacular burning effect that makes the card disappear from top to bottom
	print("🔥 SPECTACULAR BURNING ANIMATION started for:", card_name)
	
	# Store original position before burning effects
	var burn_original_pos = position
	
	# Disable interaction during burning
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Bring card to front for dramatic effect using z_index
	z_index = 200  # Higher than hover z_index
	
	# Create intense fire particles effect FIRST (so they appear in front)
	create_enhanced_fire_particles()
	
	# Create spark effects
	create_spark_effects()
	
	# Main burning animation with multiple phases
	var burn_tween = create_tween()
	burn_tween.set_parallel(true)
	
	# Phase 1: Pre-ignition flash (0.0-0.2s)
	burn_tween.tween_property(self, "modulate", Color(2.0, 2.0, 2.0, 1.0), 0.1)
	burn_tween.tween_property(self, "modulate", Color(1.8, 0.4, 0.1, 1.0), 0.1).set_delay(0.1)
	
	# Phase 2: Realistic burning effect - progressive fade with burn color (0.2-1.5s)
	burn_tween.tween_method(apply_realistic_burn_effect, 0.0, 1.0, 1.3).set_delay(0.2)
	
	# Phase 3: Dramatic curling and warping
	burn_tween.tween_property(self, "rotation", deg_to_rad(randf_range(-25, 25)), 1.0).set_delay(0.3)
	burn_tween.tween_property(self, "scale", Vector2(0.7, 0.6), 1.2).set_delay(0.4)
	burn_tween.tween_property(self, "position", burn_original_pos + Vector2(randf_range(-10, 10), 15), 1.0).set_delay(0.5)
	
	# Phase 4: Final fade to ash (1.5-2.0s)
	burn_tween.tween_property(self, "modulate", Color(0.3, 0.3, 0.3, 0.8), 0.3).set_delay(1.2)
	burn_tween.tween_property(self, "modulate:a", 0.0, 0.5).set_delay(1.5)
	
	# Add intense shake during burning
	create_enhanced_burn_shake()
	
	# Remove the card after burning
	burn_tween.tween_callback(remove_burned_card).set_delay(2.2)

func apply_realistic_burn_effect(progress: float):
	# Create a realistic burning effect that changes the card to burnt orange/black
	var burn_y = progress * size.y
	
	# Apply burning effect to the card itself instead of using a mask
	for child in get_children():
		if child.name.begins_with("fire_particle") or child.name.begins_with("spark"):
			continue  # Don't affect fire particles or sparks
			
		if child is Control:
			var child_bottom = child.position.y + child.size.y
			if child_bottom <= burn_y + 10:  # Fully burned area
				# Make it look charred - dark with ember glow
				child.modulate = Color(0.1, 0.05, 0.0, 0.3)  # Almost gone, dark ember
			elif child.position.y <= burn_y:
				# Burning transition area
				var burn_amount = (burn_y - child.position.y) / child.size.y
				burn_amount = clamp(burn_amount, 0.0, 1.0)
				
				# Blend from normal to burnt orange to black
				var burnt_color = Color(0.8, 0.2, 0.0)  # Burnt orange
				var charred_color = Color(0.1, 0.05, 0.0)  # Almost black
				var normal_color = Color(1.0, 1.0, 1.0)
				
				if burn_amount < 0.5:
					# Normal to burnt orange
					var blend_factor = burn_amount * 2.0
					child.modulate = normal_color.lerp(burnt_color, blend_factor)
				else:
					# Burnt orange to charred
					var blend_factor = (burn_amount - 0.5) * 2.0
					child.modulate = burnt_color.lerp(charred_color, blend_factor)
					child.modulate.a = 1.0 - (blend_factor * 0.8)  # Fade out gradually

func create_enhanced_burn_shake():
	# Add intense burning shake effect with varying intensity
	var shake_tween = create_tween()
	shake_tween.set_loops(25)  # More intense shaking
	var original_pos = position
	
	for i in range(25):
		var intensity = float(i) / 25.0 * 3.0  # Increasing intensity
		shake_tween.tween_property(self, "position", original_pos + Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity)), 0.04)
		shake_tween.tween_property(self, "position", original_pos, 0.04)

func create_enhanced_fire_particles():
	# Create more intense fire effect with larger particles and more colors
	for i in range(20):  # More particles
		var particle = ColorRect.new()
		particle.name = "fire_particle_" + str(i)  # Name them so burn effect ignores them
		
		# Enhanced fire colors with more variety
		var fire_colors = [
			Color(1.0, 0.1, 0.0, 0.9),  # Deep red
			Color(1.0, 0.3, 0.0, 1.0),  # Red-orange
			Color(1.0, 0.5, 0.1, 0.8),  # Orange
			Color(1.0, 0.7, 0.2, 0.7),  # Yellow-orange
			Color(1.0, 0.9, 0.3, 0.6),  # Yellow
			Color(1.0, 1.0, 0.5, 0.5),  # Bright yellow
			Color(0.9, 0.9, 0.9, 0.4),  # White-hot
			Color(0.3, 0.3, 0.3, 0.6)   # Smoke
		]
		
		particle.color = fire_colors[i % fire_colors.size()]
		particle.size = Vector2(randf_range(3, 10), randf_range(6, 18))  # Larger particles
		particle.z_index = 300  # Make sure fire particles appear in front of everything
		
		# Start particles from various points on the card
		particle.position = Vector2(
			randf_range(-5, size.x + 5),
			randf_range(-10, size.y * 0.3)
		)
		
		add_child(particle)
		
		# More dramatic particle animation
		var particle_tween = create_tween()
		particle_tween.set_parallel(true)
		
		# Bigger, more dramatic movement
		var rise_distance = randf_range(40, 80)
		var sway_amount = randf_range(-25, 25)
		var duration = randf_range(1.0, 2.0)
		
		particle_tween.tween_property(particle, "position:y", particle.position.y - rise_distance, duration)
		particle_tween.tween_property(particle, "position:x", particle.position.x + sway_amount, duration)
		particle_tween.tween_property(particle, "modulate:a", 0.0, duration * 0.8)
		particle_tween.tween_property(particle, "scale:x", randf_range(0.3, 2.0), duration)
		particle_tween.tween_property(particle, "scale:y", randf_range(0.1, 1.2), duration)
		
		# More intense flickering
		var flicker_tween = create_tween()
		flicker_tween.set_loops()
		flicker_tween.tween_property(particle, "modulate:a", particle.color.a * 0.5, 0.05)
		flicker_tween.tween_property(particle, "modulate:a", particle.color.a, 0.05)
		
		# Stop flickering when particle fades
		particle_tween.tween_callback(flicker_tween.kill).set_delay(duration * 0.8)
		
		# Remove particle after animation
		particle_tween.tween_callback(particle.queue_free).set_delay(duration + 0.2)

func create_spark_effects():
	# Add sparking effects around the edges
	for i in range(8):
		var spark = ColorRect.new()
		spark.color = Color(1.0, 1.0, 0.3, 1.0)  # Bright yellow spark
		spark.size = Vector2(randf_range(1, 3), randf_range(1, 3))
		
		# Position sparks around the card edges
		var edge = i % 4
		match edge:
			0:  # Top edge
				spark.position = Vector2(randf_range(0, size.x), randf_range(-5, 5))
			1:  # Right edge
				spark.position = Vector2(randf_range(size.x-5, size.x+5), randf_range(0, size.y))
			2:  # Bottom edge
				spark.position = Vector2(randf_range(0, size.x), randf_range(size.y-5, size.y+5))
			3:  # Left edge
				spark.position = Vector2(randf_range(-5, 5), randf_range(0, size.y))
		
		add_child(spark)
		
		# Animate sparks flying outward
		var spark_tween = create_tween()
		spark_tween.set_parallel(true)
		
		var fly_direction = Vector2(randf_range(-30, 30), randf_range(-30, 30))
		spark_tween.tween_property(spark, "position", spark.position + fly_direction, 0.5)
		spark_tween.tween_property(spark, "modulate:a", 0.0, 0.5)
		spark_tween.tween_property(spark, "scale", Vector2(0.1, 0.1), 0.5)
		
		# Remove spark
		spark_tween.tween_callback(spark.queue_free).set_delay(0.6)

func create_fire_particles():
	# Create more realistic fire effect using colored rectangles
	for i in range(12):
		var particle = ColorRect.new()
		
		# Varied fire colors
		var fire_colors = [
			Color(1.0, 0.2, 0.0, 0.8),  # Deep red
			Color(1.0, 0.4, 0.0, 0.9),  # Red-orange
			Color(1.0, 0.6, 0.1, 0.7),  # Orange
			Color(1.0, 0.8, 0.2, 0.6),  # Yellow-orange
			Color(1.0, 1.0, 0.4, 0.5),  # Yellow
			Color(0.9, 0.9, 0.9, 0.3)   # White-hot
		]
		
		particle.color = fire_colors[i % fire_colors.size()]
		particle.size = Vector2(randf_range(2, 6), randf_range(4, 12))
		
		# Start particles from the top edge and spread across width
		particle.position = Vector2(
			randf_range(0, size.x - particle.size.x),
			randf_range(-5, 15)  # Start near the top
		)
		
		add_child(particle)
		
		# Animate particles with more natural fire movement
		var particle_tween = create_tween()
		particle_tween.set_parallel(true)
		
		# Rise and sway like real fire
		var rise_distance = randf_range(30, 60)
		var sway_amount = randf_range(-15, 15)
		var duration = randf_range(0.8, 1.5)
		
		particle_tween.tween_property(particle, "position:y", particle.position.y - rise_distance, duration)
		particle_tween.tween_property(particle, "position:x", particle.position.x + sway_amount, duration)
		particle_tween.tween_property(particle, "modulate:a", 0.0, duration * 0.7)
		particle_tween.tween_property(particle, "scale:x", randf_range(0.5, 1.5), duration)
		particle_tween.tween_property(particle, "scale:y", randf_range(0.2, 0.8), duration)
		
		# Add some flickering
		var flicker_tween = create_tween()
		flicker_tween.set_loops()
		flicker_tween.tween_property(particle, "modulate:a", particle.color.a * 0.7, 0.1)
		flicker_tween.tween_property(particle, "modulate:a", particle.color.a, 0.1)
		
		# Stop flickering when particle fades
		particle_tween.tween_callback(flicker_tween.kill).set_delay(duration * 0.7)
		
		# Remove particle after animation
		particle_tween.tween_callback(particle.queue_free).set_delay(duration + 0.1)

func remove_burned_card():
	# Clean up and remove the card
	print("🔥 Card fully burned:", card_name)
	queue_free()

func mark_as_played():
	# Visual indicator that card is in battlefield and ready for execution
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	scale = Vector2(0.7, 0.7)
	modulate = Color(0.9, 0.9, 0.9, 1.0)
	print("🎯 Card marked as played in battlefield:", card_name)

func show_selected_for_targeting():
	# Visual indicator that this card is selected for target assignment
	var selected_style = $Panel.get_theme_stylebox("panel").duplicate()
	selected_style.border_color = Color(1.0, 1.0, 0.3, 1.0)  # Yellow border
	selected_style.border_width_left = 8
	selected_style.border_width_right = 8
	selected_style.border_width_top = 8
	selected_style.border_width_bottom = 8
	$Panel.add_theme_stylebox_override("panel", selected_style)
	
	# Add pulsing effect - store as instance variable so it can be properly killed
	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()
	pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(self, "modulate", Color(1.3, 1.3, 1.0, 1.0), 0.5)
	pulse_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)
	
	print("✨ Card selected for targeting:", card_name)

func hide_selected_for_targeting():
	# Remove selection visual indicators
	apply_rarity_styling()  # Reset to normal styling
	
	# Stop any tweens
	if rarity_tween and rarity_tween.is_valid():
		rarity_tween.kill()
	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()
	
	# Reset modulation
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	# Restart rarity effects
	start_rarity_effects()
	
	print("🔄 Card selection cleared:", card_name)

func show_target_assigned_feedback(enemy_name: String):
	# Show feedback that this card has been assigned to attack a specific enemy
	print("🎯 Card", card_name, "assigned to attack", enemy_name)
	
	# Create a temporary label to show the assignment
	var assignment_label = Label.new()
	assignment_label.text = "→ " + enemy_name
	assignment_label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.3, 1.0))
	assignment_label.add_theme_font_size_override("font_size", 12)
	assignment_label.position = Vector2(5, -20)
	assignment_label.z_index = 200
	add_child(assignment_label)
	
	# Fade out the label after a few seconds
	var fade_tween = create_tween()
	fade_tween.tween_property(assignment_label, "modulate:a", 0.0, 2.0).set_delay(2.0)
	fade_tween.tween_callback(assignment_label.queue_free).set_delay(4.0)

func reset_from_battlefield():
	"""Reset card appearance when moving back from battlefield to hand"""
	print("🔄 Resetting card from battlefield:", card_name)
	
	# Reset visual state
	mouse_filter = Control.MOUSE_FILTER_PASS
	scale = original_scale
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	# Clear any target assignment labels
	clear_target_assignment_display()
	
	# Restart rarity effects
	start_rarity_effects()

func clear_target_assignment_display():
	"""Remove any target assignment visual indicators"""
	# Look for and remove assignment labels
	for child in get_children():
		if child.has_method("get_text") and child.get_text().begins_with("→"):
			child.queue_free()
			print("🗑️ Removed target assignment label")

# Creature management functions
func initialize_creature(health: int, attack: int):
	"""Initialize creature-specific properties"""
	if card_type == "CREATURE":
		max_health = health
		current_health = health
		attack_power = attack
		print("🐲 Creature initialized:", card_name, "HP:", health, "ATK:", attack)

func take_creature_damage(amount: int):
	"""Handle damage to creature cards"""
	if card_type != "CREATURE":
		return false
		
	current_health = max(0, current_health - amount)
	print("💔 Creature", card_name, "takes", amount, "damage. HP:", current_health, "/", max_health)
	
	if current_health <= 0:
		die()
		return true
	else:
		update_display()
		return false

func die():
	"""Handle creature death"""
	print("💀 Creature", card_name, "has died!")
	# Could add death animation here
	start_burning_animation()

func is_instant_cast() -> bool:
	"""Check if card should be cast instantly (only items that don't need targets)"""
	if card_type == "ITEM":
		# Only healing items that have no valid targets should be instant cast
		if description.to_lower().contains("heal") or description.to_lower().contains("restore"):
			return true  # Healing items execute instantly since no ally system exists
		else:
			return false  # Damage items need target selection
	# Spells always need target selection
	return false

func get_valid_targets(enemies: Array) -> Array:
	"""Get valid targets based on card type"""
	match card_type:
		"SPELL":
			# Spells can target any alive enemy
			return enemies.filter(func(enemy): return enemy.current_health > 0)
		"ITEM":
			# Items behave differently based on their effect
			# For now, healing items target allies, damage items target enemies
			if description.to_lower().contains("heal") or description.to_lower().contains("restore"):
				# TODO: Add ally targeting when we have ally system
				return []  # For now, no valid targets for healing items
			else:
				# Damage items target enemies
				return enemies.filter(func(enemy): return enemy.current_health > 0)
		"CREATURE":
			# Creatures go to battlefield, don't need immediate targets
			return []
		_:
			return enemies.filter(func(enemy): return enemy.current_health > 0)

# Tooltip System Functions
func start_tooltip_timer():
	"""Start the timer for showing tooltip after delay"""
	if tooltip_timer:
		tooltip_timer.queue_free()
	
	tooltip_timer = Timer.new()
	tooltip_timer.wait_time = tooltip_delay
	tooltip_timer.one_shot = true
	add_child(tooltip_timer)
	
	tooltip_timer.timeout.connect(show_tooltip)
	tooltip_timer.start()

func cancel_tooltip_timer():
	"""Cancel the tooltip timer"""
	if tooltip_timer:
		tooltip_timer.queue_free()
		tooltip_timer = null

func show_tooltip():
	"""Show detailed card information tooltip"""
	if not is_hovered:
		return
	
	# Create tooltip popup
	tooltip_popup = Control.new()
	tooltip_popup.name = "CardTooltip"
	
	# Set up tooltip panel
	var tooltip_panel = Panel.new()
	tooltip_popup.add_child(tooltip_panel)
	
	# Tooltip style
	var tooltip_style = StyleBoxFlat.new()
	tooltip_style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	tooltip_style.border_width_left = 2
	tooltip_style.border_width_top = 2
	tooltip_style.border_width_right = 2
	tooltip_style.border_width_bottom = 2
	tooltip_style.border_color = Color(0.8, 0.8, 0.2, 1.0)
	tooltip_style.corner_radius_top_left = 8
	tooltip_style.corner_radius_top_right = 8
	tooltip_style.corner_radius_bottom_left = 8
	tooltip_style.corner_radius_bottom_right = 8
	tooltip_panel.add_theme_stylebox_override("panel", tooltip_style)
	
	# Set minimum and maximum widths for the tooltip
	var min_width = 200
	var max_width = 400
	
	# Create all labels first to measure their content
	var labels = []
	var label_texts = []
	var label_font_sizes = []
	
	# Collect all text content and font sizes
	label_texts.append(card_name)
	label_font_sizes.append(18)
	
	var type_text = card_type.capitalize()
	var info_text = "Cost: %d | Type: %s | %s" % [cost, type_text, rarity.capitalize()]
	label_texts.append(info_text)
	label_font_sizes.append(12)
	
	if card_type == "CREATURE":
		var stats_text = "Attack: %d | Health: %d/%d" % [attack_power, current_health, max_health]
		label_texts.append(stats_text)
		label_font_sizes.append(14)
	
	label_texts.append(description)
	label_font_sizes.append(12)
	
	# Calculate the required width based on content
	var required_width = min_width
	
	# Check each text's size to determine optimal width
	for i in range(label_texts.size()):
		var text = label_texts[i]
		var font_size = label_font_sizes[i]
		
		var font = ThemeDB.fallback_font
		if not font:
			continue
		
		# Calculate text width
		var text_size = font.get_string_size(
			text, 
			HORIZONTAL_ALIGNMENT_LEFT, 
			-1, 
			font_size
		)
		required_width = max(required_width, text_size.x + 20)  # Add padding
	
	# Clamp to our min/max bounds
	required_width = min(max_width, required_width)
	
	# Calculate height using estimated line heights with wrapping
	var content_width = required_width - 16  # Account for margins
	var total_height = 16  # Top and bottom margin
	
	for i in range(label_texts.size()):
		var text = label_texts[i]
		var font_size = label_font_sizes[i]
		
		var font = ThemeDB.fallback_font
		if not font:
			continue
		
		# Estimate wrapped text height
		var text_width = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		var lines_needed = max(1, ceil(text_width / float(content_width)))
		var line_height = font.get_height(font_size)
		
		total_height += lines_needed * line_height + 4  # Add separation
	
	# Create the container now with calculated dimensions
	var margin_container = MarginContainer.new()
	tooltip_panel.add_child(margin_container)
	margin_container.add_theme_constant_override("margin_left", 8)
	margin_container.add_theme_constant_override("margin_right", 8)
	margin_container.add_theme_constant_override("margin_top", 8)
	margin_container.add_theme_constant_override("margin_bottom", 8)
	
	var tooltip_container = VBoxContainer.new()
	tooltip_container.add_theme_constant_override("separation", 4)
	margin_container.add_child(tooltip_container)
	
	# Now create the actual labels
	var label_index = 0
	
	# Card name (larger, colored)
	var name_label = Label.new()
	name_label.text = label_texts[label_index]
	name_label.add_theme_font_size_override("font_size", label_font_sizes[label_index])
	name_label.add_theme_color_override("font_color", get_rarity_color())
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.custom_minimum_size.x = content_width
	tooltip_container.add_child(name_label)
	label_index += 1
	
	# Cost and type info
	var info_label = Label.new()
	info_label.text = label_texts[label_index]
	info_label.add_theme_font_size_override("font_size", label_font_sizes[label_index])
	info_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1.0))
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_label.custom_minimum_size.x = content_width
	tooltip_container.add_child(info_label)
	label_index += 1
	
	# Stats for creatures
	if card_type == "CREATURE":
		var stats_label = Label.new()
		stats_label.text = label_texts[label_index]
		stats_label.add_theme_font_size_override("font_size", label_font_sizes[label_index])
		stats_label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.8, 1.0))
		stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		stats_label.custom_minimum_size.x = content_width
		tooltip_container.add_child(stats_label)
		label_index += 1
	
	# Description
	var desc_label = Label.new()
	desc_label.text = label_texts[label_index]
	desc_label.add_theme_font_size_override("font_size", label_font_sizes[label_index])
	desc_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.custom_minimum_size.x = content_width
	tooltip_container.add_child(desc_label)
	
	# Set final tooltip size
	var final_size = Vector2(required_width, total_height)
	tooltip_panel.size = final_size
	tooltip_popup.size = final_size
	
	# Position tooltip (above card, adjust if near screen edge)
	var tooltip_pos = global_position
	tooltip_pos.y -= final_size.y + 10  # Above card with gap
	
	# Adjust if tooltip would go off screen
	var viewport_size = get_viewport().get_visible_rect().size
	if tooltip_pos.y < 0:
		tooltip_pos.y = global_position.y + size.y + 10  # Below card instead
	if tooltip_pos.x + final_size.x > viewport_size.x:
		tooltip_pos.x = viewport_size.x - final_size.x - 10
	if tooltip_pos.x < 0:
		tooltip_pos.x = 10
	
	tooltip_popup.position = tooltip_pos
	tooltip_popup.z_index = 1000  # Above everything
	
	# Add to scene tree
	get_tree().current_scene.add_child(tooltip_popup)
	
	# Fade in animation
	tooltip_popup.modulate = Color(1, 1, 1, 0)
	var fade_tween = create_tween()
	fade_tween.tween_property(tooltip_popup, "modulate", Color(1, 1, 1, 1), 0.2)

func hide_tooltip():
	"""Hide the tooltip with fade out animation"""
	if tooltip_popup and is_instance_valid(tooltip_popup):
		var fade_tween = create_tween()
		fade_tween.tween_property(tooltip_popup, "modulate", Color(1, 1, 1, 0), 0.15)
		fade_tween.tween_callback(tooltip_popup.queue_free)
		tooltip_popup = null

func get_rarity_color() -> Color:
	"""Get color based on card rarity"""
	match rarity.to_lower():
		"common":
			return Color(0.8, 0.8, 0.8, 1.0)
		"uncommon":
			return Color(0.3, 1.0, 0.3, 1.0)
		"rare":
			return Color(0.3, 0.6, 1.0, 1.0)
		"epic":
			return Color(1.0, 0.3, 1.0, 1.0)
		"legendary":
			return Color(1.0, 0.8, 0.3, 1.0)
		_:
			return Color(1.0, 1.0, 1.0, 1.0)

func get_spell_damage_value() -> int:
	"""Extract damage value from spell descriptions"""
	match card_name.to_lower():
		"ice shard":
			return 3
		"lightning bolt":
			return 8
		"dragon's fury":
			return 12
		"phoenix rebirth":
			return 15
		_:
			# Try to extract number from description
			return extract_damage_from_description()

func get_item_damage_value() -> int:
	"""Extract damage value from damage item descriptions"""
	# Try to extract number from description for damage items
	return extract_damage_from_description()

func get_item_heal_value() -> int:
	"""Extract healing value from healing item descriptions"""
	match card_name.to_lower():
		"healing potion":
			return 6
		_:
			# Try to extract number from description
			return extract_heal_from_description()

func extract_damage_from_description() -> int:
	"""Extract damage number from description text"""
	var desc_lower = description.to_lower()
	
	# Look for "deals X damage" pattern
	var regex = RegEx.new()
	regex.compile("deals?\\s+(\\d+)\\s+damage")
	var result = regex.search(desc_lower)
	if result:
		return int(result.get_string(1))
	
	# Look for just numbers followed by damage
	regex.compile("(\\d+)\\s+damage")
	result = regex.search(desc_lower)
	if result:
		return int(result.get_string(1))
	
	# Default fallback
	return 1

func extract_heal_from_description() -> int:
	"""Extract healing number from description text"""
	var desc_lower = description.to_lower()
	
	# Look for "restore X health" pattern
	var regex = RegEx.new()
	regex.compile("restore\\s+(\\d+)\\s+health")
	var result = regex.search(desc_lower)
	if result:
		return int(result.get_string(1))
	
	# Look for "heal X" pattern
	regex.compile("heal\\s+(\\d+)")
	result = regex.search(desc_lower)
	if result:
		return int(result.get_string(1))
	
	# Default fallback
	return 1
