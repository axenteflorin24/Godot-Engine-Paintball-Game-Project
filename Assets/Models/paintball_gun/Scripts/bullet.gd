extends MeshInstance3D


@onready var SceneNode = $"../../../../../../.."
@onready var player = $"../../../../../.."
@onready var target_point  = $"../../../../../../CrossHair/CrossHairTexture"

var enabled = false

var first_run = true

var speed : float = 8.0
var max_speed : float = 23.0
var speed_sensivity : float = 1.08
var velocity : Vector3




var stored_pos = Vector3(0.0, 0.0, 0.0)



var _get_collinder = true

func _ready():
	
	get_positions()
	reparent(SceneNode)
	enabled = true
	
func get_positions():
	if speed < 80:

		stored_pos = target_point.ray_coordinate
	
	else:
		
		stored_pos = Vector3(-80.0, -80.0, -80.0)

func _physics_process(delta):
	
	if enabled == false:
		return

	RayCastSync()
	
	movement(delta)
	

func RayCastSync():
	
	if $RayCast3D.is_colliding() and _get_collinder == true:
		
		if not $RayCast3D.get_collider() == null:
			
			_get_collinder = false
			
			player.bullets_hit += 1
			
			player.bullet_collinder = $RayCast3D.get_collider().name
			
			queue_free()
			
func movement(delta):

	if enabled :
		
		speed += delta*speed_sensivity
		
		if speed > max_speed:
			
			speed = max_speed
		
		var direction = (stored_pos - global_position).normalized()
		
		velocity = direction*speed
		
		global_position += velocity * delta

func _on_lifetime_timeout() -> void:

	enabled = false
	queue_free()


func _on_visibility_timeout() -> void:
	transparency=0.0
