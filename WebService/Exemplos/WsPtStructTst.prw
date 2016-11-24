#include 'protheus.ch'
#include 'parmtype.ch'

user function WsPtStructTst()

	Local oWs     := WSWSPTSTRUCT():NEW()
	Local oMsgRec := WSPTSTRUCT_MENSAGENSREC():NEW()

	oMsgRec:cCMENSAGEM1 := 'MSG1'
	oMsgRec:cCMENSAGEM2 := 'MSG2'

	If oWs:PTSTRUCT( oMsgRec )

		ConOut( oWs:oWSPTSTRUCTRESULT:cCIMPRIME1 )
		ConOut( oWs:oWSPTSTRUCTRESULT:cCIMPRIME2 )

	Else

		ConOut( GetWSCError() )

	End If

return