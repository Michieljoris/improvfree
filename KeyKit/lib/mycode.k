


#-make big key text plus audio perhaps?
#-make green indicator for right notes played



class mycode {
       method init { Merge = 0
                Mycodeobject = $
                global Selectedkeysarray
                global Nkeys
                global Selectedchordsarray
                global Nchords
                global Ninversions
                global Selectedoctavesarray
                global Noctaves
                global Selectedintervalsarray
                global Nintervals
                global Selectedscalesarray
                global Nscales
                global Scalestoggle
                global Selectedplayordersarray
                global Nplayorders
                
                
                Keysounds = []
                for (i=0;i<12;i++) Keysounds[i] = ''
                
                Datafilesdir = "C:\\KeyKit\\settings\\"
               
             	  
             	  $.keys = [0='c',1='d-',2='d',3='e-',4='e',5='f',
														6='g-',7='g',8='a-',9='a',10='b-',11='b']
								$.keynames = [0="C",1="Db",2="D",3="Eb",4="E",5="F",
														6="Gb",7="G",8="Ab",9="A",10="Bb",11="B"]						
														
								$.chords = [
										0=["name"="major","phrase"='c,e,g'],
										1=["name"="minor","phrase"='c,e-,g'],
										2=["name"="dim","phrase"='c,e-,g-'],
										3=["name"="aug","phrase"='c,e,g+'],
										4=["name"="dom7","phrase"='c,e,g,b-'],
										5=["name"="min7","phrase"='c,e-,g,b-'],
										6=["name"="maj7","phrase"='c,e,g,b'],
										7=["name"="dim7","phrase"='c,e-,g-,a'],
										8=["name"="HalfDim","phrase"='c,e-,g-,b-']
										
								]
								
								
								$.scales = [
										0=["name"="Ionian","phrase"='c,d,e,f,g,a,b,co4'],
										1=["name"="Dorian","phrase"='c,d,e-,f,g,a,b-,co4'],
										2=["name"="Phrygian","phrase"='c,d-,e-,f,g,a-,b-,co4'],
										3=["name"="Lydian","phrase"='c,d,e,f+,g,a,b,co4'],
										4=["name"="Myxolyd","phrase"='c,d,e,f,g,a,b-,co4'],
										5=["name"="Aeolian","phrase"='c,d,e-,f,g,a-,b-,co4'],
										6=["name"="Locrian","phrase"='c,d-,e-,f,g-,a-,b-,co4'],
										7=["name"="Minor asc.","phrase"='c,d,e-,f,g,a,b,co4'],
										8=["name"="Harm. minor","phrase"='c,d,e-,f,g,a-,b,co4'],
										9=["name"="Blues","phrase"='c,e-,f,f+,g,b-,co4'],
										10=["name"="Pentatonic",	"phrase"='c,d,e,g,a,co4']									
								]
								
								$.intervals = [	0=["name"="Unison","phrase"='c,c'],
																1=["name"="Minor 2nd","phrase"='c,d-'],
																2=["name"="Major 2nd","phrase"='c,d'],
																3=["name"="Minor 3rd","phrase"='c,e-'],
																4=["name"="Major 3rd","phrase"='c,e'],
																5=["name"="Perfect 4th","phrase"='c,f'],
																6=["name"="Dim. 5th","phrase"='c,f+'],
																7=["name"="Perfect 5th","phrase"='c,g'],
																8=["name"="Minor 6th","phrase"='c,a-'],
																9=["name"="Major 6th","phrase"='c,a'],
																10=["name"="Minor 7th","phrase"='c,b-'],
																11=["name"="Major 7th","phrase"='c,b'],
																12=["name"="Perfect 8ve","phrase"='c,c']
								]
								
								$.playorders = [
							  		0="Asc.",
							  		1="Desc.",
							  		2="Harm.",
							  		3="Random"
							  ]
							  
							  $.inversions = [
							  		0="Root pos.",
							  		1="1st inv.",
							  		2="2nd inv.",
							  		3="3rd inv."
							  ]	
							  
							  $.octaves = [ 0=-3,1=-2,2=-1,3=0,4=1,5=2,6=3,7=4 ]
							  
							  $.asktypes = [ 0="chords",1="scales",2="intervals",3="riffs" ]
							  Nasktypes = 4 
							  
							  $.Selectedasktypesarray = []
                for (i=0;i<Nasktypes;i++) $.Selectedasktypesarray[i] = 1
								
								$.octave = []
								$.randomlist = []
								$.randomchord = ""
								$.randomchordn = 0
								$.randomkey = 'a'
								$.randomkeyn = 0
								$.randominversion = ""
								$.randominversionn = 0
								$.randomoctave = ""
								$.randomoctaven = 0
								$.randomscale = ""
								$.randomscalen = 0
								$.randominterval = ""
								$.randomintervaln = 0
								$.randomriff = ""
								$.randomriffn = 0
								$.randomasktype = ""
								$.radomasktypen = 0
								$.timeron = 0
								
             	  
                $.w = new window()
                $.inherit($.w)

               
                $.questionkeytext = new ktext("Eb")
                $.answerindicator = new ktoggle("")
                $.newquestionbutton = new kbutton("New question",$,"newquestion")
                $.repeatquestionbutton = new kbutton("Repeat",$,"repeatquestion")
                $.autonewquestion = new ktoggle("Auto",$,"Autonewquestion")
                $.autoon = 0
                $.timertoggle = new ktoggle("Timer 1:00",$,"Timertoggle")
                $.playspeedslider = new khslider(60,600,120,$,"Playspeed")
                $.timerlengths = []
                for (i=0;i<15;i++) $.timerlengths[i] = string(i+1) + " min."
                $.timerlength = new kvalbutton($.timerlengths,$,"Timerlength")
                #$.timerlengthslider = new khslider(1,15,5,$,"Timerlength")
                
                i=0
                $.filelist = []
                
                for (n in lsdir(Datafilesdir)) 
                	if(n!="." && n!="..") $.filelist[i++]=n
                $.load = new kvalbutton($.filelist,$,"Load")
                $.load.settext("Load") $.load.redraw()
                $.save = new kbutton("Save",$,"Save")
                #print(lsdir("C:\\KeyKit7.4d\\improvfreedata"))
                $.speedtext = new ktext("Speed")
                $.addchild($.questionkeytext)
                $.addchild($.answerindicator)
                $.addchild($.autonewquestion)
                $.addchild($.timertoggle)
                $.addchild($.playspeedslider)
                $.addchild($.timerlength)
                $.addchild($.newquestionbutton)
                $.addchild($.repeatquestionbutton)
                $.addchild($.load)
                $.addchild($.save)
                $.addchild($.speedtext)
                $.Selectedasktypesarray[0]=1
                $.timerinminutes=1
                $.playspeed = 120
                Foundanswer = 1
								Listentomidiid = 0
								Monitorresponseid = 0
								Playkeysounds = 1
        }
        method redraw {
                $.w.redraw()
                methodbroadcast()
        }
        method resize (sz) {
                if ( nargs() > 0 )
                        $.w.resize(sz)
         	
         	$.y0 = $.ymin()+2
          $.y1 = $.ymax() - 2
          tx=$.textwidth()
          ty=$.textheight()
          dy = ($.y1-$.y0)/2
        	$.ym1 = $.ymin() + dy + 4
        	$.ym2 = $.ymin() + 2*dy + 8
        	$.ym3 = $.ymin() + 3*dy + 12
        	
        	
        	$.x0 = $.xmin() + 2
        	$.x1 = $.xmax() - 2
        	
        	totalchar=(7+6+12+10+6+5+5)*tx
        	$.xm0 = $.x0+ 5*tx
        	$.xm0a = $.xm0+ 5*tx
					$.xm1 = $.xm0a+($.x1-$.x0-totalchar)
        	$.xm2 = $.xm1 + 7*tx #repeat
        	$.xm3 = $.xm2 + 6*tx #auto
        	$.xm4 = $.xm3 + 12*tx #speedtext
					$.xm5 = $.xm4 + 10*tx 			#playspeed
					$.xm6 = $.xm5 + 6*tx #load
					#$.xm7 = $.xm6 + 10*tx #save
					#$.xm8 = $.xm7 + 6*tx #load
					#$.xm9 = $.xm8 + 6*tx #save
					#print("xm1",$.xm1,"xm1+totalchar",$.xm1+totalchar,"x1-x0",$.x1-$.x0,"totalchar",totalchar,"tx",tx,"xm9",$.xm9)
					#print("x0",$.x0,"x1",$.x1)
					$.questionkeytext.resize(xy($.x0,$.y0,$.xm0,$.y1))
					$.answerindicator.resize(xy($.xm0,$.y0,$.xm0a,$.y1))
        	$.newquestionbutton.resize(xy($.xm0a,$.y0,$.xm1,$.y1))
        	$.repeatquestionbutton.resize(xy($.xm1,$.y0,$.xm2,$.y1))
        	$.autonewquestion.resize(xy($.xm2,$.y0,$.xm3-4,$.y1))
        	$.speedtext.resize(xy($.xm3,$.ym1,$.xm4-2,$.y1))
        	$.playspeedslider.resize(xy($.xm4,$.ym1,$.xm5,$.y1))
        	$.timertoggle.resize(xy($.xm3,$.y0,$.xm4-2,$.ym1))
        	$.timerlength.resize(xy($.xm4,$.y0,$.xm5,$.ym1))
        	$.load.resize(xy($.xm5,$.y0,$.xm6,$.ym1))
        	$.save.resize(xy($.xm5,$.ym1,$.xm6,$.y1))
        	
        	
        }
        
        
        method Askchords { $.Setasktoggles(0,$.askchords) }
        method Askscales {	$.Setasktoggles(1,$.askscales) }
        method Askintervals {$.Setasktoggles(2,$.askintervals)	}
        method Askriffs { $.Setasktoggles(3,$.askriffs)	}
        method Setasktoggles (n,obj) {
					if (0)  { #Selectedplayordersarray[Currentlyselectingn][n]) {
						anyotheron=0
						for (i=0;i<Nplayorders;i++) 
							if (Selectedplayordersarray[Currentlyselectingn][i]) 	anyotheron=anyotheron+1 
						if (anyotheron>1) 	Selectedplayordersarray[Currentlyselectingn][n]= 0
						else { obj.set(1) obj.redraw() }
					}
					else		$.Selectedasktypesarray[n]= 1 - $.Selectedasktypesarray[n]
					
				}

      method newquestion  {
      			print("****************************************")
      			#colormix(0,65535,0,0)
      	    #$.questionkeytext.set("Hello")   $.questionkeytext.redraw()
      	    #colormix(0,65535,65535,65535)
      		#if (Foundanswer == 0) 
      		#if ($.autoon) sleeptill(Now+1b)
      		 #kill($.listentomidiid) kill($.monitorresponseid) 
        	#key*******************************
       		j=0
        	for (i=0;i<Nkeys;i++) $.randomlist[i]=0
        	for (i=0;i<Nkeys;i++) 
        		if (Selectedkeysarray[i]) {
        					$.randomlist[j]=i
        					j=j+1
        		}
        	if (j>0) {
		        	$.randomkeyn = $.randomlist[rand(j)]
		        	$.randomkey = $.keys[$.randomkeyn]
		        	$.randomkeyprint = $.keynames[$.randomkeyn]
		       		#print($.randomkey) 
		      }
       		else { print("No keys selected") return() }
       		#octave************************************
       		j=0
        	for (i=0;i<Noctaves;i++) $.randomlist[i]=0
        	for (i=0;i<Noctaves;i++) 
        		if (Selectedoctavesarray[i]) {
        					$.randomlist[j]=i
        					j=j+1
        		}
        	if (j>0) {
		        	$.randomoctaven = $.randomlist[rand(j)]
		        	$.randomoctave = $.octaves[$.randomoctaven]
		       		#print($.randomoctave) 
       		}
       		else { print("No octaves selected") return() }
        	
       		
       		for (i=0;i<Nasktypes;i++)  $.Selectedasktypesarray[i]=1
       		#Riffs*************************************
       		j=0
       		for (i=0;i<Maxriffspergroup*Maxgroups;i++) $.randomlist[i]=0
       		 for(g=0;g<Maxgroups;g++) 
       		 	if (Selectedgroupsarray[g]["selected"])
       		 		for (r=0;r<Selectedgroupsarray[g]["nriffs"];r++) 
       		 			if(Selectedriffsarray[g][r]["selected"]) {
       		 				$.randomlist[j]=Selectedriffsarray[g][r]
       						#print($.randomlist[j]["riffname"])
       						j+=1
       						}	
       		if (j>0)	{
       			$.randomriffn = rand(j)
       			$.randomriff = $.randomlist[$.randomriffn]
       		}
       		else $.Selectedasktypesarray[3]=0
       		
       		
       		
					
    					
        	#chord*********************************
        	j=0
        	for (i=0;i<Nchords;i++) $.randomlist[i]=0
        	for (i=0;i<Nchords;i++) 
        		if (Selectedchordsarray[i][0]) {
        					$.randomlist[j]=i
        					j=j+1
        		}
        	if (j>0) {
		        	$.randomchordn = $.randomlist[rand(j)]
		        	
		       		#print($.randomchord) 
		       		#inversion
		       		j=0
		        	for (i=0;i<Ninversions;i++) $.randomlist[i]=0
		        	for (i=0;i<Ninversions;i++)  
		        		if (Selectedchordsarray[$.randomchordn][i+1]) {
		        				$.randomlist[j]=i
		        					j=j+1
		        		}
		        	if (j>0) {
				        	$.randominversionn = $.randomlist[rand(j)]
				        	$.randominversion = $.inversions[$.randominversionn]
				       		#print($.randominversion) 
				       }
				       else print("No inversion selected????? should never happen!!") 
       		}
       		else { $.Selectedasktypesarray[0]=0   }
		      
 					#scale****************************************************
       		j=0
        	for (i=0;i<Nscales;i++) $.randomlist[i]=0
        	for (i=0;i<Nscales;i++)            
        		if (Selectedscalesarray[i]) {
        					$.randomlist[j]=i
        					j=j+1
        		}
        	if (j>0) {
        			$.randomscalen = $.randomlist[rand(j)]
        			$.randomscale = $.scales[$.randomscalen]["phrase"] 
        	}
       		else { $.Selectedasktypesarray[1]=0  }
				  
       		#intervals
       		j=0
        	for (i=0;i<Nintervals;i++) $.randomlist[i]=0
        	for (i=0;i<Nintervals;i++) 
        		if (Selectedintervalsarray[i]) {
        					$.randomlist[j]=i
        					j=j+1
        		}
        	if (j>0) {
		        	$.randomintervaln = $.randomlist[rand(j)]
		        	$.randominterval = $.intervals[$.randomintervaln]["name"]
	        }
	       	else { $.Selectedasktypesarray[2]=0  }
				    
     			#playorder*********************************
       		
       		for (i=0;i<Nplayorders;i++) #$.randomlist[i]=0
       		for (asktype=0;asktype<Nasktypes-1;asktype++) #riffs never have playorders on that's why -1
		     	{   	j=0
		      			for (i=0;i<Nplayorders;i++) 
		        		if (Selectedplayordersarray[asktype][i]) {
		        					#$.randomlist[j]=i
		        					j=j+1
		        		}
			        	if (j>0) {
			        			#print("Asktype",asktype,"j",j)
					        	#$.randomplayordern = $.randomlist[rand(j)]
					        	#$.randomplayorder = $.playorders[$.randomplayordern] 
					        	}
					      else	
					      { 			$.Selectedasktypesarray[asktype]=0 
					      	#print("Asktype",asktype,"j",j)
			     							
			     			}
		     	}
       		#print ($.Selectedasktypesarray)
       			
					#asktype*******************************************************************
       		j=0
       		for (i=0;i<Nasktypes;i++) $.randomlist[i]=0
       		for (i=0;i<Nasktypes;i++) 
       			if ($.Selectedasktypesarray[i]) {
        					$.randomlist[j]=i
        					j=j+1
        		}
        	if (j>0) {
		        	$.randomasktypen = $.randomlist[rand(j)]
		        	$.randomasktype = $.asktypes[$.randomasktypen] 
        			#print($.randomasktype)       		
		      }
       		else   $.randomasktype="Not possible" 
       						
       		if ($.randomasktype=="Not possible") { 
       			print("No possible question selected !!") 
       			return() 
       		}
       		print("randomasktype=",$.randomasktype)
       		if($.randomasktype!="Riffs") {
			       		#playorder*********************************
			       		j=0
			       		for (i=0;i<Nplayorders;i++) $.randomlist[i]=0
			       		   	for (i=0;i<Nplayorders;i++) 
					        		if (Selectedplayordersarray[$.randomasktypen][i]) {
					        					$.randomlist[j]=i
					        					j=j+1
					        		}
					        	if (j>0) {
					        			
							        	$.randomplayordern = $.randomlist[rand(j)]
							        	$.randomplayorder = $.playorders[$.randomplayordern] }
							      else	
							      { 	print("No playorder or riff selected. Should not happen!!! Should have jumped out before error!!!") 
					     							
					     			}
					 }
       			
       			
       			
       			
       			
       		$.askquestion() 
       		keysound = (transpose(Keysounds[$.randomkeyn],$.randomoctave*12))
       		#print(keysound,Keysounds[$.randomkeyn],$.randomkey)
       		#l=0
       		#for (n in keysound) l=l+n.dur
       		keysound.length=keysound%sizeof(keysound).time+keysound%sizeof(keysound).dur + 50
       		if (Playkeysounds) realtime(keysound+'rd40'+$.questionphrase)
       		else realtime($.questionphrase)
       		#print("plus keysound",transpose(Keysounds[$.randomkeyn],$.randomoctave*12)+$.questionphrase)
       		#print(keysound,Keysounds)
       		#print("going to listentomidi")
       		Foundanswerfifo = open()
       		Listentomidiid = task listentomidi($.questionphrase)
       		
       		#sleeptill(Now+1b)
       		Monitorresponseid = task monitorresponse()
       		
          #$.redraw()
			}
			
			method repeatquestion { 
				$.askquestion() 
				keysound = (transpose(Keysounds[$.randomkeyn],$.randomoctave*12))
       		#print(keysound,Keysounds[$.randomkeyn],$.randomkey)
       		#l=0
       		#for (n in keysound) l=l+n.dur
       		keysound.length=keysound%sizeof(keysound).time+keysound%sizeof(keysound).dur + 50
       		if (Playkeysounds) realtime(keysound+'rd130'+$.questionphrase)
       		else realtime($.questionphrase)
			}
			
			method askquestion {
				
				finishoff()
				#realtime(gmresetall())
				#print($.playspeed)
				print("Key = ",$.randomkey,$.randomoctave)
				
				$.questionkeytext.set($.randomkeyprint) $.questionkeytext.redraw()
				if ($.randomasktype=="chords") { 
       			print($.randomplayorder,$.chords[$.randomchordn]["name"],$.randominversion)
       			$.questionphrase = transpose ($.chords[$.randomchordn]["phrase"],canonic($.randomkey)+$.randomoctave*12)
       			#print(sizeof($.questionphrase))
       			if (sizeof($.questionphrase)==3) {
       				if ($.randominversionn==1)
       				$.questionphrase = 	makenote($.questionphrase%2.pitch - 12,$.questionphrase%2.dur)+
       														makenote($.questionphrase%3.pitch - 12,$.questionphrase%3.dur)+
       														makenote($.questionphrase%1.pitch,$.questionphrase%1.dur)
       				else 	if ($.randominversionn==2)
       							$.questionphrase = 	makenote($.questionphrase%3.pitch - 12,$.questionphrase%3.dur)+
       														makenote($.questionphrase%1.pitch,$.questionphrase%1.dur)+
       														makenote($.questionphrase%2.pitch,$.questionphrase%2.dur)
       				
       				#print("inversions.. ",$.questionphrase)
       		}
       		if (sizeof($.questionphrase)==4) {
       				if ($.randominversionn==1)
       				$.questionphrase = 	makenote($.questionphrase%2.pitch - 12,$.questionphrase%2.dur)+
       														makenote($.questionphrase%3.pitch - 12,$.questionphrase%3.dur)+
       														makenote($.questionphrase%4.pitch - 12,$.questionphrase%4.dur)+
       														makenote($.questionphrase%1.pitch,$.questionphrase%1.dur)
       				else 	if ($.randominversionn==2)
       							$.questionphrase = 	makenote($.questionphrase%3.pitch - 12,$.questionphrase%3.dur)+
       														makenote($.questionphrase%4.pitch - 12,$.questionphrase%4.dur)+
       														makenote($.questionphrase%1.pitch,$.questionphrase%1.dur)+
       														makenote($.questionphrase%2.pitch,$.questionphrase%2.dur)
       							else if ($.randominversionn==3)
       							$.questionphrase = 	makenote($.questionphrase%4.pitch - 12,$.questionphrase%4.dur)+
       														makenote($.questionphrase%1.pitch,$.questionphrase%1.dur)+
       														makenote($.questionphrase%2.pitch,$.questionphrase%2.dur)+
       														makenote($.questionphrase%3.pitch,$.questionphrase%3.dur)
       							
       				
       				#print("inversions.. ",$.questionphrase)
       		}
       			if ($.randomplayorder=="Desc.") $.questionphrase=reverse($.questionphrase)
       			else 	if ($.randomplayorder=="Random") $.questionphrase=tonerow($.questionphrase)
       						else 	if ($.randomplayorder=="Harm.") { 
		       									ph = ''
		       									for (n in $.questionphrase) { n.time=0  ph=ph|n  }
		       									ph.dur=3b $.questionphrase=ph 
		       							}
       		
       			bpm($.playspeed)
       			# realtime($.questionphrase) 
       			print("questionphrase =",$.questionphrase)
       			
       			return()
     		}
     		if ($.randomasktype=="scales") {
     			bpm($.playspeed)
     			$.questionphrase = transpose($.scales[$.randomscalen]["phrase"],canonic($.randomkey)+$.randomoctave*12)
     			if ($.randomplayorder=="Desc.") $.questionphrase = reverse($.questionphrase)
     			else 	if ($.randomplayorder=="Random") $.questionphrase = tonerow($.questionphrase)
     			# realtime($.questionphrase)
     			print($.randomplayorder," ",$.scales[$.randomscalen]["name"])
     			return()
     		}
     		if ($.randomasktype=="intervals") {
     		
     			bpm($.playspeed)
     			$.questionphrase = $.intervals[$.randomintervaln]["phrase"]
     			
     			if ($.randomplayorder=="Desc.") $.questionphrase = flip($.questionphrase,'c')
     			else 	if ($.randomplayorder=="Harm.") { 
		       									ph = ''
		       									for (n in $.questionphrase) { n.time=0  ph=ph|n  }
		       									ph.dur=3b $.questionphrase=ph 
		       							}
		      $.questionphrase = transpose($.questionphrase,canonic($.randomkey)+$.randomoctave*12)
     			# realtime($.questionphrase)
     			print($.intervals[$.randomintervaln]["name"])
     			return()
     		}
     		if ($.randomasktype=="riffs") { 
     			print("Riff: ",$.randomriff["riffname"])
     			$.questionphrase=transpose ($.randomriff["phrase"],canonic($.randomkey)-canonic(makenote($.randomriff["phrase"]%1.pitch))+$.randomoctave*12)
     			
     			bpm($.playspeed)
     			# realtime($.questionphrase) 
     			return()
     		}
		}
		
	method savedata(datafile) {
			f = open(datafile,"w")
			for (i=0;i<12;i=i+1) { put(f,Selectedkeysarray[i]) put(f,"\n") }
      for (i=0;i<7;i=i+1) { put(f,Selectedoctavesarray[i]) put(f,"\n") }            
   		for (i=0;i<Nchords;i++) 
      	   	for (j=0;j<Ninversions+1;j++) {
      	   		put(f,Selectedchordsarray[i][j]) put(f,"\n")
      	   	}
     	put(f,Scalestoggle) put(f,"\n")
     	put(f,Selectedchord) put(f,"\n")
     	put(f,Lockedchords) put(f,"\n")
      for (i=0;i<Nscales;i++) { put(f,Selectedscalesarray[i]) put(f,"\n") }
     	for (i=0;i<Nintervals;i++) { put(f,Selectedintervalsarray[i]) put(f,"\n") }
      for (i=0;i<Nasktypes;i++) 
      	for (j=0;j<Nplayorders;j++) 
      		{ put(f,Selectedplayordersarray[i][j]) put(f,"\n") }
      
      for (i=0;i<Maxgroups;i++) { 
      	put(f,Selectedgroupsarray[i]["groupname"]) put(f,"\n") 
      	put(f,Selectedgroupsarray[i]["nriffs"]) put(f,"\n") 
      	put(f,Selectedgroupsarray[i]["selected"]) put(f,"\n") 
      	}
			for (i=0;i<Maxgroups;i++) 
				for (j=0;j<Maxriffspergroup;j++) { 
					put(f,Selectedriffsarray[i][j]["riffname"]) put(f,"\n") 
					put(f,Selectedriffsarray[i][j]["selected"]) put(f,"\n") 
					put(f,string(Selectedriffsarray[i][j]["phrase"])) put(f,"\n") 
				}
			put(f,Currentgroupshowing) put(f,"\n")
			put(f,Currentpageshowing) put(f,"\n")
			put(f,Currentlyselectingn) put(f,"\n")
			#print($.autoon)
			put(f,$.autoon) put(f,"\n")
			for (i=0;i<Nkeys;i++) { 
    put(f,Keysounds[i]) put(f,"\n") }
			close(f)

	}
	
	method loaddata(datafile) {
			f = open(datafile)
			#print(f)
			if (f==-1) { print("Datafile",datafile,"doesn't exist!!") return() }
			
			for (i=0;i<12;i=i+1) { Selectedkeysarray[i]=get(f)  }
			#print("Hallo",Selectedkeysarray)
      for (i=0;i<7;i=i+1) { Selectedoctavesarray[i]= get(f)  }            
   		for (i=0;i<Nchords;i++) 
      	   	for (j=0;j<Ninversions+1;j++) {
      	   		Selectedchordsarray[i][j]=get(f) 
      	   	}
     	Scalestoggle=get(f) 
     	Selectedchord=get(f) #print(Selectedchord) 
     	Selectedchord = integer(Selectedchord)
     	Lockedchords=get(f)
      for (i=0;i<Nscales;i++) { Selectedscalesarray[i]=get(f)  }
     	for (i=0;i<Nintervals;i++) { Selectedintervalsarray[i]=get(f)  }
      for (i=0;i<Nasktypes;i++) 
      	for (j=0;j<Nplayorders;j++) 
      			{ Selectedplayordersarray[i][j]=get(f)  }
      
      for (i=0;i<Maxgroups;i++) { 
      	Selectedgroupsarray[i]["groupname"]=get(f)  
      	Selectedgroupsarray[i]["nriffs"]=integer(get(f))
      	Selectedgroupsarray[i]["selected"]=get(f)  
      	}
      	#print(Selectedgroupsarray)
			for (i=0;i<Maxgroups;i++) 
				for (j=0;j<Maxriffspergroup;j++) { 
					Selectedriffsarray[i][j]["riffname"]=get(f)  
					Selectedriffsarray[i][j]["selected"]=get(f)  
					Selectedriffsarray[i][j]["phrase"]=phrase(get(f))
					#print(Selectedriffsarray[i][j]["phrase"])
				}
			Currentgroupshowing=integer(get(f)) 
			Currentpageshowing=integer(get(f)) 
			currentlyselectingntemp=integer(get(f))
			$.autoon=integer(get(f))
			for (i=0;i<Nkeys;i++)    Keysounds[i]=phrase(get(f)) 
			
			close(f)
			#print("playorder =",Currentlyselectingn,$.asktypes[Currentlyselectingn])
			#print("load data playorder =",$.asktypes[Currentlyselectingn])
			Chordselectionobject.chordsetstate()
			#print("load data playorder =",$.asktypes[Currentlyselectingn])
			Keyselectionobject.keysetstate()
			#print("load data playorder =",$.asktypes[Currentlyselectingn])
			Riffselectionobject.riffsetstate()
			#print("load data playorder =",$.asktypes[Currentlyselectingn])
			Currentlyselectingn=currentlyselectingntemp
			Chordselectionobject.adjustplayordertoggles($.asktypes[Currentlyselectingn])
			$.autonewquestion.set($.autoon) $.autonewquestion.redraw()
			if ($.autoon) $.newquestion()
			
	}
	
	
	method Playspeed (val) {
		$.playspeed = val
	}
	method Timerlength (val) {
		$.timerinminutes= val+1
		#print(val)
		$.timeron = 0
		#kill(timerid)
		#$.timertoggle.set(0) $.timertoggle.redraw()
		$.timertoggle.settext("Timer "+string(val+1)+":00")
		$.timertoggle.redraw()
	}
	
	method Timertoggle {
		#kill(timerid)
		$.timeron = 1 - $.timeron
		if ($.timeron) #kill(timerid) else 
			timerid = task Runtimer($.timerinminutes)
		
	}	
	
	
	method Save {
	$.s = getastr("Type in name for current settings to save(or <CR> to abort) -> ","")
					if ( $.s != "")
						$.savedata(Datafilesdir+$.s+".data")
	print("Current data saved as",$.s+".data")
	i=0
	filelistlocal=[]
	for (n in lsdir(Datafilesdir)) 
 	               	if(n!="." && n!="..") filelistlocal[i++]=n
  $.filelist=filelistlocal
  $.load.setvals($.filelist) 
  $.load.redraw()
	}
	
	method Load(n) {
		$.loaddata(Datafilesdir+$.filelist[n])
		$.load.settext("Load") $.load.redraw()
	}
	
	method Autonewquestion {
		$.autoon = 1-$.autoon
	}
	
	
}

function Runtimer(l) {
			len=l
			#print(l)
			Mycodeobject.timertoggle.settext("Timer "+ string(len)+":00")
			Mycodeobject.timertoggle.redraw()
			
		for (m=l-1;m>=0;m--) {
			if (m>9) mstr=string(m)
			else mstr=" "+string(m)
			for (s=59;s>=0;s--) {
					sleeptill(Now+2b)
					if (Mycodeobject==$-1) return()
					if (s>9) sstr="Timer "+ mstr +":"+string(s)
					else sstr="Timer "+ mstr +":"+"0"+string(s)
					Mycodeobject.timertoggle.settext(sstr)
					Mycodeobject.timertoggle.redraw()
			
			if (!Mycodeobject.timeron) { $.timertoggle.set(0) $.timertoggle.redraw() return() }
			}
		}
		realtime('bo6d16v65,co7d15v61,bo6d15v65t30,l16')
		$.timertoggle.set(0) $.timertoggle.redraw()
		Mycodeobject.timeron=0
}

function listentomidi(qp) {
	Foundanswer = 0
	Midiin[$] = Mymidififo = open()
	onexit(closemidi,$)
	lookingfornote=0
	nnotes = 0
	notepitches = []
	foundpitch=-1
	harmqphrase=''
	
	#print("qp = ",qp)
	for (note in qp) {	
		notepitches[nnotes++]=note.pitch
		harmqphrase = harmqphrase|makenote(note.pitch)
	} 
	#print("harmqphrase",harmqphrase)
					
	while ( 1 ) {
			# Get a MIDI message
			m = get(Mymidififo)
				realtime(phrase(m),0)
			if (m=="Stop") {  put(Foundanswerfifo,"Stop") return() }
			#print("m=",m)
			if ( m.type == NOTEON) {
			 #print(m.pitch) #print(m.velocity)
				if ((Mycodeobject.randomasktype=="chords" || Mycodeobject.randomasktype=="intervals" ) 
						&& Mycodeobject.randomplayorder=="Harm.") {
				current =  Current
				harmphrase=''
				for (note in current) harmphrase=harmphrase|makenote(note.pitch)
				if (harmphrase == harmqphrase)  {
					Foundanswer = 1 foundpitch=m.pitch
					#print("Yes harmonic the same") 
					}
					#print(harmphrase , harmqphrase)
				}
				if (m.pitch == notepitches[lookingfornote]) {
					lookingfornote++
					#print("Put") put(f,"Ok")
					put(Foundanswerfifo,"Yes")
					if (lookingfornote == nnotes) { 
						
						Foundanswer = 1
						foundpitch=m.pitch
						#if (Mycodeobject.autoon) {  sleeptill(Now+2b) Mycodeobject.newquestion() }
						#return() 
					}
				}
				else {
					put(Foundanswerfifo,"No")
					#print("No..")
					lookingfornote=0
				}
			}
				if ( m.type == NOTEOFF && foundpitch == m.pitch && Foundanswer) 
					{ foundpitch = -1 Foundanswer=0 put(Foundanswerfifo,"Finished") return() } 
			
			if (Mycodeobject==$-1) return()
			
	}
}

function monitorresponse {
		
		while (1) {
			str=""
			str=get(Foundanswerfifo)
			#print(str)
			if (str=="Stop") {  return() }
			if (str=="Yes") { Mycodeobject.answerindicator.set(1) Mycodeobject.answerindicator.redraw() }
			if (str=="No") { Mycodeobject.answerindicator.set(0) Mycodeobject.answerindicator.redraw() }
			if(str=="Finished") {  Mycodeobject.answerindicator.set(0) Mycodeobject.answerindicator.redraw() 
														print("Good answer!!")
														sleeptill(Now+2b)  
														if (Mycodeobject.autoon) Mycodeobject.newquestion() 
														
														return() }
		}
}

