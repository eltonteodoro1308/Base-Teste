#INCLUDE 'TOTVS.CH'

User Function Semaforo( aParam )

	Local nLenParam := Len( aParam )
	local nX        := 0

	VarInfo( '',aParam,,.F.,.T. )

	RpcSetEnv( aParam[ nLenParam - 3 ], aParam[ nLenParam - 2 ] )

	If LockByName( ProcName() )

		ConOut( 'Lock permitido: ' + aParam[ 1 ] )
		ConOut( FwTimeStamp( 2 ) )
		ConOut( Replicate( '-', 500 ) )

		For nX := 1 To 500000000

		Next Nx

		UnLockByName( ProcName() )

	Else

		ConOut( 'Lock não permitido: ' + aParam[ 1 ] )
		ConOut( FwTimeStamp( 2 ) )
		ConOut( Replicate( '-', 500 ) )

	End If

	RpcClearEnv()

	ConOut( FwTimeStamp( 2 ) )

	cHoraInicio := TIME() // Armazena hora de inicio do processamento.. .
	cElapsed := ElapTime( cHoraInicio, TIME() )  // Calcula a diferença de tempo

	ConOut( cElapsed )

Return