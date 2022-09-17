extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var counter = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	$Moves/AnimatedSprite.play(String(counter))
	counter = (counter + 1) % 4
	


func _on_Close_pressed():
	visible = false


func _on_Help_pressed():
	visible = true
