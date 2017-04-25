/*O código abaixo representa o arquivo "upload.PRW", 
que contém as funções escritas em ADVPL ASP.*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

User Function UPFILE()

	Local nH := FOpen( httpPost->txtFile, 0 + 64 )

	Private LengthFile := 0

	LengthFile := fSeek( nH, 0, FS_END )

	MemoWrite( '/xml' + httpPost->txtFile , MemoRead( httpPost->txtFile ) ) 

Return h_MS01()