
function midimon(verbose) {

	if ( nargs() < 1 )
		verbose = 0
	# spawn the task that will monitor MIDI input
	t = task task_midimon(verbose)

	Root.waitforconsolekey()

	kill(t)
}

function unkorgmon(k,f) {
	k.unsendtofifo(f)
}

function task_midimon(verbose) {

	k = korgcontrol(0)
	if ( k == -1 ) {
		Midiin[$] = f = open()
		onexit(closemidi,$)
	} else {
		f = open()
		k.sendtofifo(f)
		onexit(unkorgmon,k,f)
	}

	while ( (m=get(f)) != Eof ) {
		if ( verbose ) {
			print("p=",m,"  pitch=",m.pitch,"  vol=",m.vol)
		} else {
			print(m)
		}
	}
}
