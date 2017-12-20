#Include 'TOTVS.CH'

User Function MatGraph(nTipoGraph)

	Local lGraph3D := .T. // .F. Grafico 2 dimensoes  - .T. Grafico 3 dimensoes
	Local lMenuGraph := .T. // .F. Nao exibe menu  - .T. Exibe menu para mudar o tipo de grafico  
	Local lMudaCor := .T. 
	//Local nTipoGraph := 2 
	Local nCorDefault := 1 
	Local aDados := {{"Valor 1", 100}, {"Valor 2", 500},{"Valor 3", 1000}}
	Local aStru := {}
	Local cArquivo := CriaTrab(,.F.)
	Local i

	Default nTipoGraph := 1 	               

	If MsgYesNo("Deseja exibir o grafico com os dados do array?") 	

		//o grafico sera montado a partir dos dados do array aDados    	

		MatGraph("Graficos",lGraph3D,lMenuGraph,lMudaCor,nTipoGraph,nCorDefault,aDados)

	Else	

		aStru := {	{"EixoX"		, "C", 20, 0}, {"EixoY"		, "N", 8, 2} }	

		dbCreate(cArquivo,aStru)	
		dbUseArea(.T.,,cArquivo,"GRAFICO",.F.,.F.)		

		For i:=1 to Len(aDados)		

			("GRAFICO")->( dbAppend() )		
			("GRAFICO")->(EixoX) := aDados[i][1]		
			("GRAFICO")->(EixoY) := aDados[i][2]	

		Next i		
		//o grafico sera montado a partir dos dados da area de trabalho  "GRAFICO"	

		MatGraph("Graficos",lGraph3D,lMenuGraph,lMudaCor,nTipoGraph,nCorDefault,,"GRAFICO",{"EixoX","EixoY"})	

		("GRAFICO")->( dbCloseArea() )

	EndIf	

Return