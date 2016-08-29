#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://10.31.71.72/WSSenaiSE/wsIntegracaoContabil.asmx?WSDL
Gerado em        07/29/14 15:54:35
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _RNPWRWW ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSwsIntegracaoContabil
------------------------------------------------------------------------------- */

WSCLIENT WSwsIntegracaoContabil

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD BuscaDadosContabeis

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   ncodColigada              AS int
	WSDATA   nidLan                    AS int
	WSDATA   cBuscaDadosContabeisResult AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSwsIntegracaoContabil
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.121227P-20131106] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSwsIntegracaoContabil
Return

WSMETHOD RESET WSCLIENT WSwsIntegracaoContabil
	::ncodColigada       := NIL 
	::nidLan             := NIL 
	::cBuscaDadosContabeisResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSwsIntegracaoContabil
Local oClone := WSwsIntegracaoContabil():New()
	oClone:_URL          := ::_URL 
	oClone:ncodColigada  := ::ncodColigada
	oClone:nidLan        := ::nidLan
	oClone:cBuscaDadosContabeisResult := ::cBuscaDadosContabeisResult
Return oClone

// WSDL Method BuscaDadosContabeis of Service WSwsIntegracaoContabil

WSMETHOD BuscaDadosContabeis WSSEND ncodColigada,nidLan WSRECEIVE cBuscaDadosContabeisResult WSCLIENT WSwsIntegracaoContabil
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BuscaDadosContabeis xmlns="http://www.totvs.com.br/br/">'
cSoap += WSSoapValue("codColigada", ::ncodColigada, ncodColigada , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("idLan", ::nidLan, nidLan , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += "</BuscaDadosContabeis>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.totvs.com.br/br/BuscaDadosContabeis",; 
	"DOCUMENT","http://www.totvs.com.br/br/",,,; 
	"http://10.139.64.23/ContabilizacaoPorTurma/wsIntegracaoContabil.asmx?op=BuscaDadosContabeis")

::Init()
::cBuscaDadosContabeisResult :=  WSAdvValue( oXmlRet,"_BUSCADADOSCONTABEISRESPONSE:_BUSCADADOSCONTABEISRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



