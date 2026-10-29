
extends Node

@onready var player: CharacterBody3D = $"../ProtoController"
@onready var interaction_raycast: RayCast3D = $"../ProtoController/Head/Eye/Camera3D/InteractionRaycast"
@onready var note_hand: Marker3D = %NoteHand

@onready var default_reticle: TextureRect = %DefaultReticle
@onready var highlight_reticle: TextureRect = %HighlightReticle
@onready var interacting_reticle: TextureRect = %InteractingReticle

@onready var outline_material: Material = preload("res://materials/OutlineOverlayMain.tres")

var held_note: Node3D = null
var note_return_parent: Node3D = null
var note_return_transform: Transform3D
var can_return_note: bool = false

var current_target: Node3D = null
var current_object: Node3D = null


func _ready() -> void:
	Inventory.item_drop.connect(drop_from_player)


func _process(_delta: float) -> void:
	ray_scanning()


func ray_scanning() -> void:
	if not interaction_raycast.is_colliding():
		clear_target()
		return

	var collider := interaction_raycast.get_collider() as Node3D
	#print(collider)

	if collider == null or not collider.is_in_group("interactable"):
		clear_target()
		return

	if current_target != collider:
		clear_target()
		current_target = collider
		set_outline(collider, true)

	_focus()

	if Input.is_action_just_pressed("primary"):
		if collider.is_in_group("notes"):
			_on_note_collected(collider)
		elif collider.is_in_group("Bus"):
			if collider.has_method("enter_bus"):
				collider.enter_bus()
		elif collider.is_in_group("ShopKeper"):
			_change_scene_to_shopkeper()
		elif collider.has_method("interact"):
			collider.interact()
			



func set_outline(body: Node3D, enabled: bool) -> void:
	var mesh := body.find_child("MeshInstance3D", true, false) as MeshInstance3D

	if mesh:
		mesh.material_overlay = outline_material if enabled else null


func clear_target() -> void:
	if is_instance_valid(current_target):
		set_outline(current_target, false)

	current_target = null
	_unfocus()


func _focus() -> void:
	default_reticle.visible = false
	highlight_reticle.visible = true
	interacting_reticle.visible = false


func _unfocus() -> void:
	default_reticle.visible = true
	highlight_reticle.visible = false
	interacting_reticle.visible = false


func _on_note_collected(note: Node3D) -> void:
	if held_note != null:
		return

	held_note = note
	note_return_parent = note.get_parent() as Node3D
	note_return_transform = note.global_transform

	# Disable the note's collision while it is held.
	var col := note.find_child("CollisionShape3D", true, false) as CollisionShape3D
	if col:
		col.set_deferred("disabled", true)

	note.reparent(note_hand, false)
	note.position = Vector3.ZERO
	note.rotation_degrees = Vector3(90, 10, 0)

	can_return_note = false
	await get_tree().process_frame
	can_return_note = true


func return_note_to_npc() -> void:
	if held_note == null or not can_return_note:
		return

	if not is_instance_valid(note_return_parent):
		push_error("NPC return parent is invalid")
		return

	held_note.reparent(note_return_parent, false)
	held_note.global_transform = note_return_transform

	var col := held_note.find_child("CollisionShape3D", true, false) as CollisionShape3D
	if col:
		col.set_deferred("disabled", false)

	held_note = null
	note_return_parent = null
	can_return_note = false

	clear_target()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_G:
			return_note_to_npc()
			
func drop_from_player(item: Node3D) -> void:
	if not is_instance_valid(item):
		return

	var forward := -player.global_transform.basis.z.normalized()
	item.global_position = player.global_position + forward * 2.0 + Vector3.UP * 0.5

func _change_scene_to_shopkeper() -> void:
	clear_target()
	default_reticle.visible = false
	highlight_reticle.visible = false
	interacting_reticle.visible = false
	var store_scene = preload("res://Scenes/store.tscn")
	var store = store_scene.instantiate()
	store.process_mode = Node.PROCESS_MODE_ALWAYS
	store.closed.connect(_on_store_closed)
	get_tree().root.add_child(store)
	get_tree().paused = true

func _on_store_closed() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Inventory.ui.visible = true
	_unfocus()
