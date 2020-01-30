extends KinematicBody2D

export (int) var movementSpeed = 200
export (int) var gravity = 2500
var velocity = Vector2()

var health = 10

var direction = -1

func _physics_process(delta):
	velocity = Vector2(direction * movementSpeed, velocity.y)
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if is_on_wall():
		direction *= -1
			
	if is_on_floor():
		velocity.y = 0
	else:
		velocity.y += gravity * delta
			
	var space_state = get_world_2d().direct_space_state
	var edgeCheck = Vector2(direction, 1)
	var start = global_position
	var target = start + (80 * edgeCheck)
	var result = space_state.intersect_ray(global_position, target, [self])
	if not result:
		direction *= -1
		
func HitByBullet():
	health -= 2
	if health <= 0:
		get_parent().remove_child(self)
		queue_free()
		
func HitBySlash():
	health -=5
	if health <= 0:
		get_parent().remove_child(self)
		queue_free()
