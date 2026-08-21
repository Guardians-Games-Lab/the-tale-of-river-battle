extends TextureButton

var _tocando: bool = false

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		accept_event()
		if event.pressed and not disabled:
			_tocando = true
		elif not event.pressed and _tocando:
			_tocando = false
			if not disabled:
				pressed.emit()
