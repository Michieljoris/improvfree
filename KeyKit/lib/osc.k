# Simple demo of OSC support - a listener
# and a sender.  Arrays represent OSC messages.
# First element of array is the message string,
# subsequent elements are the values, which
# can be integers, strings, or floats.

function osc_listen() {
	f = open("9999@127.0.0.1","rA","osc_listen")
	if ( f < 0 )
		return()
	while ( (d = get(f)) != Eof ) {
		print("OSC message:",string(d))
	}
}
function osc_send() {
	f = open("9999@127.0.0.1","wb","osc_send")
	a = [0="/bb",1="hello world",2=2222,3=3.333]
	print("Sending OSC message:",a)
	mdep("osc","send",f,a)
	close(f)
}
