extends Timer

signal rebuild_brick

var what = -1
var position = Vector2(0,0)
var max_count = 1
var current_count = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	var _t = connect("rebuild_brick",get_parent(),"_on_rebuild_brick")
	




func _on_Rebuild_timeout():
	if current_count < max_count:
		emit_signal("rebuild_brick",position, current_count, what)
		current_count += 1
	else:
		queue_free()
