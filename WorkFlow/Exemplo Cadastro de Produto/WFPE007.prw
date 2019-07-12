#include 'totvs.ch'

User Function WFPE007()

	Local cHTML       := ''
	Local plSuccess   := ParamIXB[1]
	Local pcMessage   := ParamIXB[2]
	Local pcProcessID := ParamIXB[3]

	VarInfo( 'PARAMIXB', PARAMIXB,, .T., .T. )

	If ( plSuccess )

		// Mensagem em formato HTML para sucesso no processamento.

		cHTML += 'Processamento executado com sucesso!'
		cHTML += '<br>'

		cHTML += pcMessage

	Else

		//Mensagem em formato HTML para falha no processamento.

		cHTML += 'Falha no processamento!'

		cHTML += '<br>'
		cHTML += pcMessage

	EndIf

Return cHTML