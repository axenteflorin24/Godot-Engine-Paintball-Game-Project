extends CharacterBody3D







var _delta = 0.0

var ROOT = null
var SCENE = null

@onready var bullet_sounds = [$sfx/bullet_a, $sfx/bullet_b, $sfx/bullet_c, $sfx/bullet_d]
@onready var BulletSpawnLocation = $Armature/Skeleton3D/Animated_collision_r_hand/paintball_gun/bullet_spawn_location
@onready var world = $".."
@onready var animator : AnimationTree = $AnimationTree


@export var ray_length: float = 0.68 
var rays: Dictionary = {}


var ray_directions = {
	"forward": Vector3(0, 0, -1),
	"forward_right": Vector3(1, 0, -1).normalized(),
	"right": Vector3(1, 0, 0),
	"backward_right": Vector3(1, 0, 1).normalized(),
	"backward": Vector3(0, 0, 1),
	"backward_left": Vector3(-1, 0, 1).normalized(),
	"left": Vector3(-1, 0, 0),
	"forward_left": Vector3(-1, 0, -1).normalized()
}




@export var gravity : float = 9.8

@export var crounching = false
@export var prone = false
@export var action = false
@export var player_status = "random_walk"
@export var movement_pos = Vector3.ZERO



var exit_point = Vector3.ZERO

@export var entered_area = 'false'
@export var entered_area_name = 'None'




var skip_exit_point = false


var player_collision_deff = Vector2(0.23, 1.733)
var player_collision_crounching = Vector2(0.18, 1.383)

var CustomCollisions  = []

var random_locations = []
var random_locations_size = 0
var wait_time = 0.0
var _stored_wait_time = 0.0
var safe_movement = false



var stored_d = 0.0 
var counts_d = 0


@export var target_point = [Vector3.ZERO]
var obstacle_points = []
@export var index_points: int = 0


var safe_movents_applied = 0


var runs = 0
var player_walking_counter = 0.0

@export var speed = 1.5
@export var turn_speed = 2.0

func _ready():
	
	for _name in ray_directions:
		var ray = RayCast3D.new()
		
		ray.target_position = ray_directions[_name] * ray_length
		
		ray.enabled = true
		
		ray.add_exception(self)

		
		add_child(ray)
		rays[_name] = ray
	
	
	init_custom_collisions()
	animator.set("parameters/transitions/transition_request", "idle")
	entered_area = 'false'
	init_scene()
	init_random_locations()
	movement_pos = global_position
	_stored_wait_time = 1.3688
	name = name_generator()

func _physics_process(delta):
	
	_delta = delta
	CollisionsSync()
	
	
	if not is_on_floor():
		velocity.y -=gravity * delta
	
	if velocity == Vector3.ZERO:
		if not animator.get("parameters/transitions/current_state") == 'idle':
			animator.set("parameters/transitions/transition_request", "idle")

	if player_status == 'random_walk':
		movement()
	if player_status == 'obstacle_avoidance':
		obstacle_avoidance()
	move_and_slide()
	
#Animations
func look_at_lerp(target_position: Vector3, delta: float):

	var direction = (target_position - global_position).normalized()
	var target_rotation = atan2(-direction.x, -direction.z)
	
	if not target_rotation == null:
		global_rotation.y = lerp_angle(global_rotation.y, target_rotation, delta * 2.38)	

func _movement(pos, _speed = 2.68):

	var d = global_position.distance_to(pos)
	
	if d<= 0.08:
		pos=global_position

	var direction = (pos - global_position).normalized()

	if not velocity == Vector3.ZERO:
		look_at_lerp(Vector3(pos.x, global_position.y, pos.z), _delta)	
		
	if rays["forward"].is_colliding():
			if not rays["forward"].get_collider() == null:
				if rays["forward"].get_collider().name.split('_')[0] == "AIPlayer":
					
					if not rays["forward_right"].is_colliding():
						direction += transform.basis.x * 0.43
					elif not rays["forward_left"].is_colliding():
						direction += -transform.basis.x * 0.43
					else:
						
						direction += transform.basis.x * 0.43

	if rays["forward_right"].is_colliding():
			if not rays["forward_right"].get_collider() == null:
				if rays["forward_right"].get_collider().name.split('_')[0] == "AIPlayer":
					direction += -transform.basis.x * 0.43 + transform.basis.z * 0.43

	if rays["forward_left"].is_colliding():
			if not rays["forward_left"].get_collider() == null:
				if rays["forward_left"].get_collider().name.split('_')[0] == "AIPlayer":
					direction += transform.basis.x * 0.43 + transform.basis.z * 0.43

	if rays["right"].is_colliding():
			if not rays["right"].get_collider() == null:
				if rays["right"].get_collider().name.split('_')[0] == "AIPlayer":
					direction += -transform.basis.x * 0.43

	if rays["left"].is_colliding():
			if not rays["left"].get_collider() == null:
				if rays["left"].get_collider().name.split('_')[0] == "AIPlayer":
					direction += transform.basis.x * 0.43

	if rays["backward"].is_colliding():
			if not rays["backward"].get_collider() == null:
				if rays["backward"].get_collider().name.split('_')[0] == "AIPlayer":
					direction += -transform.basis.z * 0.43
			
	if rays["backward_right"].is_colliding():
			if not rays["backward_right"].get_collider() == null:
				if rays["backward_right"].get_collider().name.split('_')[0] == "AIPlayer":
					direction += -transform.basis.x * 0.43
			
	if rays["backward_left"].is_colliding():
			if not rays["backward_left"].get_collider() == null:
				if rays["backward_left"].get_collider().name.split('_')[0] == "AIPlayer":
					direction += transform.basis.x * 0.43
		
	
	
	
	
	
	
	velocity.x = direction.x*_speed
	velocity.z = direction.z*_speed
	
	global_position.x += velocity.x * _delta
	global_position.z += velocity.z * _delta
	global_position.y = global_position.y
	
func obstacle_avoidance(_speed = 1.8):
	

	var d = global_position.distance_to(target_point[index_points])
			
	if d<= 0.25:
		index_points = index_points+1

	
	if index_points > target_point.size()-1:
		entered_area = 'false'
		entered_area_name = 'None'
		velocity = Vector3.ZERO
		player_status = 'random_walk'
		index_points = 0
	else:

		
		var direction = (target_point[index_points] - global_position).normalized()

		if not velocity == Vector3.ZERO:
		
			look_at_lerp(Vector3(target_point[index_points].x, global_position.y, target_point[index_points].z), _delta)	
			

		if rays["forward"].is_colliding():
			if not rays["forward"].get_collider() == null:
				if rays["forward"].get_collider().name.split('_')[0] == "AIPlayer":
					if not rays["forward_right"].is_colliding():
						direction += transform.basis.x * 0.43
					elif not rays["forward_left"].is_colliding():
						direction += -transform.basis.x * 0.43
					else:
						
						direction += transform.basis.x * 0.43
		if rays["forward_right"].is_colliding():
			if not rays["forward_right"].get_collider() == null:
				if rays["forward_right"].get_collider().name.split('_')[0] == "AIPlayer":
					direction += -transform.basis.x * 0.43 + transform.basis.z * 0.43

		if rays["forward_left"].is_colliding():

			if not rays["forward_left"].get_collider() == null:
				if rays["forward_left"].get_collider().name.split('_')[0] == "AIPlayer":
					direction += transform.basis.x * 0.43 + transform.basis.z * 0.43

		if rays["right"].is_colliding():
			if not rays["right"].get_collider() == null:
				if rays["right"].get_collider().name.split('_')[0] == "AIPlayer":
					direction += -transform.basis.x * 0.43

		if rays["left"].is_colliding():
			if not rays["left"].get_collider() == null:
				if rays["left"].get_collider().name.split('_')[0] == "AIPlayer":
					direction += transform.basis.x * 0.43

		if rays["backward"].is_colliding():
			if not rays["backward"].get_collider() == null:
				if rays["backward"].get_collider().name.split('_')[0] == "AIPlayer":
					direction += -transform.basis.z * 0.43
			
		if rays["backward_right"].is_colliding():
			if not rays["backward_right"].get_collider() == null:
				if rays["backward_right"].get_collider().name.split('_')[0] == "AIPlayer":
					direction += -transform.basis.x * 0.43
			
		if rays["backward_left"].is_colliding():
			if not rays["backward_left"].get_collider() == null:
				if rays["backward_left"].get_collider().name.split('_')[0] == "AIPlayer":
					direction += transform.basis.x * 0.43
		
		
		
		velocity.x = direction.x*_speed
		velocity.z = direction.z*_speed
		if not velocity == Vector3.ZERO:
			if not animator.get("parameters/transitions/current_state") == 'walking':
				animator.set("parameters/transitions/transition_request", "walking")
		global_position.x += velocity.x * _delta
		
		global_position.z += velocity.z * _delta
		
		global_position.y = global_position.y	
	
	
	
func movement():
	
	if entered_area == 'true':
		
		if not player_status == 'obstacle_avoidance':
			var _pos = target_point[0]
			target_point.clear()

			var markers_list = SCENE.get_markers(entered_area_name)
			var markers = SCENE.get_exit_points(entered_area_name, global_position)
	
			var _check =  SCENE._get_exit_points(markers_list, _pos)

			
			if markers[1] == _check[0][1]:
				
				
				target_point.append(_pos)
				entered_area = 'false'
				entered_area_name = 'None'
				
				player_status = 'random_walk'
				index_points = 0				
			
			else:
				
				
				var i = markers[1]
				var c = _check[0][1]
				
				if i <= c:
				
					while i<=c:
						target_point.append(markers_list[i])
						i=i+1
					target_point.append(_pos)

				else:
					while i>c:
						target_point.append(markers_list[i])
						
						i=i-1
					target_point.append(_pos)	
			
			if target_point.size() > 4:
				var temp = []
				var i=0
				for row in target_point:
					if i > 0:
						temp.append(row)
					i=i+1
				target_point = temp
			
			
			
			
			player_status = 'obstacle_avoidance'
	else:	

		if not velocity == Vector3.ZERO:
			if not animator.get("parameters/transitions/current_state") == 'walking':
				animator.set("parameters/transitions/transition_request", "walking")
		else:
			if not animator.get("parameters/transitions/current_state") == 'idle':
				animator.set("parameters/transitions/transition_request", "idle")
		
		_movement(movement_pos)

#SFX
func _sfxSync():
	$sfx.global_position = global_position	

#Functions
func CollisionsSync():

	$player_collision.global_rotation = $Armature/Skeleton3D/Animated_collision_hips/Animated_collision_hips.global_rotation
	if prone:
		$player_collision.global_position.y = $Armature/Skeleton3D/Animated_collision_hips/Animated_collision_hips.global_position.y+0.18
	else:
		if crounching:
			$player_collision.global_position.y = $Armature/Skeleton3D/Animated_collision_hips/Animated_collision_hips.global_position.y
		else:
			$player_collision.global_position.y = $Armature/Skeleton3D/Animated_collision_hips/Animated_collision_hips.global_position.y-0.20
	
	for row in CustomCollisions:
		
		if not row['target'] == null and not row['source'] == null:
			
			row['target'].global_position = row['source'].global_position
			
			
			row['target'].global_rotation = row['source'].global_rotation
			
			if not row['angle'] == null:
				
				row['target'].global_rotation.z = row['angle']

func name_generator():
	
	var random_a = randi_range(1, 100)
	var random_b = randi_range(1, 1000)
	var random_c = randi_range(1, 10000)
	
	var random_name = 'AIPlayer_'+str(random_a)+'_'+str(random_b)+'_'+str(random_c)
	return random_name
	
func check_node(_Node, Name):
	var array = _Node.get_children()
	for row in array:
		
		if row.name == Name:
			return true
	return false

func init_custom_collisions():
	CustomCollisions = [{ "target" : $Animated_collision_head, "source" : $Armature/Skeleton3D/Animated_collision_head/Animated_collision_head, "angle" : null}, { "target" : $Animated_collision_neck, "source" : $Armature/Skeleton3D/Animated_collision_neck/Animated_collision_neck, "angle" : null}, { "target" : $Animated_collision_upper_body, "source" : $Armature/Skeleton3D/Animated_collision_upper_body/Animated_collision_upper_body,"angle" : 89.8}, { "target" : $Animated_collision_body, "source" : $Armature/Skeleton3D/Animated_collision_body/Animated_collision_body, "angle" : null}, { "target" : $Animated_collision_hips, "source" : $Armature/Skeleton3D/Animated_collision_hips/Animated_collision_hips, "angle" : null}, { "target" : $Animated_collision_r_up_leg, "source" : $Armature/Skeleton3D/Animated_collision_r_up_leg/Animated_collision_r_up_leg, "angle" : null}, { "target" : $Animated_collision_l_up_leg, "source" : $Armature/Skeleton3D/Animated_collision_l_up_leg/Animated_collision_l_up_leg, "angle" : null}, { "target" : $Animated_collision_r_leg, "source" : $Armature/Skeleton3D/Animated_collision_r_leg/Animated_collision_r_leg, "angle" : null}, { "target" : $Animated_collision_l_leg, "source" : $Armature/Skeleton3D/Animated_collision_l_leg/Animated_collision_l_leg, "angle" : null}, { "target" : $Animated_collision_r_foot, "source" : $Armature/Skeleton3D/Animated_collision_r_foot/Animated_collision_r_foot, "angle" : null}, { "target" : $Animated_collision_l_foot, "source" : $Armature/Skeleton3D/Animated_collision_l_foot/Animated_collision_l_foot, "angle" : null}, { "target" : $Animated_collision_r_foot_toe, "source" : $Armature/Skeleton3D/Animated_collision_r_foot_toe/Animated_collision_r_foot_toe, "angle" : null}, { "target" : $Animated_collision_l_foot_toe, "source" : $Armature/Skeleton3D/Animated_collision_l_foot_toe/Animated_collision_l_foot_toe, "angle" : null}, { "target" : $Animated_collision_r_upper_arm, "source" : $Armature/Skeleton3D/Animated_collision_r_upper_arm/Animated_collision_r_upper_arm, "angle" : null}, { "target" : $Animated_collision_l_upper_arm, "source" : $Armature/Skeleton3D/Animated_collision_l_upper_arm/Animated_collision_l_upper_arm, "angle" : null}, { "target" : $Animated_collision_r_arm, "source" : $Armature/Skeleton3D/Animated_collision_r_arm/Animated_collision_r_arm, "angle" : null}, { "target" : $Animated_collision_l_arm, "source" : $Armature/Skeleton3D/Animated_collision_l_arm/Animated_collision_l_arm, "angle" : null}, { "target" : $Animated_collision_r_hand, "source" : $Armature/Skeleton3D/Animated_collision_r_hand/Animated_collision_r_hand, "angle" : null}, { "target" : $Animated_collision_l_hand, "source" : $Armature/Skeleton3D/Animated_collision_l_hand/Animated_collision_l_hand, "angle" : null}, { "target" : $Animated_collision_l_pinky1, "source" : $Armature/Skeleton3D/Animated_collision_l_pinky1/Animated_collision_l_pinky1, "angle" : null}, { "target" : $Animated_collision_l_pinky2, "source" : $Armature/Skeleton3D/Animated_collision_l_pinky2/Animated_collision_l_pinky2, "angle" : null}, { "target" : $Animated_collision_l_pinky3, "source" : $Armature/Skeleton3D/Animated_collision_l_pinky3/Animated_collision_l_pinky3, "angle" : null}, { "target" : $Animated_collision_l_ring1, "source" : $Armature/Skeleton3D/Animated_collision_l_ring1/Animated_collision_l_ring1, "angle" : null}, { "target" : $Animated_collision_l_ring2, "source" : $Armature/Skeleton3D/Animated_collision_l_ring2/Animated_collision_l_ring2, "angle" : null}, { "target" : $Animated_collision_l_ring3, "source" : $Armature/Skeleton3D/Animated_collision_l_ring3/Animated_collision_l_ring3, "angle" : null}, { "target" : $Animated_collision_l_middle1, "source" : $Armature/Skeleton3D/Animated_collision_l_middle1/Animated_collision_l_middle1, "angle" : null}, { "target" : $Animated_collision_l_middle2, "source" : $Armature/Skeleton3D/Animated_collision_l_middle2/Animated_collision_l_middle2, "angle" : null}, { "target" : $Animated_collision_l_middle3, "source" : $Armature/Skeleton3D/Animated_collision_l_middle3/Animated_collision_l_middle3, "angle" : null}, { "target" : $Animated_collision_l_index1, "source" : $Armature/Skeleton3D/Animated_collision_l_index1/Animated_collision_l_index1, "angle" : null}, { "target" : $Animated_collision_l_index2, "source" : $Armature/Skeleton3D/Animated_collision_l_index2/Animated_collision_l_index2, "angle" : null}, { "target" : $Animated_collision_l_index3, "source" : $Armature/Skeleton3D/Animated_collision_l_index3/Animated_collision_l_index3, "angle" : null}, { "target" : $Animated_collision_l_thumb1,   "source" : $Armature/Skeleton3D/Animated_collision_l_thumb1/Animated_collision_l_thumb1, "angle" : null}, { "target" : $Animated_collision_l_thumb2, "source" : $Armature/Skeleton3D/Animated_collision_l_thumb2/Animated_collision_l_thumb2, "angle" : null}, { "target" : $Animated_collision_l_thumb3, "source" : $Armature/Skeleton3D/Animated_collision_l_thumb3/Animated_collision_l_thumb3, "angle" : null}, { "target" : $Animated_collision_r_pinky1, "source" : $Armature/Skeleton3D/Animated_collision_r_pinky1/Animated_collision_r_pinky1, "angle" : null}, { "target" : $Animated_collision_r_pinky2, "source" : $Armature/Skeleton3D/Animated_collision_r_pinky2/Animated_collision_r_pinky2, "angle" : null}, { "target" : $Animated_collision_r_pinky3, "source" : $Armature/Skeleton3D/Animated_collision_r_pinky3/Animated_collision_r_pinky3, "angle" : null}, { "target" : $Animated_collision_r_ring1, "source" : $Armature/Skeleton3D/Animated_collision_r_ring1/Animated_collision_r_ring1, "angle" : null}, { "target" : $Animated_collision_r_ring2, "source" : $Armature/Skeleton3D/Animated_collision_r_ring2/Animated_collision_r_ring2, "angle" : null}, { "target" : $Animated_collision_r_ring3, "source" : $Armature/Skeleton3D/Animated_collision_r_ring3/Animated_collision_r_ring3, "angle" : null}, { "target" : $Animated_collision_r_middle1, "source" : $Armature/Skeleton3D/Animated_collision_r_middle1/Animated_collision_r_middle1, "angle" : null}, { "target" : $Animated_collision_r_middle2, "source" : $Armature/Skeleton3D/Animated_collision_r_middle2/Animated_collision_r_middle2, "angle" : null}, { "target" : $Animated_collision_r_middle3, "source" : $Armature/Skeleton3D/Animated_collision_r_middle3/Animated_collision_r_middle3, "angle" : null}, { "target" : $Animated_collision_r_index1, "source" : $Armature/Skeleton3D/Animated_collision_r_index1/Animated_collision_r_index1, "angle" : null}, { "target" : $Animated_collision_r_index2, "source" : $Armature/Skeleton3D/Animated_collision_r_index2/Animated_collision_r_index2, "angle" : null}, { "target" : $Animated_collision_r_index3, "source" : $Armature/Skeleton3D/Animated_collision_r_index3/Animated_collision_r_index3, "angle" : null}, { "target" : $Animated_collision_r_thumb1, "source" : $Armature/Skeleton3D/Animated_collision_r_thumb1/Animated_collision_r_thumb1, "angle" : null}, { "target" : $Animated_collision_r_thumb2, "source" : $Armature/Skeleton3D/Animated_collision_r_thumb2/Animated_collision_r_thumb2, "angle" : null}, { "target" : $Animated_collision_r_thumb3, "source" : $Armature/Skeleton3D/Animated_collision_r_thumb3/Animated_collision_r_thumb3, "angle" : null}]

func init_scene():
	var array = get_tree().root.get_children()
	for row in array:
		if row.name == 'main':
			ROOT = row
			break
			
	array = ROOT.get_children()
	
	for row in array:
		if row.name.split('_')[0] == 'scene':
			
			SCENE = row
			break	
	
func init_random_locations():
	
	var scene = SCENE.get_children()
	
	var random_points = ROOT.get_node_by_name(scene, 'RandomPoints')
	random_points = random_points.get_children()
	for point in random_points:
		
		random_locations.append(Vector3(point.global_position.x, global_position.y, point.global_position.z))
	
	random_locations_size = random_locations.size()-1


func random_navigation():
	var d = 99.99
	d = global_position.distance_to(movement_pos)
	
	if d <= 0.08:

		
		if not random_locations == []:
				
			if wait_time >= _stored_wait_time and _stored_wait_time > 0.0:
				runs = runs+1
				
				
				
				safe_movement = true
				movement_pos = random_locations[randi_range(0, random_locations_size)]
				target_point[0] = movement_pos
				_stored_wait_time = randf_range(0.8787, 2.2368)
						
				wait_time = 0.0
				

				
				counts_d = 0
				stored_d = global_position
		wait_time = wait_time+0.1
	else:
		if counts_d == 13:
			if global_position.distance_squared_to(stored_d) <= 0.8:
				
				safe_movents_applied = safe_movents_applied+1
				movement_pos = Vector3($Armature/sensors/safe_movement.global_position.x, global_position.y, $Armature/sensors/safe_movement.global_position.z)
				
				_stored_wait_time = 0.08
			counts_d = 0
			stored_d = global_position
		counts_d = counts_d+1
func stop_navigation():
	movement_pos = global_position

#Logical State
func logical_state():
	pass

func _on_trigger_timeout() -> void:
	logical_state()
	
	
	if player_status == "random_walk":
		player_walking_counter = player_walking_counter+0.1
		random_navigation()
	
	if player_status == "stop_navigation":
		stop_navigation()
		
