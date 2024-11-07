extends Sprite
class_name GoalParticle

var fadeout_timer : float = 0.0;
var fadeout_timer_max : float = 1.0;
var velocity : Vector2 = Vector2.ZERO;
var alpha_max : float = 1.0;
var parent = null;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (parent.unwinning):
		delta *= -3;
	elif (parent.dinged):
		delta *= 6
	else:
		delta *= 1.0+2.0-((parent.particle_timer_max*2) - 1.0)/1.0;
	if (velocity != Vector2.ZERO):
		position += velocity * delta;
	fadeout_timer += delta;
	if (fadeout_timer > fadeout_timer_max):
		queue_free();
	else:
		if (fadeout_timer < fadeout_timer_max / 2.0):
			self.modulate.a = alpha_max*(fadeout_timer/(fadeout_timer_max/2.0));
		else:
			self.modulate.a = alpha_max*(1-(fadeout_timer-(fadeout_timer_max/2.0))/(fadeout_timer_max/2.0));
