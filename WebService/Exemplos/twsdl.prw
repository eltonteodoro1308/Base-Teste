#include 'totvs.ch'

user function twsdl()

	Local oWsdl    := TWsdlManager():New()
	Local aParents := {}

	oWsdl:ParseUrl( 'http://spon4944:7112/ws/WSPTSTRUCT.apw?WSDL' )
	oWsdl:SetOperation( 'PTSTRUCT' )

	aAdd( aParents, 'PTSTRUCT#1' )
	aAdd( aParents, 'OMSGREC#1' )

	oWsdl:SetValPar( 'CMENSAGEM1', aParents, 'TOTVS' )
	oWsdl:SetValPar( 'CMENSAGEM2', aParents, 'S/A' )

	oWsdl:SendSoapMsg()

	ConOut( oWsdl:GetSoapMsg() )

	ConOut( oWsdl:GetSoapResponse() )

return