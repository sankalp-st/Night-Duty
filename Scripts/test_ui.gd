
extends Control

@onready var bus_details: Label = $"bus details"
@onready var player_details: Label = $"player details"
@onready var car: VehicleBody3D = $"../Car"

var player: CharacterBody3D


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as CharacterBody3D


func _process(_delta: float) -> void:
	update_bus_debug()
	update_player_debug()


# =========================
# BUS DEBUG
# =========================

func update_bus_debug() -> void:
	if not is_instance_valid(car):
		bus_details.text = "BUS DEBUG\nBus node not found!"
		return

	var bus_speed: float = car.linear_velocity.length() * 3.6

	bus_details.text = """
========== BUS DEBUG ==========

SPEED
Speed: %.1f km/h
Velocity: %s

ENGINE
RPM: %d
Engine Force: %.1f
Engine Failed: %s
Has Fuel: %s

FUEL
Fuel: %.1f / %.1f
Consumption Rate: %.3f

DAMAGE
Bus Health: %.1f / %.1f
Wheel Health: %.1f / %.1f
Wheels Worn Out: %s

CONTROLS
Steering: %.2f
Brake: %.1f
Inside Bus: %s
Can Enter Bus: %s
""" % [
		bus_speed,
		str(car.linear_velocity),
		car.RPM,
		car.engine_force,
		str(car.engine_fail),
		str(car.has_fuel),
		car.fuel,
		car.max_fuel,
		car.driving_consumption,
		car.health,
		car.max_health,
		car.wheel_health,
		car.max_wheel_health,
		str(car.wheels_worn_out),
		car.steering,
		car.brake,
		str(car.in_bus),
		str(car.can_enter_bus)
	]


# =========================
# PLAYER DEBUG
# =========================

func update_player_debug() -> void:
	if not is_instance_valid(player):
		player_details.text = "PLAYER DEBUG\nPlayer node not found!"
		return

	var player_speed: float = Vector2(
		player.velocity.x,
		player.velocity.z
	).length() * 3.6

	player_details.text = """
========== PLAYER DEBUG ==========

MOVEMENT
Speed: %.2f km/h
Velocity: %s
Vertical Velocity: %.2f
On Floor: %s

STATE
Inside Bus: %s
Visible: %s
Physics Enabled: %s
Mouse Captured: %s

POSITION
Global Position: %s

%s
""" % [
		player_speed,
		str(player.velocity),
		player.velocity.y,
		str(player.is_on_floor()),
		str(player.inside_bus),
		str(player.visible),
		str(player.is_physics_processing()),
		str(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED),
		str(player.global_position),
		get_performance_debug()
	]


# =========================
# PERFORMANCE DEBUG
# =========================

func get_performance_debug() -> String:
	var fps: int = Engine.get_frames_per_second()

	# Approximate frame time based on FPS.
	var frame_time_ms: float = 1000.0 / maxf(float(fps), 1.0)

	var static_mem_mb: float = float(
		Performance.get_monitor(
			Performance.MEMORY_STATIC
		)
	) / (1024.0 * 1024.0)

	var object_count: int = int(
		Performance.get_monitor(
			Performance.OBJECT_COUNT
		)
	)

	var node_count: int = int(
		Performance.get_monitor(
			Performance.OBJECT_NODE_COUNT
		)
	)

	var resource_count: int = int(
		Performance.get_monitor(
			Performance.OBJECT_RESOURCE_COUNT
		)
	)

	var physics_objects: int = int(
		Performance.get_monitor(
			Performance.PHYSICS_3D_ACTIVE_OBJECTS
		)
	)

	var draw_calls: int = int(
		Performance.get_monitor(
			Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME
		)
	)

	return """
========== PERFORMANCE DEBUG ==========

RENDERING
FPS: %d
Approx Frame Time: %.2f ms
Draw Calls: %d

MEMORY
Static Memory: %.1f MB

OBJECTS
Total Objects: %d
Nodes: %d
Resources: %d

PHYSICS
Active 3D Physics Objects: %d
""" % [
		fps,
		frame_time_ms,
		draw_calls,
		static_mem_mb,
		object_count,
		node_count,
		resource_count,
		physics_objects
	]
