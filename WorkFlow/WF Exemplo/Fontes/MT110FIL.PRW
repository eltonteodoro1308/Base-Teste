#include "rwmake.ch"
/*  
============================================================================
Programa.: MT110FIL  
Autor....: Pedro Augusto
Data.....: Dezembro/2014
Descricao: Ponto de entrada para filtrar somente as Solicitacoes do 
		   usuario logado/aprovador/comprador. 
Uso......: MIRA OTM
============================================================================
*/
User Function Mt110Fil()
	//Define variaveis
	Local _aArea    := GetArea()
	Local _nCall    := 1
	Local _cString  := " "
	Local _cFiltro  := " "
	
	Pergunte("MTA110",.f.)
	
	//Carrega em variavel a pilha de chamada de funcoes
	While !Empty(ProcName(_nCall))
		_cString +=AllTrim(ProcName(_nCall)) + "/"
		_nCall ++
	EndDo
	
	//Verifica se a chamada nao tem origem no system tracker.
	If !("MATRKSHOW" $ Upper(_cString))
	   	//Se nao tiver origem no system tracker e o usuario logado for comprador, nao precisa existir filtro.
	   	DbSelectArea('SY1')
	   	DbSetOrder(3)             
	   	If !DbSeek( xFilial('SY1')+__cUserId ) // nao é comprador, aplica filtro
			_cFiltro := "C1_USER == '"+__cUserID+ "' "  // somente SCs do usuario
//			_cFiltro += " .or. C1_APROV == '"+__cUserID+ "'"   
		Endif
	Endif
	
	RestArea(_aArea)
	
	Return(_cFiltro)
