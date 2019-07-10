#include "rwmake.ch"
/*
Programa.: 	³T120GOK
Autor....:	Pedro Augusto
Data.....: 	20/08/2015
Descricao: 	Ponto de Entrada na gravacao do pedido:no momento em que
            o pedido de compra é gerado
Uso......:  TERRACOM
*/
User Function MT120GOK
	Local _aArea	:= GetArea()
	DbSelectArea("SC7")
	DbSetOrder(1)
	DbSeek(xFilial("SC7")+ca120num)

// 	tratativa para Manutencao de frotas - Apresentar o numero do pedido //
//	If FunName() == "MNTA650"
//		MsgInfo("Numero do pedido gerado: "+ca120num,"Pedido gerado com sucesso")
//	Endif

	While SC7->C7_FILIAL + SC7->C7_NUM == xFilial("SC7")+ca120num .AND. !SC7->(Eof())
    	Reclock("SC7",.F.)
		SC7->C7_XWF			:= ""   	                        // Status 1 - envio email
		SC7->C7_XWFID		:= ""   						// Rastreabilidade    
		MSUnlock()  
		DbSkip() 
	Enddo         

	RestArea(_aArea)  

	Return .T.
