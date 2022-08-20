extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func fire(to_flip = false):
	if to_flip:
		rotation_degrees = -129
	else:
		rotation_degrees = -44
	visible = true
	play("fire")


func _on_Laser_animation_finished():
	stop()
	set_frame(0)
	visible = false

