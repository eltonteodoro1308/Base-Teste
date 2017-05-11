#INCLUDE 'TOTVS.CH'

User Function TSTPRG()

	MsApp():New('SIGAESP')
	oApp:CreateEnv()

	If ApMsgNoYes( 'Executa Login de Usuário ?' )

		oApp:cStartProg := 'U_EXECUTE'
		__lInternet := .T.

	Else

		oApp:bMainInit := {||;
		MsgRun( "Configurando ambiente...", "Aguarde..." ,;
		{|| RpcSetEnv( "99", "01" ), } ), U_EXECUTE(),;
		Final( "" ) }

		__lInternet := .T.
		lMsFinalAuto := .F.
		oApp:lMessageBar:= .T.
		oApp:cModDesc:= 'SIGAESP'

	End If

	oApp:Activate()

Return Nil

User Function Execute()

	Local oGet1
	Local cGet1 := MemoRead( '\system\bufexec.txt' )
	//	Local oSButton1
	//	Local oSButton2
	Local otMultiBtn
	Local aBcode := {}

	Static oDlg

	cGet1 := cGet1 + Space( 1048575 - Len( cGet1 ) )

	DEFINE MSDIALOG oDlg TITLE 'Executar' FROM 000, 000  TO 150, 1000 COLORS 0, 16777215 PIXEL

	@ 035, 005 MSGET oGet1 VAR cGet1 SIZE 490, 010 OF oDlg COLORS 0, 16777215 PIXEL
	//	DEFINE SBUTTON oSButton1 FROM 035, 005 TYPE 01 OF oDlg ENABLE ACTION Eval( {|| Execute( cGet1 ) } )
	//	DEFINE SBUTTON oSButton2 FROM 035, 035 TYPE 02 OF oDlg ENABLE ACTION oDlg:End()

	otMultiBtn := tMultiBtn():New( 01,01,'Titulo',oDlg,,200,150, 'Fundo',0,'Mensagem',3 )

	oTMultiBtn:AddButton('Executar')
	oTMultiBtn:AddButton('Histórico')
	oTMultiBtn:AddButton('Cancelar')

	oTMultiBtn:bAction := { |X,Y| VarInfo('X',X,,.F.,.T.),VarInfo('Y',Y,,.F.,.T.),Eval( aBcode[ Y ] ) }

	aAdd( aBcode, {||Execute( cGet1 ) } )
	aAdd( aBcode, {||Alert('') } )
	aAdd( aBcode, {||oDlg:End() } )

	ACTIVATE MSDIALOG oDlg CENTERED

Return

Static Function Execute( cGet1 )

	Local cBlc  := '{||' + AllTrim( cGet1 ) + '}'
	Local bBlc  := &( cBlc )
	Local bErro := ErrorBlock( {|oErro| VerErro( oErro ) } )

	MemoWrite( '\system\bufexec.txt', cGet1 )

	Eval( bBlc )

Return

Static Function VerErro( oErro )

	ApMsgStop( oErro:Description, 'Erro na Execução da Fórmula Digitada' )

Return

