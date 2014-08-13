*-- MAIN_PRUEBAS.PRG / Fernando D. Bozzo - 13/08/2014
LOCAL lcSys16

lcSys16	= SYS(16)
CD (JUSTPATH(lcSys16))
SET PATH TO clases, forms, menus, prgs, foxunit
*-- Carga principal del sistema

DO MENU_PRINCIPAL.MPR


RETURN
