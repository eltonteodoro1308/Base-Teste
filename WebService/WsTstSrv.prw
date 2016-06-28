#Define STR001 'WebService de Teste'
#Define STR002 'Metodo que executa divisao entre dois numeros inteiros e retorna o quociente e o resto da divisao.'
#Include 'PROTHEUS.CH'
#Include 'TOTVS.CH'
#INCLUDE 'APWEBSRV.CH'

WSSTRUCT RESULTDIV
	
	WSDATA nQuociente AS INTEGER
	WSDATA nResto     AS INTEGER
	
ENDWSSTRUCT

WSSERVICE WSMATH DESCRIPTION STR001
	
	WSDATA nDividendo AS INTEGER
	WSDATA nDivisor   AS INTEGER
	WSDATA oResultDiv AS RESULTDIV
	
	WSMETHOD DIVISAO DESCRIPTION STR002
	
ENDWSSERVICE

WSMETHOD DIVISAO WSRECEIVE nDividendo,nDivisor WSSEND oResultDiv WSSERVICE WSMATH
	
	If	::nDivisor	==	0
		
		SetSoapFault( 'Argumento Invalido', 'O Divisor deve ser diferente de zero.' )
		
		Return .F.
		
	End If
	
	::oResultDiv::nQuociente := Int( ::nDividendo / ::nDivisor )
	::oResultDiv::nResto     := Mod( ::nDividendo, ::nDivisor )
	
RETURN .T.
