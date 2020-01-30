extends KinematicBody2D

var time = 0
	
func _physics_process(delta):
	var collisionInfo = move_and_collide(Vector2())
	if collisionInfo:
		if collisionInfo.collider.get_collision_layer() == 4:
			collisionInfo.collider.HitBySlash()
	
	if time < 0.5:
		time += delta
	else:
		get_parent().remove_child(self)
		queue_free()
		
func flip():
	get_node("Sprite").set_flip_h(true)
