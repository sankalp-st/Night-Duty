# ProtoController v1.0 by Brackeys
# CC0 License
# Intended for rapid prototyping of first-person games.
# Happy prototyping!

extends CharacterBody3D

@export_group("Speeds")
## Look around rotation speed.
@export var look_speed : float = 0.001
## Speed of jump.
@export var jump_velocity : float = 4.5


@export_group("Input Actions")
## Name of Input Action to move Left.
@export var input_left : String = "player_left"
## Name of Input Action to move Right.
@export var input_right : String = "player_right"
## Name of Input Action to move Forward.
@export var input_forward : String = "player_forward"
## Name of Input Action to move Backward.
@export var input_back : String = "player_back"
## Name of Input Action to Jump.
@export var input_jump : String = "player_jump"
## Name of Input Action to Sprint.
@export var input_sprint : String = "player_sprint"

var mouse_captured : bool = false
var look_rotation : Vector2
var move_speed : float = 0.0
var freeflying : bool = false
var inside_bus : bool = false
@export var camra : Camera3D

## IMPORTANT REFERENCES
@onready var head: Node3D = $Head
@onready var collider: CollisionShape3D = $Collider
@onready var interactable_collider: CollisionShape3D = $interactable_check/CollisionShape3D
@onready var interaction_raycast: RayCast3D = $Head/Eye/Camera3D/InteractionRaycast

# bullets
var bullet = load("res://Scenes/bullets.tscn")
var instance


func _ready() -> void:
	#global_position = SaveLoad.SaveFileData.player_position
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x

func _input(event: InputEvent) -> void:
	# Mouse capturing
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()
	# Look around
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)

func _physics_process(delta: float) -> void:
	#print(camra.fov)
	# Apply gravity to velocity
	if not is_on_floor():
		velocity.y -= 20.0 * delta
	else:
		if velocity.y < 0:
			velocity.y = 0

	# Apply jumping
	if Input.is_action_just_pressed(input_jump) and is_on_floor():
		velocity.y = jump_velocity
	move_and_slide()



## Rotate us to look around.
## Base of controller rotates around y (left/right). Head rotates around x (up/down).
## Modifies look_rotation based on rot_input, then resets basis and rotates by look_rotation.
func rotate_look(rot_input : Vector2):
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	transform.basis = Basis()
	rotate_y(look_rotation.y)
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)


func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false
	
func in_bus() -> void:
	inside_bus = true
	# Disable player interactions
	# Disable interactable detection
	interactable_collider.set_deferred("disabled", true)
	# Hide and disable player
	visible = false
	set_physics_process(false)
	collider.set_deferred("disabled", true)


func out_bus() -> void:
	inside_bus = false
	# Re-enable player
	visible = true
	set_physics_process(true)
	collider.set_deferred("disabled", false)
	interactable_collider.set_deferred("disabled", false)
	
