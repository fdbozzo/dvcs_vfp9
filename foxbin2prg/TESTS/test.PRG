Set DEFAULT TO (SUBSTR(SYS(16,1),AT(":",SYS(16,1)) - 1, RAT("\", SYS(16,1)) - (AT(":",SYS(16,1)) - 1)))
clear dlls

*--
*-- for this test file can be correctly runs, at the first, let's make a test bmp c:\screen.bmp :-)
*--
********************************************************************************
*-- capture window or screen image into a bitmap file
Declare Integer formtobmp       IN "PCT_DLL.dll" integer hwnd,String bmpFileName
retVal = formtobmp(0,"c:\screen.bmp")  && Save screen to file c:\screen.bmp
if retval = 0
   messagebox("Capture screen ok!")
endif
********************************************************************************

********************************************************************************
*-- also a capture window or screen image into a bitmap file,you must specify the screen coordinates for capture
Declare Integer formtobmpA  IN "PCT_DLL.dll" string bmpfilename,integer nX,integer nY,integer nX2,integer nY2
retVal = formtobmpA("c:\screen0.bmp",20,20,400,400)  && Save screen to file c:\screen.bmp
                                                     && from 20,20 to 400,400
if retval = 0
   messagebox("Capture screen ok!")
endif
********************************************************************************

********************************************************************************
*-- Convert a bmp file to jpg file
Declare Integer tojpeg          IN "PCT_DLL.dll" String bmpfilename, String jpgfilename
retval = tojpeg("c:\screen.bmp","c:\screen.jpg")
if retval = 0
   messagebox("Convert bitmap to jpeg ok!")
endif
********************************************************************************

********************************************************************************
*-- Convert a jpg file to bmp file
Declare Integer tobmp           IN "PCT_DLL.dll" String jpgfilename, String bmpfilename
retval = tobmp("c:\screen.jpg","c:\screen2.bmp")
if retval = 0
   messagebox("Convert jpeg to bitmap success!")
endif
********************************************************************************

********************************************************************************
*-- Retrieves the width and height of a bmpfile
Declare Integer getbmpdimension IN "PCT_DLL.dll" string bmpfilename, integer @ nwidth,integer @ nheight
nwidth=0
nheight=0
retval = getbmpdimension("c:\screen.bmp",@ nwidth, @ nheight)
if retval = 0
   messagebox("Width:"+str(nwidth)+chr(13)+"Height:"+str(nheight))
endif
********************************************************************************

********************************************************************************
*-- Retrieves the width and height of a jpg file
Declare Integer getjpgdimension IN "PCT_DLL.dll" string jpgfilename, integer @ nwidth,integer @ nheight
nwidth=0
nheight=0
retval = getjpgdimension("c:\screen.jpg",@ nwidth, @ nheight)
if retval = 0
   messagebox("Width:"+str(nwidth)+chr(13)+"Height:"+str(nheight))
endif
********************************************************************************
clear dlls