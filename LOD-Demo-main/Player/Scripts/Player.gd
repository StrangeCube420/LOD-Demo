extends KinematicBody

var speed = 21
const accel_land = 7
const accel_air = 1
onready var accel = accel_land
var gravity = 9.8
var jump = 5

onready var cur_state = states.idle

enum states {
	idle, #the normal state
	dead
}

var cam_accel = 40
var mouse_sense = 0.8
var snap

var direction = Vector3()
var velocity = Vector3()
var gravity_vec = Vector3()
var movement = Vector3()

onready var head = $Head

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))

func _physics_process(delta):
	match cur_state:
		states.idle:
			direction = Vector3.ZERO
			var h_rot = global_transform.basis.get_euler().y
			var f_input = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
			var h_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
			direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
			
			if Input.is_action_just_pressed("ui_cancel"):
				get_tree().quit()
			
			if is_on_floor():
				snap = -get_floor_normal()
				accel = accel_land
				gravity_vec = Vector3.ZERO
			else:
				snap = Vector3.DOWN
				accel = accel_air
				gravity_vec += Vector3.DOWN * gravity * delta
				
			if Input.is_action_just_pressed("jump") and is_on_floor():
				snap = Vector3.ZERO
				gravity_vec = Vector3.UP * jump
			
			velocity = velocity.linear_interpolate(direction * speed, accel * delta)
			movement = velocity + gravity_vec
			
			movement = move_and_slide_with_snap(movement, snap, Vector3.UP)
		states.dead:
			pass
