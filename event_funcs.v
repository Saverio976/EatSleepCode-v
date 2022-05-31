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
	convert_c_to_code = {
		rune(`a`): gg.KeyCode.a
		rune(`b`): gg.KeyCode.b
		rune(`c`): gg.KeyCode.c
		rune(`d`): gg.KeyCode.d
		rune(`e`): gg.KeyCode.e
		rune(`f`): gg.KeyCode.f
		rune(`g`): gg.KeyCode.g
		rune(`h`): gg.KeyCode.h
		rune(`i`): gg.KeyCode.i
		rune(`j`): gg.KeyCode.j
		rune(`k`): gg.KeyCode.k
		rune(`l`): gg.KeyCode.l
		rune(`m`): gg.KeyCode.m
		rune(`o`): gg.KeyCode.o
		rune(`p`): gg.KeyCode.p
		rune(`q`): gg.KeyCode.q
		rune(`r`): gg.KeyCode.r
		rune(`s`): gg.KeyCode.s
		rune(`t`): gg.KeyCode.t
		rune(`u`): gg.KeyCode.u
		rune(`v`): gg.KeyCode.v
		rune(`w`): gg.KeyCode.w
		rune(`x`): gg.KeyCode.x
		rune(`y`): gg.KeyCode.y
		rune(`z`): gg.KeyCode.z
		rune(`0`): gg.KeyCode._0
		rune(`1`): gg.KeyCode._1
		rune(`2`): gg.KeyCode._2
		rune(`3`): gg.KeyCode._3
		rune(`4`): gg.KeyCode._4
		rune(`5`): gg.KeyCode._5
		rune(`6`): gg.KeyCode._6
		rune(`7`): gg.KeyCode._7
		rune(`8`): gg.KeyCode._8
		rune(`9`): gg.KeyCode._9
	}
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

fn event_update_down(mut editor EatSleepCode) {
	if editor.buffers.len == 0 {
		return
	}
	mut buf := &editor.buffers[editor.current_buffer]
	if buf.controls.cursor_file_y <= 0 {
		buf.controls.cursor_file_y = 0
		buf.controls.cursor_relative_y = 0
		return
	}
	buf.controls.cursor_file_y -= 1
	buf.controls.cursor_relative_y -= 1
	line := buf.context_content[buf.controls.cursor_file_y]
	if buf.controls.cursor_file_x >= line.len {
		buf.controls.cursor_file_x = line.len
		buf.controls.cursor_relative_x = line.len
		return
	}
}

fn event_update_up(mut editor EatSleepCode) {
	if editor.buffers.len == 0 {
		return
	}
	mut buf := &editor.buffers[editor.current_buffer]
	if buf.controls.cursor_file_y >= buf.max_number_line - 1 {
		buf.controls.cursor_file_y = buf.max_number_line - 1
		buf.controls.cursor_relative_y += buf.max_number_line - 1
		return
	}
	buf.controls.cursor_file_y += 1
	buf.controls.cursor_relative_y += 1
	line := buf.context_content[buf.controls.cursor_file_y]
	if buf.controls.cursor_file_x >= line.len {
		buf.controls.cursor_file_x = line.len
		buf.controls.cursor_relative_x = line.len
		return
	}
}

fn event_update_left(mut editor EatSleepCode) {
	if editor.buffers.len == 0 {
		return
	}
	mut buf := &editor.buffers[editor.current_buffer]
	if buf.controls.cursor_file_x <= 0 {
		buf.controls.cursor_file_x = 0
		buf.controls.cursor_relative_x = 0
		return
	}
	buf.controls.cursor_file_x -= 1
	buf.controls.cursor_relative_x -= 1
}

fn event_update_right(mut editor EatSleepCode) {
	if editor.buffers.len == 0 {
		return
	}
	mut buf := &editor.buffers[editor.current_buffer]
	line := buf.context_content[buf.controls.cursor_file_y]
	if buf.controls.cursor_file_x >= line.len {
		buf.controls.cursor_file_x = line.len
		buf.controls.cursor_relative_x = line.len
		return
	}
	buf.controls.cursor_file_x += 1
	buf.controls.cursor_relative_x += 1
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
		if buf.controls.current_mode == .normal {
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
