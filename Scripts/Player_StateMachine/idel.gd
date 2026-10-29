class_name IdlePlayerState
extends State

@export var player : CharacterBody3D
@export var head : Node3D
@export var camra : Camera3D
@export var target_fov : float = 75


func enter() -> void:
	pass


func update(delta: float) -> void:
	var input_dir := Input.get_vector(
		"player_left",
		"player_right",
		"player_forward",
		"player_back"
	)

	# Start moving
	if input_dir != Vector2.ZERO:
		if Input.is_action_pressed("player_sprint"):
			transition.emit("Sprint")
		else:
			transition.emit("Move")
	
	camra.fov = lerp(camra.fov,target_fov,delta * 4 )
