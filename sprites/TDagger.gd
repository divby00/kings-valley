class_name TDagger extends KinematicBody2D

signal on_floor(dagger)

var velocity = 3
var motion = Vector2.ZERO

enum STATE { FLYING, BOUNCE_START, BOUNCE, DOWNING , END }

onready var state = STATE.FLYING

func _ready():
	$AnimationPlayer.play("rotate")
	
func isFlip() -> bool:
	return $Sprite.scale.x < 0
	
func doFlip(flip):
	if (flip):
		velocity = -abs(velocity)
		$Sprite.scale.x = -1
	else:
		velocity = abs(velocity)
		$Sprite.scale.x = 1

func _physics_process(_delta):
	var collider:KinematicCollision2D
	match state:
		STATE.FLYING:
			motion.x = velocity 
			collider = move_and_collide(motion)
			if collider!=null:
				state = STATE.BOUNCE_START
				motion.x = 0
				velocity = 2
				if collider.collider.get_class()=="TMummy":
					print(collider.collider.get_collision_layer_bit(16))
					collider.collider.doKill()
					
		STATE.BOUNCE_START:
			$Sprite.scale.x = -$Sprite.scale.x
			state = STATE.BOUNCE
			$Timer.wait_time=0.3
			$Timer.start()
		STATE.BOUNCE:
			motion.x = -0.5 if $Sprite.scale.x<0 else 0.5
			motion.y = -1
			collider = move_and_collide(motion)
		STATE.DOWNING:
			motion.y = velocity 
			collider = move_and_collide(motion)
			if collider!=null:
				state = STATE.END
				emit_signal("on_floor",self)
		
func _on_Timer_timeout():
	state=STATE.DOWNING
