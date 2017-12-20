User Function MyMata110()

	Local aCabec := {}
	Local aItens := {}
	Local aLinha := {}
	Local nX     := 0
	Local nY     := 0
	Local cDoc   := ""
	Local lOk    := .T.         

	Private lMsHelpAuto := .T.
	PRIVATE lMsErroAuto := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Abertura do ambiente                                         |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	ConOut(Repl("-",80))
	ConOut(PadC(OemToAnsi("Teste de Inclusao de 2 solicitacoes de compra com 2 itens cada"),80))

	PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "COM" TABLES "SC1","SB1"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Verificacao do ambiente para teste                           |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbSelectArea("SB1")
	DbSetOrder(1)

	If !SB1->(MsSeek(xFilial("SB1")+"01"))	

		lOk := .F.	

		ConOut(OemToAnsi("Cadastrar produto: 01"))

	EndIf

	If !SB1->(MsSeek(xFilial("SB1")+"02"))	

		lOk := .F.	

		ConOut(OemToAnsi("Cadastrar produto: 02"))

	EndIf

	If lOk	

		ConOut(OemToAnsi("Inicio: ")+Time())		

		For nY := 1 To 2		

			aCabec := {}		
			aItens := {}		

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿		
			//| Verifica numero da SC       |		
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		

			cDoc := GetSXENum("SC1","C1_NUM")		

			SC1->(dbSetOrder(1))		

			While SC1->(dbSeek(xFilial("SC1")+cDoc))			

				ConfirmSX8()			

				cDoc := GetSXENum("SC1","C1_NUM")		

			EndDo					

			aadd(aCabec,{"C1_NUM"    ,cDoc})		
			aadd(aCabec,{"C1_SOLICIT","Administrador"})		
			aadd(aCabec,{"C1_EMISSAO",dDataBase})		

			For nX := 1 To 2			

				aLinha := {}			

				aadd(aLinha,{"C1_ITEM"   ,StrZero(nx,len(SC1->C1_ITEM)),Nil})			
				aadd(aLinha,{"C1_PRODUTO","01",Nil})			
				aadd(aLinha,{"C1_QUANT"  ,1   ,Nil})			
				aadd(aItens,aLinha)		

			Next nX		

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿		
			//| Teste de Inclusao                                            |		
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		

			MSExecAuto({|x,y| mata110(x,y)},aCabec,aItens)		

			If !lMsErroAuto			

				ConOut(OemToAnsi("Incluido com sucesso! ")+cDoc)		

			Else			

				ConOut(OemToAnsi("Erro na inclusao!"))		

			EndIf	

		Next nY	

		ConOut(OemToAnsi("Fim  : ")+Time())

	EndIf

	RESET ENVIRONMENT

Return(.T.)