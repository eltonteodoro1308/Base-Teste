#include "rwmake.ch"       
#include "protheus.ch"       
#include "Topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
                                                                            
User Function SC_MIRA()
	Local _nEmp
	Private _aMatriz  := {"01","01010"}  // para abrir a 1a empresa //
	Private _aEmpresa := {}  
	RpcSetType(3)
	RpcSetEnv(_aMatriz[1],_aMatriz[2])
	DBSelectArea("SM0")
	DBSetOrder(1)
	DBSeek(_aMatriz[1],.F.)
	
	U_CONSOLE('Montando array de empresas - SC() /' + _aMatriz[1] )
	
	Aadd(_aEmpresa, {SM0->M0_CODIGO,Alltrim(SM0->M0_CODFIL)})  

	RpcClearEnv()

    For _nEmp := 1 To Len(_aEmpresa)   
		U_SC({_aEmpresa[_nEmp]})  		
    Next 
	U_CONSOLE('Final do processamento - SC() ' )
   	Return

User Function SC_99()
	Local _nEmp
	Private _aMatriz  := {"99","01"}  // para abrir a 1a empresa //
	Private _aEmpresa := {}  
	RpcSetType(3)
	RpcSetEnv(_aMatriz[1],_aMatriz[2])
	DBSelectArea("SM0")
	DBSetOrder(1)
	DBSeek(_aMatriz[1],.F.)
	
	U_CONSOLE('Montando array de empresas - SC() /' + _aMatriz[1] )
	
	Aadd(_aEmpresa, {SM0->M0_CODIGO,Alltrim(SM0->M0_CODFIL)})  

	RpcClearEnv()

    For _nEmp := 1 To Len(_aEmpresa)   
		U_SC({_aEmpresa[_nEmp]})  		
    Next 
	U_CONSOLE('Final do processamento - SC() ' )
   	Return
   	
/*                                                           
Prepara ambiente - Empresa / Filial
*/
User Function SC( aParam )
	If aParam == Nil .OR. VALTYPE(aParam) == "U"
		U_CONSOLE("Parametros nao recebidos => SC()")
		RETURN
	EndIf
	RpcSetType(3)
	RpcSetEnv(aParam[1][1],aParam[1][2])
	U_CONSOLE('SC(aParam):' + aParam[1][1]   +'/'+ aParam[1][2])
	U_WKFSC(1)  		// 1 - ENVIO SC PARA APROVADORES
	U_WKFSC(3)  		// 3 - ENVIO SC ITENS APROVADOS PARA SOLICITANTE
	U_WKFSC(4)  		// 4 - ENVIO SC ITENS REPROVADOS PARA SOLICITANTE
	RpcClearEnv()
	RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³WKFSC ºAutor  ³Pedro Augusto       º Data ³  21/08/2013     º±±
±±ºCliente   MIRA OTM                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 1 - ENVIO DE EMAIL PARA APROVADORES                        º±±
±±º          ³ 2 - RETORNO DE EMAIL COM RESPOSTA DE APROVADORES           º±±
±±º          ³ 3 - ENVIA RESPOSTA DE SOLIC APROVADA  PARA O COMPRADOR	  º±±
±±º          ³ 4 - ENVIA RESPOSTA DE SOLIC REPROVADO PARA O COMPRADOR	  º±±
±±º          ³ 5 - ENVIO DE EMAIL - ACAO TIMEOUT                          º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function WKFSC(_nOpc, oProcess)
	Local _cIndex, _cFiltro, _cOrdem, _lProcesso := .F.
	Local _cEmp,_cFilial, _cOpcao, _cObs
	Local cObs 		:= ""
	Local _cCRNUM            
	
	Private _cQuery := ''
	
	Private _aWF 	:= {}   
	Private _aSC1_1 := {}
	
	DO 	CASE 
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³1 - Prepara as solicitacoes a serem enviados para aprovacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	
		CASE _nOpc == 1
	
			U_CONSOLE("1 - Prepara as solicitacoes a serem enviadas para aprovacao")
			U_CONSOLE("1 - EmpFil:" + cEmpAnt + xFilial("SC1"))
	
		  	_cQry := ""
		  	_cQry += " SELECT DISTINCT "
		  	_cQry += " C1_FILIAL,"  
		  	_cQry += " C1_NUM,"
		  	_cQry += " C1_USER"   
		  	
		  	_cQry += " FROM " + RetSqlName("SC1") + " SC1"
		  	_cQry += " WHERE D_E_L_E_T_ <> '*'"
		  	_cQry += " AND C1_FILIAL   = '" + xFilial("SC1") + "'"
			_cQry += " AND C1_APROV='B' "
		  	_cQry += " AND C1_WF = ' '"
		  	                     
		  	_cQry += " ORDER BY"
		  	_cQry += " C1_FILIAL," 
		  	_cQry += " C1_NUM"
			  	
			_cQuery := ChangeQuery( _cQry )  
			
			TcQuery _cQuery New Alias "TMPSC1"
		
			dbGotop()
			While !TMPSC1->(Eof())                                                                
				_cFilial   := TMPSC1->C1_FILIAL
				_cNumSC    := TMPSC1->C1_NUM
				_cUser     := TMPSC1->C1_USER
				_cGestor   := Posicione("SAI",2,xFilial("SAI")+TMPSC1->C1_USER     ,"SAI->AI_APROV") 
				_cAprov    := Posicione("SAK",1,xFilial("SAI")+_cGestor            ,"SAK->AK_USER") 
	
				Aadd(_aSC1_1, {_cFilial,_cNumSC,_cUser,_cAprov})
	
				TMPSC1->(DBSkip())           
			End
	
			dbSelectArea("TMPSC1")
			dbCloseArea()
	
			If Len(_aSC1_1) > 0
				For i := 1 to Len(_aSC1_1)
					_aWF := EnviaSC(_aSC1_1[i][1], _aSC1_1[i][2], _aSC1_1[i][3], _aSC1_1[i][4], _nOpc)
					If Len(_aWF) > 0 
						_lProcesso 	:= .T.
						DBSelectarea("SC1")
						DBSetOrder(1)
						IF SC1->(DBSeek(_aSC1_1[i][1]+ _aSC1_1[i][2]))
							While SC1->(C1_FILIAL + C1_NUM) == _aSC1_1[i][1]+_aSC1_1[i][2] .and. !SC1->(Eof())
								Reclock("SC1",.F.)
								SC1->C1_WF			:= IIF(EMPTY(_aWF[1])," ","1")  	// Status 1 - envio para aprovadores / branco-nao houve envio
					  			SC1->C1_WFID		:= _aWF[1]							// Rastreabilidade
								MSUnlock() 
								SC1->(DbSkip())  
							Enddo	  
						Endif
					Endif	
	        	Next 
			End
			
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³2 - Processa O RETORNO DO EMAIL - GESTOR              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
		CASE _nOPC	== 2
	
			U_CONSOLE("2 - Processa O RETORNO DO EMAIL")
			U_CONSOLE("2 - EmpFil:" + cEmpAnt + xFilial("SC1"))
	                                                                         
			U_CONSOLE("2 - cFilAnt    :" + xFilial("SC1"))
	
			cObs     	:= alltrim(oProcess:oHtml:RetByName("OBS"))
			cNum        := alltrim(oProcess:oHtml:RetByName("C1_NUM"))
			cNomapro    := alltrim(oProcess:oHtml:RetByName("C1_NOMAPRO"))
			cWFID     	:= oProcess:fProcessId
			cTo   		:= oProcess:cTo
			cOPC   		:= alltrim(oProcess:oHtml:RetByName("OPC"))
			oProcess:Finish() // FINALIZA O PROCESSO
			
			U_CONSOLE("2 - Chave   :" + xFilial("SC1") + cNum)
			U_CONSOLE("2 - WFId    :" + cWFID)
			U_CONSOLE("2 - cTo     :" + cTo)
	
			IF cOpc $ "S|N"  // Aprovacao S-Sim N-Nao
	                             
				dbSelectArea("SC1")
				dbSetOrder(1)
				SC1->(DbSeek(xFilial("SC1")+cNum))
		        While !SC1->(Eof()) .And. SC1->C1_FILIAL+SC1->C1_NUM == xFilial("SC1")+cNum
					U_CONSOLE("2 - Filial + SC + Item: ["+SC1->C1_FILIAL+SC1->C1_NUM+SC1->C1_ITEM+"]")            
					IF ALLTRIM(SC1->C1_WFID) <> ALLTRIM(cWFID)
						U_CONSOLE("2 - Processo nao encontrado :" + cWFID + " Processo atual :" + SC1->C1_WFID)
						Return .F.
					ENDIF  
					RECLOCK("SC1",.F.)
					If cOpc == "S"  
						SC1->C1_APROV   := "L"
					Else
						SC1->C1_APROV   := "R"
					Endif
					SC1->C1_WF		:= "2"
					SC1->C1_NOMAPRO := cNomApro
					SC1->C1_WFOBS	:= cObs
					MSUNLOCK()
					SC1->(DbSkip())
				Enddo
				
			ENDIF
			U_CONSOLE("Retorno processado : SC " +cNum )
			Return		
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³3 - Envia resposta de solic. aprovada para o solicitante³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	
		CASE _nOpc == 3
	
			U_CONSOLE("3 - Envia resposta de solicitacao APROVADA para o solicitante")
			U_CONSOLE("3 - EmpFil:" + cEmpAnt + xFilial("SC1"))
	
		  	_cQuery := ""
		  	_cQuery += " SELECT DISTINCT "
		  	_cQuery += " C1_FILIAL," 
		  	_cQuery += " C1_NUM,"
		  	_cQuery += " C1_USER"   
		  	
		  	_cQuery += " FROM " + RetSqlName("SC1") + " SC1"
		  	_cQuery += " WHERE SC1.D_E_L_E_T_ <> '*'"
		  	_cQuery += " AND C1_FILIAL   = '" + xFilial("SC1") + "'"
			_cQuery += " AND C1_APROV='L' "										// Liberado
			_cQuery += " AND C1_NOMAPRO <> '      ' "							// Aprovador
		  	_cQuery += " AND C1_WF <> '1'"	      						    	// 1 Enviado EMAIL
		  	                     
		  	_cQuery += " ORDER BY"
		  	_cQuery += " C1_FILIAL," 
		  	_cQuery += " C1_NUM"
			  	
			TcQuery _cQuery New Alias "TMPSC1"
		
			dbGotop()
			While !TMPSC1->(Eof())                                                                
				_cFilial   := TMPSC1->C1_FILIAL
				_cNumSC    := TMPSC1->C1_NUM
				_cUser     := TMPSC1->C1_USER
				_cGestor   := Posicione("SAI",2,xFilial("SAI")+TMPSC1->C1_USER     ,"SAI->AI_APROV") 
				_cAprov    := Posicione("SAK",1,xFilial("SAI")+_cGestor            ,"SAK->AK_USER") 
				Aadd(_aSC1_1, {_cFilial,_cNumSC,_cUser,_cAprov})
				TMPSC1->(DBSkip())           
			End
	
			dbSelectArea("TMPSC1")
			dbCloseArea()
	
			If Len(_aSC1_1) > 0
				For i := 1 to Len(_aSC1_1)
					_aWF := EnviaSC(_aSC1_1[i][1], _aSC1_1[i][2], _aSC1_1[i][3], _aSC1_1[i][4], _nOpc)
					If Len(_aWF) > 0 
						_lProcesso 	:= .T.
						DBSelectarea("SC1")
						DBSetOrder(1)
						IF SC1->(DBSeek(_aSC1_1[i][1]+ _aSC1_1[i][2]))
							While SC1->(C1_FILIAL + C1_NUM) == _aSC1_1[i][1]+_aSC1_1[i][2] .and. !SC1->(Eof())
								Reclock("SC1",.F.)
								SC1->C1_WF			:= IIF(EMPTY(_aWF[1])," ","1")  	// Status 1 - envio para aprovadores / branco-nao houve envio
					  			SC1->C1_WFID		:= _aWF[1]							// Rastreabilidade
								MSUnlock() 
								SC1->(DbSkip())  
							Enddo	  
						Endif
					Endif	
	        	Next 
			End
		
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³4 - Envia resposta de solicitacao bloqueada para o comprador³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
		CASE _nOpc == 4
	
			U_CONSOLE("4 - Envia resposta de solicitacao bloqueada para o solicitante")
			U_CONSOLE("4 - EmpFil:" + cEmpAnt + xFilial("SC1"))
			
		  	_cQuery := ""
		  	_cQuery += " SELECT DISTINCT "
		  	_cQuery += " C1_FILIAL," 
		  	_cQuery += " C1_NUM,"
		  	_cQuery += " C1_USER"   
		  	
		  	_cQuery += " FROM " + RetSqlName("SC1") + " SC1"
		  	_cQuery += " WHERE SC1.D_E_L_E_T_ <> '*'"
		  	_cQuery += " AND C1_FILIAL   = '" + xFilial("SC1") + "'"
			_cQuery += " AND C1_APROV='R' "										// Liberado
	//		_cQuery += " AND C1_NOMAPRO <> '      ' "							// Grupo Aprovador
		  	_cQuery += " AND C1_WF <> '1'"	      						    	// 1 Enviado EMAIL
		  	                     
		  	_cQuery += " ORDER BY"
		  	_cQuery += " C1_FILIAL," 
		  	_cQuery += " C1_NUM"
			  	
			TcQuery _cQuery New Alias "TMPSC1"
		
			dbGotop()
			While !TMPSC1->(Eof())                                                                
				_cFilial   := TMPSC1->C1_FILIAL
				_cNumSC    := TMPSC1->C1_NUM
				_cUser     := TMPSC1->C1_USER
				_cGestor   := Posicione("SAI",2,xFilial("SAI")+TMPSC1->C1_USER     ,"SAI->AI_APROV") 
				_cAprov    := Posicione("SAK",1,xFilial("SAI")+_cGestor            ,"SAK->AK_USER") 
	
				Aadd(_aSC1_1, {_cFilial,_cNumSC,_cUser,_cAprov})
	
				TMPSC1->(DBSkip())           
			End
	
			dbSelectArea("TMPSC1")
			dbCloseArea()
	
			If Len(_aSC1_1) > 0
				For i := 1 to Len(_aSC1_1)
					_aWF := EnviaSC(_aSC1_1[i][1], _aSC1_1[i][2], _aSC1_1[i][3], _aSC1_1[i][4], _nOpc)
					If Len(_aWF) > 0 
						_lProcesso 	:= .T.
						DBSelectarea("SC1")
						DBSetOrder(1)
						IF SC1->(DBSeek(_aSC1_1[i][1]+ _aSC1_1[i][2]))
							While SC1->(C1_FILIAL + C1_NUM) == _aSC1_1[i][1]+_aSC1_1[i][2] .and. !SC1->(Eof())
								Reclock("SC1",.F.)
								SC1->C1_WF			:= IIF(EMPTY(_aWF[1])," ","1")  	// Status 1 - envio para aprovadores / branco-nao houve envio
					  			SC1->C1_WFID		:= _aWF[1]							// Rastreabilidade
								MSUnlock() 
								SC1->(DbSkip())  
							Enddo	  
						Endif
					Endif	
	        	Next 
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
±±ºPrograma  ³EnviaSC   ºAutor  ³Microsiga           º Data ³  08/15/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function EnviaSC(_cFilial,_cNum, _cUser, _cGest, _nOpc) 
	Local _lRateio := .f.
	Local aArea    := GetArea()
	Private _aReturn := {}
    
	_cTo		:= Iif(_nOpc == 1, _cGest, UsrRetMail(_cUser))
		
	_cAprov     := IIF(_nOpc == 1, _cGest,"")
	
    u_console(_cTo)
	_cEmail		:= UsrRetMail(_cAprov)

	_lError := .F.            
	
	DbSelectArea("SC1")
	
	If (_nOpc == 1 .and. Alltrim(_cTo) == "") .or. (_nOpc == 1 .and. Alltrim(UsrRetMail(_cTo)) == "") .or. (_nOpc <> 1 .and. Alltrim(_cTo) == "")
		aMsg := {}
		cTitle  := "Administrador do Workflow : NOTIFICACAO" 
		aADD(aMsg , REPLICATE('*',80) )
		aADD(aMsg , Dtoc(MSDate()) + " - " + Time() + ' * Ocorreu um ERRO no envio da mensagem :' )
		If _nOpc == 1 
		    If (_nOpc == 1 .and. Alltrim(_cTo) == "")
				aADD(aMsg , "Solicitacao de Compra No: " + _cNum + " Filial : " + _cFilial  )
				aADD(aMsg , "Solicitante "+UsrFullName(_cUser)+" sem aprovador associado" )
			Else
				aADD(aMsg , "Solicitacao de Compra No: " + _cNum + " Filial : " + _cFilial  )
				aADD(aMsg , "Aprovador "+Alltrim(UsrFullName(_cGest))+" sem e-mail cadastrado" )
			Endif
		Else
			aADD(aMsg , "Solicitacao de Compra No: " + _cNum + " Filial : " + _cFilial )
			aADD(aMsg , "Campo EMAIL do cadastro de usuario "+Alltrim(UsrFullName(_cUser))+" NAO PREENCHIDO" )
		Endif
		aADD(aMsg , REPLICATE('*',80) )
		_lError := .T.
	Endif
                  

	IF _lError
		U_NotifyAdm(cTitle, aMsg)
		_aReturn := {""}
		RETURN _aReturn
	ENDIF

	// ----- FIM DA VALIDACAO

	ChkFile("SC1")
	ChkFile("SB1")
	ChkFile("SBM")
              
	DBSelectArea("SM0")
	DBSetOrder(1)
	DBSeek(cEmpAnt+cFilAnt)
	
	DBSelectArea("SC1")
	DBSetOrder(1)
	DBSeek(xFilial("SC1")+_cNum,.f.)

	DBSelectArea("SAI")
	DBSetOrder(2)
	DBSeek(xFilial("SAI")+SC1->C1_USER)
	
	DO CASE 
	//-------------------------------------------------------- INICIO PROCESSO WORKFLOW
		CASE _nOpc == 1		// Envio de email para aprovacao
				oProcess          	:= TWFProcess():New( "000001", "Envio Aprovacao SC :" + _cFilial + "/" +  TRIM(_cNum) )
				oProcess          	:NewTask( "Envio SC : "+_cFilial + _cNum, "\WORKFLOW\HTML\SCAPROV_Modelo.HTM" )
				oProcess:cSubject 	:= "Aprovacao Solicitacao de Compra " + _cFilial + "/" +  _cNum
				oProcess:bReturn  	:= "U_WKFSC(2)"
		
		CASE _nOpc == 3 		// Envio de email Aprovacao para solicitante
				oProcess          	:= TWFProcess():New( "000003", "Envio p/solicitante SC aprovada : " + _cFilial + "/" +  TRIM(_cNum) )
				oProcess          	:NewTask( "Envio SC aprovada : "+_cFilial +"/"+ _cNum, "\WORKFLOW\HTML\SCRESP_Modelo.HTM" )
				oProcess:cSubject 	:= "Solicitacao de compra aprovada: " + _cFilial + "/" +  _cNum
				_cResposta			:= "A P R O V A D A"
//				_cTo				:= _cTo + ";" + _cEmailComp
			
		CASE _nOpc == 4		// Envio de email Reprovado para solicitante
				oProcess          	:= TWFProcess():New( "000004", "Envio p/solicitante SC reprovado : " + _cFilial + "/" +  TRIM(_cNum) )
				oProcess          	:NewTask( "SC reprovada : "+_cFilial + "/"+ _cNum, "\WORKFLOW\HTML\SCRESP_Modelo.HTM" )
				oProcess:cSubject 	:= "Solicitacao de compra reprovada: " + _cFilial + "/" +  _cNum
				_cResposta			:= "<font color='#FF0000'>R E P R O V A D A</font>"
		
	ENDCASE

	oProcess:cTo      	:= _cTo
	oProcess:UserSiga	:= _cUser
	oProcess:NewVersion(.T.)
	
 	oHtml     				:= oProcess:oHTML

	IF _nOpc == 0 .OR. _nOpc == 1
		oHtml:ValByName( "OBS"		   , "" )
	ENDIF

	IF _nOpc == 0 .OR. _nOpc == 3 .OR. _nOpc == 4
		oHtml:ValByName( "MENSAGEM"  	, _cResposta)	 
		oHtml:ValByName( "C1_WFOBS"  	, SC1->C1_WFOBS)	 
	ENDIF
   
	//Cabecalho
	oHtml:ValByName( "C1_FILIAL"	, SM0->M0_FILIAL )
	oHtml:ValByName( "C1_NUM"		, SC1->C1_NUM )
	oHtml:ValByName( "C1_EMISSAO"	, DTOC(SC1->C1_EMISSAO) )
	oHtml:ValByName( "C1_SOLICIT"  	, UsrFullName(_cUser))
	oHtml:ValByName( "C1_NOMAPRO"	, UsrFullName(_cGest))
	oHtml:ValByName( "C1_WFOBS"		, SC1->C1_WFOBS)
//	oHtml:ValByName( "C1_FILENT"	, SM0->M0_NOMECOM)

	DBSelectArea("SM0")
	DBSetOrder(1)
	DBSeek(cEmpAnt+SC1->C1_FILENT)
	
/*
	// Dados local entrega
	oHtml:ValByName( "E_NOME"		, SM0->M0_NOMECOM)
	oHtml:ValByName( "E_CNPJ"	  	, Transform(SM0->M0_CGC,PesqPict("SA2","A2_CGC")))
	oHtml:ValByName( "E_ENDER" 		, Alltrim(SM0->M0_ENDENT) + " - " + Alltrim(SM0->M0_CIDENT)  + " - " + Alltrim(SM0->M0_ESTENT) + " - CEP: "+SM0->M0_CEPCOB )
*/
	
	//-------------------------------------------------------------
	// ALIMENTA A TELA DE ITENS 
	//-------------------------------------------------------------
	While !SC1->(EOF()) .AND. SC1->C1_FILIAL == xFilial("SC1") .AND. SC1->C1_NUM == _cNum     
		DBSELECTAREA("SB1")
		DBSetOrder(1)
		DBSeek(xFilial("SB1")+SC1->C1_PRODUTO)
		
		AAdd( (oHtml:ValByName( "t.1"    )), SC1->C1_ITEM)
		AAdd( (oHtml:ValByName( "t.2" 	 )), Alltrim(SC1->C1_PRODUTO))
		AAdd( (oHtml:ValByName( "t.3" 	 )), Alltrim(SB1->B1_DESC) + Iif(!Empty(SC1->C1_OBS )," - Obs: "  + Alltrim(SC1->C1_OBS),"") )
		AAdd( (oHtml:ValByName( "t.4"    )), TRANSFORM(SC1->C1_QUANT,'@E 999,999,999.99'))
		AAdd( (oHtml:ValByName( "t.5"    )), SB1->B1_UM)
		AAdd( (oHtml:ValByName( "t.6"    )), DTOC(SC1->C1_DATPRF))
		AAdd( (oHtml:ValByName( "t.7"    )), Iif(!Empty(SC1->C1_CC )     ,Alltrim(SC1->C1_CC)      + " ["+Alltrim(Posicione("CTT",1,xfilial("CTT")+SC1->C1_CC     ,"CTT->CTT_DESC01"))+"]",""))
		AAdd( (oHtml:ValByName( "t.8"    )), Iif(!Empty(SC1->C1_CONTA )	 ,Alltrim(SC1->C1_CONTA)   + " ["+Alltrim(Posicione("CT1",1,xfilial("CT1")+SC1->C1_CONTA  ,"CT1->CT1_DESC01"))+"]",""))
//		AAdd( (oHtml:ValByName( "t.9"    )), "")

		SC1->(dbSkip())
	Enddo

	// ARRAY DE RETORNO
	_aReturn := {}
	AADD(_aReturn, oProcess:fProcessId)
	
	oHtml:ValByName( "data_hora"	, DTOC(MSDATE()) + " as " + LEFT(TIME(),5) )
	oProcess:nEncodeMime := 0

	aAdd( oProcess:aParams, _cNum)						

	DO CASE
		CASE _nOpc = 1 
			oProcess:cTo      		:= nil
			oProcess:NewVersion(.T.)
			oHtml     				:= oProcess:oHTML
			oProcess:nEncodeMime := 0
			cMailID := oProcess:Start("\workflow\emp"+cEmpAnt+"\wfsc\")   //Faz a gravacao do e-mail no cPath
			
			chtmlfile  := cmailid + ".htm"
	
			csubj := "Aprovação:  Solicitacao compra - Filial: "+_cFilial+" / Numero: "+_cNum
			oProcess:newtask("Link", "\workflow\html\Link_modelo.htm")  //Cria um novo processo de workflow que informara o Link ao usuario
			oHtml:ValByName( "descproc"	  ,"A solicitação de compra abaixo aguarda sua aprovação:")
			oHtml:ValByName( "cDoctoI"	  ,"Solicitação de compra No. "+_cNum )
			oProcess:oHtml:ValByName("cNomeProcessoI", Alltrim(GetMv("MV_WFDHTTP"))+"/workflow/emp"+cempant+"/wfsc/"+chtmlfile ) // envia o link onde esta o arquivo html
			
			oProcess:cTo 	   := _cEmail
			oProcess:cSubject := cSubj
			
			oProcess:Start()
//			fErase("\workflow\emp"+cempant+"\temp\" + chtmlfile)
		OTHERWISE               
//			oProcess:cCc   := Alltrim(GetNewPar("MV_XGRCOM","pedroaugustoc@hotmail.com"))
			oProcess:Start()
			_aReturn := {}
			AADD(_aReturn, oProcess:fProcessId)
	END CASE

	RestArea(aArea)
		
	return _aReturn

