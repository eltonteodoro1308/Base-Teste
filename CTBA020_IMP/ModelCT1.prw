#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

User Function ModelCT1()

	Local cFile  := cGetFile()
	Local oFile  := FWFileReader():New(cFile)
	Local oModel := FWLoadModel('CTBA020')
	Local oCT1   := oModel:GetModel('CT1MASTER')
	Local aConta := Nil
	Local cConta := ''
	Local aCtSup := Nil
	Local cCtSup := ''
	Local aErro  := Nil
	Local nX     := 0
	Local nY     := 0
	Local aLinha := {}

	If oFile:Open()

		While AllWaysTrue()

			aConta := StrTokArr2( oFile:GetLine(), '|', .T. )

			aAdd( aLinha, aConta )

			If ! (oFile:hasLine())

				Exit

			End If

		End

		oFile:Close()

	End If

	oModel:SetOperation( MODEL_OPERATION_INSERT )

	For nX := 1 To Len( aLinha )

		ConOut( 'Lendo linha - ' + StrZero( nX, 4 ) + ': ' + aLinha[ nX, 1 ] + ';' + aLinha[ nX, 2 ] )

		aConta := aLinha[ nX ]

		oModel:Activate()

		cConta := StrTran( aConta[1], '.', '' )

		aCtSup := StrTokArr2( aConta[1], '.', .T. )

		cCtSup := ''

		If Len( StrTran( cConta, '0', '' ) ) > 1

			For nY := 1 To Len( aCtSup )

				If '/' + aCtSup[nY] + '/' $ '/00/0/'

					Exit

				Else

					cCtSup += aCtSup[nY]

				End If

			Next nX

			If Len( cCtSup ) <= 5

				cCtSup := SubStr( cCtSup, 1, Len( cCtSup ) - 1 )

			ElseIf Len( cCtSup ) == 7

				cCtSup := SubStr( cCtSup, 1, 5 )

			ElseIf Len( cCtSup ) == 9

				cCtSup := SubStr( cCtSup, 1, 7 )

			End IF

			cCtSup := Padr( cCtSup, len(cConta) , '0' )

		End If

		oCT1:SETVALUE('CT1_CONTA' , cConta )
		oCT1:SETVALUE('CT1_CTASUP', cCtSup )
		oCT1:SETVALUE('CT1_DESC01', aConta[2])
		oCT1:SETVALUE('CT1_CLASSE', '1') //oCT1:SETVALUE('CT1_CLASSE', IF(LEN(aConta[1])==7,'2','1'))
		oCT1:SETVALUE('CT1_XFUNCA', aConta[3] )
		oCT1:SETVALUE('CT1_BLOQ'  , If(aConta[4]=='ATIVA','2','1'))
		oCT1:SETVALUE('CT1_NORMAL', IF(aConta[5]=='D','1','2')) //oCT1:SETVALUE('CT1_NORMAL', IF(SUBSTR(aConta[1],1,1)$'14','1','2'))
		oCT1:SETVALUE('CT1_XTPREG', aConta[6] )

		If !( oModel:VldData() .And. oModel:CommitData() )

			aErro := oModel:GetErrorMessage()

			ConOut( 'Erro na Inclusão' )
			ConOut( Padc( '-', 100, '-' ) )
			ConOut( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1] ) + ']' )
			ConOut( "Id do campo de origem: " + ' [' + AllToChar( aErro[2] ) + ']' )
			ConOut( "Id do formulário de erro: " + ' [' + AllToChar( aErro[3] ) + ']' )
			ConOut( "Id do campo de erro: " + ' [' + AllToChar( aErro[4] ) + ']' )
			ConOut( "Id do erro: " + ' [' + AllToChar( aErro[5] ) + ']' )
			ConOut( "Mensagem do erro: " + ' [' + AllToChar( aErro[6] ) + ']' )
			ConOut( "Mensagem da solução: " + ' [' + AllToChar( aErro[7] ) + ']' )
			ConOut( "Valor atribuído: " + ' [' + AllToChar( aErro[8] ) + ']' )
			ConOut( "Valor anterior: " + ' [' + AllToChar( aErro[9] ) + ']' )

		Else

			ConOut( 'Incluído com Sucesso' )
			ConOut( Padc( '-', 100, '-' ) )

		End If

		oModel:DeActivate()

	Next nX

Return