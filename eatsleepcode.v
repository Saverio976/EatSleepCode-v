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

fn event_update(e &gg.Event, mut editor EatSleepCode) {
	if (editor.last_keys.len != 0)
		&& editor.last_keys.last() in [gg.KeyCode.right_control, gg.KeyCode.left_control] {
		for evt_listen in evtfuncsctrl {
			if evt_listen.code == e.key_code {
				evt_listen.fun(e, editor)
				editor.last_keys.delete(editor.last_keys.len - 1)
				return
			}
		}
	}
	if editor.buffers.len != 0 && editor.buffers[editor.current_buffer].controls.current_mode == .normal {
		for evt_listen in evtfuncs_normal {
			if evt_listen.code == e.key_code {
				evt_listen.fun(e, editor)
				editor.last_keys.delete(editor.last_keys.len - 1)
				return
			}
		}
	}
	if editor.last_keys.len == 10 {
		editor.last_keys.delete(0)
	}
	editor.last_keys << e.key_code
	return
}
