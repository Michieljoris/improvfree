function ergo(standalone) {
	if ( nargs() == 0 )
		standalone = 0
	if ( defined(Ergo) ) {
		print("Ergo is already running, it will be restarted!")
		if ( Ergo != $-1 )
			deleteobject(Ergo)
	}
	if ( ! defined(ErgoDebug) ) {
		ErgoDebug = 0
	}
	Ergo = new ergo_obj(standalone)
	Ergo.sendlabels()
	Ergo.start()
	if ( standalone )
		print("Ergo is now running (standalone)")
	else
		print("Ergo is now running (routed)")

	# if ( ! defined(Ergochecker) ) {
	# 	print("STARTING ERGOCHECKER!")
	# 	Ergochecker = task ergo_check()
	# }
}
function ergo_check() {
	acts = 0
	while ( 1 ) {
		sleeptill(Now+16b)
		nacts = Ergo.activity()
		print("check, activity=",nacts)
		if ( nacts == acts ) {
			print("Restarting ergo!")
			ergo()
			sleeptill(Now+4b)
		} else {
			acts = nacts
		}
	}
}
class ergo_obj {
	method init(standalone) {
		if ( ! defined(Ergoport) )
			Ergoport = "3930@localhost"

		print("Ergoport = ",Ergoport)

		$.responses = 0
		$.standalone = standalone
		$.itid = -1
		$.debug = 0
		$.mfifo = 0
		$.usegesture = 0

		$.playmode = "shape"

		$.openit()

		if ( $.usegesture && gesturedevices() > 0 ) {
			g = mdep("gesture","devices")
			$.g_width = []
			$.g_height = []
			for ( n in g ) {
				$.g_width[n] = g[n]["width"]
				$.g_height[n] = g[n]["height"]
			}
			gestureclear()
			gesturenotify($)
		}
	}
	method gotgesture(d) {
		contacts = d["contacts"]
		dev = d["device"]
		w = $.g_width[dev]
		h = $.g_height[dev]
		for ( i=0; i<contacts; i++ ) {
			if ( ! ( i in d ) ) {
				print("No i=",i," in d=",d," ??")
				continue
			}
			di = d[i]
			if ( ! "x" in di ) {
				print("No x in di=",di)
				continue
			}
			x = di["x"] / w
			y = di["y"] / h
			f = di["finger"]
			cmd = "finger "+string(f) +" "+string(x)+" "+string(y)
			$.sendergo(cmd)
		}
	}
	method openit() {
		$.numok = 0
		$.tcp = open(Ergoport,"rw","tcpip_connect")
		fifoctl($.tcp["r"],"type","l")
	}
	method closeit() {
		close($.tcp["w"])
		close($.tcp["r"])
	}
	method setdebug(dbg) {
		$.debug = dbg
	}
	method sendlabels() {
	}
	method start() {
		$.itid = task $.task_input()
		return($.itid)
	}
	method delete {
		print("ergo is killing itid and closing sockets\n")
		gestureunnotify($)
		if ( $.itid >= 0 )
			kill($.itid)
		# put($.tcp["w"],"quit\r\n")
		if ( $ != $-1 )
			$.closeit()
	}

	method set(p) {
		$.play(p)
	}


	method gridcell(r,c,v) {
		# print("Ergo.gridcell r=",r," c=",c," v=",v)
		cmd = "gridcell "+string(r)+" "+string(c)+" "+string(v)
		put($.mfifo,cmd)
	}
	method play(p) {
		# To avoid conflicting with "control" things,
		# force channel 16 to be mapped to channel 1
		p1 = p{??.chan == 16}
		if ( sizeof(p1) != 0 ) {
			p -= p1
			p1.chan = 1
			p |= p1
		}
		stime = Now
		if ( ErgoDebug )
			print("Ergo.play p=",p)
		for ( nt in p ) {
			tm1 = stime + nt.time
			sleeptill(tm1)
			if ( nt.type == NOTE ) {
				tm2 = stime + latest(nt)
				nt.type = NOTEON
				nt.time = 0
				put($.mfifo,nt)
				task $.play_off(tm2,nt)
			} else if ( nt.type == NOTEON ) {
				nt.time = 0
				put($.mfifo,nt)
			} else if ( nt.type == NOTEOFF ) {
				nt.time = 0
				put($.mfifo,nt)
			} else {
				nt.time = 0
				put($.mfifo,nt)
			}
		}
	}

	method play2(p,tm) {
		if ( nargs() < 2 )
			tm = Now
		stime = tm
		for ( nt in p ) {
			tm1 = stime + nt.time
			sleeptill(tm1)
			if ( nt.type == NOTE ) {
				tm2 = stime + latest(nt)
				nt.type = NOTEON
				nt.time = 0
				put($.mfifo,nt)
				task $.play_off(tm2,nt)
			} else if ( nt.type == NOTEON ) {
				nt.time = 0
				put($.mfifo,nt)
			} else if ( nt.type == NOTEOFF ) {
				nt.time = 0
				put($.mfifo,nt)
			} else {
				nt.time = 0
				put($.mfifo,nt)
			}
		}
	}

	method play_off(tm,nt) {
		sleeptill(tm)
		nt.type = NOTEOFF
		put($.mfifo,nt)
	}
	
	method midi_feed(n) {
		# print("Ergo.midi_feed n=",n)
		put($.mfifo,n)
	}

	method task_input {
		if ( $.standalone ) {
			Midiin[$] = $.mfifo = open()
			onexit(closemidi,$)
		} else {
			$.mfifo = open()
		}

		while ( (m=get($.mfifo)) != Eof ) {

			cmd = ""
			if ( typeof(m) == "string" ) {
				cmd = m
			} else if ( m.type == NOTEON ) {
				cmd = "noteon "+string(m.chan)+" "+string(m.pitch)+" "+string(m.vol)
			} else if ( m.type == NOTEOFF ) {
				cmd = "noteoff "+string(m.chan)+" "+string(m.pitch)+" "+string(m.vol)
			} else if ( m.type == CONTROLLER ) {
				ch = 1 + (subbytes(m,1,1)&0x0f)
				# print("ERGO task_input m=",m," ch=",ch)
				ct = 0+subbytes(m,2,1)
				cv = 0+subbytes(m,3,1)
				cmd = "controller "+string(ch)+" "+string(ct)+" "+string(cv)
			} else if ( m.type == PITCHBEND ) {
				ch = 1 + (subbytes(m,1,1)&0x0f)
				ct = 0+subbytes(m,2,1)
				cv = 0+subbytes(m,3,1)
				cmd = "pitchbend "+string(ch)+" "+string(ct)+" "+string(cv)
			}
			if ( cmd != "" )
				$.sendergo(cmd)

		}
	}

	method activity() {
		return($.responses)
	}
	method sendergo(cmd) {
		if ( $.debug || ErgoDebug )
			print("sendergo cmd=",cmd," ErgoDebug=",ErgoDebug)
		if ( ! defined(Ergobuffer) )
			Ergobuffer = 16
		while ( 1 ) {
			lock($)
			a = put($.tcp["w"],cmd+"\r\n")

			s = "OK"
			$.numok++
			# Things were too slow when we read
			# a response on every line, so we only
			# read the responses every once in a while
			if ( $.numok >= Ergobuffer ) {
				for ( i=0; i<$.numok; i++ ) {
					s = get($.tcp["r"])
					if ( s == Eof || s == Interrupt ) {
						print("EOF/INTERRUPT from ergo socket!")
					} else {
						$.responses++
					}
				}
				$.numok = 0
			}
			unlock($)
			if ( typeof(s) == "string" && s ~~ "OK.*" )
				break
			print("Ergo connection broken?  Attempting reconnect...")
			$.closeit()
			millisleep(1000)
			$.openit()
			millisleep(1000)
		}
	}
}
