module main

fn delete_line(mut editor EatSleepCode) {
	if editor.buffers.len == 0 {
		return
	}
	mut buf := &editor.buffers[editor.current_buffer]
	if buf.max_number_line == 0 {
		return
	}
	buf.context_content.delete(buf.controls.cursor_file_y)
	if buf.max_number_line - 1 == buf.controls.cursor_file_y {
		buf.controls.cursor_file_y -= 1
		buf.controls.cursor_relative_y -= 1
	}
	buf.max_number_line -= 1
}

fn event_update_bacspace(mut editor EatSleepCode) {
	if editor.buffers.len == 0 {
		return
	}
	mut buf := &editor.buffers[editor.current_buffer]
	if buf.controls.current_mode != .insert {
		return
	}
	mut b := buf.context_content[buf.controls.cursor_file_y].runes()
	if buf.controls.cursor_file_x <= 0 {
		return
	}
	b.delete(buf.controls.cursor_file_x - 1)
	buf.context_content[buf.controls.cursor_file_y] = b.string()
	event_update_left(mut editor)
}

fn event_update_del(mut editor EatSleepCode) {
	if editor.buffers.len == 0 {
		return
	}
	mut buf := &editor.buffers[editor.current_buffer]
	if buf.controls.current_mode != .insert {
		return
	}
	mut b := buf.context_content[buf.controls.cursor_file_y].runes()
	if b.len >= buf.controls.cursor_file_x {
		return
	}
	b.delete(buf.controls.cursor_file_x)
	buf.context_content[buf.controls.cursor_file_y] = b.string()
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
	event_update_right(mut editor)
}
