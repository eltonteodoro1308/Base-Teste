#INCLUDE 'TOTVS.CH'
#INCLUDE 'FILEIO.CH'

User Function TstFile()

	Local cFile   := '\system\bufexec.cfg'
	local cBuffer := '' 
	Local nHandle := 0

	For nX := 1 To 10000000000

		If File( cFile )

			nHandle := FOpen( cFile,  FO_READWRITE + FO_SHARED )

		Else

			nHandle := FCreate( cFile )

		End If

		cBuffer := FWTimeStamp( 4 ) + Chr( 13 ) + Chr( 10 )

		FSeek( nHandle, 0, FS_END )	

		FWrite( nHandle, cBuffer, Len( cBuffer ) )

		FClose(nHandle)

	Next nX

Return


User Function MyFunction()
	Local oButton1
	Local oButton2
	Local oGet1
	Local cGet1 := "Define variable value"
	Local oListBox1
	Local nListBox1 := 1
	Static oDlg

	DEFINE MSDIALOG oDlg TITLE "New Dialog" FROM 000, 000  TO 500, 500 COLORS 0, 16777215 PIXEL

	@ 005, 004 MSGET oGet1 VAR cGet1 SIZE 237, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 020, 004 LISTBOX oListBox1 VAR nListBox1 ITEMS {} SIZE 240, 205 OF oDlg COLORS 0, 16777215 PIXEL
	@ 233, 005 BUTTON oButton1 PROMPT "oButton1" SIZE 037, 012 OF oDlg ACTION AddItem( oListBox1 ) PIXEL
	@ 233, 055 BUTTON oButton2 PROMPT "oButton2" SIZE 037, 012 OF oDlg ACTION oListBox1:Reset() PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return

Static Function AddItem( oListBox1 )

	Local aList := aClone( oListBox1:aItems )

	While oListBox1:Len() > 0

		oListBox1:Del()

	End	

	oListBox1:Add( FWTimeStamp( 4 ) )

	For nX := 1 To Len( aList )

		oListBox1:Add( aList[nX] )

	Next nX

Return