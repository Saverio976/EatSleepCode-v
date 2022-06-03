module main

import gx

const (
	colors_type  = ['void', 'int', 'char', 'long', 'short', 'struct', 'union', 'enum']
	type_color   = gx.green
	colors_match = ['switch', 'if', 'for', 'while', 'case', 'default', 'do']
	match_color  = gx.magenta
	colors_brack = ['{', '}', '(', ')', '[', ']', '\'', '"']
	brack_color = gx.red
)

fn split_text(text string) []string {
	mut l_i := 0
	mut arr := []string{}
	if text.len == 0 {
		return arr
	}
	for i in 0 .. text.len {
		if text[i] in [` `, `\t`] {
			arr << text[l_i..i]
			l_i = i
		}
	}
	if !(text[text.len - 1] in [` `, `\t`]) {
		arr << text[l_i..text.len]
	}
	return arr
}

fn get_color(text string, default gx.Color) gx.Color {
	t := text.replace('|', '').trim(' \n\t')
	if t in colors_type {
		return type_color
	} else if t in colors_match {
		return match_color
	} else if t in colors_brack {
		return brack_color
	}
	return default
}

fn draw_color_text(editor EatSleepCode, text string, cfg gx.TextCfg, xx int, y int) {
	words := split_text(text)
	if words.len == 0 {
		return
	}
	mut arr := []gx.TextCfg{}
	for i in 0 .. words.len {
		mut cf := gx.TextCfg{
			color: get_color(words[i], cfg.color)
			size: cfg.size
			bold: cfg.bold
			italic: cfg.italic
		}
		arr << cf
	}
	mut x := xx
	for i in 0 .. words.len {
		for e in 0 .. words[i].len {
			b := [words[i][e]]
			cf := gx.TextCfg{
				color: get_color(b.bytestr(), arr[i].color)
				size: arr[i].size
				bold: arr[i].bold
				italic: arr[i].italic
			}
			editor.win.ctx.draw_text(x, y, b.bytestr(), cf)
			x += cfg.size
		}
	}
}
