#include "totvs.ch"

User Function restSample()
	Local oRestClient := FWRest():New("http://localhost:7312")
	Local aHeader := {"tenantId: 99,01"}


	// chamada da classe exemplo de REST com retorno de lista
	oRestClient:setPath("/rest/sample?startIndex=2&count=10")
	If oRestClient:Get(aHeader)
		ConOut("GET", oRestClient:GetResult())
	Else
		ConOut("GET", oRestClient:GetLastError())
	EndIf


	// chamada da classe exemplo de REST para operações CRUD
	oRestClient:setPath("/rest/sample/1")
	If oRestClient:Get(aHeader)
		ConOut("GET", oRestClient:GetResult())
	Else
		ConOut("GET", oRestClient:GetLastError())
	EndIf

	If oRestClient:Post(aHeader)
		ConOut("POST", oRestClient:GetResult())
	Else
		ConOut("POST", oRestClient:GetLastError())
	EndIf

	If oRestClient:Put(aHeader)
		ConOut("PUT", oRestClient:GetResult())
	Else
		ConOut("PUT", oRestClient:GetLastError())
	EndIf

	If oRestClient:Delete(aHeader)
		ConOut("DELETE", oRestClient:GetResult())
	Else
		ConOut("DELETE", oRestClient:GetLastError())
	EndIf
Return