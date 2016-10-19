#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'XMLXFUN.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} COMPW021
Exemplo de utilizacao do WebService generico para rotinas em MVC
para uma estrutura de pai/filho

@author Ernani Forastieri e Rodrigo Antonio Godinho
@since 05/10/2009
@version P10
/*/
//-------------------------------------------------------------------
User Function COMPW021()
Local oMVCWS
Local cXMLEstrut  := ''
Local cXMLEsquema := ''
Local cXMLFile    := '\XML\WSMVCTST.XML'

RpcSetType( 3 )
//RpcSetEnv( '01', '01'  )
RpcSetEnv( '99', '01'  )

// Instancia o WebService Generico para Rotinas em MVC
oMVCWS := WsFwWsModel():New()
//oMVCWS:_URL       := "http://127.0.0.1:8090/ws/curso/FWWSMODEL.apw"
oMVCWS:_URL      := "http://127.0.0.1:8080/ws/FWWSMODEL.apw"
// Set Atributos do WebService
oMVCWS:cUserLogin := 'admin'
oMVCWS:cUserToken := 'admin'
oMVCWS:cPassword  := ''
oMVCWS:cModelId   := 'COMP021_MVC' // Fonte de onde se usara o Model

// Pega a descricao do Model
If oMVCWS:GetDescription()
	//	MsgInfo( oMVCWS:cGetDescriptionResult )
Else
	//	MsgStop( 'Problemas em obter descricao do Model'  + CRLF + WSError() )
EndIf

// Obtem a estutura dos dados do Model
If oMVCWS:GetXMLData()

	If oMVCWS:GetSchema()
		cXMLEsquema := oMVCWS:cGetSchemaResult
	EndIf

	cXMLEstrut := oMVCWS:cGetXMLDataResult

	//<?xml version="1.0" encoding="UTF-8"?>
	//<COMP021M Operation="1" version="1.01">
	//	<ZA1MASTER modeltype="FIELDS" >
	//		<ZA1_FILIAL order="1"><value></value></ZA1_FILIAL>
	//		<ZA1_MUSICA order="2"><value></value></ZA1_MUSICA>
	//		<ZA1_TITULO order="3"><value></value></ZA1_TITULO>
	//		<ZA1_DATA   order="4"><value></value></ZA1_DATA>
	//		<ZA2DETAIL modeltype="GRID" >
	//			<struct>
	//				<ZA2_FILIAL order="1"></ZA2_FILIAL>
	//				<ZA2_MUSICA order="2"></ZA2_MUSICA>
	//				<ZA2_ITEM   order="3"></ZA2_ITEM>
	//				<ZA2_AUTOR  order="4"></ZA2_AUTOR>
	//			</struct>
	//			<items>
	//				<item id="1" deleted="0" >
	//					<ZA2_FILIAL></ZA2_FILIAL>
	//					<ZA2_MUSICA></ZA2_MUSICA>
	//					<ZA2_ITEM></ZA2_ITEM>
	//					<ZA2_AUTOR></ZA2_AUTOR>
	//				</item>
	//			</items>
	//		</ZA2DETAIL>
	//	</ZA1MASTER>
	//</COMP021M>

	cError := ''
	cWarning := ''

	// Cria um objeto XML a partir da estutura dos dados do Model
	// Isto é feito apenas para manipulacao de XML, pode-se usar outra
	// forma para esta manipulacao

	//CREATE oXML XMLSTRING cXMLEstrut
	oXML := XmlParser(cXMLEstrut, "_", @cError, @cWarning)

	// Seta a Operacao a ser executada
	oXML:_COMP021M:_OPERATION:TEXT := AllTrim( Str( MODEL_OPERATION_INSERT ) )

	// Preenche o objeto XML com dados
	// Para campos de valor, sempre passar zero se nao for obrigatorio
	// Para campos de data, sempre no formato AAAAMMDD
	oXML:_COMP021M:_ZA1MASTER:_ZA1_FILIAL:_VALUE:TEXT   := xFilial( 'ZA1' )
	oXML:_COMP021M:_ZA1MASTER:_ZA1_MUSICA:_VALUE:TEXT   := GEtSXeNum( 'ZA1', 'ZA1_MUSICA' )
	oXML:_COMP021M:_ZA1MASTER:_ZA1_TITULO:_VALUE:TEXT   := 'Ciranda Cirandinha 2'
	oXML:_COMP021M:_ZA1MASTER:_ZA1_DATA:_VALUE:TEXT     := '20100101'
	oXML:_COMP021M:_ZA1MASTER:_ZA1_GENERO:_VALUE:TEXT     := 'R'

	//oAux := XMLCloneNode()

	// Obtem o esquema de dados XML (XSD)
	If oMVCWS:GetSchema()
		cXMLEsquema := oMVCWS:cGetSchemaResult
	EndIf

	//XMLNode2Arr( oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM, "_ITEM")
	//XMLCloneNode( oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM, '_ITEM' )
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM:_ZA2_FILIAL:TEXT     := xFilial( 'ZA2' )
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM:_ZA2_ITEM:TEXT       := '01'
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM:_ZA2_AUTOR:TEXT      := '000002'
	//oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM:_ZA2_MUSICA:TEXT     := '000002'


	/*
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[1]:_ZA2_FILIAL:_VALUE:TEXT     := xFilial( 'ZA2' )
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[1]:_ZA2_ITEM:_VALUE:TEXT       := '01'
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[1]:_ZA2_AUTOR:_VALUE:TEXT      := '000001'
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[1]:_ZA2_MUSICA:_VALUE:TEXT     := '000001'


	// A função oXMLCloneNode clona apenas a estrutura do node,
	// as propriedades desse novo node não são clonadas e estarão vazias.
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:REALNAME                    := 'item'
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:TYPE                        := 'NOD'

	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_DELETED:REALNAME           := 'deleted'
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_DELETED:TEXT               := '0'
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_DELETED:TYPE               := 'ATT'

	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_ID:REALNAME                := 'id'
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_ID:TEXT                    := '2'
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_ID:TYPE                    := 'ATT'

	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_ZA2_FILIAL:REALNAME        := 'ZA2_FILIAL'
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_ZA2_ITEM:REALNAME          := 'ZA2_ITEM'
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_ZA2_AUTOR:REALNAME         := 'ZA2_AUTOR'
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_ZA2_MUSICA:REALNAME        := 'ZA2_MUSICA'

	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_ZA2_FILIAL:TYPE            := 'NOD'
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_ZA2_ITEM:TYPE              := 'NOD'
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_ZA2_AUTOR:TYPE             := 'NOD'
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_ZA2_MUSICA:TYPE            := 'NOD'
	*/
	/*
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_ZA2_FILIAL:_VALUE:REALNAME := 'value'
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_ZA2_ITEM:_VALUE:REALNAME   := 'value'
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_ZA2_AUTOR:_VALUE:REALNAME  := 'value'
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_ZA2_MUSICA:_VALUE:REALNAME := 'value'

	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_ZA2_FILIAL:_VALUE:TYPE     := 'NOD'
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_ZA2_ITEM:_VALUE:TYPE       := 'NOD'
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_ZA2_AUTOR:_VALUE:TYPE      := 'NOD'
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_ZA2_MUSICA:_VALUE:TYPE     := 'NOD'
	*/
	/*
	// Atribuicao dos valores
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_ZA2_FILIAL:_VALUE:TEXT     := xFilial( 'ZA2' )
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_ZA2_ITEM:_VALUE:TEXT       := '02'
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_ZA2_AUTOR:_VALUE:TEXT      := '000002'
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_ZA2_MUSICA:_VALUE:TEXT     := '000002'
	*/
	/*
	// Atribuicao dos valores
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_ZA2_FILIAL:TEXT     := xFilial( 'ZA2' )
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_ZA2_ITEM:TEXT       := '02'
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_ZA2_AUTOR:TEXT      := '000002'
	oXML:_COMP021M:_ZA1MASTER:_ZA2DETAIL:_ITEMS:_ITEM[2]:_ZA2_MUSICA:TEXT     := '000002'
	*/


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
