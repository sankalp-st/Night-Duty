extends Node

enum InteractionType {
	DEFAULT,
	ITEM,
	NOTE,
	BUTTON,
	BUS
}

@export var object_ref : Node3D
@export var interaction_type : InteractionType = InteractionType.DEFAULT
@export var item_data: ItemData

var can_interact : bool = true
var is_interacting : bool = false
var player_hand : Marker3D

#signals
signal item_collected(item:Node)
signal note_collected(node:Node3D)
signal button_pressed
signal bus_interact

func _ready() -> void:
	return
	
func preInteract(hand) -> void:
	is_interacting = true
	match interaction_type:
		InteractionType.DEFAULT:
			player_hand = hand
	
func interact() -> void:
	if not can_interact:
		return
	match interaction_type:
		InteractionType.DEFAULT:
			_default_interact()
		InteractionType.ITEM:
			_collect_item()
		InteractionType.NOTE:
			_collect_note()
		InteractionType.BUTTON:
			_button_interact()
		InteractionType.BUS:
			_bus_interact()
	
func postInteract() -> void:
	is_interacting = false

func auxInteract() -> void:
	if not can_interact:
		return
	match interaction_type:
		InteractionType.DEFAULT:
			_default_throw()
	
	
	
func _default_interact() -> void :
	var object_current_position : Vector3 = object_ref.global_transform.origin
	var player_hand_position : Vector3 = player_hand.global_transform.origin
	var object_distance : Vector3 = player_hand_position-object_current_position
	
	var rigid_body_3d : RigidBody3D = object_ref as RigidBody3D
	if rigid_body_3d:
		rigid_body_3d.set_linear_velocity((object_distance)*(5.0/rigid_body_3d.mass))

func _default_throw() -> void:
	var object_current_position : Vector3 = object_ref.global_transform.origin
	var player_hand_position : Vector3 = player_hand.global_transform.origin
	var _object_distance : Vector3 = player_hand_position-object_current_position
	
	var rigid_body_3d : RigidBody3D = object_ref as RigidBody3D
	if rigid_body_3d:
		var throw_distance : Vector3 = -player_hand.global_transform.basis.z.normalized()
		var throw_strength : float = (10.0/rigid_body_3d.mass)
		rigid_body_3d.set_linear_velocity(throw_distance*throw_strength)
		can_interact =false
		
		await get_tree().create_timer(2.0).timeout
		can_interact = true
	

func _collect_item() -> void:
	if item_data == null:
		push_warning("No ItemData assigned to this item!")
		return

	if Inventory.add_item(item_data):
		item_collected.emit(get_parent())
		get_parent().queue_free()

	
func _collect_note() -> void:
	var note := get_parent() as Node3D

	var col := note.find_child(
		"CollisionShape3D",
		true,
		false
	) as CollisionShape3D

	if col:
		col.set_deferred("disabled", true)

	emit_signal("note_collected", note)
	
func _button_interact() -> void:
	emit_signal("button_pressed")
	
func _bus_interact() -> void:
	emit_signal("bus_interact")
