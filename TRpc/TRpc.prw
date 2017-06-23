#INCLUDE 'TOTVS.CH'

user function TRpc()

	Local oTRpc := TRpc():New( 'Environment' )
	Local xRet := Nil

	If oTRpc:Connect ( 'LOCALHOST', 7011, 10  )

		xRet := oTRpc:CallProc( 'U_MYSOMA', 10, 20 )

		ConOut( 'Soma: ' + cValToChar( xRet ) )

	Else

		ConOut( 'Sem Comunicação com Servidor de Produção.' )

	End If

return

user function MySoma( n1, n2 )

	ConOut('Executando Soma')

Return n1 + n2