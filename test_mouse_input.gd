extends Control

# Simple test script to verify mouse input is working
func _ready():
	print("🧪 MOUSE INPUT TEST STARTED")
	
	# Set up this control to receive mouse input
	mouse_filter = Control.MOUSE_FILTER_PASS
	gui_input.connect(_on_test_gui_input)
	mouse_entered.connect(_on_test_mouse_entered)
	mouse_exited.connect(_on_test_mouse_exited)
	
	# Set a visible size and position
	size = Vector2(200, 100)
	position = Vector2(100, 100)
	
	# Add a colored background to make it visible
	add_theme_constant_override("margin_left", 10)
	add_theme_constant_override("margin_right", 10)
	add_theme_constant_override("margin_top", 10)
	add_theme_constant_override("margin_bottom", 10)
	
	print("🧪 Test control setup complete - size:", size, "position:", position)

func _on_test_gui_input(event):
	print("🧪 TEST: GUI input received - Event:", event)
	
	if event is InputEventMouseButton:
		if event.pressed:
			print("🧪 TEST: Mouse button pressed -", event.button_index)
		else:
			print("🧪 TEST: Mouse button released -", event.button_index)

func _on_test_mouse_entered():
	print("🧪 TEST: Mouse entered test area")

func _on_test_mouse_exited():
	print("🧪 TEST: Mouse exited test area")
