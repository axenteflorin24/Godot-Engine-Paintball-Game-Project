extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rand_rotation()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var _delta = delta
	pass
	
func rand_rotation():
	rotation.y = deg_to_rad(randi_range(0,360))
