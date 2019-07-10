#INCLUDE "Protheus.ch"
/*
Programa.: 	AVALCOPC
Autor....:	Pedro Augusto
Data.....: 	26/08/2014
Descricao: 	Ponto de entrada acionado apos a "analise da cotacao": irá
            disparar um e-mail de agradecimento aos fornecedores que 
            nao venceram a cotacao.
Uso......: 	MIRASSOL
*/
User Function AVALCOPC()
	Local _aAreaSC7  := GetArea("SC7")
	Local _aAreaSC8  := GetArea("SC8")
	Local _cNumCot   := SC7->C7_NUMCOT
	Local _cNumPC    := SC7->C7_NUM
	Private _aParticip := {}

	MsgInfo("Numero do pedido gerado: "+_cNumPC,"Pedido gerado com sucesso")

	dbSelectArea("SC8")
	SC8->(dbSetOrder(1))
	SC8->(dbSeek(xFilial("SC8")+SC7->C7_NUMCOT))
	
	While SC8->C8_FILIAL = xFilial("SC8") .and. SC8->C8_NUM = _cNumCot .and. !SC8->(Eof())
	    If SC8->C8_NUMPED <> _cNumPC .and. SC8->C8_XWF == '2' //perdedores 
			nPos := aScan( _aParticip, { |x| x[1]+x[2]+x[3] == SC8->C8_NUM + SC8->C8_FORNECE + SC8->C8_lOJA } )
			If nPos == 0 
				aAdd(_aParticip,{SC8->C8_NUM, SC8->C8_FORNECE, SC8->C8_lOJA})		
			EndIf
		Endif	
		SC8->(DbSkip())
	Enddo	
	
	//Envia notificacao de agradecimento //
	
	If Len(_aParticip) > 0
		For i = 1 to Len(_aParticip)
			U_EnviaAG(_aParticip[i][1],_aParticip[i][2],_aParticip[i][3]) // elementos do array: 	C8_NUM, C8_FORNECE, C8_LOJA
		Next i
	Endif
	
	
	SC7->(RestArea(_aAreaSC7))
	SC8->(RestArea(_aAreaSC8))

	Return .T.
	                                                                   
/*
Programa.: 	EnviaAG
Autor....:	Pedro Augusto
Data.....: 	26/08/2014
Descricao: 	Rotina de envio de e-mail de agradecimento aos fornecedores que 
            nao venceram a cotacao.
Uso......: 	MIRASSOL
*/
User Function EnviaAG(_cNum, _cFornece, _cLoja)

   	DbSelectArea("SA2")
   	DbSetOrder(1)
   	DbSeek(xFilial("SA2") + _cFornece + _cLoja)

	oProcess:= TWFProcess():New( "000001", "Agradecimento" )
	oProcess:NewTask( "Agradecimento - Cotacao de Precos", "\WORKFLOW\HTML\AGFORN_MS.HTM" )
	oProcess:nEncodeMime 	:= 0
	oProcess:cSubject 		:= "Agradecimento - Cotação Eletrônica de Precos No." + _cNum
	oProcess:cTo      		:= SA2->A2_EMAIL
	oProcess:NewVersion(.T.)            
	
 	oHtml     				:= oProcess:oHTML
    // Preencher os campos do convite : CVFORN_SITEL.HTM //
 
	oHtml:ValByName( "A2_NOME"		, SA2->A2_NREDUZ )
 	oHtml:ValByName( "C8_NUM"		, _cNum )
	oHtml:ValByName( "C8_FORNECE"   , SA2->A2_COD )
	oHtml:ValByName( "C8_LOJA"		, SA2->A2_LOJA )  
	oHtml:ValByName( "datetime"     , DTOC(MSDATE()) + " às " + left(time(),5) )
    
	oProcess:Start()

	Return                                                
