extends Node

const SAVE_PATH = "user://pool_save.json"

func save_balls(balls: Array):
	var data = []
	
	for ball in balls:
		if ball: #ball exists
			data.append({
				"name": ball.name,
				"pos": ball.global_position})
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	print("Saved!", data)
