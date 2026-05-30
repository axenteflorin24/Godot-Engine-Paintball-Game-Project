extends Area3D






func _ready() -> void:
	
	body_entered.connect(on_area_body_entered)
	body_exited.connect(on_area_body_exited)
	



func _process(delta: float) -> void:
	
	pass

func on_area_body_exited(body):
	
	pass
			
func on_area_body_entered(body):
	
	if body is CharacterBody3D:
		
		if body.name.split('_')[0] == 'AIPlayer':
			
			if not body.entered_area_name == str(self.name):
				
				
				body._entered_area = false
				
				body.entered_area = 'true'
				
				body.entered_area_name = str(self.name)
