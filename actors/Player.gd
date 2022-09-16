extends Actor
class_name Player


var is_firing: bool = false
var end_level_pos
var game 

var grace_period  = -10


signal level_won
signal stop_level
signal i_won_points


func _ready():
	if connect("level_won",get_parent(),"_on_level_won") != OK:
		print("Error in connect level_won")
		
	if connect("stop_level",get_parent(),"stop_level") != OK:
		print("Error in connect stop_level")


# Called when the node enters the scene tree for the first time.
func initialize_player(var _tm,var _in, var _g):
	.initialize(_tm, _in)
	end_level_pos = _tilemap.get_end_level_pos()
	if connect("i_won_points", _g, "player_won_points") != OK:
		print("Error in connect i_won_points")
	


func i_m_dead():
	$Dead.play()
	$Blink.start()
	emit_signal("stop_level",true)

func crushed():
	i_m_dead()


func manage_fall2(delta, _act):
	var save_move = ongoing_move
	.manage_fall2(delta, _act)
	if ongoing_move == action.fall and save_move != action.fall:
		$Falling.play()
		
func manage_stop_falling(_delta, _act):
	var save_move = ongoing_move
	.manage_stop_falling(_delta, _act)
	if ongoing_move != action.fall and save_move == action.fall:
		$Falling.stop()
		
	

func manage_leftright(delta, _act):
	if grace_period > 0:
		grace_period -= delta
		return 
	
	if _act in [action.left,action.right]:
		if ongoing_move == action.still and \
			what_facing == facing.left and \
			is_between_tiles == between.NONE and \
			_act == action.right:
				what_facing = facing.right
				velocity = Vector2.ZERO
				is_between_tiles = between.X
				ongoing_move = action.still
				$Anims.play_still_right()
				grace_period = 0.08
				return 
				
		if ongoing_move == action.still and \
			what_facing == facing.right and \
			is_between_tiles == between.NONE and \
			_act == action.left:
				what_facing = facing.left
				velocity = Vector2.ZERO
				is_between_tiles = between.X
				ongoing_move = action.still
				$Anims.play_still_left()
				grace_period = 0.08
				return
		

	.manage_leftright(delta, _act)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func manage_moves(delta,_act):
	if _tilemap.did_i_get_treasure(current_pos):
		emit_signal("i_won_points","treasure")
		$Treasure.play()
	if current_pos == end_level_pos and _tilemap.treasure_count == 0:
		$Anims.stop()
		emit_signal("i_won_points","level_won")
		emit_signal("level_won")
	
	var pointing_at
	if _act == action.fire:
		if what_facing == facing.left and ongoing_move == action.still:
			pointing_at = _tilemap.world_to_map(position) + Vector2(-1,1) 
			if _tilemap.is_free_to_break(pointing_at):
				velocity = Vector2.ZERO
				$Anims.play_fire_left()
				_tilemap.desintegrate_brick(pointing_at)
				is_firing = true 
				$LaserGun.play()
				$Rocks.play()


		elif what_facing == facing.right and ongoing_move == action.still:
			pointing_at = _tilemap.world_to_map(position) + Vector2(1,1) 
			if _tilemap.is_free_to_break(pointing_at):
				velocity = Vector2.ZERO
				$Anims.play_fire_right()
				_tilemap.desintegrate_brick(pointing_at)
				is_firing = true
				$LaserGun.play()
				$Rocks.play()
	
	if not is_firing:
		.manage_moves(delta, _act)
	else:
		$Laser.fire($Anims.flip_h)


func _on_Anims_end_fire():
	is_firing = false 




func _on_Player_area_entered(_area):
	print("I died!")
	i_m_dead()


func _on_Blink_timeout():
	if get_parent().name != "Help":
		visible = not visible
