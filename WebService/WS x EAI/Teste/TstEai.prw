#INCLUDE 'TOTVS.CH'

user function TstEai(  )

	Local oEai := WsEaiService():New()
	Local nX     := 0
	Local nStart := 0
	Local nCount := 1000

	oEai:_URL := 'http://spon4944:7112/ws/EAISERVICE.apw'

	nStart := Val( FwTimeStamp( 4 ) )

	For nX := 1 To nCount

		If oEai:ReceiveMessage( FXml() )

			ConOut( oEai:cReceiveMessageResult )
			ConOut( 'Interação: ' + cValToChar( nX ) )
			ConOut( cValToChar( Val( FwTimeStamp( 4 ) ) - nStart ) + ' Segundos.')

		Else

			ConOut( GetWSCError() )

		EndIf

	Next nX

	ConOut(ProcName() + ': ' +  cValToChar( Val( FwTimeStamp( 4 ) ) - nStart ) + ' Segundos.')

return

Static Function FXml()

	Local cRet  := ''
	Local cUUID := FwTimeStamp( 3 )

	cRet += '<![CDATA['
	cRet += '<TOTVSIntegrator>'
	cRet += '<GlobalProduct>TOTVS|EAI</GlobalProduct>'
	cRet += '<GlobalFunctionCode>EAI</GlobalFunctionCode>'
	cRet += '<GlobalDocumentFunctionCode>TSTDIVIS</GlobalDocumentFunctionCode>'
	cRet += '<GlobalDocumentFunctionDescription>DIVISAO</GlobalDocumentFunctionDescription>'
	cRet += '<DocVersion>1.000</DocVersion>'
	cRet += '<DocDateTime>'

	cRet += cUUID

	cRet += '</DocDateTime>'
	cRet += '<DocIdentifier>'

	cRet += FWUUIDV4(.T.)

	cRet += '</DocIdentifier>'
	cRet += '<DocCompany>99</DocCompany>'
	cRet += '<DocBranch>01</DocBranch>'
	cRet += '<DocName />'
	cRet += '<DocFederalID />'
	cRet += '<DocType>1</DocType>'
	cRet += '<Message>'
	cRet += '<Layouts>'
	cRet += '<Version>1.000</Version>'
	cRet += '<Identifier>' + cUUID + '</Identifier>'
	cRet += '<FunctionCode>U_TSTDIVS.' + cValToChar( Randomize( 30, 100 ) ) + '.'
	cRet += cValTochar( Randomize( 10, 20 ) ) + '</FunctionCode>'
	cRet += '<Content>'
	cRet += '</Content>'
	cRet += '</Layouts>'
	cRet += '</Message>'
	cRet += '</TOTVSIntegrator>'
	cRet += ']]>'

Return cRet