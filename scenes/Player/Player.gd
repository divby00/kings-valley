extends KinematicBody2D

onready var sprite = $Sprite
onready var animation_player = $AnimationPlayer

enum Facing {
	LEFT, RIGHT
}

enum Status {
	IDLE,
	WALK,
	JUMP
}

var animations = {
	Status.IDLE: "idle",
	Status.WALK: "walk",
	Status.JUMP: "jump",
}

export(int) var GRAVITY = 400
export(int) var MAX_SPEED = 64
export(int) var JUMP_FORCE = 128
export(int) var ACCELERATION = 512
export(int) var MAX_SLOPE_ANGLE = 46
export(float) var FRICTION = .25

var status = Status.IDLE
var motion = Vector2.ZERO
var snap_vector = Vector2.ZERO
var facing = Facing.RIGHT

func _process(_delta):
	if Input.is_action_pressed("primary"):
		pass
	
	if Input.is_action_pressed("secondary"):
		pass

func _physics_process(delta):
	var input_vector = get_input_vector()
	apply_horizontal_force(input_vector, delta)
	apply_friction(input_vector)
	update_snap_vector()
	if is_on_floor():
		if Input.is_action_pressed("up"):
			motion.y = -JUMP_FORCE
			snap_vector = Vector2.ZERO
	apply_gravity(delta)
	update_animation(input_vector)
	motion = move_and_slide_with_snap(motion, snap_vector*4, Vector2.UP, true, 4, deg2rad(MAX_SLOPE_ANGLE))

func get_input_vector():
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	if input_vector.x < 0:
		facing = Facing.LEFT
	elif input_vector.x > 0:
		facing = Facing.RIGHT
	return input_vector

func apply_horizontal_force(input_vector, delta):
	if input_vector.x != 0:
		motion.x += input_vector.x * ACCELERATION * delta
		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)

func update_snap_vector():
	if is_on_floor():
		snap_vector = Vector2.DOWN

func apply_friction(input_vector):
	if input_vector == Vector2.ZERO && is_on_floor():
		motion.x = lerp(motion.x, 0, FRICTION)

func apply_gravity(delta):
	if !is_on_floor():
		motion.y += GRAVITY * delta
		motion.y = min(motion.y, JUMP_FORCE)

func update_animation(_input_vector):
	sprite.scale.x = -1 if facing == Facing.LEFT else 1
	animation_player.play(animation_player.current_animation)