extends Area2D

# Player's speed (pixels/sec)
@export var speed: int = 400

# Player's boost factor
@export var boost_factor: int = 4

# Boost color
@export_color_no_alpha
var boost_color: Color = Color(1, 0.5, 1)

# Player's boost duration (sec)
@export_range(0, 1, 0.05, "suffix:s", "or_greater")
var boost_time: float = 0.2

# Boost cooldown
@export_range(0, 1, 0.05, "suffix:s", "or_greater")
var boost_cooldown_time: float = 2  

# Boost timer
var timer_boost := Timer.new()

# Boost cooldown timer
var timer_cooldown := Timer.new()

# Player's state (acc or not)
var is_boost: bool = false
var is_cooldown: bool = false

# Size of Game Window
var screen_size: Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	
	# initialize boost timer
	add_child(timer_boost)
	timer_boost.wait_time = boost_time
	timer_boost.one_shot = true
	timer_boost.connect("timeout", boost_timer_timeout)
	
	# initialize cooldown timer
	add_child(timer_cooldown)
	timer_cooldown.wait_time = boost_cooldown_time
	timer_cooldown.one_shot = true
	timer_cooldown.connect("timeout", cooldown_timer_timeout)

func boost_timer_timeout() -> void:
	is_boost = false
	print("Boost time out")
	
func cooldown_timer_timeout() -> void:
	is_cooldown = false
	$Sprite2D.modulate = Color(1,1,1)
	print("Cooldown time out")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# the player's velocity
	var velocity: Vector2 = Vector2.ZERO
	
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		
	if is_boost:
		velocity *= boost_factor
		
	position += velocity * delta
	
	# perodic boundaries
	if position.x < 0:
		position.x = screen_size.x
	if position.x > screen_size.x:
		position.x = 0
	if position.y < 0:
		position.y = screen_size.y
	if position.y > screen_size.y:
		position.y = 0
		
	if Input.is_action_pressed("accelerate"):
		if not is_boost and not is_cooldown:
			timer_boost.start()
			timer_cooldown.start()
			is_boost = true
			is_cooldown = true
			$Sprite2D.modulate = boost_color
