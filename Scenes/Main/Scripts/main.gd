extends Node3D



func _ready() -> void:
	pass



func _process(delta: float) -> void:
	var _delta = delta
	pass


func get_node_by_name(array_nodes, node_name, condition_a = ''):
	
	for row in array_nodes:
		
		if condition_a == '':
			
			if row.name == node_name:
				
				return row
		
		else:
			
			if row.name.split('_')[0] == condition_a:
				
				return row			
	
	return null
