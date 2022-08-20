extends Timer

var position = Vector2(0,0)
var max_count = 1
var current_count = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal destroy_brick

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	var _t = connect("destroy_brick",get_parent(),"_on_destroy_brick")
	



func _on_DestroyTimer_timeout():
	if current_count < max_count:
		emit_signal("destroy_brick",position, current_count)
		current_count += 1
	else:
		queue_free()
