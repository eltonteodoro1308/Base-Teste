#Define STR001 'WebService de Teste de Divisão'
#Define STR002 'Metodo que executa divisao entre dois numeros inteiros e retorna o quociente e o resto da divisao.'

#INCLUDE 'TOTVS.CH'
#INCLUDE 'APWEBSRV.CH'

WSSERVICE TSTDIVIS DESCRIPTION STR001

	WSDATA cDividendo AS STRING
	WSDATA cDivisor   AS STRING
	WSDATA cResultDiv AS STRING

	WSMETHOD DIVISAO DESCRIPTION STR002

ENDWSSERVICE

WSMETHOD DIVISAO WSRECEIVE cDividendo,cDivisor WSSEND cResultDiv WSSERVICE TSTDIVIS

	::cResultDiv := U_TstDivs( ,,, ::cDividendo + ',' + ::cDivisor )

RETURN .T.