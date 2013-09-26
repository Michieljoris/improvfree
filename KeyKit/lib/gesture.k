Gesturefifo = -1
Gestureid = -1
Gesturein = []
Gesturedebug = 0
Gesturequant = 1b/8
Gesturedragthreshold = 0.02

function gesturefifo() {
	if ( Gesturefifo < 0 )
		Gesturefifo = open("contacts","rA","gesture")
	while ( fifosize(Gesturefifo) > 0 )
		get(Gesturefifo)
	return(Gesturefifo)
}
function gesturedevices() {
	a = mdep("gesture","devices")
	return(sizeof(a))
}
function gestureclear() {
	mdep("gesture","clear")
}

function gesturestart() {
	if ( Gestureid >= 0 )
		gesturestop()
	Gestureid = task gesturenotifytask(3)
}
function gesturestop() {
	kill(Gestureid)
	Gestureid = -1
}
function gesturenotify(obj) {
	if ( Gestureid < 0 )
		gesturestart()
	if ( ! defined(obj.gotgesture) )
		print("No method gotgesture in obj=",obj)
	else
		Gesturein[obj] = 0
}
function gesturenotifyrc(obj,r,c) {
	if ( Gestureid < 0 )
		gesturestart()
	if ( ! defined(obj.gotgesturerc) )
		print("No method gotgesturerc in obj=",obj)
	else
		Gesturein[obj] = ["r"=r,"c"=c]
}
function gestureunnotify(obj) {
	delete Gesturein[obj]
	if ( sizeof(Gesturein) == 0 ) {
		gesturestop()
	}
}

function gesturenotifytask(queuelimit) {
	if ( ! defined(GestureFifolimit) ) {
		GestureFifolimit = 10
	}
	gf = gesturefifo()
	if ( nargs() < 2 )
		queuelimit = 0

	gestureclear()

	a = mdep("gesture","devices")
	width = []
	height = []
	for ( i in a ) {
		width[i] = a[i]["width"]
		height[i] = a[i]["height"]
	}

	curry = 0
	fing_down = []
	fing_tm = []
	ndown = 0
	lastfingerdown = -1

	while (1) {
		d = get(gf)
		# print("gfifo=",fifosize(gf)," d=",d)
		if ( fifosize(gf) > GestureFifolimit ) {
			print("CLEARING GESTURE FIFO!")
			gestureclear()
			continue
		}
		if ( Gesturedebug > 1 )
			print("\nGESTURE EVENT = ",d)
		# get rid of stale things in Gesturein
		for ( obj in Gesturein ) {
			if ( obj == $0 || obj == $-1 ) {
				delete Gesturein[obj]
			}
		}
		if ( queuelimit > 0 ) {
			ne = fifosize(f)
			if ( ne > queuelimit ) {
				print("throwing away gesture... ne=",ne)
				continue
			}
		}
		ng = sizeof(Gesturein)
		for ( obj in Gesturein ) {
			t = Gesturein[obj]
			if ( typeof(t) == "integer" ) {
				obj.gotgesture(d)
				ng--
			}
		}
		if ( ng <= 0 )
			continue
		# Someone wants row/col notification

		nc = d["contacts"]
		# print(d)
		dev = d["device"]
		if ( ! (dev in width) ) {
			print("Hey, dev=",dev," is not in width?")
			continue
		}
		wid = width[dev]
		hgt = height[dev]
		if ( wid <= 0 ) {
			print("wid for device = ",dev," is ",wid," ??")
			continue
		}
		nc = d["contacts"]
		# see what's down now
		nowdown = []
		for ( n=0; n<nc; n++ ) {
			contact = d[n]
			if ( typeof(contact) != "array" ) {
				print("Hey, d[n=",n,"]=",contact," is not an array?")
				continue
			}
			if ( ! ("finger" in contact) ) {
				print("Hey, finger is not in contact=",contact)
				continue
			}
			finger = contact["finger"]
			# print("contact=",contact)
			if ( finger == 0 ) {
				# print("IGNORING finger=0 d=",d)
				continue
			}
			nowdown[finger+dev*100] = 1
		}
		# print("MID nowdown=",nowdown," fing_down=",fing_down)
		# Update down, do noteoff for anything that's no longer down
		for ( i in fing_down ) {
			idev = i / 100
			if ( idev != dev )
				continue
			if ( ! ( i in nowdown ) ) {
				arr = fing_down[i]
				for ( obj in Gesturein ) {
					t = Gesturein[obj]
					if ( typeof(t) != "array" )
						continue
					xf = arr["x"]
					yf = arr["y"]
					f = i % 100
					r = integer(t["r"] * yf)
					c = integer(t["c"] * xf)
					if ( Gesturedebug )
						print("FINGERUP xy=",xf,yf," f=",f," i=",i," rc=",r,c)
					tt = task obj.gotgesturerc("fingerup",dev,f,r,c,0.0)
					wait(tt)
					
				}
				delete fing_down[i]
			}
		}
		for ( n=0; n<nc; n++ ) {
			contact = d[n]
			if ( typeof(contact) != "array" ) {
				print("Hey, d[n=",n,"]=",contact," is not an array?")
				continue
			}
			finger = contact["finger"]
			if ( finger == 0 )
				continue
			if ( contact["proximity"] < 0.7 )
				continue

			xf = contact["x"] / wid
			yf = contact["y"] / hgt
			fval = finger + dev*100
			if ( fval in fing_down ) {
				oldxf = fing_down[fval]["x"]
				oldyf = fing_down[fval]["y"]
				dxf = abs(oldxf - xf)
				dyf = abs(oldyf - yf)
				dist = sqrt((dxf*dxf)+(dyf*dyf))
				if ( dist > Gesturedragthreshold ) {
					if ( Gesturedebug )
						print("FINGERDRAG xy=",xf,yf," f=",f," i=",i," rc=",r,c)
					# print("dragged finger=",finger," fing_down=",fing_down[fval]," contact=",contact)
					if ( fifosize(gf) < 10 ) {
						togesturein("fingerdrag",xf,yf,contact,dev,finger)
					} else {
						print("gf=",fifosize(gf)," skipping fingerdrag callback")
					}
					fing_down[fval] = ["x"=xf,"y"=yf]
				}
				continue
			}
			togesturein("fingerdown",xf,yf,contact,dev,finger)
			fing_down[fval] = ["x"=xf,"y"=yf]
		}
	}
}

function togesturein(gtype,xf,yf,contact,dev,finger) {
	for ( obj in Gesturein ) {
		t = Gesturein[obj]
		if ( typeof(t) != "array" )
			continue
		r = integer(t["r"] * yf)
		c = integer(t["c"] * xf)
		if ( Gesturedebug )
			print("FINGERDOWN xy=",xf,yf," rc=",r,c," finger=",finger," proximity=",contact["proximity"])
		prox = contact["proximity"]
		tt = task obj.gotgesturerc(gtype,dev,finger,r,c,prox)
		wait(tt)
	}
}

function gesturemon() {
	print(mdep("gesture","devices"))
	g = new gesturemon_obj()
	gesturenotify(g)
	Root.waitforconsolekey()
	gestureunnotify(g)
	deleteobject(g)
}
function gesturemonrc(r,c) {
	if ( nargs() < 2 ) {
		r = 8
		c = 8
	}
	print(mdep("gesture","devices"))
	g = new gesturemon_obj()
	gesturenotifyrc(g,r,c)
	Root.waitforconsolekey()
	gestureunnotify(g)
	deleteobject(g)
}
class gesturemon_obj {
	method init() {
	}
	method gotgesture(d) {
		print("gesture raw =",d)
	}
	method gotgesturerc(type,dev,f,r,c,prox) {
		print("gesture ",type," dev=",dev," f=",f," prox=",prox," rc=",r,c)
	}
}
function task_gesturemon() {
	f = gesturefifo()
	gestureclear()
	while ( fifosize(f) > 0 )
		get(f)
	while (1) {
		d = get(f)
		print(d)
	}
}

function gplay() {
	print("Play away...")
	a = mdep("gesture","devices")
	limit = 7
	width = []
	height = []
	for ( i in a ) {
		width[i] = a[i]["width"]
		height[i] = a[i]["height"]
	}
	print("width=",width)
	print("height=",height)
	f = gesturefifo()
	initialized = 0
	mdep("gesture","clear")
	while (1) {
		d = get(f)
		nc = d["contacts"]
		if ( initialized == 0 ) {
			if ( nc > limit ) {
				continue
			}
			initialized = 1
		}
		# print(d)
		dev = d["device"]
		if ( ! (dev in width) ) {
			print("Hey, dev=",dev," is not in width?")
			continue
		}
		wid = width[dev]
		hgt = height[dev]
		if ( wid <= 0 ) {
			print("wid for device = ",dev," is ",wid," ??")
			continue
		}
		nc = d["contacts"]
		if ( nc > limit )
			break
		for ( n=0; n<nc; n++ ) {
			dd = d[n]
			x = dd["x"]
			y = dd["y"]
			xp = integer( 5 * dd["proximity"] + ( 128 * x / wid) )
			yp = integer(128 * y / hgt)
			print("(",xp,",",dd["proximity"],dd["finger"],")")
			nt = makenote(xp,1b/4,yp,dd["finger"])
			realtime(nt)
		}
	}
}

function gscale(...) {
	t = task task_gscale(...)
	Root.waitforconsolekey()
	print("GOT CONSOLE KEY, killing gscale...")
	kill(t)
	realtime(ano())
}

function task_gscale(key,scalename) {
	if ( nargs() < 2 ) {
		scalename = "newage"
	}
	if ( nargs() < 1 ) {
		key = 'c'
	}
	print("Play away...")
	a = mdep("gesture","devices")
	limit = 7
	width = []
	height = []
	for ( i in a ) {
		width[i] = a[i]["width"]
		height[i] = a[i]["height"]
	}
	print("width=",width)
	print("height=",height)
	f = gesturefifo()
	mdep("gesture","clear")
	sc = completescale(key,scalename)
	scsize = sizeof(sc)
	curry = 0
	print("sc=",sc)
	fing_down = []
	fing_currx = []
	fing_scpos = []
	ndown = 0
	lastfingerdown = -1
	lastxdown = 64
	lastscpos = scsize/2
	while (1) {
		d = get(f)
		nc = d["contacts"]
		# print(d)
		dev = d["device"]
		if ( ! (dev in width) ) {
			print("Hey, dev=",dev," is not in width?")
			continue
		}
		wid = width[dev]
		hgt = height[dev]
		if ( wid <= 0 ) {
			print("wid for device = ",dev," is ",wid," ??")
			continue
		}
		nc = d["contacts"]
		# see what's down now
		nowdown = []
		for ( n=0; n<nc; n++ ) {
			contact = d[n]
			finger = contact["finger"]
			# print("contact=",contact)
			if ( finger == 0 )
				continue
			nowdown[finger] = 1
		}
		# Update down, do noteoff for anything that's no longer down
		for ( i in fing_down ) {
			if ( ! ( i in nowdown ) ) {
				# print("finger i=",i," no longer down")
				nt = fing_down[i]
				nt.type = NOTEOFF
				print("Now=",Now," OFF finger=",i," pitch=",nt.pitch," nt=",nt)
				nt.time = 0
				realtime(nt)
				delete fing_down[i]
				delete fing_currx[i]
				delete fing_scpos[i]
				if ( lastfingerdown == i ) {
					if ( sizeof(fing_down) == 0 )
						lastfingerdown = -1
					else {
						for ( ff in fing_down ) {
							lastfingerdown = ff
							break
						}
					}
				}
			}
		}
		for ( n=0; n<nc; n++ ) {
			contact = d[n]
			finger = contact["finger"]
			if ( finger == 0 )
				continue
			if ( contact["proximity"] < 1.0 )
				continue
			# print("contact=",contact)

			x = integer((128 * contact["x"]) / wid)
			if ( finger in fing_down ) {
				# If last finger down moves, update currx
				if ( lastfingerdown == finger ) {
					fing_currx[finger] = x
					lastxdown = x
				}
				continue
			}
			print("")
			if ( sizeof(fing_down) == 0 ) {
				print("First finger, nothing done... x=",x)
				scpos = lastscpos
				currx = lastxdown
				lastfingerdown = finger
			} else {
				scpos = fing_scpos[lastfingerdown]
				currx = fing_currx[lastfingerdown]
				print("finger ",finger," went down x=",x," last currx = ",currx," last scpos=",scpos," for lsatfinger=",lastfingerdown)
			}
			if ( x > currx ) {
				dx = x - currx
				dc = integer(dx/12)
				print("dc=",dc," dx=",dx)
				nscpos = scpos+dc
			}
			else if ( x < currx ) {
				dx = currx - x
				dc = integer(dx/12)
				print("dc=",dc," dx=",dx)
				nscpos = scpos-dc
			}
			if ( dc == 0 ) {
				print("finger=",finger," dc==0, NO CHANGE, no update to scpos or currx")
			}
			if ( ! ( nscpos < 1 || nscpos > scsize ) ) {
				scpos = nscpos
			}
			nt = sc%scpos
			for ( ff in fing_down ) {
				if ( nt.pitch == fing_down[ff].pitch ) {
					print("Duplicate pitch ?  nt.pitch=",nt.pitch)
					# nt = ''
					break
				}
			}
			if ( nt == '' )
				continue
			nt = makenote(nt.pitch,1b/4,100)
			nt.type = NOTEON
			nt.time = nextquant(Now,1b/4) - Now
			print("Now=",Now," ON finger=",finger," pitch=",nt.pitch,"  nt=",nt)
			realtime(nt)
			fing_down[finger] = nt
			fing_scpos[finger] = scpos
			fing_currx[finger] = x
			lastxdown = x
			lastscpos = scpos
			lastfingerdown = finger
		}
	}
}

function ggrab(...) {
	t = task task_ggrab(...)
	Root.waitforconsolekey()
	print("GOT CONSOLE KEY, killing gscale...")
	kill(t)
	realtime(ano())
	f = open("last.kg","w")
	put(f,"Ggrab=")
	put(f,Ggrab)
	close(f)
}

function task_ggrab() {
	Ggrab = []
	print("Grab away...")
	a = mdep("gesture","devices")
	width = []
	height = []
	for ( i in a ) {
		width[i] = a[i]["width"]
		height[i] = a[i]["height"]
	}
	f = gesturefifo()
	mdep("gesture","clear")
	curry = 0
	fing_down = []
	fing_currx = []
	ndown = 0
	lastfingerdown = -1
	lastxdown = 64
	while (1) {
		d = get(f)
		nc = d["contacts"]
		# print(d)
		dev = d["device"]
		if ( ! (dev in width) ) {
			print("Hey, dev=",dev," is not in width?")
			continue
		}
		wid = width[dev]
		hgt = height[dev]
		if ( wid <= 0 ) {
			print("wid for device = ",dev," is ",wid," ??")
			continue
		}
		nc = d["contacts"]
		# see what's down now
		nowdown = []
		for ( n=0; n<nc; n++ ) {
			contact = d[n]
			finger = contact["finger"]
			# print("contact=",contact)
			if ( finger == 0 )
				continue
			nowdown[finger] = 1
		}
		# Update down, do noteoff for anything that's no longer down
		for ( i in fing_down ) {
			if ( ! ( i in nowdown ) ) {
				print("Now=",Now," OFF finger=",i)
				delete fing_down[i]
			}
		}
		for ( n=0; n<nc; n++ ) {
			contact = d[n]
			finger = contact["finger"]
			if ( finger == 0 )
				continue
			if ( contact["proximity"] < 1.0 )
				continue
			# print("contact=",contact)

			x = integer((128 * contact["x"]) / wid)
			y = integer((128 * contact["y"]) / hgt)
			if ( finger in fing_down ) {
				continue
			}
			fing_down[finger] = 1
			ng = sizeof(Ggrab)
			p = lastnotechord()
			p = strip(p)
			Ggrab[ng] = ["x"=x,"y"=y,"p"=p]
			print("ng=",ng," Grab=",Ggrab[ng])
		}
	}
}

function ggrabset(p,gsize,delta,onstarts) {
	if ( nargs() < 2 )
		gsize = 32
	if ( nargs() < 3 )
		delta = 1b
	if ( nargs() < 4 )
		onstarts = 1
	p = onlynotes(p)
	if ( onstarts )
		arr = splitonstarts(p,delta,3)
	else
		arr = spliteven(p,delta)
	for ( i in arr ) {
		arr[i] = strip(arr[i])
	}
	pn=0
	arrsize = sizeof(arr)
	if ( arrsize == 0 ) {
		print("No phrase?")
		return()
	}
	Ggrab = []
	dx = 128 / gsize
	dy = 128 / gsize
	for ( x=0; x<128; x++) {
		Ggrab[x] = []
		for ( y=0; y<128; y++ ) {
			p = ''
			limit = 0
			while ( p == '' && limit++ < 100 ) {
				if ( pn >= arrsize )
					pn = 0
				p = arr[pn++]
			}
			Ggrab[x][y] = p
		}
	}
}
function ggrabplay(sz) {
	if ( nargs() < 1 )
		sz = 16
	t = new ggrabplay_obj(sz,sz)
	Root.waitforconsolekey()
	print("GOT CONSOLE KEY, killing ggrabplay...")
	deleteobject(t)
	realtime(ano())
}

class ggrabplay_obj {

method init(r,c) {
	$.fing_down = []
	$.fing_tm = []
	$.min_time = 1b/4
	$.lastfingerdown = -1
	if ( nargs() > 0 ) {
		$.nrows = r
		$.ncols = c
	} else {
		$.nrows = 16
		$.ncols = 16
	}
	gesturenotifyrc($,$.nrows,$.ncols)
	print("Play away...")
}
method delete {
	gestureunnotify($)
}

method gotgesturerc(type,dev,finger,r,c,prox) {
	i = 100 * dev + finger
	if ( Gesturedebug )
		print("type=",type," i=",i)
	if ( type == "fingerup" ) {
		if ( ! ( i in $.fing_down ) ) {
			print("i=",i," not in fing_down?")
			return()
		}
		p = $.fing_down[i]
		p.type = NOTEOFF
		t = $.fing_tm[i]
		# print("Now=",Now," OFF finger=",i," p=",p)
		if ( Now < (t+$.min_time) ) {
			# print("adding min_time")
			p.time += $.min_time
		} else {
			t = Now
			p.time += (Now - t) + 2
		}
		realtime(p,0)
		# print("p=",p)
		delete $.fing_down[i]
		delete $.fing_tm[i]
	} else if ( type == "fingerdown" ) {
		r = r % ($.nrows)
		c = c % ($.ncols)
		if ( ! ( c in Ggrab ) || ! ( r in Ggrab[c] ) ) {
			if ( Gesturedebug ) {
				print("Ggrab c=",c," r=",r," doesn't exist")
				return()
			}
		}
		p = Ggrab[c][r]
		p.type = NOTEON
		if ( prox > 4.0 )
			p.vol += 60
		else if ( prox > 3.0 )
			p.vol += 40
		else if ( prox > 2.0 )
			p.vol += 20
		else if ( prox < 1.0 )
			p.vol -= 20
		t = nextquant(Now,Gesturequant)
		p.time += t
		realtime(p,0)
		# print("p=",p)
		$.fing_down[i] = p
		$.fing_tm[i] = t
	}
}
}

function ginterval(...) {
	t = task task_ginterval(...)
	Root.waitforconsolekey()
	kill(t)
	realtime(ano())
}
function task_ginterval(key,scalename) {
	if ( nargs() < 2 ) {
		scalename = "newage"
	}
	if ( nargs() < 1 ) {
		key = 'c'
	}
	print("Play away...")
	a = mdep("gesture","devices")
	limit = 7
	width = []
	height = []
	for ( i in a ) {
		width[i] = a[i]["width"]
		height[i] = a[i]["height"]
	}
	print("width=",width)
	print("height=",height)
	f = gesturefifo()
	initialized = 0
	mdep("gesture","clear")
	sc = completescale(key,scalename)
	scsize = sizeof(sc)
	curr = sizeof(sc)/2
	currx = 0
	curry = 0
	print("sc=",sc)
	print("curr nt = ",sc%curr)
	down = []
	for ( n=0; n<10; n++ ) {
		down[n] = 0
		# currx[n] = 0
	}
	ndown = 0
	while (1) {
		d = get(f)
		nc = d["contacts"]
		if ( initialized == 0 ) {
			if ( nc > limit ) {
				continue
			}
			initialized = 1
		}
		# print(d)
		dev = d["device"]
		if ( ! (dev in width) ) {
			print("Hey, dev=",dev," is not in width?")
			continue
		}
		wid = width[dev]
		hgt = height[dev]
		if ( wid <= 0 ) {
			print("wid for device = ",dev," is ",wid," ??")
			continue
		}
		nc = d["contacts"]
		if ( nc > limit )
			break
		for ( n=0; n<nc; n++ ) {
			contact = d[n]
			x = integer((128 * contact["x"]) / wid)
			if ( currx == x )
				continue
			print("x=",x)
			if ( x > currx ) {
				dx = x - currx
				dc = integer(dx/12)
				print("dc=",dc," dx=",dx)
				ncurr = curr+dc
			}
			else if ( x < currx ) {
				dx = currx - x
				dc = integer(dx/12)
				print("dc=",dc," dx=",dx)
				ncurr = curr-dc
			}
			if ( ncurr < 1 || ncurr > scsize ) {
				# do nothing
			} else {
				curr = ncurr
			}
			currx = x
			nt = sc%curr
			nt = makenote(nt.pitch,1b/4,100)
			print("nt=",nt)
			realtime(nt)
		}
	}
}

function gdrum_task() {
	tm = Now+1b
	cnt = 0
	while (1) {
		sleeptill(tm)
		tm += 1b/4
	}
}
function gdrum() {
	Gpitch=[0=40,1=41,2=42,3=43]
	Gcol=[0=0,1=0,2=0,3=0]
	Gstart=[0=0,1=0,2=0,3=0]
	print("Play away...")
	a = mdep("gesture","devices")
	limit = 7
	width = []
	height = []
	for ( i in a ) {
		width[i] = a[i]["width"]
		height[i] = a[i]["height"]
	}
	print("width=",width)
	print("height=",height)
	f = gesturefifo()
	initialized = 0
	mdep("gesture","clear")
	while (1) {
		d = get(f)
		nc = d["contacts"]
		if ( initialized == 0 ) {
			if ( nc > limit ) {
				continue
			}
			initialized = 1
		}
		# print(d)
		dev = d["device"]
		if ( ! (dev in width) ) {
			print("Hey, dev=",dev," is not in width?")
			continue
		}
		wid = width[dev]
		hgt = height[dev]
		if ( wid <= 0 ) {
			print("wid for device = ",dev," is ",wid," ??")
			continue
		}
		nc = d["contacts"]
		if ( nc > limit )
			break
		for ( n=0; n<nc; n++ ) {
			dd = d[n]
			x = dd["x"]
			y = dd["y"]
			row = integer(5 * y / hgt)
			xp = integer( 5 * dd["proximity"] + ( 128 * x / wid) )
			yp = integer(128 * y / hgt)
			print("(",xp,",",dd["proximity"],dd["finger"],")")
			nt = makenote(xp,1b/4,yp,dd["finger"])
			realtime(nt)
		}
	}
}

function ggrabdemo5(stepit) {
	a = completescale('c',"newage")
	a = step(a,1b/4)
	a.chan = 1
	a.vol -= 20
	if ( nargs() < 1 )
		stepit = 1b/2
	a = step(a,stepit)
	Ggrabphrase = a
	Ggrabstepit = stepit
	sz = 8
	ggrabset(a,sz,stepit)
	ggrabplay(sz)
}
function ggrabdemo4(stepit) {
	a = readmf("jsbach.mid")
	a = scadjust(a,makescale(scalenamed("newage")))
	a.chan = 1
	a.vol -= 20
	if ( nargs() > 0 )
		a = step(a,stepit)
	ggrabset(a,8,1b)
	ggrabplay(8)
}
function ggrabdemo3() {
	a = readmf("prelude.mid")
	a.chan = 1
	ggrabset(a,16,1b)
	ggrabplay()
}
function ggrabdemo2() {
	a = readmf("c:\\burn\\midi\\tjt\\state.mid")
	a = a - a{??.chan==10}
	a.chan = 1
	ggrabset(a,16,1b/2)
	ggrabplay()
}
function ggrabdemo1() {
	a = readmf("c:\\burn\\midi\\tjt\\autograp.mid")
	a = a - a{??.chan==10}
	a.chan = 1
	ggrabset(a,16,1b)
	ggrabplay()
}
