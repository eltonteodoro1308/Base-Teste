#INCLUDE 'TOTVS.CH'
#include 'protheus.ch'
#include 'parmtype.ch'


User Function WSGETCEP()

	Local _cURL        := 'https://viacep.com.br/ws/18120000/xml/'
	//            Local _cURL        := 'https://viacep.com.br/ws/'+_cCEP+'/json/'
	Local cRet                           := ""
	Local oXML                        := Nil
	Local cError        := ""
	Local cWarning := ""
	Local _cCEP                        := "18120000"

	Local oRestClient := FWRest():New("https://viacep.com.br/ws/18120000/xml/")
	//Local oRestClient := FWRest():New("http://sfmobile.prefeitura.sp.gov.br/api/Cadin/GetDebitosCadin?tipoDocumento=cpf&numDocumento=12635538859")
	//Local oRestClient := FWRest():New("http://cep.republicavirtual.com.br/web_cep.php?cep=02219090&formato=xml")
	//Local oRestClient := FWRest():New("https://preproducao.roadcard.com.br/sistemapamcard/services/WSPamcard?wsdl")
	oRestClient:setPath("")

	//VarInfo( 'ClassDataArr', ClassDataArr( oRestClient, .F. ),,.F.,.T.)


	//VarInfo( 'ClassMethArr', ClassMethArr( oRestClient, .F. ),,.F.,.T.)

	If oRestClient:Get()
		cRet := oRestClient:GetResult()
	Else
		cRet := oRestClient:GetLastError()
	Endif

	MsgInfo(cRet)
Return cRet

user function GetSSL01()
	Local cURL := "https://viacep.com.br/"
	Local aHeadOut := {}
	Local cHeadRet := ""
	Local cGetRet := ""

	AAdd( aHeadOut, 'User-Agent: Mozilla/4.0 (compatible; Protheus ' + GetBuild() + ')' )
	cGetRet := HTTPSGet( cURL, "", "", "", "WSDL", 120, aHeadOut, @cHeadRet )
	if Empty( cGetRet )
		conout( "Fail HTTPSGet" )
	else
		conout( "OK HTTPSGet" )
		varinfo( "WebPage", cGetRet )
	endif

	varinfo( "Header", cHeadRet )
return