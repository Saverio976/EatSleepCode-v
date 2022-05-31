module main

import os
import gx
import gg

fn main() {
	size := gg.window_size()
	mut editor := EatSleepCode{
		win: voidptr(0)
		buffers: []File{}
	}
	mut win := Win{
		width: size.width
		height: size.height
		ctx: gg.new_context(
			bg_color: gx.rgb(0, 0, 0)
			width: size.width
			height: size.height
			window_title: 'EatSleepCode'
			frame_fn: frame_update
			event_fn: event_update
			keydown_fn: event_update_key_down
			char_fn: event_update_char
			ui_mode: true
			user_data: &editor
		)
	}
	editor.win = &win
	if os.args.len >= 2 {
		mut file := new_file(os.args[1])?
		editor.buffers << file
	}
	editor.win.ctx.run()
}

fn frame_update(mut editor EatSleepCode) {
	editor.win.ctx.begin()
	editor.draw()
	editor.win.ctx.end()
}

fn event_update_key_down(c gg.KeyCode, m gg.Modifier, mut editor EatSleepCode) {
	if m == .ctrl {
		for evt_listen in evtfuncsctrl {
			if evt_listen.code == c {
				evt_listen.fun(editor)
				break
			}
		}
	}
	if editor.buffers.len == 0 {
		return
	}
	mut buf := &editor.buffers[editor.current_buffer]
	conditions := [Mode.insert, Mode.normal]
	lists := [evtfuncs_insert, evtfuncs_normal]
	for i in 0..conditions.len {
		if buf.controls.current_mode == conditions[i] {
			for evt_listen in lists[i] {
				if evt_listen.code == c && evt_listen.modifier == m {
					evt_listen.fun(editor)
				}
			}
		}
	}
}

fn event_update(e &gg.Event, mut editor EatSleepCode) {
}
