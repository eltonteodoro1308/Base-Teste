#Include 'TOTVS.CH'
Static cAlias  := GetNextAlias()
Static aParam  := {}
Static oReport := ReportDef()
Static oSectionCb := Nil
Static oSectionLn := Nil

User Function XTReport()
	
	oReport:printDialog()
	
Return

//-------------------------------------------------------------------------------------------------------------------------------------

Static Function ReportDef()
	
	Local cTitulo    := 'Lista de Tabelas Genéricas'
	Local cDescricao := 'Lista de Tabelas Genéricas conforme solicitado.'
	
	oReport := TReport():New( ProcName(), cTitulo, {|| aParam := Parametros() }, {|| PrintReport() }, cDescricao )
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
	
	oSectionCb := TRSection():New( oReport, 'SX5CB', cAlias )
	oSectionCb:SetTotalInLine(.F.)
	oSectionCb:SetCellBorder("ALL",,,.T.)
	
	oSectionLn := TRSection():New( oReport, 'SX5LN', cAlias )
	oSectionLn:SetTotalInLine(.F.)
	oSectionLn:SetCellBorder("ALL",,,.T.)
	
	TRCell():New( oSectionCb, 'X5_TABELA' , cAlias, 'CÓDIGO DA TABELA'    ,PesqPict( 'SX5', 'X5_CHAVE'  ), TamSX3( 'X5_CHAVE'  )[1] + 1 )
	TRCell():New( oSectionCb, 'X5_DESCTAB', cAlias, 'DESCRIÇÃO DA TABELA' ,PesqPict( 'SX5', 'X5_DESCRI' ), TamSX3( 'X5_DESCRI' )[1] + 1 )
	
	TRCell():New( oSectionLn, 'X5_CHAVE'  , cAlias, 'CHAVE'     ,PesqPict( 'SX5', 'X5_CHAVE'  ), TamSX3( 'X5_CHAVE'  )[1] + 1 )
	TRCell():New( oSectionLn, 'X5_DESCRI' , cAlias, 'DESCRIÇÃO' ,PesqPict( 'SX5', 'X5_DESCRI' ), TamSX3( 'X5_DESCRI' )[1] + 1 )
	
	oBreak := TRBreak():New( oSectionCb, oSectionCb:Cell( 'X5_TABELA' ) )
	
Return oReport

//-------------------------------------------------------------------------------------------------------------------------------------

Static Function Parametros()
	
	Local aPergs    := {}
	
	aAdd( aPergs, { 1, 'Tabela De  ?', Space( TamSx3( 'X5_TABELA' )[ 1 ] ), '@!', 'MV_PAR01 # "00"', '00', '.T.', TamSx3( 'X5_TABELA' )[ 1 ], AllWaysFalse() } )
	aAdd( aPergs, { 1, 'Tabela Até ?', Space( TamSx3( 'X5_TABELA' )[ 1 ] ), '@!', 'MV_PAR01 # "00"', '00', '.T.', TamSx3( 'X5_TABELA' )[ 1 ], AllWaysFalse() } )
	
	ParamBox( aPergs , 'Selecione as Tabelas !!!', aParam )
	
	BeginSql Alias cAlias
		
		SELECT SX5.X5_TABELA,
		(
		SELECT TOP 1 SX5TAB.X5_DESCRI FROM %Table:SX5% SX5TAB
		WHERE
		SX5TAB.%notdel% AND
		SX5TAB.X5_TABELA =  '00' AND
		SX5.X5_TABELA = SX5TAB.X5_CHAVE
		) X5_DESCTAB,
		SX5.X5_CHAVE,SX5.X5_DESCRI FROM %Table:SX5% SX5
		WHERE
		SX5.%notdel% AND
		SX5.X5_TABELA <> '00' AND
		SX5.X5_CHAVE >= %Exp:aParam[ 1 ]% AND
		SX5.X5_CHAVE <= %Exp:aParam[ 2 ]%;
			
	EndSql
	
Return

//-------------------------------------------------------------------------------------------------------------------------------------

Static Function PrintReport()
	
	Local cTabela    := ''
	
	oSectionCb := oReport:Section( 1 )
	oSectionCb:Init()
	oSectionCb:SetHeaderSection(.T.)
	
	oSectionLn := oReport:Section( 2 )
	oSectionLn:Init()
	oSectionLn:SetHeaderSection(.T.)
	
	ConOut( GetLastQuery()[ 2 ] )
	
	oReport:SetMeter( ( cAlias )->( LastRec() ) )
	
	cTabela := ( cAlias )->X5_TABELA
	
	oSectionCb:Cell( 'X5_TABELA'  ):SetValue( (cAlias)->X5_TABELA  )
	oSectionCb:Cell( 'X5_TABELA'  ):SetAlign( 'LEFT' )
	
	oSectionCb:Cell( 'X5_DESCTAB' ):SetValue( (cAlias)->X5_DESCTAB )
	oSectionCb:Cell( 'X5_DESCTAB' ):SetAlign( 'LEFT' )
	
	oSectionCb:PrintLine()
	
	oReport:IncMeter()
	
	Do While .Not. (cAlias)->( Eof() )
		
		If oReport:Cancel()
			
			Exit
			
		EndIf
		
		If cTabela # ( cAlias )->X5_TABELA
			
			oReport:IncMeter()
			
			oSectionCb:Cell( 'X5_TABELA'  ):SetValue( ( cAlias )->X5_TABELA  )
			oSectionCb:Cell( 'X5_TABELA'  ):SetAlign( 'LEFT' )
			
			oSectionCb:Cell( 'X5_DESCTAB' ):SetValue( ( cAlias )->X5_DESCTAB )
			oSectionCb:Cell( 'X5_DESCTAB' ):SetAlign( 'LEFT' )
			
			oSectionCb:PrintLine()
			
			oReport:IncMeter()
			
			cTabela := ( cAlias )->X5_TABELA
			
		End If
		
		oSectionLn:Cell( 'X5_CHAVE'  ):SetValue( ( cAlias )->X5_CHAVE  )
		oSectionLn:Cell( 'X5_CHAVE'  ):SetAlign( 'LEFT' )
		
		oSectionLn:Cell( 'X5_DESCRI' ):SetValue( ( cAlias )->X5_DESCRI )
		oSectionLn:Cell( 'X5_DESCRI' ):SetAlign( 'LEFT' )
		
		oSectionLn:PrintLine()
		
		( cAlias )->( DbSkip() )
		
	End Do
	
	oSectionCb:Finish()
	oSectionLn:Finish()
	
Return
