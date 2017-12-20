#include "protheus.ch"      
#include "Topconn.ch"      

/*
ฑฑษออออออออออัอออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ MT130WF บ Autor ณ Pedro Augusto Cardoso บ Data mar/2014    บฑฑ
ฑฑฬออออออออออุอออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Ponto de Entrada para mostrar o numero da cotacao gerada   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
*/
User Function MT130WF()
	Local aArea		:= GetArea()
	MsgInfo("Cota็ใo no. " + PARAMIXB[1] +" gerada com sucesso!", "Cota็ใo Gerada")
	RestArea(aArea)
	Return .T.