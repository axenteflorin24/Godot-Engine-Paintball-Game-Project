extends Node3D

@export var obstacles = []
@export var exit_points = []
@onready var obstacles_array = [[$BeamArray_001, 'multiple'], [$BrickBigArray_001, 'multiple'], [$obstacle, 'single'], [$obstacle2, 'single'], [$bnk_millenium, 'single'], [$XArray_001, 'multiple'], [$DorritoArray_001, 'multiple'], [$BrickMediumArray_001, 'multiple']] 
@onready var exit_points_array = [$"NavigationAreas/001", $"NavigationAreas/002", $"NavigationAreas/003", $"NavigationAreas/004", $"NavigationAreas/005", $"NavigationAreas/006", $"NavigationAreas/007", $"NavigationAreas/008", $"NavigationAreas/009", $"NavigationAreas/010", $"NavigationAreas/011", $"NavigationAreas/012", $"NavigationAreas/013", $"NavigationAreas/014", $"NavigationAreas/015", $"NavigationAreas/016", $"NavigationAreas/017", $"NavigationAreas/018", $"NavigationAreas/019", $"NavigationAreas/020", $"NavigationAreas/021", $"NavigationAreas/022", $"NavigationAreas/023", $"NavigationAreas/024", $"NavigationAreas/025", $"NavigationAreas/026", $"NavigationAreas/027", $"NavigationAreas/028", $"NavigationAreas/029", $"NavigationAreas/030"]


func _ready() -> void:
	init_obstacles()
	init_exit_points()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
	var temp = []
	for row in exit_points_array:
		temp.append(str(row.name))
		var array = row.get_children()
		for _row in array:
			if _row is Marker3D:
				temp.append(_row.global_position)
		exit_points.append(temp)
		temp = []

func get_exit_point(node_name, pos):
	for row in exit_points:
		if row[0] == node_name:
			var d = 99999999
			var _d = 99999999
			var _pos = Vector3.ZERO
			var i = 1
			var c = row.size()-1
			while i<=c:
				_d = pos.distance_to(row[i])
				if _d < d:
					d = _d
					_pos = row[i]
				i=i+1	
			return _pos
func get_next_exit_point(node_name, pos):
	for row in exit_points:
		if row[0] == node_name:
			var data = []
			var _d = 99999999
			var _pos = Vector3.ZERO
			var i = 1
			var c = row.size()-1
			while i<=c:
				_d = pos.distance_to(row[i])
				data.append([_d, row[i]])
				i=i+1	
			return data	
func get_type_of_obstacle(name):
	name = int(name)
	if name <= 30:
		return 'simple'
	return 'complex'
