#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://spon4944:7112/ws/TSTDIVIS.apw?WSDL
Gerado em        04/17/17 12:01:46
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _RNNDPWR ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSTSTDIVIS
------------------------------------------------------------------------------- */

WSCLIENT WSTSTDIVIS

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD DIVISAO

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCDIVIDENDO               AS string
	WSDATA   cCDIVISOR                 AS string
	WSDATA   cDIVISAORESULT            AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSTSTDIVIS
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20170323 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSTSTDIVIS
Return

WSMETHOD RESET WSCLIENT WSTSTDIVIS
	::cCDIVIDENDO        := NIL 
	::cCDIVISOR          := NIL 
	::cDIVISAORESULT     := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSTSTDIVIS
Local oClone := WSTSTDIVIS():New()
	oClone:_URL          := ::_URL 
	oClone:cCDIVIDENDO   := ::cCDIVIDENDO
	oClone:cCDIVISOR     := ::cCDIVISOR
	oClone:cDIVISAORESULT := ::cDIVISAORESULT
Return oClone

// WSDL Method DIVISAO of Service WSTSTDIVIS

WSMETHOD DIVISAO WSSEND cCDIVIDENDO,cCDIVISOR WSRECEIVE cDIVISAORESULT WSCLIENT WSTSTDIVIS
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<DIVISAO xmlns="http://spon4944:7112/">'
cSoap += WSSoapValue("CDIVIDENDO", ::cCDIVIDENDO, cCDIVIDENDO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CDIVISOR", ::cCDIVISOR, cCDIVISOR , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</DIVISAO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon4944:7112/DIVISAO",; 
	"DOCUMENT","http://spon4944:7112/",,"1.031217",; 
	"http://spon4944:7112/ws/TSTDIVIS.apw")

::Init()
::cDIVISAORESULT     :=  WSAdvValue( oXmlRet,"_DIVISAORESPONSE:_DIVISAORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



