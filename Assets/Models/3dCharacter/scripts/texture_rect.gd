extends TextureRect

@export var ray_coordinate = Vector3(0.0, 0.0, 0.0)
@export var _ray_coordinate = Vector3(0.0, 0.0, 0.0)
@export var ray_collinder = 'none'

@export var ray_length: float = 1000.0


var crosshair_texture = null
var crosshair_action_texture = null
var crosshair_dissabled_texture = null



func _ready() -> void:
	load_textures()
func load_textures():

	var _crosshair_texture = load("res://Assets/Models/Scenes/Area1/Textures/crosshair.png")
	crosshair_texture = _crosshair_texture

	
	var _crosshair_action_texture = load("res://Assets/Models/Scenes/Area1/Textures/_crosshair.png")
	crosshair_action_texture = _crosshair_action_texture
	
	
	var _crosshair_dissabled_texture = load("res://Assets/Models/Scenes/Area1/Textures/crosshair_dissabled.png")
	crosshair_dissabled_texture = _crosshair_dissabled_texture

	
	
func _process(delta: float) -> void:
	
	new_raycast()
	var crosshair_pos = $".".global_position+Vector2(13, 13)
	#var crosshair_pos = $".".global_position + ($".".size / 2.0)
		
	var origin = $"../../SpringArmPivot/SpringArm3D/Camera3D".project_ray_origin(crosshair_pos)
	var end = origin + $"../../SpringArmPivot/SpringArm3D/Camera3D".project_ray_normal(crosshair_pos) * ray_length
		
		
	var query = PhysicsRayQueryParameters3D.create(origin, end)
		
	var space_state = $"../../SpringArmPivot/SpringArm3D/Camera3D".get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	
	
	if result:
		
		
		
		if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_backwards"):
			
			set("texture", crosshair_dissabled_texture)	
		
		else:
			
			if result.collider.name == 'player':
					
				set("texture", crosshair_dissabled_texture)
			
			else:
				
				if result.collider.name.split('_')[0] == 'AIPlayer':
					
					
						
					set("texture", crosshair_action_texture)
						
					
						
				else:
					set("texture", crosshair_texture)
		
			
		ray_collinder = result.collider.name
		
		ray_coordinate = result.position
	
	else:
		
		ray_collinder = 'player'
		set("texture", crosshair_dissabled_texture)


func new_raycast():
	
	if Input.is_action_just_pressed("action"):
		
		
		var crosshair_pos = $".".global_position
		
		
		var origin = $"../../SpringArmPivot/SpringArm3D/Camera3D".project_ray_origin(crosshair_pos)
		var end = origin + $"../../SpringArmPivot/SpringArm3D/Camera3D".project_ray_normal(crosshair_pos) * ray_length
		
		
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		
		var space_state = $"../../SpringArmPivot/SpringArm3D/Camera3D".get_world_3d().direct_space_state
		
		var result = space_state.intersect_ray(query)
		
		if result:
			_ray_coordinate = result.position
			
			
			
			
			
