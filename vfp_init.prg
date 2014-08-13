*-- Programa de inicialización de VFP 9.0
*-- FDB: 07/01/2005
LOCAL lcCurDir, lcLastDir

*-- Cargo macros de trabajo
lcCurDir = JUSTPATH(SYS(16))
lcLastDir = JUSTEXT(CHRTRAN(lcCurDir, '\', '.'))
CD (lcCurDir)

MOVE WINDOW COMMAND TO 25,50
SIZE WINDOW COMMAND TO 25,100
*WAIT WINDOW NOWAIT "VFP Inicializado en directorio '" + lcCurDir + "'"

*-- Configuro el entorno
_SCREEN.CAPTION = lcLastDir + ':' + LEFT(SYS(5),1)

*SET RESOURCE TO (HOME(7)+"FOXUSER.DBF")

*-- Configura la memoria de VFP
? "Primer plano: "
?? SYS(3050,1,20971520)
? "Segundo plano: "
?? SYS(3050,2,10485760)
? "Directorio: " + SYS(5) + CURDIR()
? REPLICATE("-", 80)
