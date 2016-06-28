#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://spon4944:7111/ws/WSMATH.apw?WSDL
Gerado em        03/21/16 19:05:55
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _ZUVULSI ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWSMATH
------------------------------------------------------------------------------- */

WSCLIENT WSWSMATH

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD DIVISAO

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   nNDIVIDENDO               AS integer
	WSDATA   nNDIVISOR                 AS integer
	WSDATA   oWSDIVISAORESULT          AS WSMATH_RESULTDIV

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWSMATH
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20151103] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWSMATH
	::oWSDIVISAORESULT   := WSMATH_RESULTDIV():New()
Return

WSMETHOD RESET WSCLIENT WSWSMATH
	::nNDIVIDENDO        := NIL 
	::nNDIVISOR          := NIL 
	::oWSDIVISAORESULT   := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWSMATH
Local oClone := WSWSMATH():New()
	oClone:_URL          := ::_URL 
	oClone:nNDIVIDENDO   := ::nNDIVIDENDO
	oClone:nNDIVISOR     := ::nNDIVISOR
	oClone:oWSDIVISAORESULT :=  IIF(::oWSDIVISAORESULT = NIL , NIL ,::oWSDIVISAORESULT:Clone() )
Return oClone

// WSDL Method DIVISAO of Service WSWSMATH

WSMETHOD DIVISAO WSSEND nNDIVIDENDO,nNDIVISOR WSRECEIVE oWSDIVISAORESULT WSCLIENT WSWSMATH
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<DIVISAO xmlns="http://spon4944:7111/">'
cSoap += WSSoapValue("NDIVIDENDO", ::nNDIVIDENDO, nNDIVIDENDO , "integer", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("NDIVISOR", ::nNDIVISOR, nNDIVISOR , "integer", .T. , .F., 0 , NIL, .F.) 
cSoap += "</DIVISAO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon4944:7111/DIVISAO",; 
	"DOCUMENT","http://spon4944:7111/",,"1.031217",; 
	"http://spon4944:7111/ws/WSMATH.apw")

::Init()
::oWSDIVISAORESULT:SoapRecv( WSAdvValue( oXmlRet,"_DIVISAORESPONSE:_DIVISAORESULT","RESULTDIV",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure RESULTDIV

WSSTRUCT WSMATH_RESULTDIV
	WSDATA   nNQUOCIENTE               AS integer
	WSDATA   nNRESTO                   AS integer
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATH_RESULTDIV
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATH_RESULTDIV
Return

WSMETHOD CLONE WSCLIENT WSMATH_RESULTDIV
	Local oClone := WSMATH_RESULTDIV():NEW()
	oClone:nNQUOCIENTE          := ::nNQUOCIENTE
	oClone:nNRESTO              := ::nNRESTO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSMATH_RESULTDIV
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nNQUOCIENTE        :=  WSAdvValue( oResponse,"_NQUOCIENTE","integer",NIL,"Property nNQUOCIENTE as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNRESTO            :=  WSAdvValue( oResponse,"_NRESTO","integer",NIL,"Property nNRESTO as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return


