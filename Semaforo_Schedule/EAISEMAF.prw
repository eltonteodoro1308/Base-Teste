#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} IOMATA02
//User Function para ser definida no schedule com padrão de recorrência de sempre ativo, faz a busca no Web service do CDCF
dos clientes que precisa ser incluídos ou atualizados.
@author Elton Teodoro Alves
@since 04/08/2017
@version 12.1.017
@param aParam, array, Array com parâmetros de execução definidos no schedule
/*/
User Function EAISEMAF( aParam )

	Local cTimeStamp := FWTimeStamp( 4 )
	Local cLastTime  := GetGlbValue( 'EAISEMAF' )
	Local nTime      := Val( cTimeStamp ) - Val( cLastTime )
	Local oEai       := Nil
	Local cXml       := ''

	Default aParam := { '99', '01' }

	cXml := GerXml( aParam )

	If RpcSetEnv( aParam[1], aParam[2] )

		If nTime >= GetMv( 'IO_TMPWAIT' )

			oEai := WsEaiService():New()

			oEai:_URL := GetMv( 'IO_EAIURL' )

			If oEai:ReceiveMessage( '<![CDATA[' + cXml + ']]>' )

				ConOut( oEai:cReceiveMessageResult )

			End If

			FreeObj( oEai )

			PutGlbValue ( 'EAISEMAF', FWTimeStamp( 4 ) )

		Else

			ConOut( ProcName() + ': Rotina executada a ' + cValTochar( nTime ) + ' segundos.')

		End If

		RpcClearEnv()

	Else

		ConOut( ProcName() + ': Não foi possível acessar empresa/filial.' )

	End If

Return

/*/{Protheus.doc} FXml
//Monta o XML do documento EAI de requisição de integração com o CDCF
@author Elton Teodoro Alves
@since 04/08/2017
@version 12.1.017
@param aParam, array, Array enviado pelo schedule com dados do processamento
@return return, XML do documento de requisição do EAI.
/*/
Static Function GerXml( aParam )

	Local cRet  := ''
	Local cUUID := FWUUIDV4( .T. )

	cRet += '<TOTVSIntegrator>'
	cRet += '<GlobalProduct>TOTVS|EAI</GlobalProduct>'
	cRet += '<GlobalFunctionCode>EAI</GlobalFunctionCode>'
	cRet += '<GlobalDocumentFunctionCode>CDCF</GlobalDocumentFunctionCode>'
	cRet += '<GlobalDocumentFunctionDescription>Cadastro de Clientes e Fornecedores</GlobalDocumentFunctionDescription>'
	cRet += '<DocVersion>1.000</DocVersion>'
	cRet += '<DocDateTime>'

	cRet += FwTimeStamp( 3 )

	cRet += '</DocDateTime>'
	cRet += '<DocIdentifier>'

	cRet += cUUID

	cRet += '</DocIdentifier>'
	cRet += '<DocCompany>' + aParam[ 1 ] + '</DocCompany>'
	cRet += '<DocBranch>'  + aParam[ 2 ] + '</DocBranch>'
	cRet += '<DocName/>'
	cRet += '<DocFederalID />'
	cRet += '<DocType>2</DocType>'
	cRet += '<Message>'
	cRet += '<Layouts>'
	cRet += '<Version>1.000</Version>'
	cRet += '<Identifier>' + cUUID + '</Identifier>'
	cRet += '<FunctionCode>U_SEMAFORO</FunctionCode>'
	cRet += '<Content/>'
	cRet += '</Layouts>'
	cRet += '</Message>'
	cRet += '</TOTVSIntegrator>'

Return cRet