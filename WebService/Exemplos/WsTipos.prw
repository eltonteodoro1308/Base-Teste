#INCLUDE 'TOTVS.CH'
#INCLUDE 'APWEBSRV.CH'

WSSTRUCT TIPOSRETORNO
	
	WSDATA String  AS STRING
	WSDATA Date    AS DATE
	WSDATA Integer AS INTEGER
	WSDATA Float   AS FLOAT
	WSDATA Boolean AS BOOLEAN
	WSDATA Base64  AS BASE64BINARY
	
ENDWSSTRUCT

WSSERVICE WSTIPOS DESCRIPTION 'Imprime os Tipos de Dados'
	
	WSDATA cString  AS STRING
	WSDATA dDate    AS DATE
	WSDATA nInteger AS INTEGER
	WSDATA nFloat   AS FLOAT
	WSDATA lBoolean AS BOOLEAN
	WSDATA cBase64  AS STRING
	
	WSDATA oRetorno AS TIPOSRETORNO
	
	WSMETHOD IMPRIMETIPOS DESCRIPTION 'Retorna os Tipos de Dados'
	
ENDWSSERVICE

WSMETHOD IMPRIMETIPOS WSRECEIVE cString,dDate,nInteger,nFloat,lBoolean,cBase64 WSSEND oRetorno WSSERVICE WSTIPOS
	
	oRetorno:String  := cString
	oRetorno:Date	 := dDate
	oRetorno:Integer := nInteger
	oRetorno:Float	 := nFloat
	oRetorno:Boolean := lBoolean
	oRetorno:Base64  := cBase64
	
RETURN .T.
