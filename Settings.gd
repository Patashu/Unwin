extends Node2D
class_name Settings

onready var gamelogic = get_tree().get_root().find_node("LevelScene", true, false).gamelogic;
onready var holder : Control = get_node("Holder");
onready var pointer : Sprite = get_node("Holder/Pointer");
onready var okbutton : Button = get_node("Holder/OkButton");
onready var vsync : CheckBox = get_node("Holder/TabContainer/Graphics/VSync");
onready var masterslider : HSlider = get_node("Holder/TabContainer/Audio/MasterSlider");
onready var sfxslider : HSlider = get_node("Holder/TabContainer/Audio/SFXSlider");
onready var fanfareslider : HSlider = get_node("Holder/TabContainer/Audio/FanfareSlider");
onready var musicslider : HSlider = get_node("Holder/TabContainer/Audio/MusicSlider");
onready var animationslider : HSlider = get_node("Holder/TabContainer/Graphics/AnimationSlider");
onready var labelmaster : Label = get_node("Holder/TabContainer/Audio/LabelMaster");
onready var labelsfx : Label = get_node("Holder/TabContainer/Audio/LabelSFX");
onready var labelfanfare : Label = get_node("Holder/TabContainer/Audio/LabelFanfare");
onready var labelmusic : Label = get_node("Holder/TabContainer/Audio/LabelMusic");
onready var labelanimation : Label = get_node("Holder/TabContainer/Graphics/LabelAnimation");
onready var puzzlecheckerboard : CheckBox = get_node("Holder/TabContainer/Graphics/PuzzleCheckerboard");
onready var copysavefile : Button = get_node("Holder/TabContainer/Gameplay/CopySaveFile");
onready var pastesavefile : Button = get_node("Holder/TabContainer/Gameplay/PasteSaveFile");
onready var newsavefile : Button = get_node("Holder/TabContainer/Gameplay/NewSaveFile");
onready var virtualbuttons : SpinBox = get_node("Holder/TabContainer/Gameplay/VirtualButtons");
onready var metaundoarestart : OptionButton = get_node("Holder/TabContainer/Gameplay/MetaUndoARestart");
onready var resolution : OptionButton = get_node("Holder/TabContainer/Graphics/Resolution");
onready var fps : OptionButton = get_node("Holder/TabContainer/Graphics/FPS");
onready var fullscreenbutton: Button = get_node("Holder/TabContainer/Graphics/FullScreenButton");
onready var muteinbackground : CheckBox = get_node("Holder/TabContainer/Audio/MuteInBackground");

func floating_text(text: String) -> void:
	var label = preload("res://FloatingText.tscn").instance();
	get_node("Holder").add_child(label);
	label.rect_position.x = 0;
	label.rect_size.x = holder.rect_size.x;
	label.rect_position.y = holder.rect_size.y/2-16;
	label.text = text;

func setup_tab_instructions() -> void:
	if (gamelogic.SuperScaling != null):
		$Holder/TabInstructions.text = "(While focusing Ok, Left/Right                                       will change between tabs.)";
	else:
		$Holder/TabInstructions.text = "(While focusing Ok, Left/Right                                           will change between tabs.)";

func setup_resolution() -> void:
	var current = gamelogic.save_file["resolution"];
	var defaults = ["512x300 (x1)", "1024x600 (x2)", "1280x720 (720p)", "1536x900 (x3)", 
	"1920x1080 (1080p)", "2048x1200 (x4)"];
	for i in range(defaults.size()):
		resolution.add_item(defaults[i], 0);
		if (defaults[i].split(" ")[0] == current):
			resolution.selected = i;
	
	var mult = 5;
	var i = defaults.size();
	var size = Vector2(gamelogic.pixel_width*mult, gamelogic.pixel_height*mult);
	var monitor = gamelogic.get_largest_monitor();
	# 512x32 is the largest width a Godot 3.x canvas can be anyway
	while (i < 33 and (size.x <= monitor.x or size.y <= monitor.y)):
		var result = str(size.x) + "x" + str(size.y) + " (x" + str(mult) + ")"
		resolution.add_item(result, i);
		i += 1;
		mult += 1;
		size = Vector2(gamelogic.pixel_width*mult, gamelogic.pixel_height*mult);
		if (result.split(" ")[0] == current):
			resolution.selected = i;
	
func setup_fps() -> void:
	var current = int(gamelogic.save_file["fps"]);
	var defaults = ["20", "24", "30", "50", "60", "120", "144", "240"];
	for i in range(defaults.size()):
		fps.add_item(defaults[i], 0);
		if (int(defaults[i]) == current):
			fps.selected = i;

func _ready() -> void:
	var os_name = OS.get_name();
	var is_fixed_size = false;
	if (os_name == "HTML5" or os_name == "Android" or os_name == "iOS"):
		is_fixed_size = true;
	elif gamelogic.is_steam_deck:
		is_fixed_size = true;
	
	metaundoarestart.add_item("Yes", 0);
	metaundoarestart.add_item("Replay (Instant)", 1);
	metaundoarestart.add_item("Replay (Fast)", 2);
	metaundoarestart.add_item("Replay", 3);
	metaundoarestart.add_item("No", 4);
	if (gamelogic.save_file.has("meta_undo_a_restart")):
		metaundoarestart.selected = int(gamelogic.save_file["meta_undo_a_restart"]);
	else:
		metaundoarestart.selected = 2;
	metaundoarestart.text = "Undo a Restart?:"
	
	setup_tab_instructions();
	setup_resolution();
	setup_fps();
	
	okbutton.connect("pressed", self, "destroy");
	okbutton.grab_focus();
	if (gamelogic.save_file.has("vsync_enabled")):
		vsync.pressed = gamelogic.save_file["vsync_enabled"];
	if (gamelogic.save_file.has("master_volume")):
		masterslider.value = gamelogic.save_file["master_volume"];
		updatelabelmaster(masterslider.value);
	if (gamelogic.save_file.has("sfx_volume")):
		sfxslider.value = gamelogic.save_file["sfx_volume"];
		updatelabelsfx(sfxslider.value);
	if (gamelogic.save_file.has("fanfare_volume")):
		fanfareslider.value = gamelogic.save_file["fanfare_volume"];
		updatelabelfanfare(fanfareslider.value);
	if (gamelogic.save_file.has("music_volume")):
		musicslider.value = gamelogic.save_file["music_volume"];
		updatelabelmusic(musicslider.value);
	if (gamelogic.save_file.has("animation_speed")):
		animationslider.value = gamelogic.save_file["animation_speed"];
		updatelabelanimation(animationslider.value);
	if (gamelogic.save_file.has("puzzle_checkerboard")):
		puzzlecheckerboard.pressed = gamelogic.save_file["puzzle_checkerboard"];
	if (gamelogic.save_file.has("virtual_buttons")):
		virtualbuttons.value = gamelogic.save_file["virtual_buttons"];
	if (gamelogic.save_file.has("mute_in_background")):
		muteinbackground.pressed = gamelogic.save_file["mute_in_background"];
	
	vsync.connect("pressed", self, "_vsync_pressed");
	masterslider.connect("value_changed", self, "_masterslider_value_changed");
	sfxslider.connect("value_changed", self, "_sfxslider_value_changed");
	fanfareslider.connect("value_changed", self, "_fanfareslider_value_changed");
	musicslider.connect("value_changed", self, "_musicslider_value_changed");
	animationslider.connect("value_changed", self, "_animationslider_value_changed");
	puzzlecheckerboard.connect("pressed", self, "_puzzlecheckerboard_pressed");
	copysavefile.connect("pressed", self, "_copysavefile_pressed");
	pastesavefile.connect("pressed", self, "_pastesavefile_pressed");
	newsavefile.connect("pressed", self, "_newsavefile_pressed");
	virtualbuttons.connect("value_changed", self, "_virtualbuttons_value_changed");
	metaundoarestart.connect("item_focused", self, "_metaundoarestart_item_whatever");
	metaundoarestart.connect("item_selected", self, "_metaundoarestart_item_whatever");
	resolution.connect("item_focused", self, "_resolution_item_whatever");
	resolution.connect("item_selected", self, "_resolution_item_whatever");
	fps.connect("item_focused", self, "_fps_item_whatever");
	fps.connect("item_selected", self, "_fps_item_whatever");
	fullscreenbutton.connect("pressed", self, "_fullscreenbutton_pressed");
	muteinbackground.connect("pressed", self, "_muteinbackground_pressed");
	
	if (is_fixed_size):
		resolution.queue_free();
		vsync.queue_free();
		fullscreenbutton.queue_free();
		animationslider.focus_neighbour_top = animationslider.get_path_to(okbutton);

func _vsync_pressed() -> void:
	if (gamelogic.ui_stack.size() > 0 and gamelogic.ui_stack[gamelogic.ui_stack.size() - 1] != self):
		return;
	
	gamelogic.save_file["vsync_enabled"] = vsync.pressed;
	OS.vsync_enabled = vsync.pressed;

func _metaundoarestart_item_whatever(index: int) -> void:
	if (gamelogic.ui_stack.size() > 0 and gamelogic.ui_stack[gamelogic.ui_stack.size() - 1] != self):
		return;
	
	metaundoarestart.text = metaundoarestart.get_item_text(index);
	gamelogic.save_file["meta_undo_a_restart"] = index;
	gamelogic.update_info_labels();
	for i in range(metaundoarestart.get_popup().get_item_count()):
		metaundoarestart.get_popup().set_item_checked(i, i == index);

func _resolution_item_whatever(index: int) -> void:
	if (gamelogic.ui_stack.size() > 0 and gamelogic.ui_stack[gamelogic.ui_stack.size() - 1] != self):
		return;
	
	resolution.text = resolution.get_item_text(index);
	gamelogic.save_file["resolution"] = resolution.get_item_text(index).split(" ")[0];
	gamelogic.setup_resolution();
	setup_tab_instructions();
	for i in range(resolution.get_popup().get_item_count()):
		resolution.get_popup().set_item_checked(i, i == index);
	
func _fps_item_whatever(index: int) -> void:
	if (gamelogic.ui_stack.size() > 0 and gamelogic.ui_stack[gamelogic.ui_stack.size() - 1] != self):
		return;
	
	fps.text = fps.get_item_text(index);
	gamelogic.save_file["fps"] = int(fps.get_item_text(index).split(" ")[0]);
	Engine.target_fps = int(gamelogic.save_file["fps"]);
	for i in range(fps.get_popup().get_item_count()):
		fps.get_popup().set_item_checked(i, i == index);

func _masterslider_value_changed(value: float) -> void:
	if (gamelogic.ui_stack.size() > 0 and gamelogic.ui_stack[gamelogic.ui_stack.size() - 1] != self):
		return;
	
	gamelogic.save_file["master_volume"] = value;
	gamelogic.setup_volume();
	gamelogic.play_sound("switch");
	updatelabelmaster(value);
	
func _sfxslider_value_changed(value: float) -> void:
	if (gamelogic.ui_stack.size() > 0 and gamelogic.ui_stack[gamelogic.ui_stack.size() - 1] != self):
		return;
	
	gamelogic.save_file["sfx_volume"] = value;
	gamelogic.setup_volume();
	gamelogic.play_sound("switch");
	updatelabelsfx(value);
	
func _fanfareslider_value_changed(value: float) -> void:
	if (gamelogic.ui_stack.size() > 0 and gamelogic.ui_stack[gamelogic.ui_stack.size() - 1] != self):
		return;
	
	gamelogic.save_file["fanfare_volume"] = value;
	gamelogic.setup_volume();
	gamelogic.play_won("winentwined");
	updatelabelfanfare(value);
		
func _musicslider_value_changed(value: float) -> void:
	if (gamelogic.ui_stack.size() > 0 and gamelogic.ui_stack[gamelogic.ui_stack.size() - 1] != self):
		return;
	
	gamelogic.save_file["music_volume"] = value;
	gamelogic.setup_volume();
	updatelabelmusic(value);
	
func _animationslider_value_changed(value: float) -> void:
	if (gamelogic.ui_stack.size() > 0 and gamelogic.ui_stack[gamelogic.ui_stack.size() - 1] != self):
		return;
	
	gamelogic.save_file["animation_speed"] = value;
	gamelogic.setup_animation_speed();
	updatelabelanimation(value);

func _puzzlecheckerboard_pressed() -> void:
	if (gamelogic.ui_stack.size() > 0 and gamelogic.ui_stack[gamelogic.ui_stack.size() - 1] != self):
		return;
	
	gamelogic.save_file["puzzle_checkerboard"] = puzzlecheckerboard.pressed;
	gamelogic.checkerboard.visible = puzzlecheckerboard.pressed;

func _muteinbackground_pressed() -> void:
	if (gamelogic.ui_stack.size() > 0 and gamelogic.ui_stack[gamelogic.ui_stack.size() - 1] != self):
		return;
	
	gamelogic.save_file["mute_in_background"] = muteinbackground.pressed;
	
func _copysavefile_pressed() -> void:
	if (gamelogic.ui_stack.size() > 0 and gamelogic.ui_stack[gamelogic.ui_stack.size() - 1] != self):
		return;
	
	OS.set_clipboard(to_json(gamelogic.save_file));
	
	floating_text("Exported save file to clipboard!");
	
func _pastesavefile_pressed() -> void:
	if (gamelogic.ui_stack.size() > 0 and gamelogic.ui_stack[gamelogic.ui_stack.size() - 1] != self):
		return;
	
	var paste = OS.get_clipboard();
	
	var json_parse_result = JSON.parse(paste)
	
	var result = null;
	
	if json_parse_result.error == OK:
		var data = json_parse_result.result;
		if typeof(data) == TYPE_DICTIONARY:
			result = data;
	
	if (result == null):
		floating_text("Didn't find a valid save file on clipboard")
	else:
		gamelogic.save_file = result;
		gamelogic.react_to_save_file_update();
		gamelogic.load_level(gamelogic.level_number);
		destroy();
	
func _newsavefile_pressed() -> void:
	if (gamelogic.ui_stack.size() > 0 and gamelogic.ui_stack[gamelogic.ui_stack.size() - 1] != self):
		return;
	
	var new_save_file = gamelogic.save_file.duplicate(true);
	
	new_save_file["levels"] = {};
	new_save_file["level_number"] = 0;
	
	OS.set_clipboard(to_json(new_save_file));
	
	floating_text("Exported fresh save file to clipboard - Import it to confirm.");
	
func _virtualbuttons_value_changed(value: float) -> void:
	if (gamelogic.ui_stack.size() > 0 and gamelogic.ui_stack[gamelogic.ui_stack.size() - 1] != self):
		return;
	
	gamelogic.save_file["virtual_buttons"] = int(value);
	gamelogic.setup_virtual_buttons();

func _fullscreenbutton_pressed() -> void:
	if (!gamelogic.save_file.has("fullscreen") or !gamelogic.save_file["fullscreen"]):
		gamelogic.save_file["fullscreen"] = true;
	else:
		gamelogic.save_file["fullscreen"] = false;
	gamelogic.setup_resolution();
	setup_tab_instructions();
	
func updatelabelmaster(value: int) -> void:
	if (value <= -30):
		labelmaster.text = "Master Volume: Muted";
	else:
		labelmaster.text = "Master Volume: " + str(value) + " dB";
	
func updatelabelsfx(value: int) -> void:
	if (value <= -30):
		labelsfx.text = "SFX Volume: Muted";
	else:
		labelsfx.text = "SFX Volume: " + str(value) + " dB";
		
func updatelabelfanfare(value: int) -> void:
	if (value <= -30):
		labelfanfare.text = "Fanfare Volume: Muted";
	else:
		labelfanfare.text = "Fanfare Volume: " + str(value) + " dB";
		
func updatelabelmusic(value: int) -> void:
	if (value <= -30):
		labelmusic.text = "Music Volume: Muted";
	else:
		labelmusic.text = "Music Volume: " + str(value) + " dB";

func updatelabelanimation(value: float) -> void:
	labelanimation.text = "Animation Speed: " + ("%0.1f" % value) + "x";

func destroy() -> void:
	gamelogic.save_game();
	self.queue_free();
	gamelogic.ui_stack.erase(self);

var covered_cooldown_timer: int = 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (gamelogic.ui_stack.size() > 0 and gamelogic.ui_stack[gamelogic.ui_stack.size() - 1] != self):
		return;
	
	if (covered_cooldown_timer > 0):
		covered_cooldown_timer -= 1;
	
	var focus = holder.get_focus_owner();
	if (focus == null):
		okbutton.grab_focus();
		focus = okbutton;
		
	# spinbox correction hack
	var parent = focus.get_parent();
	if parent is SpinBox:
		focus = parent;
	elif parent is OptionButton:
		focus = parent;
		if (is_instance_valid(focus.get_popup()) and focus.get_popup().visible):
			covered_cooldown_timer = 2;
	
	if (Input.is_action_just_released("escape") or Input.is_action_just_pressed("ui_cancel")):
		if (focus is OptionButton and is_instance_valid(focus.get_popup()) and covered_cooldown_timer > 0):
			focus.get_popup().visible = false;
		else:
			destroy();

	if (!(focus is HSlider or focus is SpinBox)):
		if (Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("nonaxis_left")):
			var next_tab = $Holder/TabContainer.current_tab - 1;
			if (next_tab < 0):
				next_tab = $Holder/TabContainer.get_tab_count() - 1;
			$Holder/TabContainer.current_tab = next_tab;
		elif  (Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("nonaxis_right")):
			var next_tab = $Holder/TabContainer.current_tab + 1;
			if (next_tab >= $Holder/TabContainer.get_tab_count()):
				next_tab = 0;
			$Holder/TabContainer.current_tab = next_tab;
			
		okbutton.focus_neighbour_top = NodePath();
		if ($Holder/TabContainer.current_tab == 0):
			if is_instance_valid(resolution):
				okbutton.focus_neighbour_bottom = okbutton.get_path_to(resolution);
			else:
				okbutton.focus_neighbour_bottom = okbutton.get_path_to(animationslider);
			if (is_instance_valid(fps)):
				okbutton.focus_neighbour_top = okbutton.get_path_to(fps);
		elif ($Holder/TabContainer.current_tab == 1):
			okbutton.focus_neighbour_bottom = okbutton.get_path_to(masterslider);
		elif ($Holder/TabContainer.current_tab == 2):
			okbutton.focus_neighbour_bottom = okbutton.get_path_to(metaundoarestart);

	var focus_middle_x = round(focus.rect_position.x + focus.rect_size.x / 2);
	pointer.position.y = round(focus.rect_position.y + focus.rect_size.y / 2);
	if (focus_middle_x > holder.rect_size.x / 2):
		pointer.texture = preload("res://assets/tutorial_arrows/LeftArrow.tres");
		pointer.position.x = round(focus.rect_position.x + focus.rect_size.x + 12);
	else:
		pointer.texture = preload("res://assets/tutorial_arrows/RightArrow.tres");
		pointer.position.x = round(focus.rect_position.x - 12);
	if (focus != okbutton):
		pointer.position += $Holder/TabContainer.rect_position + $Holder/TabContainer/Audio.rect_position;

func _draw() -> void:
	draw_rect(Rect2(0, 0,
	gamelogic.pixel_width, gamelogic.pixel_height), Color(0, 0, 0, 0.5), true);
