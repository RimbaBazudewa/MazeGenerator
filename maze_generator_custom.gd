extends TileMap

export(int) var tile_count_x = 3
export(int) var tile_count_y =3 
export(Vector2) var size_hole  = Vector2(2,2)

var block_tileset_id = 0
var max_tile_width:int=3
var max_tile_height:int=3
var center_cell = Vector2(2,2) #hole size
var size_custom_cell = Vector2()
var wall_size = 1  #default value , same as 1 block size

var grid= []

var last_index= 0
var start_index = 0
var current = 0

func _ready():
	max_tile_height = tile_count_y
	max_tile_width = tile_count_x
	center_cell = size_hole
	customize_generate_tile(max_tile_width,max_tile_height)
	kill_and_hunt()

func customize_generate_tile(width:int, height:int):
	#wall width size mulityply by 2  cause wall have 2 side, as well with the wall height 
	size_custom_cell = center_cell + Vector2(wall_size*2,wall_size*2)
	for i in range(width  * height):
		var x = int(i) % width
		var y =int(float( i )/ float(width))
		customize_generate_cell(x + ((size_custom_cell.x-wall_size) * x) , y + ((size_custom_cell.y-wall_size) * y )  ,size_custom_cell.x , size_custom_cell.y )
		

func customize_generate_cell(start_x , start_y, width:int, height:int):
	var center = []
	for i in range(width * height):
		var x = int(i) % width
		var y = int(float(i) / float(width))
		x += start_x 
		y += start_y
		var max_width = start_x + width
		var max_height = start_y + height
		if (x > start_x && y > start_y && x < max_width&& y < max_height):
			center.push_back(Vector2(x, y))
	
		set_cell(x , y , block_tileset_id)	

	grid.push_back(center)		
func get_random_bottom_grid():
	var rnd = RandomNumberGenerator.new()
	rnd.randomize()
	return rnd.randi_range((grid.size()) - center_cell.x, grid.size()-1 )
		
func get_random_current_index():
	var rnd = RandomNumberGenerator.new()
	rnd.randomize()
	return rnd.randi_range(0, grid.size()-1)
func kill_and_hunt():
	start_index  = get_random_bottom_grid()
	current =start_index 
	while(current != -1):

		kill(current)

		current = hunt()
	pass
func check_nighbors(index_grid:int , is_unvisited:bool = true)->bool:
	if index_grid >= 0 &&  index_grid < grid.size():
		var center = grid[index_grid][0]
		if (is_unvisited && get_cellv(center) > -1) || (!is_unvisited && get_cellv(center) >= 0):
				return true 
	return false			
func get_direction_neigbors_left(current_index_grid:int,  width: int)->int:
	var index_left = current_index_grid -1
	var y_cur = int(current_index_grid / width)
	var y_left = int(index_left /width)
	if  y_cur != y_left  :
		index_left = -1
	return index_left
func get_direction_neigbors_right(current_index_grid:int , width:int)->int : 
	var index_right = current_index_grid + 1
	var y_cur = int(current_index_grid/width)
	var y_right = int(index_right /width)
	if y_cur != y_right:
		index_right = -1
	return index_right
func get_direction_neigbors_bottom(current_index_grid:int , width:int)->int:
	var index_top = current_index_grid + width
	return index_top
func get_direction_neigbors_top(current_index_grid:int , width:int)->int:
	var index_bottom = current_index_grid - width
	return index_bottom
func get_neighbors_valid_unvisited(current_index_grid:int)->Array:
	var index_unvisited = []
	#check unvisited index
	var list_check_index =[
		get_direction_neigbors_left(current_index_grid,max_tile_width),
		get_direction_neigbors_right(current_index_grid, max_tile_width),
		get_direction_neigbors_top(current_index_grid,max_tile_width),
		get_direction_neigbors_bottom(current_index_grid,max_tile_width)
	]
	for list in list_check_index :
		if check_nighbors(list, true):
			index_unvisited.push_back(list)
	return index_unvisited
func get_neighbors_valid_visited(current_index_grid:int) ->int:
	var list_check_index =[
		get_direction_neigbors_left(current_index_grid,max_tile_width),
		get_direction_neigbors_right(current_index_grid, max_tile_width),
		get_direction_neigbors_top(current_index_grid,max_tile_width),
		get_direction_neigbors_bottom(current_index_grid, max_tile_width)
	]
	for list in list_check_index :
		if check_nighbors(list, false):
			return list
	return -1		
	

func get_random_neighbors_unvisited(current_index_grid:int ) -> int :
	var neighbors = get_neighbors_valid_unvisited(current_index_grid)
	if neighbors.size() > 0:
		var rnd = RandomNumberGenerator.new()
		rnd.randomize()
		return neighbors[rnd.randi_range(0 , neighbors.size()-1)]
	return -1	
func get_neibors_visited(current_index_grid:int)->int:
	return get_neighbors_valid_visited(current_index_grid)

func connect_grid(current_index_grid , next_index_grid):
	var first_cell_index_grid = grid[current_index_grid][0]
	var first_cell_next_grid  = grid[next_index_grid][0]

	var diff = first_cell_next_grid- first_cell_index_grid
	# print("diff:",diff, " next:" , first_cell_next_grid , " current:", first_cell_index_grid)
	if diff.x > 0 && diff.y == 0 : #right side 
		# print("go to right side")
		remove_cell_grid(first_cell_index_grid.x +center_cell.x , first_cell_index_grid.y  , wall_size * 2, center_cell.y)
	elif diff.x < 0 && diff.y == 0 : #left side
		# print("go to left side")
		remove_cell_grid(first_cell_index_grid.x - (wall_size * 2) , first_cell_index_grid.y , wall_size * 2, center_cell.y)
		
	if diff.x == 0 && diff.y < 0 :	#top side 
		# print("go to top side")
		remove_cell_grid(first_cell_index_grid.x, first_cell_index_grid.y - (wall_size * 2), center_cell.x , wall_size *2 )
	if diff.x == 0 && diff.y > 0 : #bottom side 
		# print("go to bottom side")
		remove_cell_grid(first_cell_index_grid.x, first_cell_index_grid.y + center_cell.y, center_cell.x , wall_size *2 )
	
	remove_cell_grid(first_cell_index_grid.x , first_cell_index_grid.y ,center_cell.x , center_cell.y)	
	remove_cell_grid(first_cell_next_grid.x ,first_cell_next_grid.y , center_cell.x , center_cell.y )
	
func remove_cell_grid(start_x , start_y , size_x , size_y):
	for i in range(size_x * size_y):
		var x = int(i) % int(size_x)
		var y = float(i) / float(size_x) 
		x += start_x
		y += start_y
		set_cell(x , y , -1)


func kill(current_index_grid):
	var next_index_grid = get_random_neighbors_unvisited(current_index_grid)
	if next_index_grid != -1:
		connect_grid(current_index_grid,next_index_grid)
		last_index=next_index_grid
		kill(next_index_grid)
	
		

func hunt()->int :
	for i in range(grid.size()):
		if get_cellv(grid[i][0]) > -1:
			continue
		var next_index_grid = get_neibors_visited(i)	
		if next_index_grid != -1:
			connect_grid(i , next_index_grid)
			last_index=next_index_grid
			return next_index_grid
	return -1		

func get_grid()->Array :
	return grid
func get_start_grid()->Array:
	return grid[start_index]
func get_last_grid()->Array :
	return grid[last_index]
func get_start_index()->int :
	return start_index
func get_last_index()->int:
	return last_index

func get_grid_size()->Vector2 :
	return cell_size * center_cell
#get object start position in center of center_cell 
func get_center_position(grid_idx)->Vector2:
	var gr = grid[grid_idx]
	var top_left_pos = gr[0] * cell_size
	var grid_size = center_cell * cell_size
	return top_left_pos+(grid_size/2) 


func get_start_position_center()	->Vector2 :
	return get_center_position(start_index)

func get_last_position_center()	->Vector2 :
	return get_center_position(last_index)



func check_wall(grid_idx ,add_start_x  , add_start_y )-> int :
	var gr = grid[grid_idx]
	var gr0 = gr[0]
	var wall_cell = Vector2(gr0.x +add_start_x ,  gr0.y + add_start_y)
	return get_cellv(wall_cell)
	
func grid_have_wall_left(grid_idx)->bool:
	var result = false
	var wall = check_wall(grid_idx , -1 , 0)
	if wall >= 0 :
		result= true
	return result
func grid_have_wall_right(grid_idx)->bool:
	var result = false
	var wall = check_wall(grid_idx , center_cell.x , 0)
	if wall >= 0 :
		result= true
	return result
func grid_have_wall_bottom(grid_idx)->bool:
	var result = false
	var wall = check_wall(grid_idx , 0 , center_cell.y)
	if wall >= 0 :
		result= true
	return result
func grid_have_wall_top(grid_idx)->bool:
	var result = false
	var wall = check_wall(grid_idx , 0 , -1)
	if wall >= 0 :
		result= true
	return result
