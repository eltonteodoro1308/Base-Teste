#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static Function ModelDef()

	Local oModel := MPFormModel():New( 'SC1MODEL', , , { | oModel | Commit( oModel ) } )
	Local oStr   := FWFormStruct( 1, 'SC1' )

	oModel:SetDescription( 'Solicitação de Compras' )

	oModel:addFields( 'SC1FIELD', , oStr )

	oModel:getModel( 'SC1FIELD' ):SetDescription( 'Solictação de Compras' )

Return oModel

Static Function Commit( oModel )

	Local lRet := .F.

	Private	lMsErroAuto    := .F.
	Private	lMsHelpAuto    := .T.
	Private	lAutoErrNoFile := .T. 

	If lRet := oModel:VldData()

		If ! ( lRet := ! lMsErroAuto )

		End If

	End If

Return lRet


User Function Teste()

	Local lRet := .T.
	Local lOk  := .T.


	If ! ( lRet := ! lOk )

		ConOut('T')

	Else

		ConOut('F')

	End If

Return

