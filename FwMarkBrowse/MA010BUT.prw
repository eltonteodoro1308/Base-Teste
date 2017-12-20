#INCLUDE 'TOTVS.CH'

User Function MTA010MNU()

	aAdd( aRotina, { 'Teste Browse', 'U_BROWSE', 0, 2, 0, nil } )

return

User Function BROWSE()

	Local cAliasSB1  := ''
	Local cAliasTrb  := ''
	Local cQuery     := ''
	Local nX         := 0
	Local aArea      := GetArea()
	Local aFields    := {}
	Local cFieldName := ''
	Local cFieldType := ''
	Local cFieldTam  := 00
	Local cFieldDec  := 00

	cQuery += "SELECT SB1.B1_COD, SB1.B1_DESC, SB1.B1_TIPO, SB1.B1_UM FROM "
	cQuery += RetSqlName( 'SB1' ) + " SB1 WHERE SB1.D_E_L_E_T_ = ' ' "

	cAliasSB1 := MPSysOpenQuery( cQuery )

	aAdd( aFields, { 'B1_OK', 'C', 02, 00 } )

	For nX := 1 To ( cAliasSB1 )->( FCount() )

		cFieldName := ( cAliasSB1 )->( FieldName( nX )      )
		cFieldType := GetSx3Cache( cFieldName, 'X3_TIPO'    )
		cFieldTam  := GetSx3Cache( cFieldName, 'X3_TAMANHO' )
		cFieldDec  := GetSx3Cache( cFieldName, 'X3_DECIMAL' )

		aAdd( aFields, { cFieldName, cFieldType, cFieldTam, cFieldDec } )

	Next nX

	cAliasTrb := CriaTrab( aFields, .T. )

	DBUseArea( .T., 'CTREECDX', '\SYSTEM\' + cAliasTrb + GetDBExtension(), cAliasTrb, .F., .F. )

	( cAliasSB1 )->( DbGoTop() )

	Do While ! ( cAliasSB1 )->( Eof() )

		RecLock( cAliasTrb, .T. )

		For nX := 1 To ( cAliasSB1 )->( FCount() )

			( cAliasTRB )->&( FieldName( nX ) ) := ( cAliasSB1 )->&( FieldName( nX )      )

		Next nX

		MsUnlock()

		( cAliasSB1 )->( DbSkip() )

	End Do

	( cAliasSB1 )->( DbCloseArea() )

	( cAliasTRB )->( DbCloseArea() )

	RestArea( aArea )

Return