extends Node3D

@export var obstacles = []
@export var exit_points = []
@onready var obstacles_array = [] 
@onready var exit_points_array = []
@onready var NavigationAreas = $NavigationAreas

func _ready() -> void:
	
	init_obstacles()
	init_exit_points()
	


func _process(delta: float) -> void:
	var _delta = delta
	pass

func init_obstacles():

	for row in obstacles_array:
		if row[1] == 'multiple':
			var array = row[0].get_children()
			for _row in array:
				var _node = _row 
				var _pos = _row.global_position
				obstacles.append([_node, global_position])
		else:
			var _node = row[0]
			var _pos = row[0].global_position
			obstacles.append([_node, global_position])
			
func init_exit_points():
	var navigation_areas = NavigationAreas.get_children()
	for area in navigation_areas:
		exit_points_array.append(area)	
	var temp = []
	for row in exit_points_array:
		temp.append(str(row.name))
		var array = row.get_children()
		for _row in array:
			if _row is Marker3D:
				temp.append(_row.global_position)
		exit_points.append(temp)
		temp = []

func get_exit_points(node_name, target_point):
	var id = 0
	var temp = []
	for row in exit_points:
		if row[0] == node_name:
			for _row in row:
				
				if _row is Vector3:
					var d = _row.distance_to(target_point)
					
					temp.append([d,id,_row])
					id = id +1
	temp.sort()
	
	return temp[0]
func get_markers(node_name):
	var temp = []
	for row in exit_points:
		if row[0] == node_name:
			for _row in row:
				
				if _row is Vector3:
					
					
					temp.append(_row)
					
	
	
	return temp
func _get_exit_points(array, target_point):
	var id = 0
	var temp = []
	for row in array:
		
		if row is Vector3:
			var d = row.distance_to(target_point)
			temp.append([d,id,row])
			id = id+1
	temp.sort()
	return temp
