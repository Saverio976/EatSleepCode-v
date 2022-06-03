module main

import os
import gx
import gg

struct Win {
mut:
	width      int = 800
	height     int = 600
	ctx        &gg.Context = voidptr(0)
	char_size  int = 18
	char_space int = 3
}

enum Mode {
	insert
	command
	normal
	visual
}

struct Rect {
mut:
	left   int
	top    int
	width  int
	height int
}

struct Controls {
mut:
	cursor_relative_x int
	cursor_relative_y int
	cursor_file_x     int
	cursor_file_y     int
	current_mode      Mode = .normal
}

struct File {
mut:
	file_name       string   [required]
	file_path       string   [required]
	context_content []string = []string{}
	context_rect    Rect
	max_number_line int
	controls        Controls
}

struct EatSleepCode {
mut:
	win            &Win
	buffers        []File = []File{}
	current_buffer int
}

fn (mut editor EatSleepCode) draw() {
	editor.update_info()
	editor.draw_mode()
	editor.draw_buffer()
}

fn (editor EatSleepCode) draw_mode() {
	editor.win.ctx.draw_rounded_rect_filled(0, 0, editor.win.width, editor.win.char_size +
		(editor.win.char_space * 2), 120, gx.rgb(255, 0, 0))
	if editor.buffers.len == 0 {
		editor.draw_text(5, 0, 'No Mode', false, true, gx.black)
		return
	}
	text := match editor.buffers[editor.current_buffer].controls.current_mode {
		.normal { 'Normal' }
		.insert { 'Insert' }
		.command { 'Command' }
		.visual { 'Visual' }
	}
	editor.draw_text(5, 0, text, true, false, gx.blue)
}

fn get_str_print(s string, start int, end int) string {
	if s.len <= start || s.len == 0 {
		return ''
	}
	max := if end < s.len { end } else { s.len - 1 }
	mut e := s.substr_with_check(start, max + 1) or { '' }
	e = e.replace('\t', '    ')
	return e
}

fn (editor EatSleepCode) draw_buffer() {
	if editor.buffers.len == 0 {
		return
	}
	offset_y := (editor.win.char_size + editor.win.char_space) * 2
	lines := editor.buffers[editor.current_buffer].context_content
	editor.win.ctx.draw_rect_empty(2, offset_y, editor.win.width - 2, (editor.win.char_size +
		editor.win.char_space) * lines.len + editor.win.char_space, gx.gray)
	buf := editor.buffers[editor.current_buffer]
	mut b := lines[buf.controls.cursor_file_y].runes()
	b.insert(buf.controls.cursor_file_x, rune(`|`))
	start := buf.context_rect.left
	end := start + buf.context_rect.width
	end_line := if lines.len < buf.context_rect.top + buf.context_rect.height {
		lines.len
	} else {
		buf.context_rect.height + buf.context_rect.top
	}
	for i in buf.context_rect.top .. end_line {
		if i == buf.controls.cursor_file_y {
			true_line := get_str_print(b.string(), start, end + 1)
			editor.draw_text(5, i + 2 - buf.context_rect.top, true_line, false, false,
				gx.white)
		} else {
			true_line := get_str_print(lines[i], start, end)
			editor.draw_text(5, i + 2 - buf.context_rect.top, true_line, false, false,
				gx.white)
		}
	}
}

fn (editor EatSleepCode) draw_text(x int, line_y int, text string, is_bold bool, is_italic bool, color gx.Color) {
	y := (line_y * (editor.win.char_size + editor.win.char_space)) + editor.win.char_space
	if y > editor.win.height || y < 0 - editor.win.char_size - editor.win.char_size {
		return
	}
	cfg := gx.TextCfg{
		size: editor.win.char_size
		color: color
		italic: is_italic
		bold: is_bold
	}
	draw_color_text(editor, text, cfg, x, y)
}

fn (mut editor EatSleepCode) update_info() {
	editor.win.width = editor.win.ctx.window_size().width
	editor.win.height = editor.win.ctx.window_size().height
	if editor.buffers.len == 0 {
		return
	}
	offset_y := (editor.win.char_size + editor.win.char_space) * 2
	mut buf := &editor.buffers[editor.current_buffer]
	buf.context_rect.height = int(editor.win.height - offset_y) / (editor.win.char_size +
		editor.win.char_space)
	buf.context_rect.width = 80
}

fn new_file(path string) ?File {
	if os.is_file(path) != true {
		return error('file $path not found')
	}
	filename := os.file_name(path)
	lines := os.read_lines(path) or { return error('Cannot read file $path') }
	file := File{
		file_name: filename
		file_path: path
		context_content: lines
		max_number_line: lines.len
	}
	return file
}
