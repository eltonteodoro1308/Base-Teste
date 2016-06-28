#Include "TOTVS.CH"

User Function DicAdvpl( cTabela )
	
	Local oDlg       := Nil
	Local oSize      := FwDefSize():New(.T.)
	Local oList      := Nil
	Local aList      := {}
	Local cList      := ''
	Local aRet       := {}
	Local aHeader    := {}
	//	Local aButtons   := {}
	Local oCmbBxNmDc := Nil
	Local cCmbBxNmDc := ''
	Local oCmbBxTpBc := Nil
	Local cCmbBxTpBc := ''
	Local oGetBusca  := Nil
	Local cGetBusca  := Space( 30 )
	Local nGetBusca  := 30
	Local oBtnBusca  := Nil
	Local oBtnFechar := Nil
	Local nX         := 1
	
	Default cTabela := 'SX3'
	
	oSize:AddObject( "TOPO" , 070, 010, .F., .F. )	
	oSize:AddObject( "LISTA", 000, 000, .T., .T. )
	
	oSize:Process()
	
	MsgRun( "Processando Tabelas...", "Iniciando...", {|| aRet := ReadSX( cTabela ) } )
	
	aHeader := aRet[ 1 ]
	aList   := aRet[ 2 ]
	
	DEFINE MSDIALOG oDlg TITLE "Dicionário de Dados " + cTabela FROM oSize:aWindSize[1],oSize:aWindSize[2]  TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL
	
	@ oSize:GetDimension("TOPO","LININI"), oSize:GetDimension("TOPO","COLINI");
		MSCOMBOBOX oCmbBxNmDc VAR cCmbBxNmDc ITEMS aHeader;
		SIZE oSize:GetDimension("TOPO","COLEND"), oSize:GetDimension("TOPO","LINEND") OF oDlg PIXEL
	
	@ oSize:GetDimension("TOPO","LININI"), oSize:GetDimension("TOPO","COLINI") + oSize:GetDimension("TOPO","COLEND");
		MSCOMBOBOX oCmbBxTpBc VAR cCmbBxTpBc ITEMS {"1=Igual a","2=Começa com","3=Termina com","4=Contém"};
		SIZE oSize:GetDimension("TOPO","COLEND"), oSize:GetDimension("TOPO","LINEND") OF oDlg PIXEL
	
	@ oSize:GetDimension("TOPO","LININI"), oSize:GetDimension("TOPO","COLINI") + oSize:GetDimension("TOPO","COLEND") * 2;
		MSGET oGetBusca VAR cGetBusca SIZE oSize:GetDimension("TOPO","COLEND") + nGetBusca, oSize:GetDimension("TOPO","LINEND") - 5 OF oDlg PIXEL
	
	@ oSize:GetDimension("TOPO","LININI"), oSize:GetDimension("TOPO","COLINI") + oSize:GetDimension("TOPO","COLEND") * 3 + nGetBusca ;
		BUTTON oBtnBusca PROMPT "Buscar" SIZE oSize:GetDimension("TOPO","COLEND") - 30, oSize:GetDimension("TOPO","LINEND") - 3 OF oDlg PIXEL;
		ACTION Alert(valtype(cCmbBxTpBc) + ' - ' + cCmbBxTpBc) PIXEL
	//ACTION oList:GoPosition( 150 ) PIXEL
	
	@ oSize:GetDimension("TOPO","LININI"), oSize:GetDimension("TOPO","COLINI") + oSize:GetDimension("TOPO","COLEND") * 4 + 3;
		BUTTON oBtnFechar PROMPT "Fechar" SIZE oSize:GetDimension("TOPO","COLEND") - 30, oSize:GetDimension("TOPO","LINEND") - 3 OF oDlg PIXEL;
		ACTION oDlg:End() PIXEL
	
	@ oSize:GetDimension("LISTA","LININI"), oSize:GetDimension("LISTA","COLINI");
		LISTBOX oList Fields HEADER '';
		SIZE oSize:GetDimension("LISTA","COLEND"), oSize:GetDimension("LISTA","LINEND") OF oDlg PIXEL
	
	oList:aHeaders := aHeader
	
	oList:SetArray( aList )
	
	cList := '{|| {'
	
	For nX := 1 To Len( aHeader )
		
		cList += 'aList[oList:nAt,' + cValToChar( nX ) + ']'
		
		If nX < Len( aHeader )
			
			cList += ','
			
		End If
		
	Next nX
	
	cList += '}}'
	
	oList:bLine := &cList
	
	// DoubleClick event
	oList:bLDblClick := {|| Alert('')/*,oList:DrawSelect()*/}
	
	//	Aadd(aButtons, {"", {||Alert('')}, "Alert"})
	//	EnchoiceBar(oDlg, {||oDlg:End()}, {||oDlg:End()},,aButtons)
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
Return

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Static Function ReadSX( cTabela )
	
	Local aXArea  := ( cTabela )->( GetArea() )
	Local aArea   := GetArea()
	Local aret    := {}
	Local aHeader := Array( ( cTabela )->( FCount() ) )
	Local aList   := {}
	Local nX      := 1
	
	( cTabela )->( DbSetOrder( 1 ) )
	( cTabela )->( DbGoTop( ) )
	
	For nX := 1 To ( cTabela )->( FCount() )
		
		( cTabela )->( aHeader[ nX ] := FieldName( nX ) )
		
	Next nX
	
	Do While .Not. ( cTabela )->( EOF() )
		
		aAdd( aList, Array( Len( aHeader ) ) )
		
		For nX := 1 To Len( aHeader )
			
			( cTabela )->( aList[ Len( aList ), nX ] := &( aHeader[ nX ] ) )
			
		Next nX
		
		( cTabela )->( DbSkip() )
		
	End Do
	
	RestArea( aXArea )
	RestArea( aArea )
	
	aAdd( aRet, aHeader )
	aAdd( aRet, aList )
	
Return aRet
