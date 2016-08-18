#Include 'Protheus.ch'

User Function IRepTst()
	
	Local aArea := SX1->( GetArea() )
	
	SX1->( DbSetOrder( 1 ) )
	
	If SX1->( DbSeek( 'IREPORT00101' ) )
		
		RecLock( 'SX1', .F. )
		
		SX1->X1_CNT01 := '05'
		
		MsUnlock()
		
		CallIReport( 'IREPORT001', {'0',1,.F.,.F.} )
		
	End If
	
	SX1->( RestArea( aArea ) )
	
Return
