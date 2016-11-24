#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://spon4944:7112/ws/WSPTSTRUCT.apw?WSDL
Gerado em        11/23/16 18:38:51
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _LOPSVLZ ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWSPTSTRUCT
------------------------------------------------------------------------------- */

WSCLIENT WSWSPTSTRUCT

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD PTSTRUCT

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSOMSGREC                AS WSPTSTRUCT_MENSAGENSREC
	WSDATA   oWSPTSTRUCTRESULT         AS WSPTSTRUCT_MENSAGENSREQ

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSMENSAGENSREC           AS WSPTSTRUCT_MENSAGENSREC

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWSPTSTRUCT
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20160707 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWSPTSTRUCT
	::oWSOMSGREC         := WSPTSTRUCT_MENSAGENSREC():New()
	::oWSPTSTRUCTRESULT  := WSPTSTRUCT_MENSAGENSREQ():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSMENSAGENSREC    := ::oWSOMSGREC
Return

WSMETHOD RESET WSCLIENT WSWSPTSTRUCT
	::oWSOMSGREC         := NIL 
	::oWSPTSTRUCTRESULT  := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSMENSAGENSREC    := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWSPTSTRUCT
Local oClone := WSWSPTSTRUCT():New()
	oClone:_URL          := ::_URL 
	oClone:oWSOMSGREC    :=  IIF(::oWSOMSGREC = NIL , NIL ,::oWSOMSGREC:Clone() )
	oClone:oWSPTSTRUCTRESULT :=  IIF(::oWSPTSTRUCTRESULT = NIL , NIL ,::oWSPTSTRUCTRESULT:Clone() )

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSMENSAGENSREC := oClone:oWSOMSGREC
Return oClone

// WSDL Method PTSTRUCT of Service WSWSPTSTRUCT

WSMETHOD PTSTRUCT WSSEND oWSOMSGREC WSRECEIVE oWSPTSTRUCTRESULT WSCLIENT WSWSPTSTRUCT
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PTSTRUCT xmlns="http://spon4944:7112/">'
cSoap += WSSoapValue("OMSGREC", ::oWSOMSGREC, oWSOMSGREC , "MENSAGENSREC", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</PTSTRUCT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon4944:7112/PTSTRUCT",; 
	"DOCUMENT","http://spon4944:7112/",,"1.031217",; 
	"http://spon4944:7112/ws/WSPTSTRUCT.apw")

::Init()
::oWSPTSTRUCTRESULT:SoapRecv( WSAdvValue( oXmlRet,"_PTSTRUCTRESPONSE:_PTSTRUCTRESULT","MENSAGENSREQ",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure MENSAGENSREC

WSSTRUCT WSPTSTRUCT_MENSAGENSREC
	WSDATA   cCMENSAGEM1               AS string
	WSDATA   cCMENSAGEM2               AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSPTSTRUCT_MENSAGENSREC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSPTSTRUCT_MENSAGENSREC
Return

WSMETHOD CLONE WSCLIENT WSPTSTRUCT_MENSAGENSREC
	Local oClone := WSPTSTRUCT_MENSAGENSREC():NEW()
	oClone:cCMENSAGEM1          := ::cCMENSAGEM1
	oClone:cCMENSAGEM2          := ::cCMENSAGEM2
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSPTSTRUCT_MENSAGENSREC
	Local cSoap := ""
	cSoap += WSSoapValue("CMENSAGEM1", ::cCMENSAGEM1, ::cCMENSAGEM1 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CMENSAGEM2", ::cCMENSAGEM2, ::cCMENSAGEM2 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure MENSAGENSREQ

WSSTRUCT WSPTSTRUCT_MENSAGENSREQ
	WSDATA   cCIMPRIME1                AS string
	WSDATA   cCIMPRIME2                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSPTSTRUCT_MENSAGENSREQ
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSPTSTRUCT_MENSAGENSREQ
Return

WSMETHOD CLONE WSCLIENT WSPTSTRUCT_MENSAGENSREQ
	Local oClone := WSPTSTRUCT_MENSAGENSREQ():NEW()
	oClone:cCIMPRIME1           := ::cCIMPRIME1
	oClone:cCIMPRIME2           := ::cCIMPRIME2
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSPTSTRUCT_MENSAGENSREQ
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCIMPRIME1         :=  WSAdvValue( oResponse,"_CIMPRIME1","string",NIL,"Property cCIMPRIME1 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCIMPRIME2         :=  WSAdvValue( oResponse,"_CIMPRIME2","string",NIL,"Property cCIMPRIME2 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


