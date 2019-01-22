#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

User Function CT12SED()

	Local oFINA010 := FWLoadModel('FINA010')
	Local oSED     := oFINA010:GetModel('SEDMASTER')
	Local aArea    := GetArea()
	Local cNormal  := ''
	Local cCta     := ''
	Local cCtaSup  := ''
	Local cCtaAux  := ''

	oFINA010:SetOperation( MODEL_OPERATION_INSERT )

	DbSelectArea('CT1')
	DbSetOrder(1)
	DbGoTop()

	Do While CT1->(! Eof())

		oFINA010:Activate()

		If CT1->CT1_NORMAL == '1'

			cNormal := 'D'

		Else

			cNormal := 'R'

		End If

		// Monta Conta

		cCtaAux := AllTrim( CT1->CT1_CONTA )

		cCta := ""

		cCta += SubStr( cCtaAux, 1, 1 )

		If Len( cCtaAux ) > 1

			cCta += Chr( 64 + Val( SubStr( cCtaAux, 2, 2 ) ) )

		End If

		cCta += SubStr( cCtaAux, 4, Len( cCtaAux ) )

		// Monta Conta Superior

		cCtaAux := AllTrim(CT1->CT1_CTASUP)

		cCtaSup := ""

		If ! Empty( cCtaAux )

			cCtaSup += SubStr( cCtaAux, 1, 1 )

			If Len( cCtaAux ) > 1

				cCtaSup += Chr( 64 + Val( SubStr( cCtaAux, 2, 2 ) ) )

			End If

			cCtaSup += SubStr( cCtaAux, 4, Len( cCtaAux ) )

		End If

		oSED:SetValue( "ED_CODIGO"  , cCta )
		oSED:SetValue( "ED_DESCRIC" , AllTrim(CT1->CT1_DESC01))
		oSED:SetValue( "ED_TIPO"	, AllTrim(CT1->CT1_CLASSE))
		oSED:SetValue( "ED_PAI"     , cCtaSup )
		oSED:SetValue( "ED_COND"    , cNormal )

		If AllTrim(CT1->CT1_CLASSE) # '1'

			oSED:SetValue( "ED_CONTA"   , AllTrim(CT1->CT1_CONTA) )

		End If

		If !( oFINA010:VldData() .And. oFINA010:CommitData() )

			aErro := oFINA010:GetErrorMessage()

			ConOut( 'Erro na Inclusão Conta ' + CT1->CT1_CONTA )
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

			ConOut( 'Incluído com Sucesso Conta ' + CT1->CT1_CONTA )
			ConOut( Padc( '-', 100, '-' ) )

		End If

		oFINA010:DeActivate()

		CT1->(DbSkip())

	End Do

	RestArea( aArea )

Return