extends Node3D

@onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready():
	$UserInterface/GameOverScreen.modulate = Color.DIM_GRAY
	$UserInterface/GameOverScreen.modulate = Color.DIM_GRAY
	$UserInterface.hide()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	#if $UserInterface.visible():
		#get_tree().call_group("enemy", "update_target_location", player.global_transform.origin)
	get_tree().call_group("enemy", "update_target_location", player.global_transform.origin)

func _unhandled_input(event):
	if event.is_action_pressed("enter") and $UserInterface.is_visible_in_tree():
		get_tree().reload_current_scene()

func _on_player_hit():
	#pass
	$UserInterface.show()
	
	var temppos = Vector3.ZERO
	temppos.x = 10000
	temppos.y = 10000
	temppos.z = 10000
	
	$Monster.position = temppos
	
