#include "rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³MT110BLO  ºAutor  ³ Pedro Augusto      º Data ³  NOV/2014   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada para nao permitir que o usuario libere a  º±±
±±º          ³ SC se este nao for o aprovador (campo SAI->AI_XAPROV) asso º±±
±±º          ³ ciado ao solicitante                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MIRA OTM                                                  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MT110BLO()                                         
	Local aAreaSC1  := SC1->(GetArea())
	Local _cUser 	:= SC1->C1_USER 
	Local _cAprov 	:= "" 

	DbSelectArea("SAK")
	DbSetOrder(2)
	If SAK->(DbSeek(xFilial("SAK")+SAI->AI_APROV)) 
		_cAprov := SAK->AK_USER
	Endif   

	If _cAprov <> __cUserID
		MsgAlert("Esta solicitação não pode ser desbloqueada, pois você não é aprovador desta solicitacao.")
	   	Return .F.
	Else
	   	Return .T.
	Endif

	RestArea(aAreaSC1)
    Return lRet
