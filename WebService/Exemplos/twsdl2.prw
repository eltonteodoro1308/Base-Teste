#include 'protheus.ch'
#include 'parmtype.ch'

user function twsdl2()

	Local oWsdl    := TWsdlManager():New()
	Local aParents := {}

	ConOut( oWsdl:ParseUrl( 'http://spon4944:7112/ws/WSPTARRAY.apw?WSDL' ) )
	ConOut( oWsdl:SetOperation( 'PTARRAY' ) )

	VarInfo( 'oWsdl:NextComplex()', oWsdl:NextComplex(),,.F.,.T. )

return