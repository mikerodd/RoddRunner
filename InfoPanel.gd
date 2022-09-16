extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func update(score, women, level):
	$Score.text = "%06d" % score
	$Level.text = "%04d" % level
	$Women.text = "%03d" % women

