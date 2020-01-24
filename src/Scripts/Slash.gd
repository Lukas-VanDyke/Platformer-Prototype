extends KinematicBody2D

var time = 0
	
func _physics_process(delta):
	if time < 0.5:
		time += delta
	else:
		get_parent().remove_child(self)
		queue_free()
		
func flip():
	get_node("Sprite").set_flip_h(true)
