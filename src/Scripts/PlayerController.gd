extends KinematicBody2D

onready var grapplingHook = load("res://Scenes/Gadgets/GrapplingHook.tscn")
onready var grappleLine = load("res://Scenes/Gadgets/GrappleLine.tscn")

export (int) var movementSpeed = 500
export (int) var grapplingSpeed = 1000
export (int) var climbingSpeed = 100
export (int) var wallSlideSpeed = 200
export (int) var gravity = 2500
export (int) var jumpSpeed = -1000

var velocity = Vector2()

var grappling = false
var grapplingTarget
var previousPosition = Vector2()

var hook
var line

func _physics_process(delta):
	if line != null:
		line.points[0] = global_position
	
	if grappling:
		if (previousPosition - global_position).length() < 3:
			grappling = false
			get_parent().remove_child(hook)
			hook.queue_free()
			get_parent().remove_child(line)
			if line != null:
				line.queue_free()
				line = null
		
		previousPosition = global_position
		velocity = (grapplingTarget - global_position).normalized() * grapplingSpeed
		if (grapplingTarget - global_position).length() > 33:
			velocity = move_and_slide(velocity)
		else:
			grappling = false
			get_parent().remove_child(hook)
			hook.queue_free()
			get_parent().remove_child(line)
			if line != null:
				line.queue_free()
				line = null
		return
	
	get_input()
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
func get_input():
	velocity.x = 0
	if is_on_wall():
		if velocity.y > wallSlideSpeed:
			velocity.y = wallSlideSpeed
	
	if Input.is_action_pressed("left"):
		velocity.x -= movementSpeed
	if Input.is_action_pressed("right"):
		velocity.x += movementSpeed
	if Input.is_action_just_pressed("space") and (is_on_floor() or is_on_wall()):
		velocity.y = jumpSpeed
	if Input.is_action_just_released("space"):
		velocity.y += 300
		
	if Input.is_action_just_pressed("click"):
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(global_position, get_global_mouse_position(), [self])
		if result:
			SendGrapple(result.position)

func SendGrapple(targetPosition):
	hook = grapplingHook.instance()
	get_parent().add_child(hook)
	
	line = grappleLine.instance()
	line.points[0] = global_position
	line.points[1] = global_position
	get_parent().add_child(line)
	
	hook.set_global_position(global_position)
	hook.SetVelocity(targetPosition, line)
	hook.connect("grapple_hit", self, "StartGrapple")
	
func StartGrapple(grapplePosition):
	grapplingTarget = grapplePosition
	grappling = true