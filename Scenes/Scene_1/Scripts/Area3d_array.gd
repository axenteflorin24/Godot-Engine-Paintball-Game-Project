extends Area3D






func _ready() -> void:
	
	body_entered.connect(on_area_body_entered)
	body_exited.connect(on_area_body_exited)
	



func _process(delta: float) -> void:
	var _delta = delta
	pass

func on_area_body_exited(body):
	
	if body is CharacterBody3D:
		
		if body.name.split('_')[0] == 'AIPlayer':
			
			body.entered_area = 'false'
			
			body.entered_area_name = 'None'
			body.index_points = 0
			body.target_point[0] = body.movement_pos
			body.player_status = "random_walk"
			
			
			
			
func on_area_body_entered(body):
	
	if body is CharacterBody3D:
		
		if body.name.split('_')[0] == 'AIPlayer':
			
			if not body.entered_area_name == str(self.name):
	
				body.entered_area = 'true'
				
				body.entered_area_name = str(self.name)
