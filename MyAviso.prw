#include 'protheus.ch'
#include 'parmtype.ch'

user function MyAviso()

	Local cTitulo := 'Título'
	Local cMsg    := 'Mensagem'
	Local aBotoes := { 'Botão 1', 'Botão 2', 'Botão 3' }
	Local cText   := 'Texto'

	ApMsgInfo( 'Selecioonado o ' + aBotoes[ Aviso ( cTitulo, cMsg, aBotoes, 3, /*cText*/ ) ] )

return