#include 'totvs.ch'

user function TstJson()

	Local oPessoa   := JsonObject():New()
	Local oEndereco := JsonObject():New()

	oPessoa['NOME']       := 'Elton Teodoro Alves'
	oPessoa['IDADE']      := 43
	oPessoa['NASCIMENTO'] := StoD( '19750813' )
	oPessoa['CASADO']     := .T.
	oPessoa['ENDERECO']   := oEndereco
	oPessoa['LISTA']      := {oEndereco,oEndereco}

	oEndereco['LOGRADOURO']      := 'Rua'
	oEndereco['NOME LOGRADOURO'] := 'Phobus'
	oEndereco['NUMERO']          := 281

return


