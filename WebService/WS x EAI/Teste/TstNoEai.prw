#INCLUDE 'TOTVS.CH'

user function TstNoEai( )

	Local oWs    := WSTSTDIVIS():New()
	Local nX     := 0
	Local nStart := 0
	Local nCount := 1000

	nStart := Val( FwTimeStamp( 4 ) )

	For nX := 1 To nCount

		If oWs:Divisao( cValToChar( Randomize( 30, 100 ) ), cValTochar( Randomize( 10, 20 ) ) )

			ConOut( CvalToChar( oWs:cDivisaoResult ) )
			ConOut( 'Interação: ' + cValToChar( nX ) )
			ConOut( cValToChar( Val( FwTimeStamp( 4 ) ) - nStart ) + ' Segundos.')

		Else

			ConOut( GetWSCError() )

		End IF

	Next nX

	ConOut(ProcName() + ': ' +  cValToChar( Val( FwTimeStamp( 4 ) ) - nStart ) + ' Segundos.')

return