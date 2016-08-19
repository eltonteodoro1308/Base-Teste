#include "protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MA103BUT  �Autor  � Alt Ideias         � Data �  06/12/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada para adicionar botoes aa barra de ferra-  ���
���          � mentas do Documento de Entrada. Utilizado para replicar TES���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function ma103But()
return {{"E5", {|| U_x103TES() }, "Replicar TES", "Repl. TES"}}


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �x103TES   �Autor  � Alt Ideias         � Data �  06/12/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Utilizado para replicar TES em todos os itens da NF.       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function x103TES()
local nOld := n

if ConPad1(,,,"SF4",,,.F.) .and. MaAvalTes("E",SF4->F4_CODIGO)

	for n := 1 to len(aCols)
		GDFieldPut("D1_TES", SF4->F4_CODIGO, n)
		MaFisRef("IT_TES","MT100",SF4->F4_CODIGO)                                           
	next n

endIf    

n := nOld

return