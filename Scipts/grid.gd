extends Node2D

#State Machine
enum {wait, move}
var state

#grid variable
@export var width : int
@export var height : int
@export var x_start : int
@export var y_start : int
@export var offset : int
@export var y_offset : int

#Obstacle stuff
@export var emty_space : PackedVector2Array
@export var ice_spaces: PackedVector2Array
@export var lock_spaces: PackedVector2Array
@export var concrete_spaces: PackedVector2Array
@export var slime_spaces: PackedVector2Array
var damaged_slime = false

#obstacle Signals
signal make_ice
signal damage_ice
signal make_lock
signal damage_lock
signal make_concrete
signal damage_concrete
signal make_slime
signal damage_slime

#Preset board
@export var preset_spaces: PackedVector3Array

# The piece array
var possible_pieces = [
	preload("res://Sences/blue_piece.tscn"),
	preload("res://Sences/light_green_piece.tscn"),
	preload("res://Sences/yellow_piece.tscn"),
	preload("res://Sences/pink_piece.tscn"),
	preload("res://Sences/orange_piece.tscn"),
	preload("res://Sences/green_piece.tscn")
]

#hint
@export var hint_effect: PackedScene
var hint = null
var hint_color = ""

# The current in the sence
var all_pieces = []
var clone_array = []
var current_matches = []

#Biến swap back
var piece_one = null
var piece_two = null
var last_place = Vector2(0,0)
var las_direction = Vector2(0,0)
var move_check = false

# Touch variable
var first_touch = Vector2(0,0)
var final_touch = Vector2(0,0)
var controlling = false

var color_bomb_used = false

#sinker
@export var sinker_piece: PackedScene
@export var sinker_in_sence: bool
@export var max_sinkers: int
var current_sinker = 0

#score variables
signal update_score
signal setup_max_score
@export var max_score: int
@export var piece_value: int
var streak = 1

#Counter variable
signal update_couter
@export var current_couter_value: int
@export var is_moves: bool
signal game_over

#goal signal
signal check_goal


#Effect
var particle_effect = preload("res://Sences/particle_effect.tscn")
var explode_effect = preload("res://Sences/explode.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	state = move
	randomize()
	all_pieces = make_2d_array()
	clone_array = make_2d_array()
	spawn_preset_pieces()
	if sinker_in_sence:
		spawn_sinker(max_sinkers)
	spawn_pieces()
	spawn_ice()
	spawn_lock()
	spawn_concrete()
	spawn_slime()
	emit_signal("update_couter", current_couter_value)
	emit_signal("setup_max_score", max_score)
	if !is_moves:
		$Timer.start()

func restrict_fill(place):
	if is_in_array(emty_space, place):
		return true
	if is_in_array(concrete_spaces, place):
		return true
	if is_in_array(slime_spaces, place):
		return true
	return false

func retrict_move(place):
	if is_in_array(lock_spaces, place):
		return true
	return false
	
func is_in_array(array, item):
	if array != null:
		for i in array.size():
			if array[i] == item:
				return true
	return false

func remove_from_array(array, item):
	for i in range(array.size() -1, -1, -1):
		if array[i] == item:
			array.remove_at(i)

func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array

func spawn_pieces():
	for i in width:
		for j in height:
			if !restrict_fill(Vector2(i,j)) and all_pieces[i][j] == null:
			#if all_pieces[i][j] == null:
			#choose a random number and store it
				var rand = floor(randf_range(0, possible_pieces.size()))
				var piece = possible_pieces[rand].instantiate()
				var loops = 0
				while(match_at(i, j, piece.color) && loops <100):
					rand = floor(randf_range(0, possible_pieces.size()))
					loops += 1
					piece = possible_pieces[rand].instantiate()
				# instance that piece from the array
				add_child(piece)
				piece.position = grid_to_pixel(i,j)
				all_pieces[i][j] = piece
	if is_deadblock():
		$shuffle.start()
	$hint.start()

func is_piece_sinker(col, row):
	if all_pieces[col][row] != null:
		if all_pieces[col][row].color == "None":
			return true
	return false
	pass

func spawn_ice():
	if ice_spaces != null:
		for i in ice_spaces.size():
			emit_signal("make_ice", ice_spaces[i])
		
func spawn_lock():
	if lock_spaces != null:
		for i in lock_spaces.size():
			emit_signal("make_lock", lock_spaces[i])
		
func spawn_concrete():
	if concrete_spaces != null:
		for i in concrete_spaces.size():
			emit_signal("make_concrete", concrete_spaces[i])

func spawn_slime():
	if slime_spaces != null:
		for i in slime_spaces.size():
			emit_signal("make_slime", slime_spaces[i])

func  spawn_sinker(number_to_spawn):
	for i in number_to_spawn:
		var column = floor(randf_range(0,width))
		while !is_piece_null(column, height-1) and restrict_fill(Vector2(column,height-1)):
			column = floor(randf_range(0, width))
		var current = sinker_piece.instantiate()
		add_child(current)
		current.position = grid_to_pixel(column, height-1)
		all_pieces[column][height -1] = current
		current_sinker += 1

func spawn_preset_pieces():
	if preset_spaces != null:
		if preset_spaces.size() > 0:
			for i in preset_spaces.size():
				var piece = possible_pieces[preset_spaces[i].z].instantiate()
				add_child(piece)
				piece.position = grid_to_pixel(preset_spaces[i].x, preset_spaces[i].y)
				all_pieces[preset_spaces[i].x][preset_spaces[i].y] = piece

func match_at(i, j, color):
	if i > 1:
		if all_pieces[i-1][j] != null && all_pieces[i-2][j] != null:
			if all_pieces[i-1][j].color == color && all_pieces[i-2][j].color == color:
				return true
	if j > 1:
		if all_pieces[i][j-1] != null && all_pieces[i][j-2] != null:
			if all_pieces[i][j-1].color == color && all_pieces[i][j-2].color == color:
				return true

func grid_to_pixel(column,row):
	var new_x = x_start + offset * column
	var new_y = y_start + -offset * row
	return Vector2(new_x,new_y)

func pixel_to_grid(pixel_x, pixel_y):
	var new_x = round((pixel_x - x_start) / offset)
	var new_y = round((pixel_y - y_start) / -offset)
	return Vector2(new_x,new_y)

func is_in_grid(grid_position):
	if grid_position.x >= 0 && grid_position.x < width:
		if grid_position.y >= 0 && grid_position.y < height:
			return true
	return false

func touch_input():
	var mouse = get_global_mouse_position()
	mouse = pixel_to_grid(mouse.x,mouse.y)
	if Input.is_action_just_pressed("ui_touch"):
		if is_in_grid(mouse):
			first_touch = mouse
			controlling = true
			if hint != null:
				hint.queue_free()
	if Input.is_action_just_released("ui_touch"):
		if is_in_grid(mouse) && controlling:
			controlling = false
			final_touch = mouse
			touch_difference(first_touch, final_touch)
		
func swap_piece(column, row, direction):
	var first_piece = all_pieces[column][row]
	var other_piece = all_pieces[column+direction.x][row+direction.y]
	if first_piece != null && other_piece != null:
		if !retrict_move(Vector2(column, row)) and !retrict_move(Vector2(column, row) + direction):
			if first_piece.color == "Color" and other_piece.color == "Color":
				clear_board()
			if is_color_bomb(first_piece, other_piece):
				if is_piece_sinker(column, row) or is_piece_sinker(column + direction.x, row + direction.y):
					swap_back()
					return
				if first_piece.color == "Color":
					match_color(other_piece.color)
					match_and_dim(first_piece)
					add_to_array(Vector2(column,row))
				else:
					match_color(first_piece.color)
					match_and_dim(other_piece)
					add_to_array(Vector2(column + direction.x, row + direction.y))
			store_info(first_piece, other_piece, Vector2(column, row), direction)
			state = wait
			all_pieces[column][row] = other_piece
			all_pieces[column+direction.x][row+direction.y] = first_piece
			first_piece.move(grid_to_pixel(column+direction.x, row+direction.y))
			other_piece.move(grid_to_pixel(column, row))
			if !move_check:
				find_matches()

func is_color_bomb(piece_one, piece_two):
	if piece_one.color == "Color" or piece_two.color == "Color":
		color_bomb_used = true
		return true
	return false
	

func store_info(first_piece, other_piece, place, direction):
	piece_one = first_piece
	piece_two = other_piece
	las_direction = direction
	last_place = place
	pass

func swap_back():
	#Trả lại vị trí nếu không đúng
	if piece_one != null && piece_two != null:
		swap_piece(last_place.x, last_place.y, las_direction)
	state = move
	move_check = false
	$hint.start()

func touch_difference(grid_1, grid_2):
	var difference = grid_2 - grid_1
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap_piece(grid_1.x, grid_1.y, Vector2(1,0))
		elif difference.x < 0:
			swap_piece(grid_1.x, grid_1.y, Vector2(-1,0))
	elif abs(difference.y) > abs(difference.x):
		if difference.y > 0:
			swap_piece(grid_1.x, grid_1.y, Vector2(0,1))
		elif difference.y < 0:
			swap_piece(grid_1.x, grid_1.y, Vector2(0,-1))
			
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if state == move:
		touch_input()
	
func find_matches(query = false, array = all_pieces):
	for i in width:
		for j in height:
			if array[i][j] != null and !is_piece_sinker(i,j):
				var current_color = array[i][j].color
				if i > 0 && i < width - 1:
					if array[i-1][j] != null && array[i+1][j] != null:
						if array[i-1][j].color == current_color && array[i+1][j].color == current_color:
							if query:
								hint_color = current_color
								return true
							match_and_dim(array[i-1][j])
							match_and_dim(array[i][j])
							match_and_dim(array[i+1][j])
							add_to_array(Vector2(i,j))		
							add_to_array(Vector2(i+1,j))
							add_to_array(Vector2(i-1,j))
				if j > 0 && j < height - 1:
					if array[i][j-1] != null && array[i][j+1] != null:
						if array[i][j-1].color == current_color && array[i][j+1].color == current_color:
							if query:
								hint_color = current_color
								return true
							match_and_dim(array[i][j-1])
							match_and_dim(array[i][j])
							match_and_dim(array[i][j+1])
							add_to_array(Vector2(i,j))
							add_to_array(Vector2(i,j+1))
							add_to_array(Vector2(i,j-1))
	if query:
		return false
	get_bombed_pieces()
	get_parent().get_node("destroy_timer").start()

func get_bombed_pieces():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					if all_pieces[i][j].is_column_bomb:
						match_all_in_column(i)
					elif all_pieces[i][j].is_row_bomb:
						match_all_in_row(j)
					elif all_pieces[i][j].is_adjacent_bomb:
						find_adjacent_piece(i,j)

func add_to_array(value, array_to_add = current_matches):
	if !array_to_add.has(value):
		array_to_add.append(value)

func is_piece_null(column, row):
	if all_pieces[column][row] == null:
		return true
	return false

func match_and_dim(item):
	item.matched = true
	item.dim() 

func find_bomb():
	if !color_bomb_used:
		for i in current_matches.size():
			#store value for this match
			var current_column = current_matches[i].x
			var current_row = current_matches[i].y
			var current_color = all_pieces[current_column][current_row].color
			var col_matched = 0
			var row_matched = 0
			#
			for j in current_matches.size():
				var this_column = current_matches[j].x
				var this_row = current_matches[j].y
				var this_color = all_pieces[this_column][this_row].color
				if this_column == current_column and current_color == this_color:
					col_matched += 1 
				if this_row == current_row and this_color == current_color:
					row_matched +=1
			if col_matched == 4:
				make_bomb(2, current_color)
				continue
			elif row_matched == 4:
				make_bomb(1, current_color)
				continue
			elif col_matched >= 3 and row_matched >= 3:
				make_bomb(0, current_color)
				continue
			elif col_matched == 5 or row_matched == 5:
				make_bomb(3, current_color)
				continue

func make_bomb(bomb_type, color):
	for i in current_matches.size():
		var current_column = current_matches[i].x
		var current_row = current_matches[i].y
		if all_pieces[current_column][current_row] == piece_one and piece_one.color == color:
			damage_special(current_column, current_row)
			emit_signal("check_goal", piece_one.color)
			piece_one.matched = false
			change_bomb(bomb_type, piece_one)
		elif all_pieces[current_column][current_row] == piece_two and piece_two.color == color:
			damage_special(current_column, current_row)
			emit_signal("check_goal", piece_two.color)
			piece_two.matched = false
			change_bomb(bomb_type, piece_two)

func change_bomb(bomb_type, piece):
	if bomb_type == 0:
		piece.make_adjacent_bomb()
	elif bomb_type == 1:
		piece.make_row_bomb()
	elif bomb_type == 2:
		piece.make_column_bomb()
	elif bomb_type == 3:
		piece.make_color_bomb()

func destroy_match():
	find_bomb()
	var was_matched = false
	for i in width:
		for j in height:
			if !is_piece_null(i,j):
				if all_pieces[i][j].matched:
					emit_signal("check_goal", all_pieces[i][j].color)
					damage_special(i,j)
					was_matched = true
					all_pieces[i][j].queue_free()
					all_pieces[i][j] = null
					make_effect(particle_effect, i, j)
					make_effect(explode_effect, i, j)
					emit_signal("update_score", piece_value* streak)
	move_check = true 
	if was_matched:
		get_parent().get_node("collapse_timer").start()
	else:
		swap_back()
		current_matches.clear()

func make_effect(effect, column, row):
	var current = effect.instantiate()
	current.position = grid_to_pixel(column,row)
	add_child(current)

func check_concrete(column, row):
	#check right
	if column < width - 1:
		emit_signal("damage_concrete", Vector2(column+1,row))
	#check left
	if column > 0:
		emit_signal("damage_concrete", Vector2(column-1,row))
	#check up
	if row < height - 1:
		emit_signal("damage_concrete", Vector2(column,row+1))
	#check down
	if row > 0:
		emit_signal("damage_concrete", Vector2(column,row-1))

func check_slime(column, row):
	#check right
	if column < width - 1:
		emit_signal("damage_slime", Vector2(column+1,row))
	#check left
	if column > 0:
		emit_signal("damage_slime", Vector2(column-1,row))
	#check up
	if row < height - 1:
		emit_signal("damage_slime", Vector2(column,row+1))
	#check down
	if row > 0:
		emit_signal("damage_slime", Vector2(column,row-1))

func damage_special(column, row):
	emit_signal("damage_ice", Vector2(column,row))
	emit_signal("damage_lock", Vector2(column,row))
	check_concrete(column, row)
	check_slime(column,row)

func match_color(color):
	for i in width:
		for j in height:
			if all_pieces[i][j] != null and !is_piece_sinker(i,j):
				if all_pieces[i][j].color == color:
					if all_pieces[i][j].is_column_bomb:
						match_all_in_column(i)
					if all_pieces[i][j].is_row_bomb:
						match_all_in_row(j)
					if all_pieces[i][j].is_adjacent_bomb:
						find_adjacent_piece(i,j)
					match_and_dim(all_pieces[i][j])
					add_to_array(Vector2(i,j))

func clear_board():
	for i in width:
		for j in height:
			if !is_piece_null(i,j) and !is_piece_sinker(i,j):
				match_and_dim(all_pieces[i][j])
				add_to_array(Vector2(i,j))

func collapse_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null && !restrict_fill(Vector2(i,j)):
				for k in range(j+1, height):
					if all_pieces[i][k] != null:
						all_pieces[i][k].move(grid_to_pixel(i,j))
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][k] = null
						break
	destroy_sinker()
	get_parent().get_node("refill_timer").start()

func refill_columns():
	if current_sinker < max_sinkers:
		spawn_sinker(max_sinkers-current_sinker)
	streak +=1
	for i in width:
		for j in height:
			if all_pieces[i][j] == null && !restrict_fill(Vector2(i,j)):
			#choose a random number and store it
				var rand = floor(randf_range(0, possible_pieces.size()))
				var piece = possible_pieces[rand].instantiate()
				var loops = 0
				while(match_at(i, j, piece.color) && loops <100):
					rand = floor(randf_range(0, possible_pieces.size()))
					loops += 1
					piece = possible_pieces[rand].instantiate()
				# instance that piece from the array
				add_child(piece)
				piece.position = (grid_to_pixel(i, j-y_offset))
				piece.move(grid_to_pixel(i,j))
				all_pieces[i][j] = piece
	after_refill()

func after_refill():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if match_at(i, j, all_pieces[i][j].color) or all_pieces[i][j].matched:
					find_matches()
					get_parent().get_node("destroy_timer").start()
					return
	if !damaged_slime:
		generate_slime()
	state = move
	streak = 1
	move_check = false
	damaged_slime = false
	color_bomb_used = false
	if is_deadblock():
		print("deadblock")
		$shuffle.start()
	current_matches.clear()
	_on_timer_timeout()
	$hint.start()
			

func generate_slime():
	if slime_spaces.size() > 0:
		var slime_made = false
		var tracker = 0
		while !slime_made and tracker < 100:
			#check random slime
			var random_num = floor(randf_range(0,slime_spaces.size()))
			var curr_x = slime_spaces[random_num].x
			var curr_y = slime_spaces[random_num].y
			var neighbor = find_normal_neighbor(curr_x, curr_y)
			if neighbor != null:
				# Turn that neighbor into slime
				all_pieces[neighbor.x][neighbor.y].queue_free()
				#set it to null
				all_pieces[neighbor.x][neighbor.y] = null
				# Add this new spot to array of slimes
				slime_spaces.append(Vector2(neighbor.x,neighbor.y))
				#send a signal to slime_holder to make new slime
				emit_signal("make_slime", Vector2(neighbor.x, neighbor.y))
				slime_made = true
			tracker += 1

func find_normal_neighbor(column, row):
	#check right
	if is_in_grid(Vector2(column+1,row)) and !is_piece_sinker(column+1,row):
		if !is_piece_null(column+1,row):
			return Vector2(column+1, row)
	#check left
	elif is_in_grid(Vector2(column-1,row)) and !is_piece_sinker(column-1,row):
		if !is_piece_null(column-1,row):
			return Vector2(column-1, row)
	#check up
	elif is_in_grid(Vector2(column,row+1)) and !is_piece_sinker(column,row+1):
		if !is_piece_null(column,row+1):
			return Vector2(column, row+1)
	#check down
	elif is_in_grid(Vector2(column,row-1)) and !is_piece_sinker(column,row-1):
		if !is_piece_null(column,row-1):
			return Vector2(column, row-1)
			
	return null

func match_all_in_column(column):
	for i in height:
		if all_pieces[column][i] != null and !is_piece_sinker(column,i):
			if all_pieces[column][i].is_row_bomb:
				match_all_in_row(i)
			if all_pieces[column][i].is_adjacent_bomb:
				find_adjacent_piece(column,i)
			if all_pieces[column][i].is_color_bomb:
				match_color(column[i].color)
			all_pieces[column][i].matched = true

func match_all_in_row(row):
	for i in width:
		if all_pieces[i][row] != null and !is_piece_sinker(i,row):
			if all_pieces[i][row].is_column_bomb:
				match_all_in_column(i)
			if all_pieces[i][row].is_adjacent_bomb:
				find_adjacent_piece(i,row)
			if all_pieces[i][row].is_color_bomb:
				match_color(all_pieces[i][row].color)
			all_pieces[i][row].matched = true

func find_adjacent_piece(column,row):
	for i in range(-1,2):
		for j in range(-1,2):
			if is_in_grid(Vector2(column+i,row+j)):
				if all_pieces[column+i][row+j] != null and !is_piece_sinker(column+i,row + j):
					if all_pieces[column+i][row + j].is_row_bomb:
						match_all_in_row(j)
					if all_pieces[column + i][row+j].is_column_bomb:
						match_all_in_column(i)
					if all_pieces[column+i][row+j].is_color_bomb:
						match_color(all_pieces[column+i][row+j])
					all_pieces[column+i][row+j].matched = true

func destroy_sinker():
	for i in width:
			if all_pieces[i][0] != null:
				if all_pieces[i][0].color == "None":
					all_pieces[i][0].matched = true
					current_sinker -= 1

func switch_pieces(place, direction, array):
	if is_in_grid(place) and !restrict_fill(place):
		if is_in_grid(place + direction) and !restrict_fill(place + direction):
			#first, hold piece to swap
			var holder = array[place.x + direction.x][place.y + direction.y]
			#then set swap spot as original piece
			array[place.x + direction.x][place.y + direction.y] = array[place.x][place.y]
			#then set the original spot as other piece
			array[place.x][place.y] = holder

func is_deadblock():
	clone_array = copy_array(all_pieces)
	for i in width:
		for j in height:
			#switch and check right
			if switch_and_check(Vector2(i,j), Vector2(1,0), clone_array):
				return false
			# up
			if switch_and_check(Vector2(i,j), Vector2(0,1), clone_array):
				return false
	return true

func switch_and_check(place, direction, array):
	switch_pieces(place, direction, array)
	if find_matches(true, array):
		switch_pieces(place, direction, array)
		return true
	switch_pieces(place, direction, array)
	return false

func copy_array(array_to_copy):
	var new_array = make_2d_array()
	for i in width:
		for j in height:
			new_array[i][j] = array_to_copy[i][j]
	return new_array

func clear_and_store_board():
	var holder_array = []
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				holder_array.append(all_pieces[i][j])
				all_pieces[i][j] = null
	return holder_array

func shuffle_board():
	var holder_array = clear_and_store_board()
	for i in width:
		for j in height:
			if !restrict_fill(Vector2(i,j)) and all_pieces[i][j] == null:
			#if all_pieces[i][j] == null:
			#choose a random number and store it
				var rand = floor(randf_range(0, holder_array.size()))
				var piece = holder_array[rand]
				var loops = 0
				while(match_at(i, j, piece.color) && loops <100):
					rand = floor(randf_range(0, holder_array.size()))
					loops += 1
					piece = holder_array[rand]
				# instance that piece from the array
				piece.move(grid_to_pixel(i,j))
				all_pieces[i][j] = piece
				holder_array.remove_at(rand)
	if is_deadblock():
		shuffle_board()
	state = move

func find_all_matches():
	var hint_holder = []
	clone_array = copy_array(all_pieces)
	for i in range(width):
		for j in range(height):
			if clone_array[i][j] != null:
				if switch_and_check(Vector2(i,j), Vector2(1,0), clone_array):
					#add to hint array
					if hint_color != "":
						if hint_color == clone_array[i][j].color:
							hint_holder.append(clone_array[i][j])
						else:
							hint_holder.append(clone_array[i+1][j])
				if switch_and_check(Vector2(i,j), Vector2(0,1), clone_array):
					if hint_color != "":
						if hint_color == clone_array[i][j].color:
							hint_holder.append(clone_array[i][j])
						else:
							hint_holder.append(clone_array[i][j+1])
	return hint_holder

func generate_hint():
	#if hint != null:
		#hint.queue_free()
	var hints = find_all_matches()
	if hints != null:
		var rand = floor(randf_range(0, hints.size()))
		hint = hint_effect.instantiate()
		add_child(hint)
		hint.position = hints[rand].position
		hint.Setup(hints[rand].get_node("Sprite").texture)
		

func _on_destroy_timer_timeout():
	destroy_match()

func _on_collapse_timer_timeout():
	collapse_columns()

func _on_refill_timer_timeout():
	refill_columns()

func _on_lock_holder_remove_lock(place):
	for i in range(lock_spaces.size() -1, -1, -1):
		if lock_spaces[i] == place:
			lock_spaces.remove_at(i)

func _on_concrete_holder_remove_crete(place):
	for i in range(concrete_spaces.size() -1, -1, -1):
		if concrete_spaces[i] == place:
			concrete_spaces.remove_at(i)

func _on_slime_holder_remove_slime(place):
	damaged_slime = true 
	for i in range(slime_spaces.size() -1, -1, -1):
		if slime_spaces[i] == place:
			slime_spaces.remove_at(i)

func _on_timer_timeout():
	current_couter_value -=1
	emit_signal("update_couter")
	if current_couter_value == 0:
		declare_game_over()
		$Timer.stop()

func declare_game_over():
	emit_signal("game_over")
	state = wait

func _on_goal_holder_game_won():
	state = wait 


func _on_shuffle_timeout():
	shuffle_board()

func _on_hint_timeout():
	generate_hint()
