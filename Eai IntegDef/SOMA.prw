#INCLUDE 'TOTVS.CH'

user function SOMA( cXml, cError, cWarning, cParams, oFwEai )

	Local aParams   := StrTokArr2( cParams, ',', .T. )

	ConOut( cXml )
	ConOut( cParams )

	oFwEai:cReturnMsg := 'Valor da soma.'

	If val( aParams[1] ) = 0

	UserException( 'Erro do usuário.' )

	End If

return cValTochar( val( aParams[1] ) + val( aParams[2] ) )