extends TileMap


class_name RoddRunnerTilemap

var destroy_seq = [6, 7, 9, 8]
var build_seq = [8, 9, 7, 6]
var destroy_idx = 0
var current_destroy 
var destroy_timer_scene
var rebuild_timer_scene

var treasure_count = 0 

const REBUILD_DELAY = 10

var trapped_foes = Array()

const TILE_MAX_X = 28
const TILE_MAX_Y = 17

var ladder_tile_id = -1
var escape_ladder_id = -1
var treasure_id = -1 


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	var list = tile_set.get_tiles_ids()
	
	for idx in list:
		if tile_set.tile_get_name(idx) == "ladder":
			ladder_tile_id = idx
		elif tile_set.tile_get_name(idx) == "escape_ladder":
			escape_ladder_id = idx
		elif tile_set.tile_get_name(idx) == "treasure":
			treasure_id = idx
		print(idx,", name :", tile_set.tile_get_name(idx))
		
	destroy_timer_scene = load("res://levels/DestroyTimer.tscn")
	rebuild_timer_scene = load("res://levels/RebuildTimer.tscn")

	for x in range(TILE_MAX_X):
		for y in range(TILE_MAX_Y):
			if (is_tile_contains_treasure(Vector2(x,y))):
				treasure_count += 1
	print("we have : ", treasure_count, " treasures")


func show_escape_ladder():
	for x in range(TILE_MAX_X):
		for y in range(TILE_MAX_Y):
			if x == 27:
				pass
			
			if get_cell(x, y) == escape_ladder_id:
				set_cell(x, y, ladder_tile_id)
	

func my_tile_get_name(cell):
	pass 
	if cell == - 1:
		return ""
	else:
		if cell == 2:
			pass
		return  tile_set.tile_get_name(cell)


func is_tile_solid(pos):
	var t = my_tile_get_name(get_cell(pos.x, pos.y))
	return (t in ["wall", "wall2", "concrete"])


func is_tile_upon_ladder(pos):
	var t = my_tile_get_name(get_cell(pos.x, pos.y + 1))
	return(t == "ladder")

func is_tile_ladder(pos):
	var t = my_tile_get_name(get_cell(pos.x, pos.y))
	return(t == "ladder")

	
func is_tile_climbable(pos):
	var t = my_tile_get_name(get_cell(pos.x, pos.y))
	return(t == "ladder" or is_tile_upon_ladder(pos))


func is_tile_under_me_floor(pos):
	var t = my_tile_get_name(get_cell(pos.x, pos.y + 1))
	return (t in ["wall", "wall2", "ladder","concrete"] or \
		 (trapped_foes.find(pos+ Vector2(0,1)) != -1))
	
func is_tile_rope(pos):
	var t = my_tile_get_name(get_cell(pos.x, pos.y))
	return (t == "rope")

func is_free_to_break(pos):
	var t = my_tile_get_name(get_cell(pos.x, pos.y)) 
	return  ((t == "wall" or t == "wall2") and not is_tile_ladder(pos + Vector2(0,-1)))
	
func is_tile_ok_to_go_down(pos):
	var t = my_tile_get_name(get_cell(pos.x, pos.y + 1))
	return (t == "" or t == "ladder" or t == "rope")
	


func is_tile_contains_treasure(pos):
	var t = my_tile_get_name(get_cell(pos.x, pos.y))
	return  (t == "treasure")

func release_treasure(pos):
	set_cell(pos.x, pos.y, treasure_id)

func get_treasure(pos):
	if is_tile_contains_treasure(pos):
		set_cell(pos.x, pos.y, -1)
		return true
	else:
		return false
	
	
func did_i_get_treasure(pos):
	if is_tile_contains_treasure(pos):
		treasure_count -= 1
		set_cell(pos.x, pos.y, -1)
		if treasure_count == 0:
			show_escape_ladder()
		return true
	else:
		return false

func get_end_level_pos():
	return world_to_map($EndLevel.position)

func is_tile_destroyed(pos):
	var t = my_tile_get_name(get_cell(pos.x, pos.y))
	return  (t == "destroyed" or t == "destroyed3" or t == "destroyed4")

func is_tile_rebuilt(pos):
	var t = my_tile_get_name(get_cell(pos.x, pos.y))
	return  (t == "destroyed1" or t == "wall" or t == "wall2")
	

func desintegrate_brick(pos):
	
	var dt = destroy_timer_scene.instance()
	dt.position = pos
	dt.max_count = 5
	add_child(dt)

	var rb = rebuild_timer_scene.instance()
	rb.position = pos
	rb.max_count = REBUILD_DELAY + 5
	rb.what = get_cell(pos.x, pos.y)
	add_child(rb)
	


func _on_destroy_brick(pos, count):
		
	if count < destroy_seq.size():
		set_cell(pos.x, pos.y, destroy_seq[count])
	else:
		set_cell(pos.x, pos.y, 11)
		
		
		
func _on_rebuild_brick(pos, count, what):	
	var reb = count - REBUILD_DELAY
	if reb < build_seq.size() and reb >= 0:
		set_cell(pos.x, pos.y, build_seq[reb])
	elif reb >= build_seq.size():
		set_cell(pos.x, pos.y, what)
	

func is_trapped_foe(pos):
	return (trapped_foes.find(pos) != -1)
	
func add_trapped_foe(pos):
	trapped_foes.append(pos)
	
func remove_trapped_foe(pos):
	var idx 
	idx = trapped_foes.find(pos)
	if idx != - 1:
		trapped_foes.remove(idx)


func get_spawn_location():
	var idx = randi() % TILE_MAX_X
	for _test in range(100):
		if get_cell(idx,0) == -1:
			return Vector2(idx,0)
			
	return Vector2(0,0) # it's wrong...
	
	
		
	
