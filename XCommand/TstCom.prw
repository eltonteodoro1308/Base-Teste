#INCLUDE 'MYINCLUDE.CH'
#INCLUDE 'TOTVS.CH'

user function TstCom()

	MYEXECUTA 1
	MYEXECUTA 1 "OLÁ ....."

	MYEXECUTA 2
	MYEXECUTA 2 "OLÁ1 .....", "OLÁ2 ....."

	MYEXECUTA 3 NOME
	MYEXECUTA 3 IDADE
	MYEXECUTA 3 ENDERECO
	MYEXECUTA 3

	MYEXECUTA 4 OPTIONAL
	MYEXECUTA 4

	MYEXECUTA 5 1,'ABC',.T.,{||.T.},Date(),Nil,MpFormModel():New('MODEL')

	MYEXECUTA 6 Alert('Oi')

	MYEXECUTA 7
	
	MYEXECUTA 8 A,B,C,D,E,F
	
	MYEXECUTA 9 XXX

return

Static Function Executa1( cStr )

	Default cStr := 'Sem Param'

	ConOut( cStr )

Return 

Static Function Executa2( cStr1, cStr2)

	Default cStr1 := 'Sem Param 1'
	Default cStr2 := 'Sem Param 2'

	ConOut( cStr1 )
	ConOut( cStr2 )

Return

Static Function Executa3(cDesc)

	Default cDesc := 'Sem Desc'

	ConOut( cDesc )

Return

Static Function Executa4( lOptional )

	VarInfo( 'lOptional', lOptional,,.F.,.T.)

Return

Static Function Executa5( aArr )

	VarInfo( 'aArr', aArr,,.F.,.T.)

Return

Static Function Executa6( bBlk )

	VarInfo( 'bBlk', bBlk,,.F.,.T.)
	ConOut( GetCBSource( bBlk ) )

Return

Static Function Executa7( cStr )

	Default cStr := 'Sem Param'

	ConOut( cStr )

Return

Static Function Executa8( aArr )

	VarInfo( 'aArr', aArr,,.F.,.T.)

Return

Static Function Executa9( cStr )

	Default cStr := 'Sem Param'

	ConOut( cStr )

Return 