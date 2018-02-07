#INCLUDE 'TOTVS.CH'

User Function TmpTable()

	Local cQuery     := "SELECT * FROM " + RetSqlName( "SX5" ) + " WHERE D_E_L_E_T_ = ' '"
	Local cAliasTmp  := GetNextAlias()
	Local cAliasSx5  := MPSysOpenQuery( cQuery )
	Local oTempTable := FWTemporaryTable():New( cAliasTmp )
	Local aFields    := {}
	Local nX         := 0
	Local cTableName := ""

	//	For nX := 1 To ( cAliasSx5 )->( FCount() )
	//
	//		cName := ( cAliasSx5 )->( FieldName( nX ) )
	//
	//		If ! cName $ 'R_E_C_N_O_/R_E_C_D_E_L_'
	//
	//			cType := GetSx3Cache( cName, 'X3_TIPO'    )
	//			nLen  := GetSx3Cache( cName, 'X3_TAMANHO' )
	//			nDec  := GetSx3Cache( cName, 'X3_DECIMAL' )
	//
	//			aAdd( aFields, { cName, cType, nLen, nDec } )
	//
	//		End If
	//
	//	Next nX

	//( cAliasSx5 )->( DbStruct() )

	AEval( ( cAliasSx5 )->( DbStruct() ), { | aField | If( ! aField[1] $ 'R_E_C_N_O_/R_E_C_D_E_L_', aAdd( aFields, aField ) , Nil ) }  )

	oTempTable:SetFields( aFields )

	oTempTable:Create()

	( cAliasSx5 )->( DbGoTop() )

	Do While ! ( cAliasSx5 )->( Eof() )

		RecLock( cAliasTmp, .T. )

		For nX := 1 To ( cAliasSx5 )->( FCount() )

			cName := FieldName( nX )

			( cAliasTmp )->&( cName ) := ( cAliasSx5 )->&( cName )

		Next nX

		MsUnlock()

		( cAliasSx5 )->( DbSkip() )

	End Do
	
	cTableName := oTempTable:GetRealName()

	( cAliasSx5 )->( DbCloseArea() )

	//oTempTable:Delete()

Return