extends ActorBase
class_name Actor

var gamelogic = null
var actorname : int = -1
var stored_position : Vector2 = Vector2.ZERO
var pos : Vector2 = Vector2.ZERO
var broken : bool = false
var strength : int = 0
var heaviness : int = 0
var durability : int = 0
var floats : bool = false
var is_character : bool = false
# animation system logic
var animation_timer : float = 0.0;
var animation_timer_max : float = 0.05;
var animations : Array = [];
var facing_dir : Vector2 = Vector2.RIGHT;
# animated sprites logic
var frame_timer : float = 0.0;
var frame_timer_max : float = 0.1;
var post_mortem : int = -1;
# transient multi-push/multi-fall state:
# basically, things that move become non-colliding until the end of the multi-push/fall tick they're
# a part of, so other things that shared their tile can move with them
var just_moved : bool = false;
var fade_tween = null;

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
				return preload("res://assets/player.png");
		
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
	# facing updates here, even if the texture didn't change
#	if facing_left_at_the_time:
#		flip_h = true;
#	else:
#		flip_h = false;
	
	if (self.texture == tex):
		return;
		
	if tex == null:
		visible = false;
	elif self.texture == null:
		visible = true;
		
	self.texture = tex;
	
	frame_timer = 0;
	frame = 0;
#	match texture:
#		preload("res://assets/heavy_broken.png"):
#			frame_timer_max = 0.4;
#			hframes = 8;

func pushable(checking_phased_out: bool = false) -> bool:
	if (!checking_phased_out and just_moved):
		return false;
	if (broken):
		return is_character;
	return true;
		
func phases_into_terrain() -> bool:
	return false;
	
func phases_into_actors() -> bool:
	return false;

func afterimage() -> void:
	gamelogic.afterimage(self);

func _process(delta: float) -> void:
	#animated sprites
	if hframes <= 1:
		pass
	else:
		frame_timer += delta;
		if (frame_timer > frame_timer_max):
			frame_timer -= frame_timer_max;
			if (frame == hframes - 1):
				frame = 0;
	
	# animation system stuff
	if (animations.size() > 0):
		var current_animation = animations[0];
		var is_done = true;
		match current_animation[0]:
			0: #move
				# afterimage if it was a retro move
				if (animation_timer == 0):
					gamelogic.broadcast_animation_nonce(current_animation[3]);
					if current_animation[2]:
						afterimage();
				animation_timer_max = 0.083;
				position -= current_animation[1]*(animation_timer/animation_timer_max)*24;
				animation_timer += delta;
				if (animation_timer > animation_timer_max):
					position += current_animation[1]*1*24;
					# no rounding errors here! get rounded sucker!
					position.x = round(position.x); position.y = round(position.y);
				else:
					is_done = false;
					position += current_animation[1]*(animation_timer/animation_timer_max)*24;
			1: #bump
				if (animation_timer == 0):
					gamelogic.broadcast_animation_nonce(current_animation[2]);
				animation_timer_max = 0.1;
				var bump_amount = (animation_timer/animation_timer_max);
				if (bump_amount > 0.5):
					bump_amount = 1-bump_amount;
				bump_amount *= 0.2;
				position -= current_animation[1]*bump_amount*24;
				animation_timer += delta;
				if (animation_timer > animation_timer_max):
					position.x = round(position.x); position.y = round(position.y);
				else:
					is_done = false;
					bump_amount = (animation_timer/animation_timer_max);
					if (bump_amount > 0.5):
						bump_amount = 1-bump_amount;
					bump_amount *= 0.2;
					position += current_animation[1]*bump_amount*24;
			2: #set_next_texture
				set_next_texture(current_animation[1], current_animation[3]);
				gamelogic.broadcast_animation_nonce(current_animation[2]);
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
		