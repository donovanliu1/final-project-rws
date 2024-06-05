extends Control

@onready var player = "res://Scenes/player.tscn"
@onready var slider = $GridContainer/SensitivitySlider
@onready var percent = $SensitivityPercent
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_sensitivity_slider_drag_ended(value_changed):
	#print(slider.value)
	#print((100 - slider.value) * 0.00002)
	#print(0.002 - ((100 - slider.value) * 0.00002))
	#Player.set_sensitivity(0.002 - ((100 - slider.value) * 0.00002))
	PlayerSettings.sensitivity = 0.004 - ((100 - slider.value) * 0.00004)



func _on_sensitivity_slider_value_changed(value):
	percent.text = str(slider.value) + " %"
