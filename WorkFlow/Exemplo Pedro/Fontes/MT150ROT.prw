#Include 'Rwmake.ch'
#Include 'AP5Mail.ch'
#include "Protheus.Ch"
/*
Programa.: 	MT150ROT 
Autor....:	Pedro Augusto
Data.....: 	26/08/2014 
Descricao: 	Ponto de Entrada para adicionar para adicionar um botao no browse da rotina "Atualiza cotacao"
Uso......: 	MIRASSOL
*/
User Function MT150ROT()  
	aAdd(aRotina,{"Enviar e-mail","U_MT150EM", 0 , 4})
	Return aRotina                                  

User Function MT150EM()
	U_ListBoxMar(SC8->C8_NUM) 
	Return .T.

/*
Programa.: 	ListBoxMar
Autor....:	Pedro Augusto
Data.....: 	18/02/2014 
Descricao: 	Abre uma janela com os fornecedores da cotacao posicionada na 
         	rotina "Atualiza cotacao" e permite selecionar os fornecedores
         	para envio da cotação
Uso......: 	ELCA
*/
User Function ListBoxMar(cCotacao)

Local cVar      := Nil
Local oDlg      := Nil
Local cTitulo   := "Selecionar Fornecedores para envio"
Local lMark     := .F.
Local oOk       := LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
Local oNo       := LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
Local oChk      := Nil
Local aAreaSC8	:= GetArea("SC8")
Local _cFornece := ""
Local _cLoja    := ""

Private lChk     := .F.
Private oLbx := Nil
Private aVetor := {}               


dbSelectArea("SC8")
dbSetOrder(1) //C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO+C8_ITEMGRD 
dbSeek(xFilial("SC8") + cCotacao)

//+-------------------------------------+
//| Carrega o vetor conforme a condicao |
//+-------------------------------------+

While !Eof() .And. C8_FILIAL == xFilial("SC8") .AND. C8_NUM == cCotacao	
	If SC8->C8_FORNECE + SC8->C8_LOJA <> _cFornece + _cLoja
   		aAdd( aVetor, { lMark, 	C8_NUM, ;
   								C8_FORNECE, ;
   								C8_LOJA, ;
   								Posicione("SA2",1,xFilial("SA2")+SC8->(C8_FORNECE+C8_LOJA),"A2_NREDUZ"),;
   								Posicione("SA2",1,xFilial("SA2")+SC8->(C8_FORNECE+C8_LOJA),"A2_EMAIL") })
		_cFornece := SC8->C8_FORNECE
		_cLoja    := SC8->C8_LOJA
		   		
   	Endif	
	dbSkip()
End

//+-----------------------------------------------+
//| Monta a tela para usuario visualizar consulta |
//+-----------------------------------------------+
If Len( aVetor ) == 0
   Aviso( cTitulo, "Nao existe Fornecedores a consultar", {"Ok"} )
   Return
Endif

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,500 PIXEL
   
@ 10,10 LISTBOX oLbx VAR cVar FIELDS HEADER ;
   " ", "Numero","Fornecedor", "Loja", "Nome Fornecedor", "E-mail Fornecedor" ;
   SIZE 230,095 OF oDlg PIXEL ON dblClick(aVetor[oLbx:nAt,1] := !aVetor[oLbx:nAt,1],oLbx:Refresh())

oLbx:SetArray( aVetor )
oLbx:bLine := {|| {Iif(aVetor[oLbx:nAt,1],oOk,oNo),;
                       aVetor[oLbx:nAt,2],;
                       aVetor[oLbx:nAt,3],;
                       aVetor[oLbx:nAt,4],;
                       aVetor[oLbx:nAt,5],;
                       aVetor[oLbx:nAt,6]}}
	 
@ 110,10 CHECKBOX oChk VAR lChk PROMPT "Marca/Desmarca" SIZE 60,007 PIXEL OF oDlg ;
         ON CLICK(aEval(aVetor,{|x| x[1]:=lChk}),oLbx:Refresh())

DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTER

// Enviar e-mail para os elementos do aVetor que estejam TRUE //

If Len(aVetor) <> 0
	For i = 1 to Len(aVetor)
        If aVetor[i][1] == .T.
			IF EMPTY(aVetor[i][6])
				cTitle  := "Administrador do Workflow : NOTIFICACAO" 
				aMsg	:= {}
				AADD(aMsg, Dtoc(MSDate()) + " - " + Time() )
				AADD(aMsg, "Cotação No: " + aVetor[i][2] + " Filial : " + cFilAnt + " Fornecedor : " + aVetor[i][5] + " (" + aVetor[i][3] +"-" + aVetor[i][4] + ")")
			ELSE
				U_EnviaCT(aVetor[i][2],aVetor[i][3],aVetor[i][4]) // elementos do array: 	C8_NUM, C8_FORNECE, C8_LOJA
			ENDIF
		Endif	
	Next i
Endif

/*
Programa.: 	EnviaCT
Autor....:	Pedro Augusto
Data.....: 	18/02/2014 
Descricao: 	Rotina de envio de e-mail com a cotacao para os fornecedores da rotina "Atualiza cotacao"
Uso......: 	ELCA
*/
User Function EnviaCT(_cNum, _cFornece, _cLoja)
	Local _cUser
	Private _aCond := {} 
	Private _aFrete:= {} 

	DBSelectArea("SC8")
	DBSetOrder(1)
	DBSeek(xFilial("SC8")+_cNum + _cFornece + _cLoja)
	_cUser := SC8->C8_XUSER

   	DbSelectArea("SA2")
   	DbSetOrder(1)
   	DbSeek(xFilial("SA2") + _cFornece + _cLoja)

	dbSelectArea("SE4")
	dbSetOrder(1)
   	DbSeek(xFilial("SE4") + SA2->A2_COND)

	If Alltrim(SE4->E4_CODIGO) <> ""
		aAdd( _aCond, SE4->E4_CODIGO + " - " + SE4->E4_DESCRI )
    Endif
    
	// CONDIÇÃO DE PAGAMENTO
	dbSelectArea("SE4")
	dbSetOrder(1)
	dbGoTop()

	while !SE4->(Eof()) .and. xFilial("SE4") == SE4->E4_FILIAL
		If SE4->E4_MSBLQL <> '1'
			aAdd( _aCond, SE4->E4_CODIGO + " - " + SE4->E4_DESCRI )
		Endif	
		SE4->(dbSkip())
	enddo

	aAdd( _aFrete, "C=CIF" )
	aAdd( _aFrete, "F=FOB" )
	aAdd( _aFrete, "T=Terceiros" )
	aAdd( _aFrete, "S=Sem frete" )

	oProcess:= TWFProcess():New( "000001", "Cotacao Eletronica" )
	oProcess:NewTask( "Cotacao de Precos", "\WORKFLOW\HTML\CTFORN_MS.HTM" )
	oProcess:bReturn  		:= "U_RecCT()"
	oProcess:nEncodeMime 	:= 0
	oProcess:cSubject 		:= "Cotação Eletrônica de Precos No." + _cNum
	oProcess:cTo      		:= _cUser
	oProcess:NewVersion(.T.)            
	
 	oHtml     				:= oProcess:oHTML

	oHtml:ValByName( "C8_NUM"		, _cNum 			)
	oHtml:ValByName( "A2_NREDUZ"	, SA2->A2_NREDUZ 	)
	oHtml:ValByName( "A2_COD"		, SA2->A2_COD 		)
	oHtml:ValByName( "A2_LOJA"		, SA2->A2_LOJA 		)
	oHtml:ValByName( "A2_END"		, SA2->A2_END 		)
	oHtml:ValByName( "A2_BAIRRO"	, SA2->A2_BAIRRO 	)
	oHtml:ValByName( "A2_MUN"		, SA2->A2_MUN 		)
	oHtml:ValByName( "A2_EST"		, SA2->A2_EST 		)
	oHtml:ValByName( "A2_TEL"		, SA2->A2_TEL 		)	
	oHtml:ValByName( "A2_FAX"		, SA2->A2_FAX 		)	  
	oHtml:ValByName( "E4_COND"   	, _aCond      		)
	oHtml:ValByName( "TPFRETE" 		, _aFrete     		)
	oHtml:ValByName( "CONTATO"   	, SC8->C8_CONTATO   )
	oHtml:ValByName( "FRETE"   		, ""   				)
	
	// ALIMENTA A TELA DE ITENS DA COTACAO

	While !SC8->(EOF()) .AND. SC8->(C8_FILIAL +  C8_NUM + C8_FORNECE + C8_LOJA) == xFilial("SC8") + _cNum + _cFornece + _cLoja   

		DBSELECTAREA("SB1")
		DBSetOrder(1)
		DBSeek(xFilial()+SC8->C8_PRODUTO)

		DBSELECTAREA("SBM")
		DBSetOrder(1)
		DBSeek(xFilial()+SB1->B1_GRUPO)      

		DBSELECTAREA("SB5")
		dbSetOrder(1)
		If SB5->(dbSeek( xFilial("SB5") + SC8->C8_PRODUTO ))
			_cDescPro := SB5->B5_CEME   
		Else                                                        
			_cDescPro := SB1->B1_DESC
		EndIf
		
		aAdd( (oHtml:ValByName( "t.1"     )), SC8->C8_ITEM    )
		AAdd( (oHtml:ValByName( "t.2"    )), SC8->C8_PRODUTO)
		AAdd( (oHtml:ValByName( "t.3"    )), Alltrim(_cDescPro)) 
		AAdd( (oHtml:ValByName( "t.4"    )), Iif(Alltrim(SC8->C8_OBS)<> "" ,"("+Alltrim(SC8->C8_OBS)+")","") )
		AAdd( (oHtml:ValByName( "t.5"    )), SC8->C8_UM)
		AAdd( (oHtml:ValByName( "t.6"    )), TRANSFORM(SC8->C8_QUANT,PesqPict("SC8","C8_QUANT")))
		AAdd( (oHtml:ValByName( "t.7"    )), "")
		AAdd( (oHtml:ValByName( "t.9"    )), "")
		AAdd( (oHtml:ValByName( "t.10"   )), "")
		AAdd( (oHtml:ValByName( "t.10a"   )), DTOC(SC8->C8_DATPRF))
//		AAdd( (oHtml:ValByName( "t.11"   )), TRANSFORM(SC8->C8_PRAZO,'@E 999'))
		AAdd( (oHtml:ValByName( "t.11"   )), 0)

	
		SC8->(dbSkip()) 
	Enddo


	aAdd( oProcess:aParams, xFilial("SC8"))						
	aAdd( oProcess:aParams, _cNum)                     
	aAdd( oProcess:aParams, _cFornece)                     
	aAdd( oProcess:aParams, _cLoja)                     
			
//	oHtml:ValByName( "datetime"     , DTOC(MSDATE()) + " às " + left(time(),5) )
//	oHtml:ValByName( "procid"       , oProcess:fProcessID  )
	       
	oProcess:nEncodeMime := 0
	cMailId    := oProcess:Start("\workflow\emp"+cEmpAnt+"\wfct\")  // Crio o processo e gravo o ID do processo de Workflow
	         
	// ARRAY DE RETORNO
	_aReturn := {}
	AADD(_aReturn, oProcess:fProcessId)

	chtmlfile  := cmailid + ".htm"

	oProcess:= TWFProcess():New( "000002", "Cotacao Eletronica" )
	oProcess:NewTask( "Cotacao de Precos", "\WORKFLOW\HTML\CVFORN_MS.HTM" )
	oProcess:cSubject 		:= "Cotação Eletrônica de Precos No." + _cNum
	oProcess:nEncodeMime 	:= 0
	oProcess:cTo      		:= SA2->A2_EMAIL
	oProcess:NewVersion(.T.)            
	
 	oHtml     				:= oProcess:oHTML
 
 	oHtml:ValByName( "C8_NUM"		, _cNum )
	oHtml:ValByName( "A2_NOME"		, SA2->A2_NREDUZ )
	oHtml:ValByName( "C8_FORNECE"	, SA2->A2_COD )
	oHtml:ValByName( "C8_LOJA"		, SA2->A2_LOJA )  
	oHtml:ValByName( "cMailID"		, Alltrim(GetMv("MV_WFHTTPE"))+"/workflow/emp"+cempant+"/wfct/"+chtmlfile)
	oProcess:Start()

	If Len(_aReturn) > 0 
		_lProcesso 	:= .T.
		DBSELECTAREA("SC8")
		DBSetOrder(1)
		DBSeek(xFilial("SC8")+_cNum + _cFornece + _cLoja)
		While !SC8->(EOF()) .AND. SC8->(C8_FILIAL +  C8_NUM + C8_FORNECE + C8_LOJA) == xFilial("SC8") + _cNum + _cFornece + _cLoja   

			Reclock("SC8",.F.)
			SC8->C8_XWF			:= IIF(EMPTY(_aReturn[1])," ","1")  	// Status 1 - envio para aprovadores / branco-nao houve envio
// 			SC8->C8_XWFID		:= _aReturn[1]							// Rastreabilidade
			MSUnlock()
			SC8->(dbSkip()) 
			 
		Enddo	
	Endif	

	Return 


/*
Programa.: 	RecCT
Autor....:	Pedro Augusto
Data.....: 	26/08/14 
Descricao: 	Rotina de tratamento do retorno com a cotacao para os fornecedores da rotina "Atualiza cotacao"
Uso......: 	MIRASSOL
*/
User function RecCT(oProcess)     
	Local _cUser := ""
	ChkFile("SC8")
	ChkFile("SE4")
		
	U_CONSOLE("2 - Processa O RETORNO DO EMAIL")

	_cNUM    	:= oProcess:aParams[2]
	_cFORNECE	:= oProcess:aParams[3]
	_cLOJA 		:= oProcess:aParams[4]
	_cEMAIL 	:= ALLTRIM(oProcess:cTo)
	_cWFID		:= oProcess:fProcessID

	U_CONSOLE("2 - Cotacao : " + _cNum + " - Forn.: " + _cFornece +  " - WFID: " + _cWFID)
	
	_cOPC	     := oProcess:oHtml:RetByName("OPC")
	_cOBS	     := oProcess:oHtml:RetByName("OBS")
	_cContato    := oProcess:oHtml:RetByName("CONTATO")
	_cCond  	 := oProcess:oHtml:RetByName("E4_COND")
	_cTpFrete  	 := Substr(oProcess:oHtml:RetByName("TPFRETE"),1,1)
	_nFrete  	 := Iif(_cTpFrete="C",Val(oProcess:oHtml:RetByName("FRETE")),0)
	_lOk 		:= .F.
	_lEncerrado	:= .F.
	aProd		:= {}

	if valtype(oProcess:oHtml:RetByName("t.1")) <> "U"
		nQuant := LEN(oProcess:oHtml:RetByName("t.1"))
	endif
			
	FOR _nInd := 1 TO nQuant
		_cITEM  :=   iif(valtype(oProcess:oHtml:RetByName("t.1"))  <>"U",     oProcess:oHtml:RetByName("t.1" )[_nind] ,"")
		_nQUANT :=   iif(valtype(oProcess:oHtml:RetByName("t.6" )) <>"U", val(oProcess:oHtml:RetByName("t.6" )[_nind]), 0)
		_nPRECO :=   iif(valtype(oProcess:oHtml:RetByName("t.7" )) <>"U", val(oProcess:oHtml:RetByName("t.7" )[_nind]), 0)
		_nVLDESC:=   iif(valtype(oProcess:oHtml:RetByName("t.9" )) <>"U", val(oProcess:oHtml:RetByName("t.9" )[_nind]), 0)
		_nALIIPI:=   iif(valtype(oProcess:oHtml:RetByName("t.10")) <>"U", val(oProcess:oHtml:RetByName("t.10")[_nind]), 0)
		_nVALIPI:=   iif(valtype(oProcess:oHtml:RetByName("t.10")) <>"U", ((_nPRECO*_nQUANT)-_nVLDESC)*(_nALIIPI/100) , 0)  
		_nPRAZO :=   iif(valtype(oProcess:oHtml:RetByName("t.11")) <>"U", val(oProcess:oHtml:RetByName("t.11")[_nind]), 0)

		dbSelectArea("SC8")

		dbSetOrder(1)
		IF SC8->(dbSeek( xFilial("SC8") + _cNUM + _cFORNECE + _cLOJA + _cITEM))  
			_cUser := SC8->C8_XUSER
			IF Alltrim(SC8->C8_NUMPED) == "" 
				CONOUT("Atualizando dados do item: " + _cItem )
				RecLock("SC8",.F.)                              
				If _cOpc == "N" // Recusa de participacao
					SC8->C8_XOBSWF  	:= "Recusou participar: "+_cOBS
				Else
					SC8->C8_PRECO  	:= _nPRECO
					SC8->C8_TOTAL  	:= Round(_nQUANT * _nPRECO,2)
					SC8->C8_ALIIPI 	:= _nALIIPI
					SC8->C8_PRAZO  	:= _nPRAZO
					SC8->C8_COND   	:= _cCOND
	//				SC8->C8_OBS    	:= LEFT(_cOBS,30)	//ALTERADO PARA 30 ESTAVA 60 POSICOES
					SC8->C8_CONTATO	:= LEFT(_cCONTATO,15)
					SC8->C8_TPFRETE	:= _cTpFrete
					SC8->C8_VALFRE	:= Iif(_nInd=1,_nFrete,0)
					SC8->C8_TOTFRE	:= _nFrete
					SC8->C8_VLDESC 	:= _nVLDESC
					SC8->C8_VALIPI 	:= _nVALIPI
					SC8->C8_XOBSWF  := _cOBS
				Endif   

				SC8->C8_XWF := Iif(_cOpc == "S","2","3")
				MsUnlock()
				
			ELSE
				CONOUT("Item: " + _cItem + " nao processado, verifique cotacao... ")
			ENDIF
		Endif
	NEXT
	oProcess:Finish() // FINALIZA O PROCESSO

	U_EnviaAV(_cNUM, _cFORNECE, _cLOJA, _cUser, _cOpc, _cObs ) // elementos do array: 	C8_NUM, C8_FORNECE, C8_LOJA
 
	RETURN

/*
Programa.: 	EnviaAV
Autor....:	Pedro Augusto
Data.....: 	26/08/2014
Descricao: 	Apos o processamento da resposta do fornecedor dispara aviso ao usuario protheus (C8_XUSER)
Uso......: 	MIRASSOL
*/
User Function EnviaAV(_cNum, _cFornece, _cLoja, _cUser, _cOpc, _cObs )

   	DbSelectArea("SA2")
   	DbSetOrder(1)
   	DbSeek(xFilial("SA2") + _cFornece + _cLoja)

	oProcess:= TWFProcess():New( "000003", "Aviso - Cotacao de Precos respondida" )
	oProcess:NewTask( "Cotacao de Precos respondida", "\WORKFLOW\HTML\AVFORN_MS.HTM" )
	oProcess:nEncodeMime 	:= 0
	oProcess:cSubject 		:= "Cotacao Eletrônica de Precos No." + _cNum + " respondida."
	oProcess:cTo      		:= UsrRetMail(_cUser) ///// -> Mandar para o usuario que gerou a cotacao /////////////////////////////////////
	oProcess:NewVersion(.T.)            
	
 	oHtml     				:= oProcess:oHTML
 
	oHtml:ValByName( "A2_NOME"		, SA2->A2_NREDUZ )
 	oHtml:ValByName( "C8_NUM"		, _cNum + Iif(_cOpc == "N"," Recusou-se a participar",""))
 	oHtml:ValByName( "C8_XOBSWF"	, Iif(_cOpc == "N"," Recusou-se a participar: ","")+_cObs)
	oHtml:ValByName( "C8_FORNECE"   , SA2->A2_COD )
	oHtml:ValByName( "C8_LOJA"		, SA2->A2_LOJA )  
	oHtml:ValByName( "datetime"     , DTOC(MSDATE()) + " às " + left(time(),5) )
    
	oProcess:Start()

	Return 
	