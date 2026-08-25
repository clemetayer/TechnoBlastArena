extends "res://addons/gut/test.gd"

##### VARIABLES #####
#---- VARIABLES -----
var sound_manager


##### SETUP #####
func before_each():
	sound_manager = add_child_autofree(
		load("res://Utils/Audio/ui_sound_manager.tscn").instantiate()
	)


##### TESTS #####
func test_autoconnect():
	# given
	var button_click = autofree(Button.new())
	button_click.add_to_group("ui_click")
	var button_close = autofree(Button.new())
	button_close.add_to_group("ui_close")
	var button_confirm = autofree(Button.new())
	button_confirm.add_to_group("ui_confirm")
	var control_hover = autofree(Control.new())
	control_hover.add_to_group("ui_hover")
	var button_open = autofree(Button.new())
	button_open.add_to_group("ui_open")
	var range_tick = autofree(VSlider.new())
	range_tick.add_to_group("ui_tick")
	var button_nonexistent = autofree(Button.new())
	button_nonexistent.add_to_group("nonexistent")
	var button_click_late = autofree(Button.new())
	button_click_late.add_to_group("ui_click")
	get_tree().root.add_child(button_click)
	get_tree().root.add_child(button_close)
	get_tree().root.add_child(button_confirm)
	get_tree().root.add_child(control_hover)
	get_tree().root.add_child(button_open)
	get_tree().root.add_child(range_tick)
	get_tree().root.add_child(button_nonexistent)
	# when
	sound_manager._ready()
	# then
	assert_true(button_click.pressed.is_connected(sound_manager.play_click))
	assert_true(button_close.pressed.is_connected(sound_manager.play_close))
	assert_true(button_confirm.pressed.is_connected(sound_manager.play_confirm))
	assert_true(control_hover.focus_entered.is_connected(sound_manager.play_hover))
	assert_true(button_open.pressed.is_connected(sound_manager.play_open))
	assert_true(range_tick.value_changed.is_connected(sound_manager.play_tick))
	assert_false(button_nonexistent.pressed.is_connected(sound_manager.play_click))
	assert_false(button_click_late.pressed.is_connected(sound_manager.play_click))
	get_tree().root.add_child(button_click_late)
	await wait_physics_frames(1)
	assert_true(button_click_late.pressed.is_connected(sound_manager.play_click))


func test_play_click():
	generic_test_play_sound(sound_manager.play_click, [UISoundBankData.UI_CLICK])


func test_play_close():
	generic_test_play_sound(sound_manager.play_close, [UISoundBankData.UI_CLOSE])


func test_play_confirm():
	generic_test_play_sound(sound_manager.play_confirm, [UISoundBankData.UI_CONFIRM])


func test_play_hover():
	generic_test_play_sound(sound_manager.play_hover, [UISoundBankData.UI_HOVER])


func test_play_open():
	generic_test_play_sound(sound_manager.play_open, [UISoundBankData.UI_OPEN])


func test_play_tick():
	generic_test_play_sound(sound_manager.play_tick, [UISoundBankData.UI_TICK])


func generic_test_play_sound(method: Callable, triggers: Array):
	# given
	var event_audio = mock_event_audio()
	# when
	method.call()
	# then
	assert_called(
		event_audio,
		"play_2d",
		[SoundBankData.get_trigger_string(triggers), sound_manager._audio_emitter, ""],
	)


##### UTILS #####
func mock_event_audio():
	var event_audio = double(load("res://addons/event_audio/event_audio.gd")).new()
	stub(event_audio, "play_2d").to_return(autofree(EventAudioAPI.AudioEmitter2D.new()))
	sound_manager.event_audio = event_audio
	return event_audio
