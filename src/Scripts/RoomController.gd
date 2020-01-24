extends Node2D

var player
var playerVisibility
var playerStart = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node("Player")
	playerVisibility = player.get_node("PlayerVisibility")
	playerStart = player.get_global_position()

func _process(delta):
	if not playerVisibility.is_on_screen():
		ResetPlayer()
		
func ResetPlayer():
	player.set_global_position(playerStart)
	
func End():
	get_tree().quit()
