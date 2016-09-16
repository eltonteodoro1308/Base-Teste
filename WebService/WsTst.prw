#include 'totvs.ch'

user function WsTst()

	Local oWsTst := WSWSMATH():New()

	If oWsTst:Divisao( 233, 51 )

		ConOut( CvalToChar( oWsTst:oWSDIVISAORESULT:nNQUOCIENTE ) )
		ConOut( CvalToChar( oWsTst:oWSDIVISAORESULT:nNRESTO     ) )

	Else

		ConOut( GetWSCError() )

	End IF

return