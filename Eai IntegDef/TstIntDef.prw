#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEDITPANEL.CH'
#INCLUDE 'FWADAPTEREAI.CH'

User Function TstIntDef()

	Local oEai := WsEaiService():New()

	oEai:_URL := 'http://spon4944:7112/ws/EAISERVICE.apw'

	If oEai:ReceiveMessage( FXml() )

		ConOut( oEai:cReceiveMessageResult )

	Else

		ConOut( GetWSCError() )

	EndIf

Return

User Function Teste( cXml, cError, cWarning, cParams, oFwEai )

	Local cRet := 'Teste TotvsIntegrator'
	Local cMsg := 'Falha na execução'

	VarInfo( 'cXml', cXml,, .F., .T. )
	VarInfo( 'cParams', cParams,, .F., .T. )

	//oFwEai:lMessageOk := .F.
	oFwEai:cReturnMsg := cMsg

	//ExUserException ( cMsg )

Return cRet

Static Function FXml()

	Local cRet := ''

	cRet += '<![CDATA['
	cRet += '<TOTVSIntegrator>'
	cRet += '<GlobalProduct>TOTVS|EAI</GlobalProduct>'
	cRet += '<GlobalFunctionCode>EAI</GlobalFunctionCode>'
	cRet += '<GlobalDocumentFunctionCode>TESTE</GlobalDocumentFunctionCode>'
	cRet += '<GlobalDocumentFunctionDescription>TESTE</GlobalDocumentFunctionDescription>'
	cRet += '<DocVersion>1.000</DocVersion>'
	cRet += '<DocDateTime>'

	cRet += FwTimeStamp( 3 )

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
	cRet += '<Identifier>TESTE</Identifier>'
	cRet += '<FunctionCode>U_TESTE.123.ABC.XYZ</FunctionCode>'
	cRet += '<Content>'
	cRet += '<IOGPEC01_REM xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
	cRet += '<CONDITION>'
	cRet += '<filter field="RA_SITFOLH" relation="NOT_EQUAL">'
	cRet += '<value>D</value>'
	cRet += '</filter>'
	cRet += '<filter field="RA_NOMECMP" relation="CONTAINS">'
	cRet += '<value>cesaro</value>'
	cRet += '</filter>'
	cRet += '</CONDITION>'
	cRet += '<SORT>'
	cRet += '<DESC>RA_NOME</DESC>'
	cRet += '<DESC>RA_MAT</DESC>'
	cRet += '</SORT>'
	cRet += '</IOGPEC01_REM>'
	cRet += '</Content>'
	cRet += '</Layouts>'
	cRet += '</Message>'
	cRet += '</TOTVSIntegrator>'
	cRet += ']]>'

Return cRet