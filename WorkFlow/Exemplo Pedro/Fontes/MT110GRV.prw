#include "protheus.ch"
/*  
============================================================================
Programa.: 	MT110GRV  
Autor....:	Pedro Augusto
Data.....: 	AGOSTO/2014
Descricao: 	PE chamado apos a gravacao de cada item da solicitacao de compra. 
			Atualizar os campos de controle do workflow
Uso......: 	MIRA OTM
============================================================================
*/

User Function MT110GRV()
	Local aArea := Getarea()

	RECLOCK("SC1",.F.)
	SC1->C1_APROV	:= "B"
	SC1->C1_WF		:= " "
	SC1->C1_WFID	:= " "
	SC1->C1_WFOBS	:= " "
	MSUNLOCK()  
	RETURN
	                   	