extends Spatial

export var enabled = true

export(int, 0, 2000, 1) var lod_0_max_distance = 80

export(int, 0, 2000, 1) var lod_1_max_distance = 150

export(int, 0, 2000, 1) var lod_2_max_distance = 250

export (float, 0.25, 15, 0.05) var refresh_rate = 0.25

var timer = 0.0

var lods = [null, null, null]

var collision = []

func _ready() -> void:
	for node in self.get_children():
		if "-lod0" in node.name:
			lods[0] = node
		elif "-lod1" in node.name:
			lods[1] = node
		elif "-lod2" in node.name:
			lods[2] = node
	
	if has_node("Collision"):
		for shape in get_node("Collision").get_children():
			if shape is CollisionShape:
				collision.append(shape)
	
	randomize()
	timer += rand_range(0, refresh_rate)

func _physics_process(delta: float) -> void:
	if not enabled:
		return
	
	var camera := get_viewport().get_camera()
	if camera == null:
		return
	
	if timer <= refresh_rate:
		timer += delta
		return
	
	timer = 0.0
	
	var distance := camera.global_transform.origin.distance_to(global_transform.origin)
	var lod : int
	if distance < lod_0_max_distance:
		lod = 0
	elif distance < lod_1_max_distance:
		lod = 1
	elif distance < lod_2_max_distance:
		lod = 2
	else:
		lod = 3
	
	if lods != [null, null, null]:
		for node in lods:
			if node == null:
				continue
			node.visible = false
		if lod != 3:
			if lods[lod] != null:
				lods[lod].visible = true
	
	if collision != []:
		for shape in collision:
			shape.disabled = lod > 0
