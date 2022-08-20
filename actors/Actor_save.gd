extends Node2D


class_name Actor_Save

var base_speed = 170
const VELO_RATIO = 2.7143

var is_touched : bool


var velocity = Vector2.ZERO


var tile_size_x
var tile_size_y

var _tilemap : RoddRunnerTilemap
var _input

enum between {NONE, X, Y  }
var is_between_tiles = between.NONE

# actions and relative vectors
enum action {left, right, up, down, still, fire, fall}
var rel_vectors = {0:Vector2(-1,0), 1:Vector2(1, 0), 2:Vector2(0,-1), 3:Vector2(0,1),4:Vector2(0,0),5:Vector2(0,0), 6:Vector2(0,1) }
var vect_shift  = {0:Vector2(1,0), 1:Vector2(0,0), 2:Vector2(0,0), 3:Vector2(0,0), 4:Vector2(0,0), 5:Vector2(0,0), 6:Vector2(0,0)}
enum facing {left, right, up, rope}
var what_facing = facing.left


var current_pos = Vector2.ZERO
var ongoing_pos = Vector2.ZERO
var next_obstacle_pos = Vector2.ZERO

var ongoing_move = action.still
var next_action = action.still

var my_delta 

func initialize(var _tm,var _in):
	_tilemap = _tm
	_input = _in
	$Anims.get_sprite_frames().set_animation_speed("run_left", base_speed / VELO_RATIO)

	tile_size_x = $Anims.get_sprite_frames().get_frame("run_left",0).get_width()
	tile_size_y = $Anims.get_sprite_frames().get_frame("run_left",0).get_height()
	$Anims.play_still_left()
	ongoing_pos = _tilemap.world_to_map(position)
	current_pos = ongoing_pos
	next_obstacle_pos = ongoing_pos


func get_rel_vector(move): 
	return rel_vectors[move]
	


func _process(delta):
	if position.x == 160 and position.y > 590:
		pass
		
	current_pos = _tilemap.world_to_map(position)
	ongoing_pos = _tilemap.world_to_map(position + get_rel_vector(ongoing_move) * base_speed * delta)
	my_delta = delta
	_input.update(self) # next_action updated
	manage_moves(delta, next_action)
	position += velocity * delta
	
	
	
func do_i_fall():
	if ongoing_move in [action.right, action.still, action.left]:
		if not _tilemap.is_tile_under_me_floor(current_pos + vect_shift[ongoing_move]) and \
		   not _tilemap.is_tile_rope(current_pos + vect_shift[ongoing_move]):
				return true
				
	return false
	

# in 
# ongoing_move
# ongoing_pos
# current_pos
# _tilemap
# is_between_tiles
# delta
#
# out :
# velocity
# ongoing_mov
# what_facing
# next_obstacle_pos

func manage_fall(delta, _act):

	if ongoing_move in [action.right, action.still, action.left]:
		if not _tilemap.is_tile_under_me_floor(current_pos + vect_shift[ongoing_move]) and \
		   not _tilemap.is_tile_rope(current_pos + vect_shift[ongoing_move]):
			immobilize_me()
			velocity = rel_vectors[action.fall] * base_speed 
			$Anims.play_fall()
			ongoing_move = action.fall
			return true
	return false




func manage_moves(delta, _act):
	
	if ongoing_move in [action.right, action.left, action.still, action.up, action.down, action.fall]:
		pass
	else:
		return

#	if do_i_fall():
#		immobilize_me()
#		velocity = rel_vectors[action.fall] * base_speed 
#		$Anims.play_fall()
#		ongoing_move = action.fall
#		return
		
	if manage_fall(delta, _act):
		return 
		
	
	
	if ongoing_move == action.fall:
		if _tilemap.is_tile_under_me_floor(ongoing_pos):
			immobilize_me()
			ongoing_move = action.still
			what_facing = facing.left
		return


	var ahead = 1 
	
	if is_between_tiles == between.X and not _act in [action.left, action.right, action.still]:
		if (current_pos != ongoing_pos):
			manage_moves(delta, action.still) 
		else:
			return
	elif is_between_tiles == between.Y and not _act in [action.up, action.down, action.still]:
		if (current_pos != ongoing_pos):
			manage_moves(delta, action.still) 
		else:
			return
	elif is_between_tiles == between.Y and _act == action.down and \
		 current_pos != ongoing_pos:
			ahead = 2 
	elif is_between_tiles == between.X and _act == action.right and \
		 current_pos != ongoing_pos:
			ahead = 2 
	next_obstacle_pos  = _tilemap.world_to_map(position + rel_vectors[_act] * ahead * tile_size_x)
	
	if _act == action.still:
		immobilize_me()


	if _act in [action.left,action.right]:
		if  not _tilemap.is_tile_solid(next_obstacle_pos):
			velocity = rel_vectors[_act] * base_speed
			is_between_tiles = between.X
			ongoing_move = _act
			if  _tilemap.is_tile_rope(next_obstacle_pos):
				what_facing = facing.rope
				$Anims.play_use_rope()
			elif _act == action.left:
				what_facing = facing.left
				$Anims.play_run_left()
			else:
				what_facing = facing.right
				$Anims.play_run_right()
		else:
			if _act == action.left:
				immobilize_me()
			else:
				immobilize_me(true)


	if _act in [action.up,action.down]:
		if  _tilemap.is_tile_cimbable(next_obstacle_pos) or _tilemap.is_tile_rope(next_obstacle_pos):
			velocity = rel_vectors[_act]  * base_speed
			is_between_tiles = between.Y
			what_facing = facing.up
			ongoing_move = _act
			if _act == action.up:
				$Anims.play_climb_up()
			else:
				$Anims.play_climb_down()
		elif _act == action.down and not _tilemap.is_tile_under_me_floor(current_pos):
			immobilize_me()
			velocity = rel_vectors[action.fall] * base_speed 
			$Anims.play_fall()
			ongoing_move = action.fall
		else:
			if _act == action.up:
				immobilize_me()
			else:
				immobilize_me(true)
	return





func immobilize_me(shift = false):
	if velocity.x != 0:
		if _tilemap.world_to_map(position).x != ongoing_pos.x or shift:
			if velocity.x < 0:
				position.x = (ongoing_pos.x  + 1)  * tile_size_x
				if what_facing == facing.rope:
					$Anims.play_still_rope()
				else:					
					what_facing = facing.left
					$Anims.play_still_left()
				velocity = Vector2.ZERO
			else:
				position.x = (ongoing_pos.x)  * tile_size_x
				if what_facing == facing.rope:
					$Anims.play_still_rope()
				else:					
					what_facing = facing.right
					$Anims.play_still_right()
				velocity = Vector2.ZERO

			is_between_tiles = between.NONE
			ongoing_move = action.still
			
	elif velocity.y != 0:
		if _tilemap.world_to_map(position).y != ongoing_pos.y or shift:
			position.y = (ongoing_pos.y  + (1 if velocity.y < 0 else 0 )) * tile_size_y
			what_facing = facing.up
			is_between_tiles = between.NONE
			velocity = Vector2.ZERO
			$Anims.play_still_ladder()
	else:
		if what_facing == facing.left:
			$Anims.play_still_left()
		elif what_facing == facing.right:
			$Anims.play_still_right()
		elif what_facing == facing.rope:
			$Anims.play_still_rope()
		else:
			$Anims.play_still_ladder()
