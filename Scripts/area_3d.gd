extends Area3D

var cue_ball_start_position: Vector3
var cue_ball_node: Node3D

func _ready():
	# Get cue ball directly from group
	var cue_balls = get_tree().get_nodes_in_group("cue_ball")
	if cue_balls.size() > 0:
		cue_ball_node = cue_balls[0]
		cue_ball_start_position = cue_ball_node.global_transform.origin
	else:
		push_warning("No cue ball found in scene!")

	# setup Area3D monitoring
	monitorable = true
	monitoring = true

	# IMPORTANT: connect the signal in code
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	# remove normal balls
	if body.is_in_group("normal_balls"):
		body.queue_free()
		print("Removed ball:", body.name)

	# reset cue ball
	elif body.is_in_group("cue_ball") and cue_ball_node:
		cue_ball_node.global_transform.origin = cue_ball_start_position
		cue_ball_node.linear_velocity = Vector3.ZERO
		cue_ball_node.angular_velocity = Vector3.ZERO
		print("Cue ball respawned at starting position")

 
