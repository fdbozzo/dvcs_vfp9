#DEFINE CRLF CHR(13) + CHR(10)

LPARAMETERS cBuildName, cProjectName

TRY && something dangerous

	cPjmFile = FORCEEXT( cProjectName, "pjm" )

	ox = CREATEOBJECT( "PjmFile" )

	ox.BuildName = cBuildName
	ox.PjmFile = cPjmFile
	ox.BUILD()

CATCH TO cErr && something nasty

   \Error Updating Project List
   \Error No: << cErr.ErrorNo >>
   \Line Contents: << cErr.LineContents >>
   \Line No: << cErr.LineNo >>
   \Message: << cErr.Message >>
   \Name: << cErr.Name >>
   \Procedure: << cErr.Procedure >>
   \Stack Level: << cErr.StackLevel >>

FINALLY

	* Consolidate Error Logs
	IF NOT EMPTY( ox.ErrorLog )

		IF FILE( ox.ErrFile )
			ox.ErrorLog = ;
				ox.ErrorLog + CRLF + CRLF + ;
				"---------------" + CRLF + ;
				FILETOSTR( ox.ErrFile )
		ENDIF


		ERASE ( ox.ErrFile )
		STRTOFILE( ox.ErrorLog, ox.ErrFile )

	ENDIF


ENDTRY


* If in a build exit
IF NOT EMPTY( cBuildName )
	QUIT
ENDIF


DEFINE CLASS PjmFile AS SESSION

	* Core properties
	ErrorLog = ""
	BuildName = ""
	PjxFile = ""
	PjmFile = ""
	PjmFileName = ""
	PjmPath = ""
	ErrFile = ""
	CurrentDefault = SYS(5) + SYS(2003)
	DIMENSION ProjectFiles[1]

	* Pjx Properties
	VERSION=  1.20
	Author=""
	Company=""
	Address=""
	City=""
	State=""
	Zip=""
	Country=""
	SaveCode=.T.
	DEBUG=.T.
	ENCRYPT=.F.
	NoLogo=.F.
	CommentStyle=1
	Comments="Project created by " + ;
		PROPER( PROGRAM() )
	CompanyName=""
	FileDescription=""
	LegalCopyright= "© 1999-" + ;
		STR(YEAR(DATE()),4) + " FooBar Inc."
	LegalTrademarks="® FooBar is a registered" +;
		" trademark of FooBar Inc."
	ProductName="FooBar"
	Major=""
	Minor=""
	Revision=""
	AUTOINCREMENT=.F.


	* Coerce CommentStyle to a numeric
	PROCEDURE CommentStyle_assign(pCommentStyle)

		DO CASE
		CASE VARTYPE( pCommentStyle ) = "N"
			THIS.CommentStyle = pCommentStyle
		CASE VARTYPE( pCommentStyle ) = "C"
			THIS.CommentStyle = VAL( pCommentStyle )
		ENDCASE


	ENDPROC


	* Reload the project object
	* when assigned a new PJM
	PROCEDURE PjmFile_assign( pcPjmFile )

		IF FILE( pcPjmFile )

			THIS.PjmFile = pcPjmFile
			THIS.PjmFileName = JUSTFNAME( pcPjmFile )
			THIS.PjmPath = JUSTPATH( pcPjmFile )

			THIS.ErrFile = ADDBS( THIS.PjmPath ) + ;
				FORCEEXT( THIS.PjmFileName, "err" )
			ERASE ( THIS.ErrFile )


			THIS.ParsePjm()

			* Start the error log
			SET TEXTMERGE TO MEMVAR ;
				THIS.ErrorLog NOSHOW ADDITIVE
			SET TEXTMERGE ON

		ENDIF


	ENDPROC


	PROCEDURE BUILD

		THIS.CreatePjx()
		THIS.TweakPjx()

		SET TEXTMERGE TO

		IF EMPTY( THIS.ErrorLog )

			lcPJX = ADDBS( THIS.PjmPath ) + ;
				FORCEEXT( THIS.PjmFileName, "pjx" )
			lcEXE = ADDBS( THIS.PjmPath ) + ;
				FORCEEXT( THIS.PjmFileName, "exe" )

			BUILD EXE ( lcEXE ) ;
				FROM ( lcPJX ) recompile

		ENDIF


	ENDPROC


	* Update the project with data from the PJM
	PROCEDURE TweakPjx

		USE ( THIS.PjxFile ) ALIAS PJX

		* Update project properties
		LOCATE FOR TYPE = "H"
		REPLACE ;
			SaveCode WITH THIS.SaveCode, ;
			DEBUG WITH THIS.DEBUG, ;
			ENCRYPT WITH THIS.ENCRYPT, ;
			NoLogo WITH THIS.NoLogo, ;
			CmntStyle WITH THIS.CommentStyle

		* Update the project files
		FOR EACH loFile IN THIS.ProjectFiles

			IF loFile.MainProgram

				LOCATE FOR MainProg

			ELSE

				APPEND BLANK

			ENDIF


			REPLACE ;
				NAME WITH loFile.FileName + ;
				CHR(0), ;
				TYPE WITH loFile.FileType, ;
				ID WITH loFile.ID, ;
				Exclude WITH loFile.Exclude, ;
				MainProg WITH ;
				loFile.MainProgram, ;
				CPID WITH loFile.CODEPAGE, ;
				Comments WITH ;
				loFile.FileDescription

		ENDFOR


		USE IN PJX


	ENDPROC


	* Build the create the project files AND
	* verify that files in the project exist.
	PROCEDURE CreatePjx

		* Preserve the existing project if
		* testing. Normally during a build
		* there is only the pjm.
		lcFile = IIF( EMPTY( THIS.BuildName ) AND ;
			FILE( FORCEEXT( THIS.PjmFile, "pjx" ) ) ;
			, "_", "" ) + THIS.PjmFileName

		lcPJX = FORCEEXT( lcFile, "pjx" )
		lcPjt = FORCEEXT( lcFile, "pjt" )

		THIS.PjxFile = ADDBS( THIS.PjmPath ) + lcPJX

		SET DEFAULT TO ( THIS.PjmPath )

		ERASE ( lcPJX )
		ERASE ( lcPjt )

		lcFiles = ""
		lcMain = ""

		FOR EACH loFile IN THIS.ProjectFiles

			lcFileName = loFile.FileName

			IF FILE( lcFileName )

				IF loFile.MainProgram

					lcMain = lcFileName

				ELSE

					* The docs say you can specify
					* more than one file in the
					* build project files clause.
					* In practice only the first file
					* is added.
					* lcFiles =lcFiles+" "+lcFileName

				ENDIF


			ELSE

         \Project file << lcFileName >>
         \\was not found.

			ENDIF


		ENDFOR


		lcFiles = lcMain && + ", " + lcFiles

		* Create the project file and add the file(s)
		BUILD PROJECT ( lcPJX ) FROM &lcFiles


		* Initialize the project
	PROCEDURE INIT
		THIS.ProjectFiles[1] = NULL
		SET TEXTMERGE TO
	ENDPROC


	* Clean up
	PROCEDURE DESTROY
		SET DEFAULT TO ( THIS.CurrentDefault )
		SET TEXTMERGE TO
		SET TEXTMERGE OFF
	ENDPROC


	* Hydrate the object from the PJM
	PROCEDURE ParsePjm

		IF EMPTY( THIS.PjmFile ) OR ;
				NOT FILE( THIS.PjmFile )
			RETURN
		ENDIF

		lcPjM = FILETOSTR( THIS.PjmFile )

		IF EMPTY( lcPjM )
			RETURN
		ENDIF

		=ALINES( laLines, lcPjM, 1 )

		* First section of file
		lcState = "[Properties]"

		FOR EACH lcLine IN laLines

			* Section markers
			IF INLIST( lcLine, ;
					"[OLEServers]", ;
					"[OLEServersEnd]", ;
					"[ProjectFiles]", ;
					"[EOF]" )

				lcState = lcLine
				LOOP

			ENDIF


			DO CASE
			CASE lcState = "[Properties]"

				lcPropertyName = ALLTRIM( ;
					GETWORDNUM( lcLine, 1, "=" ) )
				lcProperty = "this." + lcPropertyName
				lcValue = GETWORDNUM( lcLine, 2, "=")

				IF NOT EMPTY( lcValue )

					DO CASE
					CASE INLIST( lcPropertyName, ;
							[SaveCode], ;
							[Debug], ;
							[Encrypt], ;
							[NoLogo], ;
							[AutoIncrement] )

						STORE EVALUATE(lcValue) ;
							TO &lcProperty

					CASE INLIST( lcPropertyName, ;
							[CommentStyle], ;
							[Major], ;
							[Minor], ;
							[Revision] )

						STORE VAL(lcValue) ;
							TO &lcProperty
					OTHERWISE
						STORE lcValue TO &lcProperty
					ENDCASE


				ENDIF


			CASE lcState = "[OLEServers]"
				* TODO: Add support for COM Servers
				LOOP
			CASE lcState = "[OLEServersEnd]"
				* TODO: Add support for COM Servers
				LOOP
			CASE lcState = "[ProjectFiles]"
				THIS.AddFile( lcLine )
			CASE lcState = "[EOF]"
				LOOP
			ENDCASE


		ENDFOR


	ENDPROC


	* Add a file to the project object
	PROCEDURE AddFile( lcLine )

		loFile = CREATEOBJECT( "ProjectFile" )
		loFile.ParseFile( lcLine )

		IF NOT ISNULL( THIS.ProjectFiles[ alen( ;
      this.ProjectFiles ) ] )
			DIMENSION THIS.ProjectFiles[ alen( ;
         this.ProjectFiles ) + 1 ]
		ENDIF

		THIS.ProjectFiles[ ;
      alen( this.ProjectFiles ) ] = loFile

	ENDPROC


ENDDEFINE



DEFINE CLASS ProjectFile AS SESSION
	ID = ""
	FileType = ""
	FileName = ""
	Exclude = .F.
	MainProgram = .F.
	CODEPAGE = 1252
	User1 = ""
	User2 = ""
	FileDescription = ""



	PROCEDURE INIT

	ENDPROC

	PROCEDURE DESTROY

	ENDPROC

	PROCEDURE ParseFile( pcLine )

		THIS.ID = VAL( GETWORDNUM( pcLine, 1, "," ) )
		THIS.FileType = GETWORDNUM( pcLine, 2, "," )
		THIS.FileName = GETWORDNUM( pcLine, 3, "," )
		THIS.Exclude = EVAL( GETWORDNUM( pcLine, 4, "," ) )
		THIS.MainProgram = EVAL( GETWORDNUM( pcLine, 5, "," ) )
		THIS.CODEPAGE = VAL( GETWORDNUM( pcLine, 6, "," ) )
		THIS.User1 = GETWORDNUM( pcLine, 7, "," )
		THIS.User2 = GETWORDNUM( pcLine, 8, "," )
		THIS.FileDescription = GETWORDNUM( pcLine, 9, "," )

	ENDPROC


	PROCEDURE ERROR
		LPARAMETERS nError, cMethod, nLine

   \
   \Error Building Project
   \Error: << nError >>
   \Line: << nLine >>
   \Method: << cMethod >>

	ENDPROC


	PROCEDURE BuildProject
		LPARAMETERS cBuildName, cProjectName

		cEXE = FORCEEXT( cProjectName, "exe" )
		cPJX = FORCEEXT( cProjectName, "pjx" )

		BUILD EXE ( cEXE ) FROM ( cPJX )


ENDDEFINE

