class_name TDagger extends KinematicBody2D

signal on_floor(dagger)

enum STATE { FLYING, BOUNCE_START, BOUNCE, DOWNING, END }

onready var timer = $Timer
onready var animator = $AnimationPlayer
onready var state = STATE.FLYING

var velocity = 3
var motion = Vector2.ZERO


func _ready():
	animator.play("rotate")


func is_flip() -> bool:
	return $Sprite.scale.x < 0


func do_flip(flip):
	if flip:
		velocity = -abs(velocity)
		$Sprite.scale.x = -1
	else:
		velocity = abs(velocity)
		$Sprite.scale.x = 1


func _physics_process(_delta):
	var collider: KinematicCollision2D
	match state:
		STATE.FLYING:
			motion.x = velocity
			collider = move_and_collide(motion)
			if collider != null:
				state = STATE.BOUNCE_START
				motion.x = 0
				velocity = 2
				if collider.collider.get_class() == "TMummy":
					collider.collider.do_kill()
		STATE.BOUNCE_START:
			$Sprite.scale.x = -$Sprite.scale.x
			state = STATE.BOUNCE
			timer.wait_time = 0.3
			timer.start()
		STATE.BOUNCE:
			motion.x = -0.5 if $Sprite.scale.x < 0 else 0.5
			motion.y = -1
			collider = move_and_collide(motion)
		STATE.DOWNING:
			motion.y = velocity
			collider = move_and_collide(motion)
			if collider != null:
				state = STATE.END
				emit_signal("on_floor", self)


func _on_Timer_timeout():
	state = STATE.DOWNING
