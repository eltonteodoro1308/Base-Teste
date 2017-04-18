#INCLUDE 'TOTVS.CH'

User Function TstDivs( cXml, cError, cWarning, cParams, oFwEai )

	Local aParams    := StrTokArr2( cParams, ',', .T. )
	Local nDividendo := Val( aParams[ 1 ] )
	Local nDivisor   := Val( aParams[ 2 ] )
	Local nQuociente := 0
	Local nResto     := 0

	nQuociente := Int( nDividendo / nDivisor )
	nResto     := Mod( nDividendo, nDivisor  )

Return;
'Quociente: ' + cValToChar( nQuociente ) +;
' / Resto: ' + cValToChar( nResto )
