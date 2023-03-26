extends RigidBody3D

func _ready() -> void:
	freeze = true
	
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event = event as InputEventKey
		if key_event.is_action_pressed("ui_accept"):
			freeze = false
