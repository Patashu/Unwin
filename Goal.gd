extends ActorBase
class_name Goal

var gamelogic = null;
var actorname : int = -1;
var pos = Vector2.ZERO
var dinged = false;
var animations = [];
var animation_timer = 0;
var animation_timer_max = 1.0;
var particle_timer_max = 1.5;
var particle_timer = particle_timer_max;
var last_particle_angle = 0.0;
var unwinning = false;
var starbar = null;

func update_graphics() -> void:
	pass
	
func get_next_texture() -> Texture:
	return texture
	
func set_next_texture(tex: Texture) -> void:
	pass
	
func calculate_speed() -> void:
	unwinning = false;
	if (starbar.collected >= starbar.collected_max or starbar.collected_max < 1):
		particle_timer_max = 0.5;
		dinged = true;
		return;
	dinged = false;
	particle_timer_max = (3.0-2.0*(float(starbar.collected)/float(starbar.collected_max)))/2;

func _process(delta: float) -> void:
	particle_timer += delta;
	if (particle_timer > particle_timer_max):
		var underactorsparticles = gamelogic.underactorsparticles;
		particle_timer -= particle_timer_max;
		var sprite = Sprite.new();
		sprite.set_script(preload("res://GoalParticle.gd"));
		sprite.texture = preload("res://assets/win_particle.png");
		sprite.hframes = 3;
		sprite.frame = gamelogic.rng.randi_range(0, 2);
		sprite.position = self.position;
		sprite.centered = true;
		sprite.alpha_max = 1.0;
		sprite.modulate = Color(modulate.r, modulate.g, modulate.b, 0);
		sprite.parent = self;
		var next_particle_angle = last_particle_angle + 2*PI/6 + gamelogic.rng.randf_range(0, 2*PI*4/6)
		last_particle_angle = next_particle_angle;
		sprite.fadeout_timer_max = 4;
		sprite.velocity = Vector2(0, 6).rotated(next_particle_angle);
		sprite.position -= sprite.velocity*sprite.fadeout_timer_max;
		underactorsparticles.add_child(sprite);
	
	if (animations.size() > 0):
		var current_animation = animations[0];
		var is_done = true;
		if (current_animation[0] == 9): #starget
			if (animation_timer == 0.0):
				particle_timer = 0.25;
			animation_timer_max = 1.0;
			particle_timer_max = 0.25;
			dinged = true;
			animation_timer += delta;
			if (animation_timer >= animation_timer_max):
				calculate_speed();
			else:
				is_done = false;
		elif (current_animation[0] == 10): #starunget
			if (animation_timer == 0.0):
				particle_timer = -1.0;
			animation_timer_max = 1.0;
			unwinning = true;
			animation_timer += delta;
			if (animation_timer >= animation_timer_max):
				calculate_speed();
			else:
				is_done = false;
		if (is_done):
			animations.pop_front();
			animation_timer = 0;
