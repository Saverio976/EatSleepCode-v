module main

import os
import gg

struct EvtFunc {
	code gg.KeyCode
	modifier gg.Modifier
	fun  fn (mut editor EatSleepCode)
}

const (
	evtfuncsctrl = [EvtFunc{
		code: .s
		fun: event_update_ctrls
	}, EvtFunc{
		code: .q
		fun: event_update_ctrlq
	}]
	evtfuncs_normal = [EvtFunc{
		code: .down
		fun: event_update_up
	}, EvtFunc{
		code: .up
		fun: event_update_down
	}, EvtFunc{
		code: .left
		fun: event_update_left
	}, EvtFunc{
		code: .right
		fun: event_update_right
	}, EvtFunc{
		code: .d
		modifier: .shift
		fun: delete_line
	}]
	evtfuncs_insert = [EvtFunc{
		code: .escape
		fun: event_update_escape
	}, EvtFunc{
		code: .down
		fun: event_update_up
	}, EvtFunc{
		code: .up
		fun: event_update_down
	}, EvtFunc{
		code: .left
		fun: event_update_left
	}, EvtFunc{
		code: .right
		fun: event_update_right
	}]
)

fn event_update_ctrls(mut editor EatSleepCode) {
	if editor.buffers.len == 0 {
		return
	}
	mut buf := &editor.buffers[editor.current_buffer]
	text := buf.context_content.join('\n')
	os.write_file(buf.file_path, text) or {}
}

fn event_update_ctrlq(mut editor EatSleepCode) {
	editor.win.ctx.quit()
}

fn event_update_escape(mut editor EatSleepCode) {
	if editor.buffers.len == 0 {
		return
	}
	editor.buffers[editor.current_buffer].controls.current_mode = .normal
}

fn event_update_i(mut editor EatSleepCode) {
	if editor.buffers.len == 0 {
		return
	}
	if editor.buffers[editor.current_buffer].controls.current_mode != .normal {
		return
	}
	editor.buffers[editor.current_buffer].controls.current_mode = .insert
}

fn event_update_char(c u32, mut editor EatSleepCode) {
	if editor.buffers.len == 0 {
		return
	}
	mut buf := &editor.buffers[editor.current_buffer]
	if buf.controls.current_mode != .insert {
		if buf.controls.current_mode == .normal && rune(c) == `i` {
			event_update_i(mut editor)
		}
		return
	}
	mut b := buf.context_content[buf.controls.cursor_file_y].runes()
	b.insert(buf.controls.cursor_file_x, rune(c))
	buf.context_content[buf.controls.cursor_file_y] = b.string()
	buf.controls.cursor_file_x += 1
	buf.controls.cursor_relative_x += 1
}
