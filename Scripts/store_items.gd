extends PanelContainer

@onready var item: TextureRect = $TextureRect/VerticalBoxContainer/LeftMarginContainer/Item
@onready var heading_1: Label = $TextureRect/VerticalBoxContainer/RightMarginContainer/VBoxContainer/Heading1
@onready var heading_2: Label = $TextureRect/VerticalBoxContainer/RightMarginContainer/VBoxContainer/Heading2
@onready var button: Button = $TextureRect/VerticalBoxContainer/RightMarginContainer/VBoxContainer/Buy/Button

signal item_buy_pressed(id)
signal mouse_enter(id)

var id: int


func setup(data: Dictionary, p_id: int) -> void:
	item.texture = load(data.get("icon_path"))
	heading_1.text = data.get("heading_1", "")
	heading_2.text = data.get("heading_2", "")
	id = p_id
	if data.get("custom_button_text"):
		button.text = data.get("custom_button_text")


func _on_button_pressed() -> void:
	item_buy_pressed.emit(id)


func _on_mouse_entered() -> void:
	mouse_enter.emit(id)
