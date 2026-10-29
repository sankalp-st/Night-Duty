extends VehicleBody3D

@onready var steering_wheel: Node3D = $Wheel
@export var player: CharacterBody3D
@export var look_speed : float = 0.001

var mouse_captured : bool = false
var look_rotation : Vector2
@onready var camera_pivot: Node3D = $CamraPivot
@onready var front_cam: Camera3D = $CamraPivot/FrontCam
@onready var player_exit_point: Marker3D = $PlayerMarker/PlayerExitPoint

@export_group("Wheel Wear")
@export var max_wheel_health: float = 100.0
@export var brake_wear: float = 5.0

var wheel_health: float = 100.0
var wheels_worn_out: bool = false

@export var RPM: int = 100
@export var max_fuel: float = 100.0
@export var driving_consumption: float = 0.08
@export var max_health: float = 100.0

var fuel: float = 100.0
var has_fuel: bool = true
var health: float = 100.0
var in_bus: bool = false
var engine_fail : bool = false
var can_enter_bus: bool = true


func _unhandled_input(event: InputEvent) -> void:
	# Mouse capturing
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()
	# Look around
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)

func _ready() -> void:
	look_rotation.y = camera_pivot.rotation.y
	look_rotation.x = front_cam.rotation.x
	player = get_tree().get_first_node_in_group("player") as CharacterBody3D
func _physics_process(delta: float) -> void:
	#print(RPM)
	if engine_fail :
		EngineFailed(delta)
		return
	if not in_bus:
		return
	if Input.is_action_pressed("player_sprint"):
		RPM = 150
	else:
		RPM = 100
	# FUEL
	if has_fuel:
		# STEERING
		consume_fuel(delta)
		var steering_input := Input.get_axis("right_bus", "left_bus")
		var target_steering := steering_input * deg_to_rad(24.0)
		steering = move_toward(steering,target_steering,delta * 3.0)
		# Steering wheel visual
		var target_wheel_rotation := steering * 4.0
		steering_wheel.rotation.y = target_wheel_rotation + deg_to_rad(270)
		# ENGINE
		var throttle := Input.get_axis("back_bus","forward_bus")
		engine_force = throttle * RPM
		#print(engine_force)
		# BRAKE
		if Input.is_action_just_pressed("break_bus"):
			if not wheels_worn_out:
				wheels_damage()
		if Input.is_action_pressed("break_bus"):
			brake = 10.0
		else:
			brake = 0.0
	else:
		EngineFailed(delta)

func EngineFailed(delta:float) -> void:
		engine_fail = true
		engine_force = 0.0
		brake = move_toward(brake,2.0,delta * 1.0)
		
func _input(event: InputEvent) -> void:
	if not in_bus:
		return
	if event.is_action_pressed("primary") and not event.is_echo():
		get_viewport().set_input_as_handled()
		exit_bus()
		return
		
func take_damage(amount: float) -> void:
	#print("bus took damage of :",amount)
	health -= amount
	health = clamp(
		health,
		0.0,
		max_health
	)
	#print("Bus Health:", health)
	if health <= 0.0:
		engine_fail = true

func refuel(amount: float, delta: float) -> void:
	fuel += amount * delta
	fuel = min(fuel, max_fuel)
	has_fuel = fuel > 0.0
	
func _on_bus_interact() -> void:
	if in_bus:
		exit_bus()
	else:
		enter_bus()
func enter_bus() -> void:
	if in_bus or not can_enter_bus:
		return
	#print("Inside the bus")
	in_bus = true
	player.in_bus()
	player.global_position = player_exit_point.global_position
	front_cam.current = true
	capture_mouse()

func exit_bus() -> void:
	if not in_bus:
		return
	#print("Exited the bus")
	engine_force = 0
	in_bus = false
	can_enter_bus = false
	player.out_bus()
	player.global_position = player_exit_point.global_position
	front_cam.current = false
	await get_tree().create_timer(0.5).timeout
	can_enter_bus = true

func rotate_look(rot_input: Vector2) -> void:
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(
		look_rotation.x,
		deg_to_rad(-30),
		deg_to_rad(30)
	)
	look_rotation.y -= rot_input.x * look_speed
	look_rotation.y = clamp(
		look_rotation.y,
		deg_to_rad(-30),
		deg_to_rad(30)
	)
		# Rotate only camera horizontally
	camera_pivot.rotation.y = look_rotation.y
		# Rotate camera vertically
	front_cam.rotation.x = look_rotation.x


func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false
	
func wheels_damage() -> void:
	wheel_health -= brake_wear
	wheel_health = max(wheel_health, 0.0)
	#print("Wheel health: ", wheel_health)
	if wheel_health <= 0.0:
		wheels_worn_out = true
		engine_fail = true
		#print("Wheels worn out! Replace them.")

func replace_wheels() -> void:
	wheel_health = max_wheel_health
	wheels_worn_out = false
	engine_fail = false
	#print("Wheels replaced! Health: ", wheel_health)

func consume_fuel(delta:float) ->void:
	#print("fuellevel ",fuel)
	var speed := linear_velocity.length()
	# FUEL CONSUMPTION
	if abs(engine_force) > 0.1:
		fuel -= driving_consumption * speed * delta
	# CLAMP FUEL
	fuel = clamp(fuel, 0.0, max_fuel)
	# UPDATE FUEL STATE
	has_fuel = fuel > 0.0
	
	
