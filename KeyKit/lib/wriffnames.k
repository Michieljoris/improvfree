class wriffnames {
method init {
	$.w = new window()
	$.inherit($.w)

	$.ph = new wphrase()
	$.riffs = [0='c e g']
	arr = [0="C Chord"]
	$.b1 = new kvalbutton(arr,$,"change")
	$.b2 = new kmenubutton("More","mkmenu_riffnames_more",$)
	$.randbutt = new kbutton("Rand",$,"randomize")
	$.t2 = new ktoggle("Loop",$,"setvar","loop")
	$.addchild($.ph)
	$.addchild($.b1)
	$.addchild($.b2)
	$.addchild($.randbutt)
	$.addchild($.t2)

	$.startquant = 1
	$.loopquant = 1
	$.loop = 0
	$.factor = 1.0
	$.ison = 0
	$.leng = 0
	$.nexttranspose = 0
	$.stoptids = []
	$.riffnames_listentokey = 0
	$.basekey = 'c'
	$.currentkey = 'c'
	$.neverfit = 0

	$.realset($.riffs[0])
}
method clear {
	$.riffs = []
	$.b1.set(0)
	$.b1.setvals([])
	$.b1.redraw()
	$.ph.set('',1)
}
method change(n) {
	p = $.riffs[n]
	$.realset(p,1)
}
method addnew {
	vals = $.b1.getvals()
	nv = sizeof(vals)
	nm = "riff_"+string(nv)
	vals[nv] = nm
	$.b1.setvals(vals)
	$.b1.set(nv)
	$.b1.redraw()
}
method viewset(...) { $.ph.viewset(...) }
method wayout { $.ph.wayout() }
method redraw { $.w.redraw() ; methodbroadcast(); }

method delete {
			killtids($.stoptids)
			$.stoptids = []
			}

method setname(p) {
	curr = $.b1.get()
	nm = getastr("Enter name --> ")
	p = $.get()
	names = $.b1.getvals()
	names[curr] = nm
	$.b1.setvals(names)
	$.riffs[curr] = p

	$.b1.set(curr)
	$.b1.redraw()
}

method setvar (v,m,nm) {
			if ( nm == "on" ) {
				if ( v ) $.play(); else $.stop()
			}
			$.(nm) = v
			return(99)
		}
method strip { $.set(strip($.ph.get()),1) }
method bang {
			if ( $.ison )
				$.stop()
			else
				$.play()
			}
method setstartquant (v) { $.startquant = v }
method setlooping (v) {
	$.loop = v
	$.t2.set(1)
}
method setloopquant (v) { $.loopquant = v }
method setfactor(f) {
	$.factor = f
	$.set($.get(),1)
}
method get {
	curr = $.b1.get()
	return($.riffs[curr])
}
method set (p,doredraw) {
	# A "set" adds a new named phrase - this may be a mistake,
	# but it's superficially convenient
	$.addnew()
	if ( nargs() < 2 )
		doredraw = 0
	$.realset(p,doredraw)
}
method realset (p,doredraw) {
	curr = $.b1.get()
	$.riffs[curr] = p
	if ( $.factor != 1.0 )
		p = scatimes(p,$.factor)
	if ( $.riffnames_listentokey != 0 ) {
		tr = canonic(Key)-canonic($.basekey)
		p = transpose($.riffs[curr],tr)
	}
	$.ph.set(p,0)
	$.leng = p.length
	if ( $.neverfit == 0 )
		$.ph.fitall()
	if ( nargs() > 1 && doredraw )
		$.redraw()
}
method mousedown (m) {
				if ( $.ph.contains(m) )
					$.bang()
				else {
					mouseforward(m,"mousedown")
				}
			}
method dump {
	arr = [
		"riffs" = arraycopy($.riffs),
		"names" = arraycopy($.b1.getvals()),
		"curr" = $.b1.get(),
		"loop" = $.loop
	]
	return(arr)
}
method restore (state) {
	names = state["names"]
	$.b1.setvals(names)
	curr = state["curr"]
	$.b1.set(curr)
	$.riffs = state["riffs"]
	$.loop = state["loop"]
	$.realset($.riffs[curr])
}
method setriffnames_listentokey (v,k) { $.riffnames_listentokey = v; $.basekey = k }
method setneverfit (v) { $.neverfit = v; }
method loadrec (space,addit) {
	p = lastbunch(Recorded,space)
	p = syncphr(p)
	if ( (p%1).time > (Met.length/2) ) {
		p.time -= Met.length
		p.length -= Met.length
	}
	if ( addit )
		$.addnew()
	$.realset(p,1)
}
method snarf { Snarf = $.ph.get() }
method loadsnarf(addit) {
	p = Snarf
	p = syncphr(p)
	if ( (p%1).time > (Met.length/2) ) {
		p.time -= Met.length
		p.length -= Met.length
	}
	if ( addit )
		$.addnew()
	$.realset(p,1)
}
method loadfile(addit) {
	ph = browsephrase()
	if ( sizeof(ph) > 0 ) {
		if ( addit )
			$.addnew()
		$.realset(ph,1)
	}
}

method transpose(v) {
	$.nexttranspose += integer(v)
}
method play(stime) {
	$.ison = 1
	curr = $.b1.get()
	qnt = $.startquant
	if ( nargs() < 1 ) {
		if ( qnt == 1 )
			stime = Now
		else
			stime = nextquant(Now,qnt)
	}
	if ( $.nexttranspose != 0 ) {
		$.ph.transpose($.nexttranspose)
		$.nexttranspose = 0
		$.ph.fitall()
		$.ph.redraw()
	}
	if ( $.riffnames_listentokey != 0 && $.currentkey != Key ) {
		$.currentkey = Key
		$.realset($.riffs[curr],1)	# This will pay attention to Key
		tr = canonic(Key)-canonic($.basekey)
		p = transpose($.riffs[curr],tr)
		$.ph.set(p,0)
		$.leng = p.length
	}
	tid = $.ph.play(stime,qnt)
	$.stoptids[tid] = 1

	$.looplng = numquant($.leng, $.loopquant)
	if ( $.looplng == 0 )
		$.looplng = $.loopquant
	tid = task $.wriffnameschk(stime+$.looplng)
	$.stoptids[tid] = 1
}

method stop {
	killtids($.stoptids)
	$.stoptids = []
	$.setoff()
}

method seton {
	if ( ! $.ison ) {
		$.play()
	}
}

method setoff {
	$.ison = 0
}

method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	dx = ($.xmax()-$.xmin()) / 4
	y0 = $.ymin()+2
	y0a = $.ymin() + $.textheight() + 4
	x0 = $.xmin() + 2
	x1 = $.xmax() - 2
	y1 = $.ymax() - 2
	$.b1.resize(xy(x0,y0,x0+1*dx-1,y0a))
	$.randbutt.resize(xy(x0+1*dx+1,y0,x0+2*dx-1,y0a))
	$.b2.resize(xy(x0+2*dx+1,y0,x0+3*dx-1,y0a))
	$.t2.resize(xy(x0+3*dx+1,y0,x1,y0a))

	$.ph.resize(xy(x0,y0a+2,x1,y1))
}
method wriffnameschk(tm) {
	sleeptill(tm-milliclicks(50))
	if ( $.ison ) {
		if ( $.loop!=0 && $.looplng>0 ) {
			$.play(tm)
		}
		else {
			$.setoff()
		}
	}
}
method randomize {
	r = rand(sizeof($.riffs))
	$.b1.set(r)
	$.b1.redraw()
	$.realset($.riffs[r],1)
}
method fillfrom(typ,dt) {
	if ( typ == 0 ) {
		f = browsefiles("MIDI files (*.mid)","*.mid",1)
		if ( ! fileexists(f) ) {
			print("File "+f+" doesn't exist")
			return()
		}
		ph = readmf(f)
	} else if ( typ == 1 ) {
		ph = Snarf
	}
	ph = onlynotes(ph)
	t1 = 0
	t2 = dt
	n = 0
	while ( ph%1.time >= dt ) {
		ph.time -= dt
	}
	$.clear()
	print("Size is now ",sizeof($.riffs))
	while ( n++ < 8096 ) {
		p = cut(ph,CUT_TIME,t1,t2)
		if ( sizeof(p) == 0 )
			break
		p.time -= t1
		p.length = dt
		$.addnew()
		$.realset(p,1)
	print("after addnew Size is now ",sizeof($.riffs))
		t1 += dt
		t2 += dt
	}
}
method monoall {
	curr = $.b1.get()
	for ( n in $.riffs ) {
		p = $.riffs[n]
		$.riffs[n] = mono(p)
	}
	p = $.riffs[curr]
	$.realset(p,1)
}
}

function mkmenu_riffnames_listentokey(o,po) {
	o.menucmd("On",po,"setriffnames_listentokey",1,'c')
	o.menucmd("Off",po,"setriffnames_listentokey",0,'c')
}

function mkmenu_riffnamesqvals(o,po,meth) {
	o.menucmd("None",po,meth,1)
	o.menucmd("1b",po,meth,1b)
	o.menucmd("2b",po,meth,2b)
	o.menucmd("4b",po,meth,4b)
	o.menucmd("8b",po,meth,8b)
}
function mkmenu_riffnames_add(o,po,addit) {
	o.menucmd("From Rec (1b space)",po,"loadrec",1b,addit)
	o.menucmd("From Rec (4b space)",po,"loadrec",4b,addit)
	o.menucmd("From Snarf",po,"loadsnarf",addit)
	o.menucmd("From File",po,"loadfile",addit)
}
function mkmenu_riffnames_fill(o,po) {
	o.menucmd("From File (2b)",po,"fillfrom",0,2b)
	o.menucmd("From File (4b)",po,"fillfrom",0,4b)
	o.menucmd("From Snarf (2b)",po,"fillfrom",1,2b)
	o.menucmd("From Snarf (4b)",po,"fillfrom",1,4b)
}
function mkmenu_riffnames_more(o,po) {
	o.submenu("Add One       ->","mkmenu_riffnames_add",po,1)
	o.submenu("Set Current   ->","mkmenu_riffnames_add",po,0)
	o.submenu("Fill From     ->","mkmenu_riffnames_fill",po)
	o.menucmd("Set Name",po,"setname")
	o.menucmd("Clear",po,"clear")
	o.submenu("Loop Quant    ->","mkmenu_riffnamesqvals",po,"setloopquant")
	o.submenu("Retrigger     ->","mkmenu_riffnames2",po)
	o.submenu("Listen to Key ->","mkmenu_riffnames_listentokey",po)
	o.submenu("Start Quant   ->","mkmenu_riffnamesqvals",po,"setstartquant")
	o.menucmd("Mono All",po,"monoall")
	o.menucmd("Snarf",po,"snarf")
	o.menucmd("Strip",po,"strip")
}

