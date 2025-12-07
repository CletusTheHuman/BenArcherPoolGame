extends RigidBody3D

@onready var camera = get_viewport().get_camera_3d()

var move_speed = 0.5
var rotation_speed = 0.5

var max_shot_force = 100.0
var shot_charge_speed = 10.0
var shot_force = 0.0
var charging_shot = false

var still_threshold := 0.05
var still_time_required := 0.4
var ball_still_timer := 0.0

var start_transform: Transform3D   # <-- store editor position

func _ready():
	contact_monitor = true
	max_contacts_reported = 10

	# Save whatever position/rotation the cue has in the editor
	start_transform = global_transform

func _process(delta):
	if not freeze and camera:
		var cam_forward = -camera.global_transform.basis.z
		cam_forward.y = 0
		cam_forward = cam_forward.normalized()

		var cam_right = camera.global_transform.basis.x
		cam_right.y = 0
		cam_right = cam_right.normalized()

		if Input.is_action_pressed("move_forward"):
			global_translate(cam_forward * move_speed * delta)
		if Input.is_action_pressed("move_back"):
			global_translate(-cam_forward * move_speed * delta)
		if Input.is_action_pressed("move_left"):
			global_translate(-cam_right * move_speed * delta)
		if Input.is_action_pressed("move_right"):
			global_translate(cam_right * move_speed * delta)
	
	if Input.is_action_pressed("rotate_left"):
		rotate_y(rotation_speed * delta)
	if Input.is_action_pressed("rotate_right"):
		rotate_y(-rotation_speed * delta)

	if Input.is_action_just_pressed("shoot"):
		charging_shot = true
		shot_force = 0.0

	if charging_shot and Input.is_action_pressed("shoot"):
		shot_force += shot_charge_speed * delta
		shot_force = min(shot_force, max_shot_force)

	if Input.is_action_just_released("shoot") and charging_shot:
		var dir = transform.basis.z.normalized()
		apply_central_impulse(dir * shot_force)
		charging_shot = false
		shot_force = 0.0

	for body in get_colliding_bodies():
		if body.is_in_group("cue_ball"):
			freeze = true

	_reset_after_shot(delta)

func _reset_after_shot(delta):
	if not freeze:
		ball_still_timer = 0.0
		return

	# Check cue ball + all object balls
	var balls: Array = []
	balls.append_array(get_tree().get_nodes_in_group("normal_balls"))

	var cue_ball := get_tree().get_first_node_in_group("cue_ball") as RigidBody3D
	if cue_ball:
		balls.append(cue_ball)

	var all_still := true

	for b in balls:
		var rb := b as RigidBody3D
		if rb == null:
			continue
		if rb.linear_velocity.length() > still_threshold:
			all_still = false
			break

	if all_still:
		ball_still_timer += delta
		if ball_still_timer >= still_time_required:
			global_transform = start_transform
			linear_velocity = Vector3.ZERO
			angular_velocity = Vector3.ZERO
			freeze = false
			ball_still_timer = 0.0
	else:
		ball_still_timer = 0.0

func _input(event):
	if event.is_action_pressed("save"):
		save_game_state()
		print("Game Saved")

func save_game_state():
	var balls = get_tree().get_nodes_in_group("balls")
	SaveGame.save_balls(balls)
