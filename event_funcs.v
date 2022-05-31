module main

import gg

struct EvtFunc {
	code gg.KeyCode
	fun  gg.FNEvent
}

const (
	evtfuncsctrl    = [EvtFunc{
		code: .s
		fun: event_update_ctrls
	}, EvtFunc{
		code: .q
		fun: event_update_ctrlq
	}]
	evtfuncs_normal = [EvtFunc{
		code: .i
		fun: event_update_i
	}]
)

fn event_update_ctrls(event &gg.Event, mut editor EatSleepCode) {
}

fn event_update_ctrlq(event &gg.Event, mut editor EatSleepCode) {
	editor.win.ctx.quit()
}

fn event_update_i(event &gg.Event, mut editor EatSleepCode) {
}
