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
	
	aAdd( aEmp, '01' )
	aAdd( aTab, {'SA6','AD2','AD5','AD7','AD8','ADA','ADB','ADE','ADJ','ADK','ADL','AE1','AF1','AF2',;
<<<<<<< HEAD
		'AF3','AF5','AF7','AF8','AF9','AFC','AFG','AFN','AFR','AFS','AFT','AGH','AH9','AI8',;
		'AIC','SB2','SB5','SB6','SB7','BA0','BA3','BEA','BG9','BQC','BT5','C07','SC1','SC5',;
		'SC6','SC7','SC8','SC9','CC3','CC5','CC6','CC7','CCF','CCX','CD0','D20','CD3','CD4',;
		'CD5','CD6','CD7','CD8','CD9','CDA','CDB','CDC','CDD','CDE','CDF','CDG','CDL','CDR',;
		'CDS','CDT','CE1','CE5','CF4','CF5','CF6','CF8','CN0','CN1','CN9','CNB','CNC','CND',;
		'CNE','CNF','CNG','CNL','CNR','CNX','SCR','CS0','CT2','CT5','CTN','CTS','CV8','CVA',;
		'CVD','CVF','CVN','SD1','SD2','SD3','DA3','SDE','DT3','DUL','DY3','SE1','SE2','SE5',;
		'SEE','EE5','EE6','EE7','EE8','EE9','EEC','EEM','EEQ','EES','EET','EEU','SEF','EF1',;
		'EF3','EF7','SEH','EL0','ELA','SEU','EX9','EXL','EYJ','EYY','SF1','SF2','SF3','FIL',;
		'SFT','SI3','SJ5','SLG','SLX','SN1','SN3','SN4','SR4','RCA','SRL','SRV','TZ4','TZ5',;
		'WF7','SWN','SY0','SY9','SYB','SYD','SYQ','SYT'} )
	
	aAdd( aEmp, '02' )
	aAdd( aTab, {'SA1','SA2','CC5','SE5','SEE','SEF','SEH','SEU','SF1','SF2','SF3','SF6','SF9','SFT',;
		'SI3','SLG','SN1','SN3','SN4','SR4','SRL','TM4','TMR','SUS','WF7','SWN','SYD','SYQ',;
		'SYT','CTU'} )
	
	aAdd( aEmp, '04' )
	aAdd( aTab, {'SB2','SB6','SBM','SC1','SC6','SC7','SC9','SCR','CTB','SD1','SD2','SD3','SDE','SE1',;
		'SE2','SE4','SE5','SEE','SEF','SEH','SEU','SF1','SF2','SF3','SF6','SF7','SFT','SI3',;
		'SLG','SLX','SN1','SN3','SN4','SR4','SRL','WF4','WF7','SY9','SYD','SB1'} )
	
	aAdd( aEmp, '04' )
=======
	             'AF3','AF5','AF7','AF8','AF9','AFC','AFG','AFN','AFR','AFS','AFT','AGH','AH9','AI8',;
	             'AIC','SB2','SB5','SB6','SB7','BA0','BA3','BEA','BG9','BQC','BT5','C07','SC1','SC5',;
	             'SC6','SC7','SC8','SC9','CC3','CC5','CC6','CC7','CCF','CCX','CD0','D20','CD3','CD4',;
	             'CD5','CD6','CD7','CD8','CD9','CDA','CDB','CDC','CDD','CDE','CDF','CDG','CDL','CDR',;
	             'CDS','CDT','CE1','CE5','CF4','CF5','CF6','CF8','CN0','CN1','CN9','CNB','CNC','CND',;
	             'CNE','CNF','CNG','CNL','CNR','CNX','SCR','CS0','CT2','CT5','CTN','CTS','CV8','CVA',;
	             'CVD','CVF','CVN','SD1','SD2','SD3','DA3','SDE','DT3','DUL','DY3','SE1','SE2','SE5',;
	             'SEE','EE5','EE6','EE7','EE8','EE9','EEC','EEM','EEQ','EES','EET','EEU','SEF','EF1',;
	             'EF3','EF7','SEH','EL0','ELA','SEU','EX9','EXL','EYJ','EYY','SF1','SF2','SF3','FIL',;
	             'SFT','SI3','SJ5','SLG','SLX','SN1','SN3','SN4','SR4','RCA','SRL','SRV','TZ4','TZ5',;
	             'WF7','SWN','SY0','SY9','SYB','SYD','SYQ','SYT'} )

	aAdd( aEmp, '02' )	             
	aAdd( aTab, {'SA1','SA2','CC5','SE5','SEE','SEF','SEH','SEU','SF1','SF2','SF3','SF6','SF9','SFT',;
	             'SI3','SLG','SN1','SN3','SN4','SR4','SRL','TM4','TMR','SUS','WF7','SWN','SYD','SYQ',;
	             'SYT','CTU'} )

        aAdd( aEmp, '04' )	             
	aAdd( aTab, {'SB2','SB6','SBM','SC1','SC6','SC7','SC9','SCR','CTB','SD1','SD2','SD3','SDE','SE1',;
                     'SE2','SE4','SE5','SEE','SEF','SEH','SEU','SF1','SF2','SF3','SF6','SF7','SFT','SI3',;
                     'SLG','SLX','SN1','SN3','SN4','SR4','SRL','WF4','WF7','SY9','SYD','SB1'} )
                     
        aAdd( aEmp, '04' )	             
>>>>>>> a2fb6343eb2d3ad35c8efb24a4914cf228377464
	aAdd( aTab, {'SA1'} )
	
	aAdd( aEmp, '09' )
	aAdd( aTab, {'CC5','CC7','CF2','CF8','CTB','SD3','SFA','SA1'} )
<<<<<<< HEAD
	
	aAdd( aEmp, '10' )
	aAdd( aTab, {'CC5','CC7','CF2','CF8','CTB','SD3','SE2','SBI'} )
	
	aAdd( aEmp, '11' )
	aAdd( aTab, {'SC7','SC8','SC9','SCR','CTB','SD1','SD2','SD3','SD5','SD7','SD8','SDA','SDB','SDE',;
		'SDH','SDS','SDT','SE1','SE2','SE3','SE4','SE5','SE6','SE7','SED','SEE','SEF','SEH',;
		'SEU','SEZ','SF1','SF2','SF3','SF5','SF6','SF7','SF8','SFB','SFC','SFP','SFT','SFU',;
		'SFX','SM2','SN1','SN3','SN4','SNJ','SNM','SNQ','SNR','SNS','SNX','SR4','SRA','SRC',;
		'SRD','SRL','SRV','ST1','ST6','ST9','TBB','STC','TCD','STG','STJ','STL','TMY','TNN',;
		'TNQ','TO0','STP','TP1','TP2','TPG','TPP','TQF','STS','TS1','STT','SU5','SUS','WF4',;
		'WF7','SWN','SYA'} )
	
	aAdd( aEmp, '12' )
	aAdd( aTab, {'CTB'} )
	
	aAdd( aEmp, '16' )
	aAdd( aTab, {'SB2','SC7','SCR','SD1','SE2','SE5','SEF','SF1','SF3','SFT','SYA'} )
	
	aAdd( aEmp, '19' )
	aAdd( aTab, {'CC5'} )
	
	aAdd( aEmp, '25' )
	aAdd( aTab, {'SC7','SC9','SCR','SD1','SD2','SDE','SE1','SE2','SE5','SEF','SEH','SF1','SF2','SF3',;
		'SFT','SI3','SLX','SN1','SN3','SN4','SR4','SRL','SY0','SYD','SYQ'} )
	
	aAdd( aEmp, '26' )
	aAdd( aTab, {'SA1','CTB'} )
	
	aAdd( aEmp, '27' )
	aAdd( aTab, {'SA1','SA2'} )
	
	
	
=======

	aAdd( aEmp, '10' )
	aAdd( aTab, {'CC5','CC7','CF2','CF8','CTB','SD3','SE2','SBI'} )

	aAdd( aEmp, '11' )
	aAdd( aTab, {'SC7','SC8','SC9','SCR','CTB','SD1','SD2','SD3','SD5','SD7','SD8','SDA','SDB','SDE',;
                     'SDH','SDS','SDT','SE1','SE2','SE3','SE4','SE5','SE6','SE7','SED','SEE','SEF','SEH',;
                     'SEU','SEZ','SF1','SF2','SF3','SF5','SF6','SF7','SF8','SFB','SFC','SFP','SFT','SFU',;
                     'SFX','SM2','SN1','SN3','SN4','SNJ','SNM','SNQ','SNR','SNS','SNX','SR4','SRA','SRC',;
                     'SRD','SRL','SRV','ST1','ST6','ST9','TBB','STC','TCD','STG','STJ','STL','TMY','TNN',;
                     'TNQ','TO0','STP','TP1','TP2','TPG','TPP','TQF','STS','TS1','STT','SU5','SUS','WF4',;
                     'WF7','SWN','SYA'} )
                     
        aAdd( aEmp, '12' )	             
	aAdd( aTab, {'CTB'} )
	
        aAdd( aEmp, '16' )	             
	aAdd( aTab, {'SB2','SC7','SCR','SD1','SE2','SE5','SEF','SF1','SF3','SFT','SYA'} )
	
	aAdd( aEmp, '19' )	             
	aAdd( aTab, {'CC5'} )
	
	aAdd( aEmp, '25' )	             
	aAdd( aTab, {'SC7','SC9','SCR','SD1','SD2','SDE','SE1','SE2','SE5','SEF','SEH','SF1','SF2','SF3',;
	             'SFT','SI3','SLX','SN1','SN3','SN4','SR4','SRL','SY0','SYD','SYQ'} )
	             
	aAdd( aEmp, '26' )	             
	aAdd( aTab, {'SA1','CTB'} )


>>>>>>> a2fb6343eb2d3ad35c8efb24a4914cf228377464
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
