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
