class_name MovePlayerState
extends State

@onready var note_hand: Marker3D = %NoteHand
@onready var footsteps: AudioStreamPlayer3D = %Footsteps

@export var player : CharacterBody3D
@export var head : Node3D
@export var move_speed : float = 7.0
@export var BOB_FREQ : float = 2.0
@export var BOB_AMP : float = 0.08
@export var t_bob : float = 0.0
@export var camra : Camera3D
@export var target_fov : float = 75

var note_sway_amout : float = 0.1
var last_bob_position_x : float = 0.0
var last_bob_direction : int = 0


func update(delta: float) -> void:
	var input_dir := Input.get_vector(
		"player_left",
		"player_right",
		"player_forward",
		"player_back"
	)

	# No movement → Idle
	if input_dir == Vector2.ZERO:
		transition.emit("Idel")

	# Sprint pressed → Sprint
	if Input.is_action_pressed("player_sprint"):
		transition.emit("Sprint")

	var move_dir := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if move_dir:
		player.velocity.x = move_dir.x * move_speed
		player.velocity.z = move_dir.z * move_speed
	else:
		player.velocity.x = 0.0
		player.velocity.z = 0.0
	
	#headbob
	t_bob += delta * player.velocity.length() * float(player.is_on_floor())
	camra.transform.origin = _headbob(t_bob)
	play_footstep()
	
	#fov
	camra.fov = lerp(camra.fov,target_fov,delta * 4 )
	
	#note sway
	note_tilt_and_sway(input_dir,delta)
	
	

	
func _headbob(time) -> Vector3:
		var pos = Vector3.ZERO
		pos.y = sin(time * BOB_FREQ)*BOB_AMP
		pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
		return pos
		
func note_tilt_and_sway(input_dir : Vector2 , delta : float) -> void:
	if note_hand:
		note_hand.rotation.x = lerp(note_hand.rotation.x, -input_dir.y * note_sway_amout , delta* 10)
		note_hand.rotation.z = lerp(note_hand.rotation.z, -input_dir.x * note_sway_amout , delta* 10)
		
		
func play_footstep() -> void:
	if not player.is_on_floor():
		return
	if player.inside_bus:
		return
	var bob_position_x = camra.transform.origin.x
	var bob_direction = sign(bob_position_x - last_bob_position_x)

	if bob_direction != 0 and bob_direction != last_bob_direction and last_bob_direction != 0:
		footsteps.play()

	last_bob_direction = bob_direction
	last_bob_position_x = bob_position_x
	
		
		
