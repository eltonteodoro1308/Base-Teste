#include "rwmake.ch"       
#include "Topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"

                                                                            
User Function PC_99()
	Local _nEmp
	Private _aMatriz  := {"99","01"}  // para abrir a 1a empresa //
	Private _aEmpresa := {}  
	RpcSetType(3)
	RpcSetEnv(_aMatriz[1],_aMatriz[2])
	DBSelectArea("SM0")
	DBSetOrder(1)
	DBSeek(_aMatriz[1],.F.)
	
	U_CONSOLE('Montando array de empresas - PC() /' + _aMatriz[1] )
	
	Aadd(_aEmpresa, {SM0->M0_CODIGO,Alltrim(SM0->M0_CODFIL)})  

	RpcClearEnv()

    For _nEmp := 1 To Len(_aEmpresa)   
		U_PC({_aEmpresa[_nEmp]})  		
    Next 
	U_CONSOLE('Final do processamento - PC() ' )
   	Return
 
User Function PC_TRC()
	Local _nEmp
	Private _aMatriz  := {"01","01001"}  // para abrir a 1a empresa //
	Private _aEmpresa := {}  
	RpcSetType(3)
	RpcSetEnv(_aMatriz[1],_aMatriz[2])

	IF !LockByName("PC_TRC")
		Conout("JOB de aprovação de PC já estava em execução: Finalizado em " + DTOC(dDATABASE) + " - " + TIME() )
		RpcClearEnv()	// Limpa o ambiente, liberando a licença e fechando as conexões
    	RETURN
    ENDIF

	DBSelectArea("SM0")
	DBSetOrder(1)
	DBSeek(_aMatriz[1],.F.)
	
	U_CONSOLE('Montando array de empresas - PC() /' + _aMatriz[1] )
	
	WHILE !SM0->(EOF())     
		if SM0->M0_CODIGO <> _aMatriz[1]
			Exit
		Endif	
		Aadd(_aEmpresa, {SM0->M0_CODIGO,Alltrim(SM0->M0_CODFIL)})  
		SM0->(DBSkip())
	END
	RpcClearEnv()

	U_CONSOLE("["+DtoC(Date())+" "+Time()+"]: Processando U_PC() " )

    For _nEmp := 1 To Len(_aEmpresa)   
		U_PC({_aEmpresa[_nEmp]})  		
    Next 
	U_CONSOLE("["+DtoC(Date())+" "+Time()+"]: Final do processamento - PC() " )
   	Return
   	
/*                                                           
Prepara ambiente - Empresa / Filial
*/
User Function PC( aParam )
	If aParam == Nil .OR. VALTYPE(aParam) == "U"
		U_CONSOLE("Parametros nao recebidos => PC()")
		RETURN
	EndIf
	RpcSetType(3)
	RpcSetEnv(aParam[1][1],aParam[1][2])
	U_CONSOLE('PC(aParam):' + aParam[1][1]   +'/'+ aParam[1][2])
	U_WKFPC(1)  		// 1 - ENVIO PC PARA APROVADORES
	U_WKFPC(3)  		// 3 - ENVIO PC ITENS APROVADOS PARA COMPRADOR
	U_WKFPC(4)  		// 4 - ENVIO PC ITENS REPROVADOS PARA COMPRADOR
	RpcClearEnv()
	RETURN
		
User Function WKFPC(_nOpc, oProcess)      
	Local _lProcesso := .F.
	Local _cFilial, _cChaveSCR
	
	Local _cAprov    	:= "" , cObs 		:= ""
	Local nTotal    	:= 0 , 	cGrupo	 	:= "" , lLiberou	:= .F.
	Local i, j, _cItem
	Private _aReturn
			
	Private _aWF 	:= {}   
	Private _aSC7   := {}
	Private _aSCR   := {}
	
	DO 	CASE 
	
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³1 - Prepara os pedidos a serem enviados para aprovacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	
		CASE _nOpc == 1
	
			U_CONSOLE("1 - Prepara os pedidos a serem enviados para aprovacao")
			U_CONSOLE("1 - EmpFil:" + cEmpAnt + cFilAnt)
		  	_cQuery := ""
		  	_cQuery += " SELECT"
		  	_cQuery += " CR_FILIAL," 
		  	_cQuery += " CR_TIPO,"   
		  	_cQuery += " CR_NUM,"
		  	_cQuery += " CR_NIVEL," 
		  	_cQuery += " CR_TOTAL," 
		  	_cQuery += " CR_USER,"   
		  	_cQuery += " CR_APROV,"   
		  	_cQuery += " CR_DTLIMIT,"
		  	_cQuery += " CR_HRLIMIT"
		  	_cQuery += " FROM " + RetSqlName("SCR") + " SCR"
		  	_cQuery += " WHERE "
		  	_cQuery += "     CR_FILIAL = '" + xFilial("SCR") + "'"
		  	_cQuery += " AND (CR_TIPO = 'PC' OR CR_TIPO = 'AE' )" 
		  	_cQuery += " AND CR_STATUS = '02'"  						// Em aprovacao
		  	_cQuery += " AND CR_DTLIMIT  <= '" + DTOS(MSDATE()) + "'"	// Data Limite
		  	_cQuery += " AND CR_WF = ' '"
		  	_cQuery += " AND SCR.D_E_L_E_T_ = ' '"
		  	_cQuery += " ORDER BY"
		  	_cQuery += " CR_FILIAL," 
		  	_cQuery += " CR_NUM,"
		  	_cQuery += " CR_NIVEL,"
		  	_cQuery += " CR_USER"
		  	
			TcQuery _cQuery New Alias "TMP"
		
			dbGotop()    
			_aSCR   := {}
			
			While !TMP->(Eof())
				_cFilial   := TMP->CR_FILIAL
				_cTipo     := TMP->CR_TIPO
				_cNumPC    := TMP->CR_NUM
				_cAprov    := TMP->CR_USER
	
				Aadd(_aSCR, {_cFilial,_cTipo,_cNumPC,_cAprov})
	
				TMP->(DBSkip())           
			End
	
			dbSelectArea("TMP")
			dbCloseArea()

			If Len(_aSCR) > 0
				For i := 1 to Len(_aSCR)
					DBSelectarea("SCR")
					DBSetOrder(2)
					DBSeek(_aSCR[i][1]+_aSCR[i][2]+_aSCR[i][3]+_aSCR[i][4])

					DBSelectArea("SC7")
					DBSetOrder(1)
					DBSeek(xFilial("SC7")+Substr(_aSCR[i][3],1,6))

					IF EMPTY(SC7->C7_APROV)
						DBSelectarea("SCR")
						DBSetOrder(2)
						IF DBSeek(_aSCR[i][1]+_aSCR[i][2]+_aSCR[i][3]+_aSCR[i][4])
							Reclock("SCR",.F.)
							SCR->CR_WF			:= "1" 		 // Status 1 - envio para aprovadores / branco-nao houve envio
				  			SCR->CR_WFID		:= "N/D"	 // Rastreabilidade
							MSUnlock()
						ENDIF	
					ELSE 	                 
//						_nRecnoSCR := SCR->(Recno())
						_aWF	 		:= U_EnviaPC(SCR->CR_FILIAL, SCR->CR_NUM, SCR->CR_USER , SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER) , SCR->CR_TOTAL, SCR->CR_DTLIMIT, SCR->CR_HRLIMIT, _nOpc)
						If Len(_aWF) > 0 
							_lProcesso 	:= .T.
							DBSelectarea("SCR")
							DBSetOrder(2)
							If SCR->(DBSeek(_aSCR[i][1]+_aSCR[i][2]+_aSCR[i][3]+_aSCR[i][4]))
								Reclock("SCR",.F.)
								SCR->CR_WF			:= IIF(EMPTY(_aWF[1])," ","1")  	// Status 1 - envio para aprovadores / branco-nao houve envio
				  				SCR->CR_WFID		:= _aWF[1]		// Rastreabilidade
								SCR->CR_DTLIMIT		:= _aWF[2]		// Data Limite
								SCR->CR_HRLIMIT		:= _aWF[3]		// Hora Limite
								MSUnlock()     
							Endif
						Endif			
					ENDIF
				Next i
			End
			
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³2 - Processa O RETORNO DO EMAIL                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
		CASE _nOPC	== 2
	
			U_CONSOLE("2 - Processa O RETORNO DO EMAIL")
			U_CONSOLE("2 - EmpFil:" + cEmpAnt + cFilAnt)

			U_CONSOLE("2 - Semaforo Vermelho" )
			nWFPC2 		:= U_Semaforo("WFPC2")

//			cFilAnt		:= padr(alltrim(oProcess:oHtml:RetByName("CFILANT")),2)
			__cChaveSCR	:= oProcess:oHtml:RetByName("CHAVE")
			_cAprov    	:= alltrim(oProcess:oHtml:RetByName("CR_USER"))
			_cChaveSCR	:= Padr(__cChaveSCR,60)+_cAprov
			cOpc     	:= alltrim(oProcess:oHtml:RetByName("OPC"))
			cObs     	:= alltrim(oProcess:oHtml:RetByName("OBS"))
			cWFID     	:= alltrim(oProcess:oHtml:RetByName("WFID"))

			oProcess:Finish() // FINALIZA O PROCESSO
			
			U_CONSOLE("2 - cFilAnt    :" + cFilAnt)
			U_CONSOLE("2 - __cChaveSCR:" + __cChaveSCR)
			U_CONSOLE("2 - Opc        :" + cOpc)
			U_CONSOLE("2 - Obs        :" + cObs)
			U_CONSOLE("2 - WFId       :" + cWFID)
			U_CONSOLE("2 - _cAprov    :" + _cAprov)
//			U_CONSOLE("2 - _cChaveSCR :" + _cChaveSCR)

			IF cOpc $ "S|N"  // Aprovacao S-Sim N-Nao
				// Posiciona na tabela de Alcadas 
				DBSelectArea("SCR")
				DBSetOrder(2)
				DBSeek(__cChaveSCR)  // BR153301PC000014                                      000000
				IF !FOUND()  
					U_CONSOLE("2 - Processo nao encontrado : Not Found")
					U_CONSOLE("2 - Semaforo Verde" )
					U_Semaforo(nWFPC2)
					Return .T.
				Endif
				If ALLTRIM(SCR->CR_WFID) <> ALLTRIM(cWFID)
					U_CONSOLE("2 - Processo nao encontrado :" + cWFID + " Processo atual :" + SCR->CR_WFID)
					U_CONSOLE("2 - Semaforo Verde" )
					U_Semaforo(nWFPC2)
					Return .T.
				ENDIF
				
				Reclock("SCR",.F.)
				SCR->CR_WF		:= "2"			// Status 2 - respondido
				MSUnlock()
				
				If !Empty(SCR->CR_DATALIB) .And. SCR->CR_STATUS$"03#04#05"
					U_CONSOLE("2 - Processo ja respondido via sistema :" + cWFID)
					U_CONSOLE("2 - Semaforo Verde" )
					U_Semaforo(nWFPC2)             
					U_CONSOLE("2 - 1" )
					Return .T.
				EndIf

				// Verifica se o pedido de compra esta aprovado
				// Se estiver, finaliza o processo
				dbSelectArea("SC7")
				dbSetOrder(1)
				SC7->(dbSeek(xFilial("SC7")+LEFT(SCR->CR_NUM,6)))

				IF SC7->C7_CONAPRO <> "B"  // NAO ESTIVER BLOQUEADO
					U_CONSOLE("2C - Processo ja respondido via sistema :" + cWFID)
					U_CONSOLE("2C - Semaforo Verde" )
					U_Semaforo(nWFPC2)
					U_CONSOLE("2 - 2" )
					Return .T.
				ENDIF

				// REPosiciona na tabela de Alcadas 
				DBSelectArea("SCR")
				DBSetOrder(2)
				DBSeek(__cChaveSCR)
				
				// verifica quanto a saldo de alçada para aprovação				
				// Se valor do pedido estiver dentro do limite Maximo e minimo 
				// Do aprovador , utiliza o controle de saldos, caso contrário nao
				// faz o tratamento como vistador.

				nTotal := SCR->CR_TOTAL
				
				lLiberou := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,nTotal,SCR->CR_APROV,,SC7->C7_APROV,,,,,cObs},msdate(),If(cOpc=="S",4,6))
				
				U_CONSOLE("2 - Liberado :" + IIF(lLiberou, "Sim", "Nao"))

				_lProcesso := .T.
				
				If lLiberou
					dbSelectArea("SC7")
					dbSetOrder(1)
					dbSeek(xFilial("SC7")+LEFT(SCR->CR_NUM,6))
			        While !Eof() .And. SC7->C7_FILIAL+SC7->C7_NUM == SCR->CR_FILIAL+LEFT(SCR->CR_NUM,6)
		                Reclock("SC7",.F.)
		                SC7->C7_CONAPRO 	:= "L"
		                MsUnlock()
		                dbSkip()
			        EndDo
				EndIf
			EndIf				

			U_CONSOLE("2 - Semaforo Verde" )
			U_Semaforo(nWFPC2)

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³3 - Envia resposta de pedido aprovado para o comprador³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	
		CASE _nOpc == 3
			U_CONSOLE("3 - Envia resposta de pedido APROVADO para o comprador")
			U_CONSOLE("3 - EmpFil:" + cEmpAnt + cFilAnt)
		  	_cQuery := ""
		  	_cQuery += " SELECT DISTINCT "
		  	_cQuery += " C7_FILIAL," 
		  	_cQuery += " C7_NUM,"
		  	_cQuery += " C7_TIPO,"   
		  	_cQuery += " C7_USER"   
		  	_cQuery += " FROM " + RetSqlName("SC7") + " SC7"
		  	_cQuery += " WHERE SC7.D_E_L_E_T_ <> '*'"
		  	_cQuery += " AND C7_FILIAL   = '" + xFilial("SC7") + "'"
			_cQuery += " AND (C7_TIPO=1 OR C7_TIPO=2)  "		// 1-Pedido de compra ou autorizacao de entrega
			_cQuery += " AND C7_CONAPRO='L' "				// Liberado
			_cQuery += " AND C7_APROV <> '      ' "			// Grupo Aprovador
		  	_cQuery += " AND C7_WF <> '1'"	      			// 1 Enviado EMAIL
		  	_cQuery += " ORDER BY"
		  	_cQuery += " C7_FILIAL," 
		  	_cQuery += " C7_NUM"
			TcQuery _cQuery New Alias "TMP"

			dbGotop()
			_aSCR   := {}
			
			While !TMP->(Eof())
				_cFilial    := TMP->C7_FILIAL
				_cTipoDoc   := Iif(TMP->C7_TIPO = 1,"PC","AE")
				_cNum    	:= TMP->C7_NUM   
				_cUser 		:= TMP->C7_USER
				Aadd(_aSCR, {_cFilial,_cTipoDoc,_cNum, _cUser})
				TMP->(DBSkip())           
			End

			dbSelectArea("TMP")
			dbCloseArea()

			If Len(_aSCR) > 0
				For i := 1 to Len(_aSCR)
					DBSelectarea("SCR")
					DBSetOrder(1)
					DBSeek(_aSCR[i][1]+_aSCR[i][2]+_aSCR[i][3],.T.)
					_lAchou  := .F.
					_lAprov	:= .F.
					_cChave	:= ''
					_nTotal	:= 0
					While !SCR->(EOF()) 					.AND. ;
	    		   	SCR->CR_FILIAL		== _aSCR[i][1]  	.AND. ;
	      			SCR->CR_TIPO 	    == _aSCR[i][2]		.AND. ;
	        		SCR->CR_NUM         == Padr(_aSCR[i][3],50)
		        		IF SCR->CR_STATUS == '03' .AND. !EMPTY(SCR->CR_LIBAPRO)   // SOMENTE CASO APROVADO
    	    				_cChave	:= SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER)
        					_lAprov	:= .T.
							_lAchou  := .T.        				
        					_nTotal	:= SCR->CR_TOTAL
        				ENDIF
		        		SCR->(DBSkip())
						IF !_lAchou
							DBSelectarea("SC7")
							DBSetOrder(1)
							IF DBSeek(_aSCR[i][1]+_aSCR[i][3])
								While C7_FILIAL == _aSCR[i][1] .AND. C7_NUM == _aSCR[i][3] .and. !SC7->(Eof())
									Reclock("SC7",.F.)
									SC7->C7_WF			:= "1"   	                        // Status 1 - envio email
					  				SC7->C7_WFID		:= "N/D"   									// Rastreabilidade
									MSUnlock()
									SC7->(DbSkip())                       
								Enddo
							ENDIF
						ENDIF
	
			    		IF _lAprov
							_aWF:= U_EnviaPC(_aSCR[i][1], _aSCR[i][3], _aSCR[i][4] , _cChave, _nTotal, ctod('  /  /  '), '     ',_nOpc)
							If Len(_aWF) > 0 
								_lProcesso 	:= .T.
		
								DBSelectarea("SC7")
								DBSetOrder(1)
								IF DBSeek(_aSCR[i][1]+_aSCR[i][3])
									While C7_FILIAL == _aSCR[i][1] .AND. C7_NUM == _aSCR[i][3] .and. !SC7->(Eof())
		//								U_CONSOLE("EnvPCFor - While SC7" )						
										Reclock("SC7",.F.)
										SC7->C7_WF			:= IIF(EMPTY(_aWF[1]), " ", "1")   	// Status 1 - envio email / branco -nao enviado
							  			SC7->C7_WFID		:= _aWF[1]							// Rastreabilidade
										MSUnlock() 
										SC7->(DbSkip())
									Enddo	
								ENDIF
							END
						ENDIF
					Enddo
				Next i
			END

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³4 - Envia resposta de pedido bloqueado para o comprador³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
		CASE _nOpc == 4
	
			U_CONSOLE("4 - Envia resposta de pedido bloqueado para o comprador")
			U_CONSOLE("4 - EmpFil:" + cEmpAnt + cFilAnt)
			
		  	_cQuery := ""
		  	_cQuery += " SELECT"
		  	_cQuery += " CR_FILIAL," 
		  	_cQuery += " CR_TIPO,"   
		  	_cQuery += " CR_NUM,"    
		  	_cQuery += " CR_NIVEL," 
		  	_cQuery += " CR_TOTAL," 
		  	_cQuery += " CR_USER,"   
		  	_cQuery += " CR_APROV"    
		  	
		  	_cQuery += " FROM " + RetSqlName("SCR") + " SCR"
		  	_cQuery += " WHERE SCR.D_E_L_E_T_ <> '*'"
		  	_cQuery += " AND CR_FILIAL = '" + xFilial("SCR") + "'"
		  	_cQuery += " AND CR_LIBAPRO <> '      '" 							// Seleciona o Aprovador que reprovou
		  	_cQuery += " AND CR_STATUS = '04'"                          // REPROVADO
		  	_cQuery += " AND (CR_TIPO = 'PC' OR CR_TIPO = 'AE')"                            // PEDIDO DE COMPRA
		  	_cQuery += " AND CR_WF <> '1'"	      					    	// 1-Enviado
//		  	_cQuery += " AND CR_NUM = '012135'"
		  	
		  	_cQuery += " ORDER BY"
		  	_cQuery += " CR_FILIAL," 
		  	_cQuery += " CR_NUM,"
		  	_cQuery += " CR_NIVEL,"
		  	_cQuery += " CR_USER"
		  	
			TcQuery _cQuery New Alias "TMP"
		                            
			dbGotop()
			_aSCR   := {}

			While !TMP->(Eof())
				_cFilial   := TMP->CR_FILIAL
				_cTipo     := TMP->CR_TIPO
				_cNumPC    := TMP->CR_NUM
				_cAprov    := TMP->CR_USER
	
				Aadd(_aSCR, {_cFilial,_cTipo,_cNumPC,_cAprov})
	
				TMP->(DBSkip())           
			End
	
			dbSelectArea("TMP")
			dbCloseArea()

			If Len(_aSCR) > 0
				For i := 1 to Len(_aSCR)
					DBSelectarea("SCR")
					DBSetOrder(2)
					DBSeek(_aSCR[i][1]+_aSCR[i][2]+_aSCR[i][3]+_aSCR[i][4])

					DBSelectArea("SC7")
					DBSetOrder(1)
					DBSeek(xFilial("SC7")+Substr(_aSCR[i][3],1,6))
	
					IF EMPTY(SC7->C7_APROV)
						DBSelectarea("SCR")
						DBSetOrder(2)
						IF DBSeek(_aSCR[i][1]+_aSCR[i][2]+_aSCR[i][3]+_aSCR[i][4])
							Reclock("SCR",.F.)
							SCR->CR_WF			:= "1" 		 	// Status 1 - envio para aprovadores / branco-nao houve envio
				  			SCR->CR_WFID		:= "N/D"		   // Rastreabilidade
							MSUnlock()
						ENDIF	
					ELSE 				
	
						_aWF	 		:= U_EnviaPC(SCR->CR_FILIAL, SCR->CR_NUM, SC7->C7_USER , SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_APROV) , SCR->CR_TOTAL, ctod('  /  /  '), '     ', _nOpc)
		
						DBSelectarea("SCR")
						DBSetOrder(2)
						If SCR->(DBSeek(_aSCR[i][1]+_aSCR[i][2]+_aSCR[i][3]+_aSCR[i][4]))
							Reclock("SCR",.F.)
							SCR->CR_WF			:= IIF(EMPTY(_aWF[1])," ","1")  	// Status 1 - envio para aprovadores / branco-nao houve envio
				  			SCR->CR_WFID		:= _aWF[1]							// Rastreabilidade
							MSUnlock()
						ENDIF
					ENDIF		
					_lProcesso := .T.
				Next i								
			End
			
	END CASE			
	
	IF 	_lProcesso 
		U_CONSOLE(" Mensagem processada " )
	ELSE
		U_CONSOLE(" Nao houve processamento")
	ENDIF	
					
	RETURN
	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EnviaPC   ºAutor  ³Microsiga           º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER Function EnviaPC(_cFilial,_cNum, _cUser, _cChave, _nTotal, _dDTLimit, _cHRLimit, _nOpc)
//	Local _cHttp		:= GetNewPar("MV_WFDHTTP", "http://189.20.203.131:9898")

	Local _cTo	   		:= IIF(_nOpc == 1, _cUser , UsrRetMail(_cUser))
	Local _cEmail		:= UsrRetMail(_cUser)
	Local _nDD   	  	:= GetNewPar("ES_WFTODD", 0)		// TimeOut - Dias
	Local _cTimeOut		:= GetNewPar("ES_WFTOPC","24:00")
	Local _dDataLib		:= IIF( !EMPTY(_dDTLimit), _dDTLimit, MSDATE() )
	Local _cHoraLib		:= IIF( !EMPTY(_cHRLimit), _cHRLimit, LEFT(TIME(),5) )
	Local _nTimeOut  	:= (_nDD * 24) + VAL(LEFT(_cTimeOut,2)) + (VAL(RIGHT(_cTimeOut,2))/60) 
	Local _nVrSC		:= 0
    Local _cUnidReq		:= ""  
    Local _aAreaSM0		:= {}

	Local _nVALMERC		:= 0
	Local _nVALIPI		:= 0
	Local _nFRETE		:= 0
	Local _nSEGURO		:= 0
	Local _nDESCONTO	:= 0   
	Local _nDESPESA		:= 0   	
	Local _nVALTOT		:= 0
	Local _lCotacao 	:= .F.
    Local _cTipoDoc		:= ''
   	Local _lRateio 		:= .F.
	Local j

	_aTimeOut	:= U_GetTimeOut(_nTimeOut,_dDATALIB,_cHoraLib)
	Private _aPedidos:= {}       

	//------------------- VALIDACAO
	_lError := .F.

	DbSelectArea("SC7")

	if Empty(_cTo)
		aMsg := {}
		cTitle  := "Administrador do Workflow : NOTIFICACAO" 
		aADD(aMsg , REPLICATE('*',80) )
		aADD(aMsg , Dtoc(MSDate()) + " - " + Time() + ' * Ocorreu um ERRO no envio da mensagem :' )
		aADD(aMsg , "Pedido de Compra No: " + _cNum + " Filial : " + cFilAnt + " Usuario : " + UsrRetName(_cUser) )
		aADD(aMsg , "Campo EMAIL do cadastro de usuario NAO PREENCHIDO" )
		aADD(aMsg , REPLICATE('*',80) )
		
		_lError := .T.
	Endif
                  
	IF _lError
		U_NotifyAdm(cTitle, aMsg)
		_aReturn := {}
		AADD(_aReturn, "")
		AADD(_aReturn, _aTimeOut[1])
		AADD(_aReturn, _aTimeOut[2])
		
		RETURN _aReturn
	ENDIF

	// ----- FIM DA VALIDACAO
              
//	_cChaveSCR	:= PADR(_cFilial + 'PC' + _cNum,60)
	_cChaveSCR	:= PADR(Substr(_cChave,1,13),60)
	_cNum 		:= PADR(ALLTRIM(_cNum),6)

	DBSelectArea("SCR")
	DBSetOrder(2)
	DBSeek(_cChave)

	DBSelectArea("SM0")
	DBSetOrder(1)
	DBSeek(cEmpAnt+cFilAnt)
	
	DBSelectArea("SC7")
	DBSetOrder(1)
	DBSeek(_cFilial+_cNum)

    DBSELECTAREA("SC3")
	DBSetOrder(1)
	DBSeek(SC7->(C7_FILIAL+C7_NUMSC+C7_ITEMSC))     

	DBSelectArea("SA2")
	DBSetOrder(1)
	DBSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA)
	_cFornece := SC7->C7_FORNECE
	_cLojaFor := SC7->C7_LOJA

	DBSelectArea("SE4")
	DBSetOrder(1)
	DBSeek(xFilial("SE4")+SC7->C7_COND)

	DBSelectArea("SAL")
	DBSetOrder(3)
	DBSeek(xFilial("SAL")+SC7->C7_APROV+SCR->CR_APROV)

	_cVersao := ""
	DBSelectArea("SCY")
	DBSetOrder(1)
	DBSeek(_cFilial+_cNum) 
	
	While SCY->CY_FILIAL + SCY->CY_NUM == _cFilial+_cNum .AND. !SCY->(EOF())
		_cVersao := Alltrim(SCY->CY_VERSAO)
		SCY->(DbSkip())
	Enddo

	_cTipoDoc	:= Iif(SC7->C7_TIPO = 1,"PC","AE")
	
	DO CASE 
	//-------------------------------------------------------- INICIO PROCESSO WORKFLOW
		CASE _nOpc == 1		// Envio de email para aprovacao
				oProcess          	:= TWFProcess():New( "000001", "Envio Aprovacao PC :" + _cFilial + "/" +  TRIM(_cNum) )
				oProcess:NewTask( "Envio PC : "+_cFilial + _cNum, "\WORKFLOW\HTML\PCAPROV_Modelo.HTM" )
				oProcess:bReturn  	:= "U_WKFPC(2)"
		
		CASE _nOpc == 3		// Envio de email Aprovacao para solicitante
				oProcess          	:= TWFProcess():New( "000003", "Envio p/comprador PC aprovado : " + _cFilial + "/" +  TRIM(_cNum) )
				oProcess          	:NewTask( "Envio PC aprovado : "+_cFilial + _cNum, "\WORKFLOW\HTML\PCRESP_Modelo.HTM" )
				_cResposta			:= " A P R O V A D O "
			
		CASE _nOpc == 4		// Envio de email Reprovado para solicitante
				oProcess          	:= TWFProcess():New( "000004", "Envio p/comprador PC reprovado : " + _cFilial + "/" +  TRIM(_cNum) )
				oProcess          	:NewTask( "Envio PC reprovado : "+_cFilial + _cNum, "\WORKFLOW\HTML\PCRESP_Modelo.HTM" )
				_cResposta			:= "<font color='#FF0000'>R E P R O V A D O </font>"
	
	ENDCASE

	oProcess:cTo      	:= _cTo
	oProcess:UserSiga	:= _cUser
 	oHtml     				:= oProcess:oHTML

	IF _nOpc == 1
		oHtml:ValByName( "CFILANT"	   , xFilial("SCR"))
		oHtml:ValByName( "CHAVE"	   , _cChave)
		oHtml:ValByName( "WFID"		   , oProcess:fProcessId)
		oHtml:ValByName( "OBS"		   , "" )
	ENDIF

	IF _nOpc == 3 .OR. _nOpc == 4
		oHtml:ValByName( "resposta"  	, _cResposta)	 
	ENDIF
   
	//Cabecalho
	oHtml:ValByName( "C7_FILIAL"	, SM0->M0_FILIAL )
	oHtml:ValByName( "C7_TIPO"		, Iif(_cTipoDoc == "PC","Pedido de compra","Autorização de entrega") )    
	oHtml:ValByName( "C7_NUM"		, SC7->C7_NUM )    
	oHtml:ValByName( "C7_EMISSAO"	, DTOC(SC7->C7_EMISSAO) )
	oHtml:ValByName( "C7_USER"		, UsrFullName(SC7->C7_USER))
	oHtml:ValByName( "A2_NOME"		, SA2->A2_NOME + " " + SA2->A2_COD)
	oHtml:ValByName( "A2_EMAIL"		, SA2->A2_EMAIL)
	oHtml:ValByName( "E4_DESCRI"    , SE4->E4_DESCRI)

	DBSelectArea("SM0")
	DBSetOrder(1)
	DBSeek(cEmpAnt+SC7->C7_FILENT)
	
	// Dados local entrega
	//oHtml:ValByName( "E_NOME"		, SM0->M0_NOMECOM)
	//oHtml:ValByName( "E_CNPJ"	  	, Transform(SM0->M0_CGC,PesqPict("SA2","A2_CGC")))
	//oHtml:ValByName( "E_ENDER" 		, Alltrim(SM0->M0_ENDENT) + " - " + Alltrim(SM0->M0_CIDENT)  + " - " + Alltrim(SM0->M0_ESTENT) + " - CEP: "+SM0->M0_CEPCOB )


	//-------------------------------------------------------------
	// ALIMENTA A TELA DE ITENS DO PEDIDO DE COMPRA
	//-------------------------------------------------------------
	
	While !SC7->(EOF()) .AND. SC7->C7_FILIAL == _cFilial .AND. SC7->C7_NUM == _cNum

        DBSELECTAREA("SB1")
		DBSetOrder(1)
		DBSeek(xFilial("SB1")+SC7->C7_PRODUTO)
		
        DBSELECTAREA("SC1")
		DBSetOrder(1)
		DBSeek(SC7->(C7_FILIAL+C7_NUMSC+C7_ITEMSC)) 
		
        DBSELECTAREA("SC3")
		DBSetOrder(1)
		DBSeek(SC7->(C7_FILIAL+C7_NUMSC+C7_ITEMSC))     
		    
		
		AAdd( (oHtml:ValByName( "t.1" )), SC7->C7_ITEM)
		AAdd( (oHtml:ValByName( "t.2" )), SC7->C7_PRODUTO)
		AAdd( (oHtml:ValByName( "t.3" )), Alltrim(SB1->B1_DESC) + Iif(!Empty(SC7->C7_OBS )     ," - Obs: "  + Alltrim(SC7->C7_OBS),"") )
		AAdd( (oHtml:ValByName( "t.4"  )), SB1->B1_UM)
		AAdd( (oHtml:ValByName( "t.5"  )), Alltrim(TRANSFORM(SC7->C7_QUANT ,'@E 9,999,999,999.99')))
		AAdd( (oHtml:ValByName( "t.6"  )), Alltrim(TRANSFORM(SC7->C7_PRECO ,'@E 9,999,999,999.99')))  
		AAdd( (oHtml:ValByName( "t.7"  )), Alltrim(TRANSFORM(SC7->C7_IPI   ,'@E 99.99')))
		AAdd( (oHtml:ValByName( "t.8"  )), Alltrim(TRANSFORM(SC7->C7_TOTAL+SC7->C7_VALIPI ,'@E 9,999,999,999,999.99')))
		AAdd( (oHtml:ValByName( "t.9"  )), SC7->C7_DATPRF)
		AAdd( (oHtml:ValByName( "t.10" )), Alltrim(TRANSFORM(SB1->B1_UPRC  ,'@E 9,999,999,999.99' )))

		_nVALMERC		:= _nVALMERC +  SC7->C7_TOTAL
		_nVALIPI		:= _nVALIPI  +  SC7->C7_VALIPI
		_nFRETE			:= _nFRETE   +  SC7->C7_VALFRE
		_nSEGURO		:= _nSEGURO  +  SC7->C7_SEGURO
		_nDESPESA		:= _nDESPESA +  SC7->C7_DESPESA  
		_nDESCONTO		:= _nDESCONTO+  SC7->C7_VLDESC  
		_nVALTOT		:= _nVALMERC  + (_nVALIPI + _nFRETE + _nSEGURO + _nDESPESA - _nDESCONTO)
	
		Aadd(_aPedidos,{SC7->C7_ITEM, SC7->C7_PRODUTO} )

		SC7->(dbSkip()) 
	Enddo

	oHtml:ValByName( "C7_VALMERC"	, Alltrim(TRANSFORM(_nValmerc 			,'@E 9,999,999,999,999.99')))
	oHtml:ValByName( "C7_VALBRU"    , Alltrim(TRANSFORM(_nValmerc+_nVALIPI 	,'@E 9,999,999,999,999.99')))
	oHtml:ValByName( "FRETE"	    , Alltrim(TRANSFORM(_nFRETE 			,'@E 9,999,999,999,999.99')))
	oHtml:ValByName( "SEGURO"   	, Alltrim(TRANSFORM(_nSeguro 			,'@E 9,999,999,999,999.99')))
	oHtml:ValByName( "DESPESA"   	, Alltrim(TRANSFORM(_nDespesa  			,'@E 9,999,999,999,999.99')))
	oHtml:ValByName( "DESCONTO" 	, Alltrim(TRANSFORM(_nDesconto			,'@E 9,999,999,999,999.99')))
	oHtml:ValByName( "VALTOT"		, Alltrim(TRANSFORM(_nVALTOT			,'@E 9,999,999,999,999.99')))


	If _nOpc == 1
//  	Imprimir as cotacoes para este item 
	    _aSC8 := {}
		_cSelCot := "SELECT * FROM "+RetSqlName('SC7')+" SC7, "+RetSqlName('SC8')+" SC8"
		_cSelCot += " WHERE SC7.C7_FILIAL = '"+xFilial("SC7")+"' "
		_cSelCot += " AND SC8.C8_FILIAL   = '"+xFilial("SC8")+"' "
	    _cSelCot += " AND SC7.C7_NUM = '"+_cNum+"' "
	    _cSelCot += " AND SC7.C7_NUMCOT = SC8.C8_NUM"
	    _cSelCot += " AND SC7.C7_PRODUTO = SC8.C8_PRODUTO"
	    _cSelCot += " AND SC7.C7_NUMSC   = SC8.C8_NUMSC"
	    _cSelCot += " AND SC7.C7_ITEMSC  = SC8.C8_ITEMSC"    
		_cSelCot += " AND SC7.D_E_L_E_T_ = ' '" 
	    _cSelCot += " AND SC8.D_E_L_E_T_ = ' '"
		_cSelCot += " ORDER BY SC7.C7_ITEM, SC7.C7_PRODUTO"
		_cSelCot := ChangeQuery(_cSelCot)
		TCQUERY _cSelCot NEW ALIAS "C7C8"
		TCSETFIELD("C7C8","C8_PRECO"  ,"N",14,4)
		TCSETFIELD("C7C8","C8_VALIPI"  ,"N",14,2)
		DBSELECTAREA("C7C8")
		dbGoTop()
		
		While !Eof()
			DbSelectArea('SA2')
			DbSeek( xFilial('SA2')+C7C8->(C8_FORNECE+C8_LOJA) )
			DBSelectArea("SE4")
			DBSetOrder(1)
			DBSeek(xFilial("SE4")+C7C8->C8_COND)

		    Aadd( _aSC8, {C7C8->C7_ITEM, ;
		    			SA2->A2_NOME        , ;
		    			DtoC(StoD(C7C8->C8_DATPRF)) , ;
		    			SE4->E4_DESCRI        , ;
		    			C7C8->C8_CONTATO      , ;
		    			TRANSFORM(C7C8->C8_QUANT,'@E 999,999.99'), ;
		    			TRANSFORM(C7C8->C8_PRECO,'@E 999,999.99')  , ;
		    			C7C8->C8_NUMPED       , ;
		    			TRANSFORM(C7C8->C8_ALIIPI ,'@E 99.99')     , ;
		    			TRANSFORM((C7C8->C8_PRECO + (C7C8->C8_PRECO * C7C8->C8_ALIIPI / 100)) * C7C8->C8_QUANT,  '@E 999,999.99'),;
		    		    C7C8->C8_NUM, ;
		    		    C7C8->C8_ITEM, ;
		    		    C7C8->C8_PRODUTO,;
		    		    C7C8->C8_FORNECE, ;
		    		    C7C8->C8_LOJA;		    			  
		    			   } )
			_lCotacao := .t.
			DbSelectArea('C7C8')
			DbSkip()	
		EndDo
//		dbSelectArea("C7C8")
//		dbCloseArea("C7C8") 
		dbCloseArea() 
	    dbSelectArea("SC8")	
		// Deve-se tambem testar se houve cotacao para o pedido:
		If !_lCotacao
			// #FF0000
	 		_cExibe  := "<p><font color='#FF0000'>*** Nao foi gerada concorrencia para este pedido ***</font></p>"
			AAdd( (oHtml:ValByName( "tc.1"  )), "" )
			AAdd( (oHtml:ValByName( "tc.2"  )), "" )
			AAdd( (oHtml:ValByName( "tc.3"  )), "" )
			AAdd( (oHtml:ValByName( "tc.4"  )), "" )
			AAdd( (oHtml:ValByName( "tc.5"  )), "" ) 
			AAdd( (oHtml:ValByName( "tc.6"  )), "" )
			AAdd( (oHtml:ValByName( "tc.7"  )), "" )
			AAdd( (oHtml:ValByName( "tc.9"  )), "" )
			AAdd( (oHtml:ValByName( "tc.10" )), "" )
//			AAdd( (oHtml:ValByName( "tc.11"  )), "" )
			
		Else	
		    Asort(_aSC8,,, { |x,y| x[1]+x[7] < y[1]+y[7] } )
	   		_cItem := ""
		    For j := 1 To Len(_aSC8)   
		        If Alltrim((_aSC8[j][7])) <> "0,00"
			        If _aSC8[j][8] # "XXXXXX" // Cotacao XXXXXX = Perdedora
						_cExibe1 := "<p><font color='#0000FF'>"+_aSC8[j][1]+"</font></p>"
						_cExibe2 := "<p><font color='#0000FF'>"+_aSC8[j][2]+"</font></p>"
						_cExibe3 := "<p><font color='#0000FF'>"+_aSC8[j][3]+"</font></p>"
						_cExibe4 := "<p><font color='#0000FF'>"+_aSC8[j][4]+"</font></p>"
						_cExibe5 := "<p><font color='#0000FF'>"+_aSC8[j][5]+"</font></p>"
						_cExibe6 := "<p><font color='#0000FF'>"+_aSC8[j][6]+"</font></p>"
						_cExibe7 := "<p><font color='#0000FF'>"+_aSC8[j][7]+"</font></p>"
						_cExibe9 := "<p><font color='#0000FF'>"+_aSC8[j][9]+"</font></p>"
		 				_cExibe10:= "<p><font color='#0000FF'>"+_aSC8[j][10]+"</font></p>"
//		 				_cExibe11:= "<p><font color='#0000FF'>"+_aSC8[j][16]+"</font></p>"
						AAdd( (oHtml:ValByName( "tc.1" )), Iif(_cItem = _aSC8[j][1],"",_cExibe1) )
						AAdd( (oHtml:ValByName( "tc.2" )), _cExibe2 )
						AAdd( (oHtml:ValByName( "tc.3" )), _cExibe3 )
						AAdd( (oHtml:ValByName( "tc.4" )), _cExibe4 )
						AAdd( (oHtml:ValByName( "tc.5" )), _cExibe5 )
						AAdd( (oHtml:ValByName( "tc.6" )), _cExibe6 )
						AAdd( (oHtml:ValByName( "tc.7" )), _cExibe7 )
						AAdd( (oHtml:ValByName( "tc.9" )), _cExibe9 )
						AAdd( (oHtml:ValByName( "tc.10" )), _cExibe10 )
//						AAdd( (oHtml:ValByName( "tc.11" )), _cExibe11 )
					Else
						AAdd( (oHtml:ValByName( "tc.1" )), Iif(_cItem = _aSC8[j][1],"",_aSC8[j][1] ))
						AAdd( (oHtml:ValByName( "tc.2" )), _aSC8[j][2] )
						AAdd( (oHtml:ValByName( "tc.3" )), _aSC8[j][3] )
						AAdd( (oHtml:ValByName( "tc.4" )), _aSC8[j][4] )
						AAdd( (oHtml:ValByName( "tc.5" )), _aSC8[j][5] )
						AAdd( (oHtml:ValByName( "tc.6" )), _aSC8[j][6] )
						AAdd( (oHtml:ValByName( "tc.7" )), _aSC8[j][7] )
						AAdd( (oHtml:ValByName( "tc.9" )), _aSC8[j][9] )
						AAdd( (oHtml:ValByName( "tc.10" )), _aSC8[j][10] )
//						AAdd( (oHtml:ValByName( "tc.11" )), _aSC8[j][16] )
					EndIf 
					_cItem := _aSC8[j][1]	
				Endif
			Next
		EndIf

//      Imprimir os 3 ultimos pedidos para este item
	    _aSC7 := {}    
		_lPedidos := .F.

		For j = 1 to len(_aPedidos)  
			_cSelPed := "SELECT TOP 3 C7_FILIAL, C7_ITEM, C7_PRODUTO, C7_NUM, C7_FORNECE, C7_LOJA, A2_NOME, C7_QUANT,C7_PRECO, C7_IPI , C7_EMISSAO, C7_DATPRF, C7_COND, E4_DESCRI, C7_QUJE "
			_cSelPed += "FROM "+RetSqlName('SC7')+" SC7, "+RetSqlName('SA2')+" SA2, "+RetSqlName('SE4')+" SE4 "
			_cSelPed += "     WHERE C7_PRODUTO = '"+_aPedidos[j,2]+"'"
			_cSelPed += "       AND C7_FORNECE = A2_COD AND C7_LOJA = A2_LOJA  "
			_cSelPed += "       AND C7_COND       = E4_CODIGO"
			_cSelPed += "       AND C7_QUJE <> 0  "
			_cSelPed += "       AND C7_ENCER <> ' '  "
			_cSelPed += "  ORDER BY C7_EMISSAO DESC"
 			_cSelPed := ChangeQuery(_cSelPed)
 			TCQUERY _cSelPed NEW ALIAS "ULTC7"
	   		dbGoTop()     
			While !ULTC7->(Eof())
                Aadd( _aSC7, {_aPedidos[j,1], ;
			    			  ULTC7->C7_NUM , ;   
			    			  ULTC7->A2_NOME, ;
			    			  TRANSFORM(ULTC7->C7_QUANT,'@E 99,999,999.99'), ;
			    			  TRANSFORM(ULTC7->C7_PRECO,'@E 99,999,999.99')  , ;
			    			  TRANSFORM(ULTC7->C7_IPI , '@E 99.99')     , ;
			    			  DtoC(StoD(ULTC7->C7_EMISSAO)) , ;
			    			  DtoC(StoD(ULTC7->C7_DATPRF))  , ;
			    			  ULTC7->E4_DESCRI              , ;
			    			  TRANSFORM(ULTC7->C7_QUJE,'@E 999,999.99') ;
			    			   } )
				_lPedidos := .t.
				ULTC7->(DbSkip())	
			EndDo
//			DbSelectArea("ULTC7")
//			DbCloseArea("ULTC7")
			DbCloseArea()
		Next
		If !_lPedidos
//	 		_cExibe  := "<p><font color='#FF0000'>*** Não há historico de pedidos ***</font></p>"
			AAdd( (oHtml:ValByName( "tp.1"  )), " " )
			AAdd( (oHtml:ValByName( "tp.2"  )), " " )
			AAdd( (oHtml:ValByName( "tp.3"  )), " " )
			AAdd( (oHtml:ValByName( "tp.4"  )), " " )
			AAdd( (oHtml:ValByName( "tp.5"  )), " " )
			AAdd( (oHtml:ValByName( "tp.6"  )), " " )
			AAdd( (oHtml:ValByName( "tp.7"  )), " " )
			AAdd( (oHtml:ValByName( "tp.8"  )), " " )
			AAdd( (oHtml:ValByName( "tp.9"  )), " " )
			AAdd( (oHtml:ValByName( "tp.10" )), " " )
			
		Else	
//		    Asort(_aSC7,,, { |x,y| x[1]+x[7] < y[1]+y[7] } )
	   		_cItem := ""
		    For j := 1 To Len(_aSC7)   
				AAdd( (oHtml:ValByName( "tp.1"  )), Iif(_aSC7[j][1] == _cItem,"",_aSC7[j][1]) )
				AAdd( (oHtml:ValByName( "tp.2"  )), _aSC7[j][2] )
				AAdd( (oHtml:ValByName( "tp.3"  )), _aSC7[j][3] )
				AAdd( (oHtml:ValByName( "tp.4"  )), _aSC7[j][4] )
				AAdd( (oHtml:ValByName( "tp.5"  )), _aSC7[j][5] )
				AAdd( (oHtml:ValByName( "tp.6"  )), _aSC7[j][6] )
				AAdd( (oHtml:ValByName( "tp.7"  )), _aSC7[j][7] )
				AAdd( (oHtml:ValByName( "tp.8"  )), _aSC7[j][8] )
				AAdd( (oHtml:ValByName( "tp.9"  )), _aSC7[j][9] )
				AAdd( (oHtml:ValByName( "tp.10" )), _aSC7[j][10] )
		   		_cItem := _aSC7[j][1]
			Next
		EndIf

	Endif	
	//-------------------------------------------------------------
	// ALIMENTA A TELA DE PROCESSO DE APROVAÇÃO DE PEDIDO DE COMPRA
	//-------------------------------------------------------------

//	_cCHAVESCR := SUBS(_cCHAVE, 1, 24)
	
	DBSelectarea("SCR")
	DBSetOrder(1)
	DBSeek(_cCHAVESCR,.T.)
	
	WHILE !SCR->(EOF()) .AND. Alltrim(SCR->(CR_FILIAL+CR_TIPO+CR_NUM)) == Alltrim(_cCHAVESCR)

		cSituaca := ""
		Do Case
             Case SCR->CR_STATUS == "01"
                     cSituaca := "Aguardando"
             Case SCR->CR_STATUS == "02"
                     cSituaca := "Em Aprovacao"
             Case SCR->CR_STATUS == "03"
                     cSituaca := "Aprovado"
             Case SCR->CR_STATUS == "04"
                     cSituaca := "Bloqueado"
                     lBloq := .T.
             Case SCR->CR_STATUS == "05"
                     cSituaca := "Nivel Liberado"
        EndCase	
                                             
		_cT4 := UsrRetName(SCR->CR_USERLIB)
		_cT6 := SCR->CR_OBS
		
		AAdd( (oHtml:ValByName( "t1.1"    )), SCR->CR_NIVEL)
		AAdd( (oHtml:ValByName( "t1.2"    )), UsrFullName(SCR->CR_USER))
		AAdd( (oHtml:ValByName( "t1.3"    )), cSituaca    )
		AAdd( (oHtml:ValByName( "t1.4"    )), IIF(EMPTY(_cT4),"", _cT4))
		AAdd( (oHtml:ValByName( "t1.5"    )), DTOC(SCR->CR_DATALIB))
		AAdd( (oHtml:ValByName( "t1.6"    )), IIF(EMPTY(_cT6),"", _cT6))
		
		SCR->(DBSkip())
   ENDDO

	oProcess:nEncodeMime := 0

	DO CASE
		CASE _nOpc == 1
			oProcess:cTo      		:= nil
			oProcess:NewVersion(.T.)
			oHtml     				:= oProcess:oHTML
			oProcess:nEncodeMime := 0
			cMailID := oProcess:Start("\workflow\emp"+cEmpAnt+"\wfpc\")   //Faz a gravacao do e-mail no cPath
			
			chtmlfile  := cmailid + ".htm"
	
			If _cTipoDoc == "PC"
				csubj := "Aprovação Pedido de compra - Filial: "+_cFilial+" / Numero: "+_cNum
				oProcess:newtask("Link", "\workflow\html\Link_Modelo.htm")  //Cria um novo processo de workflow que informara o Link ao usuario
				oHtml:ValByName( "descproc"	  ,"O pedido de compra abaixo aguarda sua aprovação:")
				oHtml:ValByName( "cDoctoI"	  ,"Pedido de compra No. "+_cNum )
				oProcess:oHtml:ValByName("cNomeProcessoI", Alltrim(GetMv("MV_WFDHTTP"))+"/workflow/emp"+cempant+"/wfpc/"+chtmlfile ) // envia o link onde esta o arquivo html
			Else
				csubj := "Aprovação Autorizacao de entrega - Filial: "+_cFilial+" / Numero: "+_cNum
				oProcess:newtask("Link", "\workflow\html\Link_TRC.htm")  //Cria um novo processo de workflow que informara o Link ao usuario
				oHtml:ValByName( "descproc"	  ,"A Autorizacao de entrega abaixo aguarda sua aprovação:")
				oHtml:ValByName( "cDoctoI"	  ,"Autorizacao de entrega No. "+_cNum )
				oProcess:oHtml:ValByName("cNomeProcessoI", Alltrim(GetMv("MV_WFDHTTP"))+"/workflow/emp"+cempant+"/wfpc/"+chtmlfile ) // envia o link onde esta o arquivo html
			Endif
				
			oProcess:cTo 	   := _cEmail
			oProcess:cSubject := cSubj
			
			oProcess:Start()

		OTHERWISE       
			If _cTipoDoc == "PC"
				oProcess:cSubject    := "WORKFLOW  - Pedido de compra " + _cNum +Iif(_cVersao <> ""," Revisão: "+_cVersao +" - ","") + Iif(_nOpc=3," APROVADO"," REPROVADO")
			Else
				oProcess:cSubject    := "WORKFLOW  - Autorizacao de entrega " + _cNum +Iif(_cVersao <> ""," Revisão: "+_cVersao +" - ","") + Iif(_nOpc=3," APROVADA"," REPROVADA")
			Endif
			oProcess:Start()
	END CASE

	// ARRAY DE RETORNO
	_aReturn := {}
	AADD(_aReturn, oProcess:fProcessId)
	AADD(_aReturn, _aTimeOut[3])
	AADD(_aReturn, _aTimeOut[4])

	U_CONSOLE("_aReturn[1]: "+ _aReturn[1])

	return _aReturn
	