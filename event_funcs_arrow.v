module main

fn event_update_down(mut editor EatSleepCode) {
	if editor.buffers.len == 0 {
		return
	}
	mut buf := &editor.buffers[editor.current_buffer]
	if buf.controls.cursor_file_y <= 0 {
		buf.controls.cursor_file_y = 0
		buf.controls.cursor_relative_y = 0
		buf.context_rect.top = 0
		return
	}
	buf.controls.cursor_file_y -= 1
	buf.controls.cursor_relative_y -= 1
	if buf.controls.cursor_relative_y <= buf.context_rect.top {
		buf.context_rect.top -= 1
	}
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
		buf.controls.cursor_relative_y = buf.max_number_line - 1
		buf.context_rect.top = buf.max_number_line - 1
		return
	}
	buf.controls.cursor_file_y += 1
	buf.controls.cursor_relative_y += 1
	if buf.controls.cursor_relative_y >= buf.context_rect.top + buf.context_rect.height {
		buf.context_rect.top += 1
	}
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
		buf.context_rect.left = 0
		return
	}
	buf.controls.cursor_file_x -= 1
	buf.controls.cursor_relative_x -= 1
	if buf.controls.cursor_relative_x <= buf.context_rect.left {
		buf.context_rect.left -= 1
	}
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
		buf.context_rect.left = line.len
		return
	}
	buf.controls.cursor_file_x += 1
	buf.controls.cursor_relative_x += 1
	if buf.controls.cursor_relative_x >= buf.context_rect.left + buf.context_rect.width {
		buf.context_rect.left += 1
	}
}
