class test {
    method init {	
    	$.w = new window()
  		$.inherit($.w)
  		$.chordswindow= new keyselection()
  		$.addchild($.chordswindow)
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
		dy = ($.y1-$.y0)/3               
  	$.ym1 = $.ymin() + dy + 4
    
                             
                             
    $.x0 = $.xmin() + 2      
    $.x1 = $.xmax() - 2   
    $.chordswindow.resize(xy($.x0,$.y0,$.x1,$.y1))   
  }
}  
    