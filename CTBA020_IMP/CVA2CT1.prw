#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

User Function CVN2CT1()

	Local oCTBA020 := FWLoadModel('CTBA020')
	Local oCT1     := oCTBA020:GetModel('CT1MASTER')
	Local oCVD     := oCTBA020:GetModel('CVDDETAIL')
	Local aArea    := GetArea()
	Local cNormal  := ''

	oCTBA020:SetOperation( MODEL_OPERATION_INSERT )

	DBSelectArea("CVN")
	DbSetOrder(1)
	DbGotop()

	Do While ! Eof()

		oCTBA020:Activate()

		If CVN->CVN_NATCTA $ '/01/04/'

			cNormal := '1'

		Else

			cNormal := '2'

		End If

		oCT1:SetValue( "CT1_CONTA" , StrTran(AllTrim(CVN->CVN_CTAREF),".","") )
		oCT1:SetValue( "CT1_DESC01", AllTrim(CVN->CVN_DSCCTA) )
		oCT1:SetValue( "CT1_CLASSE", AllTrim(CVN->CVN_CLASSE) )
		oCT1:SetValue( "CT1_NORMAL", cNormal )
		oCT1:SetValue( "CT1_CTASUP", StrTran(AllTrim(CVN->CVN_CTASUP),".","") )
		oCT1:SetValue( "CT1_NATCTA", AllTrim(CVN->CVN_NATCTA) )
		oCT1:SetValue( "CT1_NTSPED", AllTrim(CVN->CVN_NATCTA) )

		oCVD:SetValue( "CVD_ENTREF", AllTrim(CVN->CVN_ENTREF ))
		oCVD:SetValue( "CVD_CODPLA", AllTrim(CVN->CVN_CODPLA ))
		oCVD:SetValue( "CVD_VERSAO", AllTrim(CVN->CVN_VERSAO ))
		oCVD:SetValue( "CVD_CTAREF", AllTrim(CVN->CVN_CTAREF ))

		If !( oCTBA020:VldData() .And. oCTBA020:CommitData() )

			aErro := oCTBA020:GetErrorMessage()

			ConOut( 'Erro na Inclusão Conta ' + CVN->CVN_CTAREF)
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

			ConOut( 'Incluído com Sucesso Conta ' + CVN->CVN_CTAREF)
			ConOut( Padc( '-', 100, '-' ) )

		End If


		oCTBA020:DeActivate()

		DbSkip()

	End Do

	RestArea( aArea )

Return