#include 'protheus.ch'
#include 'parmtype.ch'

user function MyAviso()

	Local cTitulo := 'T�tulo'
	Local cMsg    := 'Mensagem'
	Local aBotoes := { 'Bot�o 1', 'Bot�o 2', 'Bot�o 3' }
	Local cText   := 'Texto'

	ApMsgInfo( 'Selecioonado o ' + aBotoes[ Aviso ( cTitulo, cMsg, aBotoes, 3, /*cText*/ ) ] )

return