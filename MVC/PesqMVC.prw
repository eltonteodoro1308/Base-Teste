#Include 'Protheus.ch'

User Function PesqMV
	
	Local oModel := FWLoadModel( 'PCPA104' )
	
Return

User Function PCPA104()
	
	Local aParam   := PARAMIXB
	Local oObj     := aParam[ 1 ]
	Local cIdPonto := aParam[ 2 ]
	Local cIdModel := aParam[ 3 ]
	Local xRet     := .T.
	
	If cIdPonto == 'BUTTONBAR'
		
		xRet := { {'Salvar', 'SALVAR', { || MyAlert( 'Salvou' ) }, 'Este botão Salva' } }
		
	End If
	
Return xRet


Static Function MyAlert( cMsg)
	
	Alert( cMsg )
	
Return
