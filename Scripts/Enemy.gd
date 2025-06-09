extends Control
class_name Enemy

var enemy_name: String = "Fire Dummy"
var max_health: int = 20
var current_health: int = 20
var statuses = {}
var status_effects_tween: Tween
var original_scale: Vector2

func _ready():
	# Initialize original scale
	original_scale = scale
	
	update_display()
	
	# Set up mouse input for targeting system
	mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Make sure all child controls don't block mouse input
	setup_mouse_filters()
	
	# Add visual debugging for mouse events
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func setup_mouse_filters():
	# Ensure all child nodes pass mouse events to the enemy
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

func take_damage(amount: int):
	print(enemy_name, "takes", amount, "damage.")
	current_health -= amount
	current_health = max(current_health, 0)
	update_display()
	
	# Enhanced damage animation
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.1)
	tween.tween_property(self, "scale", original_scale * 1.1, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	tween.tween_property(self, "scale", original_scale, 0.2)
	
	if current_health <= 0:
		print(enemy_name, "has been defeated!")
		death_animation()

func death_animation():
	print("💀 Starting death animation for:", enemy_name)
	
	# Disable mouse input immediately when enemy dies
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Stop any existing status effect animations
	if status_effects_tween:
		status_effects_tween.kill()
	
	# Create death particles before the animation
	create_death_particles()
	
	# Enhanced death animation
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade to gray and more transparent
	tween.tween_property(self, "modulate", Color(0.3, 0.3, 0.3, 0.2), 1.2)
	
	# Rotate and scale down
	tween.tween_property(self, "rotation", deg_to_rad(90), 1.2)
	tween.tween_property(self, "scale", original_scale * 0.8, 1.2)
	
	print("💀", enemy_name, "death animation complete - mouse input disabled")

func create_death_particles():
	"""Create dramatic death particle effects"""
	print("💀 Creating death particles for:", enemy_name)
	
	# Create multiple particle groups for death effect
	var particle_count = 15
	var enemy_center = global_position + size / 2
	
	# Death particle colors
	var death_colors = [
		Color(0.8, 0.2, 0.2, 0.9),  # Dark red
		Color(0.6, 0.6, 0.6, 0.8),  # Gray
		Color(0.3, 0.3, 0.3, 0.7),  # Dark gray
		Color(0.9, 0.9, 0.9, 0.6),  # Light gray (soul effect)
		Color(0.5, 0.1, 0.1, 0.8),  # Blood red
	]
	
	for i in range(particle_count):
		var particle = ColorRect.new()
		get_parent().add_child(particle)  # Add to parent so it's not affected by enemy rotation
		
		# Random size for variety
		var particle_size = randf_range(3, 8)
		particle.size = Vector2(particle_size, particle_size)
		particle.color = death_colors[i % death_colors.size()]
		particle.z_index = 500  # Above everything else
		
		# Start position at enemy center with slight randomness
		particle.global_position = enemy_center + Vector2(
			randf_range(-size.x/4, size.x/4),
			randf_range(-size.y/4, size.y/4)
		)
		
		# Animate particle with random trajectory
		var particle_tween = create_tween()
		particle_tween.set_parallel(true)
		
		# Random direction and distance
		var end_position = particle.global_position + Vector2(
			randf_range(-80, 80),
			randf_range(-60, -20)  # Mostly upward
		)
		
		# Animate movement, rotation, and fade
		particle_tween.tween_property(particle, "global_position", end_position, randf_range(1.0, 2.0))
		particle_tween.tween_property(particle, "rotation", randf_range(-PI, PI), randf_range(0.8, 1.5))
		particle_tween.tween_property(particle, "modulate:a", 0.0, randf_range(1.2, 2.2))
		particle_tween.tween_property(particle, "scale", Vector2.ZERO, randf_range(1.0, 1.8))
		
		# Clean up particle after animation
		particle_tween.tween_callback(particle.queue_free).set_delay(2.5)

func apply_status(status: String, turns: int):
	print(enemy_name, "is afflicted with", status, "for", turns, "turn(s).")
	statuses[status] = turns
	update_display()
	start_status_effects()

func start_status_effects():
	# Stop any existing status effect animations
	if status_effects_tween:
		status_effects_tween.kill()
	
	# Reset modulation
	if not has_status_effects():
		$Panel.modulate = Color.WHITE
		return
	
	# Apply visual effects based on active statuses
	if statuses.has("Burn"):
		start_burn_effect()
	elif statuses.has("Frozen"):
		start_freeze_effect()
	elif statuses.has("Poison"):
		start_poison_effect()
	else:
		# Default status effect glow
		start_generic_status_effect()

func start_burn_effect():
	# Flickering red-orange effect
	status_effects_tween = create_tween()
	status_effects_tween.set_loops()
	status_effects_tween.tween_property($Panel, "modulate", Color(1.5, 0.8, 0.6, 1.0), 0.3)
	status_effects_tween.tween_property($Panel, "modulate", Color(1.2, 0.5, 0.3, 1.0), 0.3)
	status_effects_tween.tween_property($Panel, "modulate", Color(1.8, 1.0, 0.4, 1.0), 0.2)

func start_freeze_effect():
	# Steady blue-white effect
	status_effects_tween = create_tween()
	status_effects_tween.set_loops()
	status_effects_tween.tween_property($Panel, "modulate", Color(0.7, 0.9, 1.3, 1.0), 1.0)
	status_effects_tween.tween_property($Panel, "modulate", Color(0.8, 0.95, 1.2, 1.0), 1.0)

func start_poison_effect():
	# Pulsing green effect
	status_effects_tween = create_tween()
	status_effects_tween.set_loops()
	status_effects_tween.tween_property($Panel, "modulate", Color(0.7, 1.3, 0.7, 1.0), 0.8)
	status_effects_tween.tween_property($Panel, "modulate", Color(0.9, 1.1, 0.9, 1.0), 0.8)

func start_generic_status_effect():
	# Purple pulsing for other effects
	status_effects_tween = create_tween()
	status_effects_tween.set_loops()
	status_effects_tween.tween_property($Panel, "modulate", Color(1.2, 1.0, 1.3, 1.0), 1.0)
	status_effects_tween.tween_property($Panel, "modulate", Color(1.0, 1.0, 1.0, 1.0), 1.0)

func has_status_effects() -> bool:
	return statuses.size() > 0

func heal(amount: int):
	current_health = min(current_health + amount, max_health)
	print(enemy_name, "heals", amount, "HP.")
	update_display()
	
	# Enhanced heal animation
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(0.7, 1.3, 0.7, 1.0), 0.2)
	tween.tween_property(self, "scale", original_scale * 1.05, 0.2)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	tween.tween_property(self, "scale", original_scale, 0.3)

func update_display():
	# Store original scale if not set
	if original_scale == Vector2.ZERO:
		original_scale = scale
		
	$VBoxContainer/EnemyNameLabel.text = enemy_name
	$VBoxContainer/HealthLabel.text = "HP: %d / %d" % [current_health, max_health]
	
	# Update health bar color based on health percentage
	var health_percentage = float(current_health) / float(max_health)
	var health_label = $VBoxContainer/HealthLabel
	if health_percentage > 0.6:
		health_label.modulate = Color(0.7, 1.0, 0.7, 1.0)  # Green
	elif health_percentage > 0.3:
		health_label.modulate = Color(1.0, 1.0, 0.7, 1.0)  # Yellow
	else:
		health_label.modulate = Color(1.0, 0.7, 0.7, 1.0)  # Red
	
	# Update status effects display with colors
	update_status_display()

func update_status_display():
	var status_text = ""
	var status_label = $VBoxContainer/StatusContainer/StatusLabel
	
	if statuses.size() > 0:
		status_text = "Status Effects:\n"
		for status in statuses:
			var turns = statuses[status]
			# Don't use BBCode markup, just append the status name
			status_text += "%s (%d turns)\n" % [status, turns]
		
		# Set label color based on primary status
		var primary_status = statuses.keys()[0]
		status_label.modulate = get_status_color(primary_status)
	else:
		status_text = "No Status Effects"
		status_label.modulate = Color(0.8, 0.8, 0.8, 1.0)
	
	status_label.text = status_text

func get_status_color(status: String) -> Color:
	match status.to_lower():
		"burn":
			return Color(1.0, 0.6, 0.3, 1.0)  # Orange-red
		"frozen":
			return Color(0.6, 0.8, 1.0)  # Light blue
		"poison":
			return Color(0.6, 1.0, 0.6)  # Light green
		_:
			return Color(0.9, 0.7, 1.0)  # Light purple

func get_status_color_code(status: String) -> String:
	# For rich text formatting (if we want to use RichTextLabel later)
	match status.to_lower():
		"burn":
			return "[color=orange]"
		"frozen":
			return "[color=cyan]"
		"poison":
			return "[color=lime]"
		_:
			return "[color=purple]"

# Visual targeting system
func show_targeting_highlight():
	# Add a bright pulsing border to indicate this enemy can be targeted
	var highlight_tween = create_tween()
	highlight_tween.set_loops()
	highlight_tween.tween_property($Panel, "modulate", Color(1.0, 1.0, 0.3, 1.0), 0.3)  # Bright yellow
	highlight_tween.tween_property($Panel, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3)

func hide_targeting_highlight():
	# Reset to normal appearance or current status effect
	if status_effects_tween:
		status_effects_tween.kill()
	
	$Panel.modulate = Color.WHITE
	
	# Restart status effects if any exist
	if has_status_effects():
		start_status_effects()

func show_target_selected_effect():
	# Brief flash to show this enemy was selected
	var flash_tween = create_tween()
	flash_tween.tween_property($Panel, "modulate", Color(2.0, 2.0, 0.5, 1.0), 0.1)  # Bright flash
	flash_tween.tween_property($Panel, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)
	
	# Restart status effects after flash
	flash_tween.tween_callback(func():
		if has_status_effects():
			start_status_effects()
	)

func show_target_assigned_effect():
	# Show feedback that this enemy has been assigned as a target
	print("🎯 Enemy", enemy_name, "assigned as target")
	
	# Create a brief glow effect
	var glow_tween = create_tween()
	glow_tween.set_parallel(true)
	glow_tween.tween_property($Panel, "modulate", Color(1.5, 1.5, 0.3, 1.0), 0.3)
	glow_tween.tween_property(self, "scale", original_scale * 1.1, 0.3)
	
	# Return to normal
	glow_tween.tween_property($Panel, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3).set_delay(0.3)
	glow_tween.tween_property(self, "scale", original_scale, 0.3).set_delay(0.3)
	
	# Restart status effects after assignment feedback
	glow_tween.tween_callback(func():
		if has_status_effects():
			start_status_effects()
	).set_delay(0.6)

func _on_gui_input(event):
	# Don't process input if enemy is dead
	if current_health <= 0:
		return
		
	print("🖱️ Enemy GUI input received:", enemy_name, "Event:", event)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("🎯 Enemy LEFT CLICK detected:", enemy_name)
	# Let the event bubble up to Main.gd for handling

func _on_mouse_entered():
	# Don't show hover effects if enemy is dead
	if current_health <= 0:
		return
		
	print("Enemy mouse entered:", enemy_name)
	# Add visual feedback for debugging
	var panel = get_node("Panel")
	if panel:
		var style = panel.get_theme_stylebox("panel").duplicate()
		style.border_color = Color.GREEN
		style.border_width_left = 5
		style.border_width_top = 5
		style.border_width_right = 5
		style.border_width_bottom = 5
		panel.add_theme_stylebox_override("panel", style)

func _on_mouse_exited():
	# Don't show hover effects if enemy is dead
	if current_health <= 0:
		return
		
	print("Enemy mouse exited:", enemy_name)
	# Reset visual feedback
	var panel = get_node("Panel")
	if panel:
		var style = panel.get_theme_stylebox("panel").duplicate()
		style.border_color = Color(0.6, 0.3, 0.3, 1)
		style.border_width_left = 3
		style.border_width_top = 3
		style.border_width_right = 3
		style.border_width_bottom = 3
		panel.add_theme_stylebox_override("panel", style)
