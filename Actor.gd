extends ActorBase
class_name Actor

var gamelogic = null
var actorname : int = -1
var stored_position : Vector2 = Vector2.ZERO
var pos : Vector2 = Vector2.ZERO
var broken : bool = false
var post_mortem : int = -1;
var strength : int = 0
var heaviness : int = 0
var durability : int = 0
var floats : bool = false
var is_character : bool = false
# animation system logic
var animation_timer : float = 0.0;
var animation_timer_max : float = 0.05;
var base_frame = 0;
var animation_frame = 0;
var animations : Array = [];
var facing_dir : Vector2 = Vector2.DOWN;
# animated sprites logic
var frame_timer : float = 0.0;
var frame_timer_max : float = 0.1;
var moving = false;
# transient multi-push/multi-fall state:
# basically, things that move become non-colliding until the end of the multi-push/fall tick they're
# a part of, so other things that shared their tile can move with them
var just_moved : bool = false;
var fade_tween = null;

enum PostMortems {
	Fall,
	Melt,
	Collect
}

# faster than string comparisons
enum Name {
	Player,
	Star,
	DirtBlock,
	IceBlock,
}

func update_graphics() -> void:
	var tex = get_next_texture();
	set_next_texture(tex, facing_dir);

func get_next_texture() -> Texture:
	if (fade_tween != null):
		fade_tween.queue_free();
		fade_tween = null;

	# airborne, broken
	match actorname:
		Name.Player:
			if broken:
				return null;
			else:
				return preload("res://assets/player_spritesheet.png");
		
		Name.Star:
			if broken:
				return preload("res://assets/star_broken.png");
			else:
				return preload("res://assets/star.png");
		
		Name.DirtBlock:
			if broken:
				return null;
			else:
				return preload("res://assets/dirt_block.png");
				
		Name.IceBlock:
			if broken:
				return null;
			else:
				return preload("res://assets/ice_block.png");
		
	return null;

func set_next_texture(tex: Texture, facing_dir_at_the_time: Vector2) -> void:		
	if tex == null:
		visible = false;
	elif self.texture == null:
		visible = true;
		
	self.texture = tex;
	
	frame_timer = 0;
	frame = 0;
	match texture:
		preload("res://assets/player_spritesheet.png"):
			hframes = 4;
			vframes = 3;
			frame_timer_max = 0.033;
			match (facing_dir_at_the_time):
				Vector2.DOWN:
					frame = 0;
					flip_h = false;
				Vector2.UP:
					frame = 4;
					flip_h = false;
				Vector2.LEFT:
					frame = 8;
					flip_h = true;
				Vector2.RIGHT:
					frame = 8;
					flip_h = false;
			base_frame = frame;
			animation_frame = 0;

func pushable(by_actor: Actor) -> bool:
	if (self.actorname == Name.Star and by_actor.actorname == Name.Player):
		return false;
	return !broken;
		
func phases_into_terrain() -> bool:
	return false;
	
func phases_into_actors() -> bool:
	return false;

func afterimage() -> void:
	gamelogic.afterimage(self);

func _process(delta: float) -> void:
	#animated sprites
	if actorname == Name.Player:
		if moving:
			frame_timer += delta;
			if (frame_timer > frame_timer_max):
				frame_timer -= frame_timer_max;
				animation_frame += 1;
				if (animation_frame >= hframes):
					animation_frame = 0;
		else:
			animation_frame = 0;
			frame = base_frame;
			# brittle logic for ping pong that'll break if hframes changes from 4
		var adjusted_frame = animation_frame;
		if (adjusted_frame == 0):
			adjusted_frame = 2;
		frame = base_frame + animation_frame;
	
	# animation system stuff
	moving = false;
	if (animations.size() > 0):
		var current_animation = animations[0];
		var is_done = true;
		match current_animation[0]:
			0: #move
				moving = true;
				# afterimage if it was a retro move
				if (animation_timer == 0):
					pass
					if current_animation[2]:
						afterimage();
				animation_timer_max = 0.083;
				position -= current_animation[1]*(animation_timer/animation_timer_max)*gamelogic.cell_size;
				animation_timer += delta;
				if (animation_timer > animation_timer_max):
					position += current_animation[1]*1*gamelogic.cell_size;
					# no rounding errors here! get rounded sucker!
					position.x = round(position.x); position.y = round(position.y);
				else:
					is_done = false;
					position += current_animation[1]*(animation_timer/animation_timer_max)*gamelogic.cell_size;
			1: #bump
				if (animation_timer == 0):
					pass
				animation_timer_max = 0.1;
				var bump_amount = (animation_timer/animation_timer_max);
				if (bump_amount > 0.5):
					bump_amount = 1-bump_amount;
				bump_amount *= 0.2;
				position -= current_animation[1]*bump_amount*gamelogic.cell_size;
				animation_timer += delta;
				if (animation_timer > animation_timer_max):
					position.x = round(position.x); position.y = round(position.y);
				else:
					is_done = false;
					bump_amount = (animation_timer/animation_timer_max);
					if (bump_amount > 0.5):
						bump_amount = 1-bump_amount;
					bump_amount *= 0.2;
					position += current_animation[1]*bump_amount*gamelogic.cell_size;
			2: #set_next_texture
				set_next_texture(current_animation[1], current_animation[2]);
			3: #sfx
				gamelogic.play_sound(current_animation[1]);
			4: #afterimage_at
				gamelogic.afterimage_terrain(current_animation[1], current_animation[2], current_animation[3]);
			5: #fade
					if (fade_tween != null):
						fade_tween.queue_free();
					fade_tween = Tween.new();
					self.add_child(fade_tween);
					fade_tween.interpolate_property(self, "modulate:a", current_animation[1], current_animation[2], current_animation[3]);
					fade_tween.start();
			6: #stall
				animation_timer_max = current_animation[1];
				animation_timer += delta;
				if (animation_timer > animation_timer_max):
					is_done = true;
				else:
					is_done = false;
		if (is_done):
			animations.pop_front();
			animation_timer = 0;
		
