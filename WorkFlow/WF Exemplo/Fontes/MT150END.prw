#Include 'Rwmake.ch'
/*
Programa.: 	AVALCOPC
Autor....:	Pedro Augusto
Data.....: 	26/08/2014
Descricao: 	Ponto de entrada para tratar o campo C8_XWF.
Uso......: 	MIRASSOL
*/

User Function MT150END        
	Local aAreaA := GetArea()
	Local _cNum 	:= SC8->C8_NUM             
	Local _cFornece := SC8->C8_FORNECE
	Local _cLoja	:= SC8->C8_LOJA 
	
	If ParamIXB[1] == 2     // Novo fornecedor
		DbSelectArea('SC8')
		RecLock('SC8',.f.)
		SC8->C8_XUSER := __cUserId
		MsUnLock()
		
		RestArea( aAreaA )
			
	ElseIf ParamIXB[1] == 3 // Atualizacao da cotacao

		DBSELECTAREA("SC8")
		DBSetOrder(1)
		DBSeek(xFilial("SC8")+_cNum + _cFornece + _cLoja)
		While !SC8->(EOF()) .AND. SC8->(C8_FILIAL +  C8_NUM + C8_FORNECE + C8_LOJA) == xFilial("SC8") + _cNum + _cFornece + _cLoja   

			Reclock("SC8",.F.)
			SC8->C8_XWF		:= " " 
			MSUnlock()
			SC8->(dbSkip()) 
			 
		Enddo	
	Endif
	Return .t.
	
