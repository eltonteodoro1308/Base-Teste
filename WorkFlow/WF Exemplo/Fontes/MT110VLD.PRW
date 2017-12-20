#Include "Protheus.ch"
/*  
============================================================================
Programa.: MT110Vld  
Autor....: Pedro Augusto
Data.....: Dezembro/2014
Descricao: Ponto de entrada antes da montagem da GetDados da rotina de
           Solicitacao de Compras, nas opcoes Inclui, Altera e Exclui.
           Verifica se o usuario esta devidamente cadastrado como     
           Solicitante e se ha aprovador associado a ele         
Uso......: 	MIRA OTM
============================================================================
*/
User Function MT110VLD
//	Local cParam1  := Paramixb[1]		//3=Inclusao, 4=Alteracao, 6=Exclusao
	Local lRetorna := .T.   
	Local aArea    := GetArea()
	Local cGrupo   := ""

	dbSelectArea("SAI")
	dbSetOrder(2)
	If !SAI->(dbSeek(xFilial("SAI")+__cUserId))   
	    MsgStop("ATENCAO! Usuário não está cadastrado como solicitante."+Chr(13)+Chr(10)+Chr(13)+Chr(10)+;
	             "Por favor, entre em contato com o departamento de COMPRAS e informe esta ocorrencia.","Solicitação de compra")
	    lRetorna := .F.
	Else
		If Alltrim(SAI->AI_APROV) == ''     
		    MsgStop("ATENCAO! Usuario está cadastrado na tabela de solicitantes, mas nao há aprovador associado."+Chr(13)+Chr(10)+Chr(13)+Chr(10)+;
			             "Por favor, entre em contato com o departamento de COMPRAS e informe esta ocorrencia.","Solicitação de compra")
		    lRetorna := .F.  
		EndIf
	EndIf
	RestArea(aArea)
	Return(lRetorna)  
	