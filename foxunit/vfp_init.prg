*-- Programa de inicialización de VFP 9.0
*-- Defino una nueva opción para la búsqueda de archivos con FILER
*-- FDB: 07/01/2005
*-- FDBOZZO: 02/04/2007 - MODIFICADO PARA QUE NO DE ERROR SI FOXUSER ESTA EN USO Y USE OTRO.
DEFINE BAR 20 OF _MSM_TOOLS PROMPT "\-" AFTER _MLAST
DEFINE BAR 21 OF _MSM_TOOLS PROMPT "Buscar archivos..." AFTER _MLAST MESSAGE "Ejecuta la herramienta de búsqueda FILER"
ON SELECTION BAR 21 OF _MSM_TOOLS DO FORM (HOME()+'tools\filer\filer')
LOCAL lcCurDir, llErrorFoxUser, llErrorFoxUserHome, lcLastDir ;
	, lcCurDir, lcFoxUser, lcUsuario, I, lcFoxUserOrig
*-- Cargo macros de trabajo
lcCurDir = JUSTPATH(SYS(16))
lcLastDir = JUSTEXT(CHRTRAN(lcCurDir, '\', '.'))
CD (lcCurDir)

MOVE WINDOW COMMAND TO 25,50
SIZE WINDOW COMMAND TO 25,100
*WAIT WINDOW NOWAIT "VFP Inicializado en directorio '" + lcCurDir + "'"

*-- Configuro el entorno
_SCREEN.CAPTION = lcLastDir + ':' + LEFT(SYS(5),1) + IIF(EMPTY(I), '', ' (' + STR(I,1) + ')')

*SET RESOURCE TO (HOME(7)+"FOXUSER.DBF")

*-- Configura la memoria de VFP
? "Primer plano: "
?? SYS(3050,1,20971520)
? "Segundo plano: "
?? SYS(3050,2,10485760)
? "Directorio: " + SYS(5) + CURDIR()
? REPLICATE("-", 80)

do c:\vfpx\thor.app
