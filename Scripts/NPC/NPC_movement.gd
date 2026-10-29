class_name NPCMoveState
extends State

@export var npc: CharacterBody3D
@export var navigation_agent: NavigationAgent3D

var BusStopMarker: Marker3D
var BusEntryMarker: Marker3D
var current_target: Marker3D

var inspection_done: bool = false

@export var SPEED: float = 10.0


func enter() -> void:
	BusEntryMarker = get_tree().get_first_node_in_group("BusEntryMarker") as Marker3D
	BusStopMarker = get_tree().get_first_node_in_group("BusStopMarker") as Marker3D
	set_target()



	if navigation_agent.is_navigation_finished():

		npc.velocity.x = 0.0
		npc.velocity.z = 0.0

		# Only stop here if inspection is NOT done.
		# If inspection is done, NPC should be at the bus.
		if not inspection_done:
			transition.emit("idel")

		return

	var next_path: Vector3 = navigation_agent.get_next_path_position()

	var direction: Vector3 = npc.global_position.direction_to(next_path)

	# Don't overwrite Y because NPC.gd handles gravity
	#npc.velocity.x = direction.x * SPEED
	#npc.velocity.z = direction.z * SPEED

	var look_at_target := Vector3(
		next_path.x,
		npc.global_position.y,
		next_path.z
	)

	if not npc.global_position.is_equal_approx(look_at_target):
		npc.look_at(look_at_target)


func set_target() -> void:

	if inspection_done:
		current_target = BusEntryMarker
	else:
		current_target = BusStopMarker

	if current_target:
		navigation_agent.target_position = current_target.global_position
