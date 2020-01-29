extends KinematicBody2D

var velocity = Vector2()
var speed = 20

var vis

func _ready():
	vis = get_node("VisibilityNotifier2D")

func _physics_process(delta):
	if not vis.is_on_screen():
		get_parent().remove_child(self)
		queue_free()
	
	var collisionInfo = move_and_collide(velocity)
	if collisionInfo:
		if collisionInfo.collider.get_collision_layer() == 4:
			collisionInfo.collider.HitByBullet()
		get_parent().remove_child(self)
		queue_free()

func SetVelocity(newVelocity):
	velocity = newVelocity * speed
	if newVelocity.x < 0:
		get_node("Sprite").set_flip_h(true)