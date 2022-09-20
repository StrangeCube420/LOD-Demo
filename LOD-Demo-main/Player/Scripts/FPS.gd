extends Label

onready var label = self

func _process(delta):
	label.text = str("FPS : ", Engine.get_frames_per_second(), ", Frame Time : ", delta)
