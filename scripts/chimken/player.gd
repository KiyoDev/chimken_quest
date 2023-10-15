class_name Player extends Character


enum Direction {
	Up,
	Down,
	Left,
	Right
}


@onready var Sprite : Sprite2D = $Sprite2D
@onready var Animator : AnimationPlayer = $AnimationPlayer


@export_group("Info")
@export var speed = 60.0
@export var moving_direction : Direction = Direction.Down


func _ready():
	moving_direction = Direction.Down
	Animator.play(&"idle_down")
#	var cam : Camera2D = get_node("%MainCamera");
#	add_child(cam);
#	print("a-%s" % [get_children()]);
#	print("asdsadas-%s" % [cam]);


func _physics_process(delta):
	if(Game.in_battle()):
		Animator.pause();
		return;
	
	if(!Animator.is_playing()): 
		Animator.playback_active = true;
#	global_position = Util.pixel_clamp(global_position);
	handle_input()
	move_and_slide()


# For constant input detection, should go into physics
func handle_input():
	var direction := Input.get_vector(&"ui_left", &"ui_right", &"ui_up", &"ui_down");
	velocity = direction.round() * speed;
#	velocity = Vector2(roundi(direction.x), roundi(direction.y)) * speed;
#	velocity = Util.pixel_clamp(direction * speed);
	
#	if(velocity.x != 0 || velocity.y != 0):
	if(velocity):
		print("vel=%s, [%s], [%s]" % [velocity, position, direction]);
#		print("velocity = %s" % velocity)
		if(direction.x > 0): # right
			if(!Animator.current_animation.begins_with(&"idle") && direction.y != 0 && moving_direction != Direction.Left):
				return;
			Sprite.flip_h = true;
			moving_direction = Direction.Right;
			Animator.play(&"walk_horizontal");
		elif(direction.x < 0): # left
			if(!Animator.current_animation.begins_with(&"idle") && direction.y != 0 && moving_direction != Direction.Right):
				return;
			Sprite.flip_h = false;
			moving_direction = Direction.Left;
			Animator.play(&"walk_horizontal");
		
		if(direction.y > 0): # down
			if(!Animator.current_animation.begins_with(&"idle") && direction.x != 0):
				return;
			moving_direction = Direction.Down;
			Animator.play(&"walk_down");
		elif(direction.y < 0): # up
			if(!Animator.current_animation.begins_with(&"idle") && direction.x != 0):
				return;
			moving_direction = Direction.Up;
			Animator.play(&"walk_up");
	else:
		if(moving_direction == Direction.Up):
			Animator.play(&"idle_up");
		elif(moving_direction == Direction.Down):
			Animator.play(&"idle_down");
		elif(moving_direction == Direction.Left || moving_direction == Direction.Right):
			Animator.play(&"idle_horizontal");
