#Include 'Protheus.ch'

User Function X3UPDTBL()
	
	Private oProcess := MsNewProcess():New( { || Processa() }, "Atualizando", "Aguarde, atualizando ...", .F. )
	
	oProcess:Activate()
	
Return

Static Function Processa()
	
	Local aEmp     := {}
	Local aTab     := {}
	Local nX       := 0
	Local nY       := 0
	Local nHandle  := 0
	Local cLog     := ''
	Local cMask    := 'Arquivos Texto' + '(*.TXT)|*.txt|'
	Local oDlg     := Nil
	Local oFont    := Nil
	Local oMemo    := Nil
	
	aAdd( aEmp, '99' )
	aAdd( aTab, {'SC1','SC2','SC3','SC4','SC5','SC6','ZZZ'} )
	
	aAdd( aEmp, '99' )
	aAdd( aTab, {'SC1','SC2','SC3','SC4','SC5','SC6','ZZZ'} )
	
	
	oProcess:SetRegua1( Len( aEmp ) )
	
	oProcess:SetRegua2( Len( aTab ) )
	
	For nX := 1 To Len( aEmp )
		
		oProcess:IncRegua1( 'Atualizando Empresa ' + aEmp[ nX ] )
		
		If .Not. RpcSetEnv( aEmp[ nX ] )
			
			RpcSetType(3)
			
			AutoGrLog( 'Não foi possível conectar na empresa ' + aEmp[ nX ] )
			
		Else
			
			AutoGrLog( 'Empresa ' + aEmp[ nX ] + ' conectada.' )
			
			For nY := 1 To Len( aTab[ nX ] )
				
				oProcess:IncRegua2( 'Atualizando Tabela ' + aTab[ nX, nY ] )
				
				X31UpdTable( aTab[ nX, nY ] )
				
				If __GetX31Error()
					
					AutoGrLog( 'Erro na atualização da Tabela ' + aTab[ nX, nY ] )
					
				Else
					
					AutoGrLog( 'Tabela ' + aTab[ nX, nY ] + ' atualizada.' )
					
				End If
				
			Next nY
			
			RpcClearEnv()
			
			AutoGrLog( 'Empresa ' + aEmp[ nX ] + ' desconectada.' )
			
		End If
		
	Next nX
	
	nHandle := fOpen( NomeAutoLog() )
	
	cLog :=  fReadStr( nHandle, 1048000 )
	
	Define Font oFont Name "Mono AS" Size 5, 12
	
	Define MsDialog oDlg Title "Atualização concluida." From 3, 0 to 340, 417 Pixel
	
	@ 5, 5 Get oMemo Var cLog Memo Size 200, 145 Of oDlg Pixel
	oMemo:bRClicked := { || AllwaysTrue() }
	oMemo:oFont     := oFont
	
	Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
	Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
		MemoWrite( cFile, cLog ) ) ) Enable Of oDlg Pixel
	
	Activate MsDialog oDlg Center
	
	
Return

