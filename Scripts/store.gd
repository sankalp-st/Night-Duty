extends Control

@onready var grid_container: GridContainer = %ItemContainer
@export var store_item : PackedScene
@onready var description_label: Label = $Container/VBoxContainer/MainContent/aboutItem/ItemDiscription

var store_item_id : int = 0
signal closed

var store_data : Array = [
	{
		"icon_path": "res://Assets/Store/icons/repair kit.png",
		"heading_1": "Repair Kit",
		"heading_2": "Vehicles",
		"custom_button_text": "10 Diamonds",
		"description":"Repairs damage to your bus and restores its durability.",
		"item":preload("res://Resources/Collectables/Gun.tres"),
		"price":"5"
	},
	{
		"icon_path": "res://Assets/Store/icons/shotgun.png",
		"heading_1": "Shotgun",
		"heading_2": "Weapon",
		"custom_button_text": "5 Diamonds",
		"description":"A powerful close-range weapon for defending yourself against monsters.",
		"item":preload("res://Scenes/bus_repair_kit.tscn"),
	},
	{
		"icon_path": "res://Assets/Store/icons/pistol.png",
		"heading_1": "Pistol",
		"heading_2": "Weapon",
		"custom_button_text": "3 Diamonds",
		"description":"A lightweight weapon for protecting yourself during dangerous encounters.",
		"item":preload("res://Scenes/bus_repair_kit.tscn"),
	},
	{
		"icon_path": "res://Assets/Store/icons/medikit.png",
		"heading_1": "Medikit",
		"heading_2": "Value pack",
		"custom_button_text": "100 Diamonds",
		"description":"Restores your health when you are injured.",
		"item":preload("res://Scenes/bus_repair_kit.tscn"),
	},
	{
		"icon_path": "res://Assets/Store/icons/repair kit.png",
		"heading_1": "Repair Kit",
		"heading_2": "Vehicles",
		"custom_button_text": "10 Diamonds",
		"description":"Medikit",
		"item":preload("res://Scenes/bus_repair_kit.tscn"),
	},
	{
		"icon_path": "res://Assets/Store/icons/shotgun.png",
		"heading_1": "Shotgun",
		"heading_2": "Weapon",
		"custom_button_text": "5 Diamonds",
		"description":"Medikit",
		"item":preload("res://Scenes/bus_repair_kit.tscn"),
	},
	{
		"icon_path": "res://Assets/Store/icons/pistol.png",
		"heading_1": "Pistol",
		"heading_2": "Weapon",
		"custom_button_text": "3 Diamonds",
		"description":"Medikit",
		"item":preload("res://Scenes/bus_repair_kit.tscn"),
	},
	{
		"icon_path": "res://Assets/Store/icons/medikit.png",
		"heading_1": "Medikit",
		"heading_2": "Value pack",
		"custom_button_text": "100 Diamonds",
		"description":"Medikit",
		"item":preload("res://Scenes/bus_repair_kit.tscn"),
	}

]

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Inventory.ui.visible = false
	setup_store()


func setup_store() -> void:
	for data in store_data:
		var temp = store_item.instantiate()
		temp.item_buy_pressed.connect(on_item_buy_pressed)
		temp.mouse_enter.connect(show_details_items)
		grid_container.add_child(temp)
		temp.setup(data, store_item_id)
		store_item_id += 1


func on_item_buy_pressed(id : int) -> void:
	print(store_data[id].get("heading_1") + " bought.")
	var entry = store_data[id]
	var item: ItemData = entry.get("item")
	if item == null or item.interactable_scene == null:
		push_warning("No ItemData for " + entry.heading_1)
		return

	var counter := get_tree().get_first_node_in_group("shop_counter") as Node3D
	if counter == null:
		push_error("No node in group 'shop_counter'")
		return

	if not SaveLoad.spend_diamonds(int(entry.price)):
		print("Not enough diamonds")   # show this in the UI later
		return

	# Small random offset so several purchases don't stack inside each other
	var offset := Vector3(randf_range(-0.2, 0.2)+.5, 0.3, randf_range(-0.2, 0.2))
	Inventory.spawn_item_at(item, counter.global_position + offset)
	SaveLoad._save()


func _on_quit_pressed() -> void:
	closed.emit()
	queue_free()
	
func show_details_items(id:int) -> void:
	description_label.text = store_data[id].get(
		"description",
		"No description available."
	)
