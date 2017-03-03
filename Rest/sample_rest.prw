#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

WSRESTFUL sample DESCRIPTION "Exemplo de serviço REST"

WSDATA count      AS INTEGER
WSDATA startIndex AS INTEGER

WSMETHOD GET DESCRIPTION "Exemplo de retorno de entidade(s)" WSSYNTAX "/sample || /sample/{id}"
WSMETHOD POST DESCRIPTION "Exemplo de inclusao de entidade" WSSYNTAX "/sample/{id}"
WSMETHOD PUT DESCRIPTION "Exemplo de alteração de entidade" WSSYNTAX "/sample/{id}"
WSMETHOD DELETE DESCRIPTION "Exemplo de exclusão de entidade" WSSYNTAX "/sample/{id}"

END WSRESTFUL

// O metodo GET nao precisa necessariamente receber parametros de querystring, por exemplo:
// WSMETHOD GET WSSERVICE sample
WSMETHOD GET WSRECEIVE startIndex, count WSSERVICE sample
	Local i

	// define o tipo de retorno do método
	::SetContentType("application/json")

	// verifica se recebeu parametro pela URL
	// exemplo: http://localhost:8080/sample/1
	If Len(::aURLParms) > 0

		// insira aqui o código para pesquisa do parametro recebido

		// exemplo de retorno de um objeto JSON
		::SetResponse('{"id":' + ::aURLParms[1] + ', "name":"sample"}')

	Else
		// as propriedades da classe receberão os valores enviados por querystring
		// exemplo: http://localhost:8080/sample?startIndex=1&count=10
		DEFAULT ::startIndex := 1, ::count := 5

		// exemplo de retorno de uma lista de objetos JSON
		::SetResponse('[')
		For i := ::startIndex To ::count + 1
			If i > ::startIndex
				::SetResponse(',')
			EndIf
			::SetResponse('{"id":' + Str(i) + ', "name":"sample"}')
		Next
		::SetResponse(']')
	EndIf
Return .T.

// O metodo POST pode receber parametros por querystring, por exemplo:
// WSMETHOD POST WSRECEIVE startIndex, count WSSERVICE sample
WSMETHOD POST WSSERVICE sample
	Local lPost := .T.
	Local cBody
	// Exemplo de retorno de erro
	If Len(::aURLParms) == 0
		SetRestFault(400, "id parameter is mandatory")
		lPost := .F.
	Else
		// recupera o body da requisição
		cBody := ::GetContent()
		// insira aqui o código para operação inserção
		// exemplo de retorno de um objeto JSON
		::SetResponse('{"id":' + ::aURLParms[1] + ', "name":"sample"}')
	EndIf
Return lPost

// O metodo PUT pode receber parametros por querystring, por exemplo:
// WSMETHOD PUT WSRECEIVE startIndex, count WSSERVICE sample
WSMETHOD PUT WSSERVICE sample
	Local lPut := .T.

	// Exemplo de retorno de erro
	If Len(::aURLParms) == 0
		SetRestFault(400, "id parameter is mandatory")
		lPut := .F.
	Else
		// recupera o body da requisição
		cBody := ::GetContent()
		// insira aqui o código para operação de atualização
		// exemplo de retorno de um objeto JSON
		::SetResponse('{"id":' + ::aURLParms[1] + ', "name":"sample"}')
	EndIf
Return lPut

// O metodo DELETE pode receber parametros por querystring, por exemplo:
// WSMETHOD DELETE WSRECEIVE startIndex, count WSSERVICE sample
WSMETHOD DELETE WSSERVICE sample
	Local lDelete := .T.

	VarInfo( ':', SELF,,.F.,.T. )

	// Exemplo de retorno de erro
	If Len(::aURLParms) == 0
		SetRestFault(400, "id parameter is mandatory")
		lDelete := .F.

	Else
		// insira aqui o código para operação exclusão
		// exemplo de retorno de um objeto JSON
		::SetResponse('{"id":' + ::aURLParms[1] + ', "name":"sample"}')
	EndIf
Return lDelete