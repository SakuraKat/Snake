extends Node

const SNAKE = 0
const APPLE = 1

var apple_position
var snake_body = [Vector2(5, 10), Vector2(4, 10), Vector2(3, 10)]
var snake_direction = Vector2(1, 0)
var add_apple = false

const UP = Vector2(0, -1)
const RIGHT = Vector2(1, 0)
const LEFT = Vector2(-1, 0)
const DOWN = Vector2(0, 1)

func _ready() -> void:
	apple_position = place_apple()
	
	draw_snake()

func place_apple():
	randomize()
	var x = randi() % 20
	var y = randi() % 20
	
	return Vector2(x, y)

func draw_apple():
	$SnakeApple.set_cell(apple_position.x, apple_position.y, APPLE)

func draw_snake():
	for block_index in snake_body.size():
		var block = snake_body[block_index]
		if block_index == 0:
			var head_direction = relation_to(snake_body[0], snake_body[1])
			if head_direction == "right":
				$SnakeApple.set_cell(block.x, block.y, SNAKE, true, false, false, Vector2(2,0))
			if head_direction == "left":
				$SnakeApple.set_cell(block.x, block.y, SNAKE, false, false, false, Vector2(2,0))
			if head_direction == "up":
				$SnakeApple.set_cell(block.x, block.y, SNAKE, false, false, false, Vector2(3,0))
			if head_direction == "down":
				$SnakeApple.set_cell(block.x, block.y, SNAKE, false, true, false, Vector2(3,0))
		
		elif block_index == snake_body.size() - 1:
			var tail_direction = relation_to(snake_body[-1], snake_body[-2])
			if tail_direction == "right":
				$SnakeApple.set_cell(block.x, block.y, SNAKE, false, false, false, Vector2(0,0))
			if tail_direction == "left":
				$SnakeApple.set_cell(block.x, block.y, SNAKE, true, false, false, Vector2(0,0))
			if tail_direction == "up":
				$SnakeApple.set_cell(block.x, block.y, SNAKE, false, true, false, Vector2(0,1))
			if tail_direction == "down":
				$SnakeApple.set_cell(block.x, block.y, SNAKE, false, false, false, Vector2(0,1))
		
		else:
			var previous_block = snake_body[block_index + 1] - block
			var next_block = snake_body[block_index - 1] - block
			
			if previous_block.y == next_block.y:
				$SnakeApple.set_cell(block.x, block.y, SNAKE, false, false, false, Vector2(4, 0))
			elif previous_block.x == next_block.x:
				$SnakeApple.set_cell(block.x, block.y, SNAKE, false, false, false, Vector2(4, 1))
			else:
				if previous_block.x == -1 and next_block.y == -1 or next_block.x == -1 and previous_block.y == -1:
					$SnakeApple.set_cell(block.x, block.y, SNAKE, true, true, false, Vector2(5, 0))
				if previous_block.x == -1 and next_block.y == 1 or next_block.x == -1 and previous_block.y == 1:
					$SnakeApple.set_cell(block.x, block.y, SNAKE, true, false, false, Vector2(5, 0))
				if previous_block.x == 1 and next_block.y == -1 or next_block.x == 1 and previous_block.y == -1:
					$SnakeApple.set_cell(block.x, block.y, SNAKE, false, true, false, Vector2(5, 0))
				if previous_block.x == 1 and next_block.y == 1 or next_block.x == 1 and previous_block.y == 1:
					$SnakeApple.set_cell(block.x, block.y, SNAKE, false, false, false, Vector2(5, 0))

func relation_to(first_block: Vector2, second_block: Vector2):
	var block_relation = second_block - first_block
	
	if block_relation == LEFT:
		return "left"
	if block_relation == DOWN:
		return "down"
	if block_relation == UP:
		return "up"
	if block_relation == RIGHT:
		return "right"

func move_snake():
	if add_apple:
		delete_tiles(SNAKE)
		var body_copy = snake_body.slice(0, snake_body.size() - 1)
		var new_head = body_copy[0] + snake_direction
		body_copy.insert(0, new_head)
		snake_body = body_copy
		add_apple = false
	else:
		delete_tiles(SNAKE)
		var body_copy = snake_body.slice(0, snake_body.size() - 2)
		var new_head = body_copy[0] + snake_direction
		body_copy.insert(0, new_head)
		snake_body = body_copy

func delete_tiles(id: int):
	var cells = $SnakeApple.get_used_cells_by_id(id)
	for cell in cells:
		$SnakeApple.set_cell(cell.x, cell.y, -1)

func _input(event: InputEvent) -> void:
	var head_direction = relation_to(snake_body[0], snake_body[1])
	if Input.is_action_just_pressed("ui_up"):
		if not head_direction == "up":
			snake_direction = UP
	if Input.is_action_just_pressed("ui_right"):
		if not head_direction == "right":
			snake_direction = RIGHT
	if Input.is_action_just_pressed("ui_left"):
		if not head_direction == "left":
			snake_direction = LEFT
	if Input.is_action_just_pressed("ui_down"):
		if not head_direction == "down":
			snake_direction = DOWN

func check_apple_eaten():
	if apple_position == snake_body[0]:
		apple_position = place_apple()
		add_apple = true
		get_tree().call_group("ScoreGroup", "update_score", snake_body.size())
		$CrunchSound.play()

func check_game_over():
	var head = snake_body[0]
	
	if head.x > 19 or head.x < 0 or head.y < 0 or head.y > 19:
		reset()
	
	for block in snake_body.slice(1, snake_body.size() - 1):
		if block == head:
			reset()

func reset():
	snake_body = [Vector2(5, 10), Vector2(4, 10), Vector2(3, 10)]
	snake_direction = Vector2(1, 0)

func _on_SnakeTick_timeout() -> void:
	draw_apple()
	move_snake()
	draw_snake()
	check_apple_eaten()

func _process(delta: float) -> void:
	check_game_over()
	if apple_position in snake_body:
		apple_position = place_apple()
