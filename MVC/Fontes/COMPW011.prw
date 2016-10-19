#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'XMLXFUN.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} COMPW011
Exemplo de utilizacao do WebService generico para rotinas em MVC
para uma tabela simples

@author Ernani Forastieri e Rodrigo Antonio Godinho
@since 05/10/2009
@version P10
/*/
//-------------------------------------------------------------------

User Function COMPW011()
Local oMVCWS
Local cXMLEstrut  := ''
Local cXMLEsquema := ''
Local cXMLFile    := '\XML\WSMVCTST.XML'

RpcSetType( 3 )
//RpcSetEnv( '01', '01'  )
RpcSetEnv( '99', '01'  )

// Instancia o WebService Generico para Rotinas em MVC
oMVCWS := WsFwWsModel():New()
oMVCWS:_URL      := "http://127.0.0.1:8080/ws/FWWSMODEL.apw"

// Set Atributos do WebService
oMVCWS:cUserLogin := 'admin'
oMVCWS:cUserToken := 'admin'
oMVCWS:cPassword  := ''
oMVCWS:cModelId   := 'COMP011_MVC' // Fonte de onde se usara o Model

// Pega a descricao do Model
//If oMVCWS:GetDescription()
//    MsgInfo( oMVCWS:cGetDescriptionResult )
//Else
//    MsgStop( 'Problemas em obter descricao do Model'  + CRLF + WSError() )
//EndIf

// Obtem a estutura dos dados do Model
If oMVCWS:GetXMLData()

	cXMLEstrut := oMVCWS:cGetXMLDataResult

	//<?xml version="1.0" encoding="UTF-8"?>
	//<COMP011M Operation="1" version="1.01">
	//    <ZA0MASTER modeltype="FIELDS" >
	//        <ZA0_FILIAL order="1"><value></value></ZA0_FILIAL>
	//        <ZA0_CODIGO order="2"><value></value></ZA0_CODIGO>
	//        <ZA0_NOME   order="3"><value></value></ZA0_NOME>
	//        <ZA0_NOTAS  order="4"><value></value></ZA0_NOTAS>
	//        <ZA0_DTAFAL order="5"><value></value></ZA0_DTAFAL>
	//        <ZA0_TIPO   order="6"><value></value></ZA0_TIPO>
	//        <ZA0_BITMAP order="7"><value></value></ZA0_BITMAP>
	//        <ZA0_QTDMUS order="8"><value></value></ZA0_QTDMUS>
	//        <ZA0_OK     order="9"><value></value></ZA0_OK>
	//    </ZA0MASTER>
	//</COMP011M>


	// Cria um objeto XML a partir da estutura dos dados do Model
	// Isto é feito apenas para manipulacao de XML, pode-se usar outra
	// forma para esta manipulacao

	//CREATE oXML XMLSTRING cXMLEstrut

	cError   := ''
	cWarning := ''
	oXML     := XmlParser(cXMLEstrut, '_', @cError, @cWarning)

	// Seta a Operacao a ser executada
	oXML:_COMP011M:_OPERATION:TEXT := '3'

	// Preenche o objeto XML com dados
	// Para campos de valor, sempre passar zero se nao for obrigatorio
	// Para campos de data, sempre no formato AAAAMMDD
	oXML:_COMP011M:_ZA0MASTER:_ZA0_FILIAL:_VALUE:TEXT  := xFilial( 'ZA0' )
	oXML:_COMP011M:_ZA0MASTER:_ZA0_CODIGO:_VALUE:TEXT  := '010002'
	oXML:_COMP011M:_ZA0MASTER:_ZA0_NOME:_VALUE:TEXT    := 'Ernani Forastieri e Rodrigo Godinho'
	OXML:_COMP011M:_ZA0MASTER:_ZA0_NOTAS:_VALUE:TEXT   := 'NOTAS'
	oXML:_COMP011M:_ZA0MASTER:_ZA0_DTAFAL:_VALUE:TEXT  := '20091001'
	oXML:_COMP011M:_ZA0MASTER:_ZA0_TIPO:_VALUE:TEXT    := '2'
	oXML:_COMP011M:_ZA0MASTER:_ZA0_QTDMUS:_VALUE:TEXT  := '1'  //Para campos de valor, sempre passar zero se nao for obrigatorio

	//DELETENODE '_ZA0_QTDMUS' ON oXML
	//DELETENODE 'ZA0_QTDMUS'  ON oXML
	//
	//If !XmlDelNode( oXML:_COMP011M:_ZA0MASTER, '_ZA0_QTDMUS' )
	//	conout('Não foi possível excluir')
	//EndIf


	// Obtem o esquema de dados XML (XSD)
	If oMVCWS:GetSchema()
		cXMLEsquema := oMVCWS:cGetSchemaResult
	EndIf

	// Salva o objeto XML como arquivo
	SAVE oXML XMLFILE cXMLFile

	// Le o XML para enviar ao WebService
	cXML := MemoRead ( cXMLFile )
	cXML := StrTran( cXML , '&quot;', '' )

	// Joga o XML para o atributo do WebService
	oMVCWS:cModelXML := cXML


	// É necessario se fazer apenas o VldXMLData() ou PutXMLData()
	// Aqui é estão os 2 metodos apenas para demonstracao da chamada

	// Apenas Valida os dados
	If oMVCWS:VldXMLData()

		// Valida e Grava os dados
		If oMVCWS:PutXMLData()

			If oMVCWS:lPutXMLDataResult
				MsgInfo( 'Informação Importada com sucesso.' )

			Else
				MsgStop( 'Não importado' + CRLF + WSError() )

			EndIf

		Else
			MsgStop( AllTrim( oMVCWS:cVldXMLDataResult ) + CRLF + WSError() )

		EndIf

	Else
		MsgStop( 'Problemas na validacao dos dados'  + CRLF + WSError() )

	EndIf

Else
	MsgStop( 'Problemas em obter Folha de Dados do Model'  + CRLF + WSError()  )

EndIf

RpcClearEnv()

Return NIL

//-------------------------------------
Static Function WSError()
Return IIf( Empty( GetWscError(3) ), GetWscError(1), GetWscError(3) )
