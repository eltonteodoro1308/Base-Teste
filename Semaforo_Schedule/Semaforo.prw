#INCLUDE 'TOTVS.CH'

User Function Semaforo( /*aParam*/ )

Local cRet := ''

//VarInfo( 'Val( GetGlbValue( "Semaforo" ) )', Val( GetGlbValue( 'Semaforo' ) ),,.F.,.T. )
//VarInfo( 'Val( GetGlbValue( "Semaforo" ) ) # 0', Val( GetGlbValue( 'Semaforo' ) ) # 0,,.F.,.T. )

If Val( GetGlbValue( 'Semaforo' ) ) == 0

	ConOut( ProcName() + ': Iniciada ' + Time() )

	PutGlbValue ( 'Semaforo', '1' )

	Sleep( 1000 * 60 * 2 )

	PutGlbValue ( 'Semaforo', '0' )

	ConOut( ProcName() + ': Finalizada ' + Time() )

Else

		ConOut( ProcName() + ': Em Execução ' + Time() )

End If

Return cRet


//	Local nLenParam := Len( aParam )
//	local nX        := 0
//
//	VarInfo( '',aParam,,.F.,.T. )
//
//	RpcSetEnv( aParam[ nLenParam - 3 ], aParam[ nLenParam - 2 ] )
//
//	If LockByName( ProcName() )
//
//		ConOut( 'Lock permitido: ' + aParam[ 1 ] )
//		ConOut( FwTimeStamp( 2 ) )
//		ConOut( Replicate( '-', 500 ) )
//
//		For nX := 1 To 500000000
//
//		Next Nx
//
//		UnLockByName( ProcName() )
//
//	Else
//
//		ConOut( 'Lock não permitido: ' + aParam[ 1 ] )
//		ConOut( FwTimeStamp( 2 ) )
//		ConOut( Replicate( '-', 500 ) )
//
//	End If
//
//	RpcClearEnv()
//
//	ConOut( FwTimeStamp( 2 ) )
//
//	cHoraInicio := TIME() // Armazena hora de inicio do processamento.. .
//	cElapsed := ElapTime( cHoraInicio, TIME() )  // Calcula a diferença de tempo
//
//	ConOut( cElapsed )
//
//Return