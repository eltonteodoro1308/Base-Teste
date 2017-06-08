#Include 'Totvs.Ch'

User Function testeba()
	RpcSetEnv("99","01")
	__cInterNet := Nil
	oGrid:=FWGridProcess():New("MATA330","teste","teste do processamento",{|lEnd| u_testeba1(oGrid,@lEnd)},"MTA330","u_testeba2")
	oGrid:SetMeters(2)
	oGrid:SetThreadGrid(5)
	oGrid:Activate()
	If oGrid:IsFinished()
		alert("fim")
	Else
		alert("fim com erro")
	EndIf
Return
User Function Testeba1(oGrid,lEnd)
	Local nX,nY
	oGrid:SetMaxMeter(4,1,"teste1")
	For nX := 1 To 4
		oGrid:SetMaxMeter(10,2,"teste2")
		For nY := 1 To 10
			If !oGrid:CallExecute("callexecute is load",Iif(nX==5.And.nY==10,0,1))
				lEnd := .T.
			EndIf
			oGrid:SetIncMeter(2)
			If lEnd
				Exit
			EndIf
		Next nY
		If lEnd
			Exit
		EndIf
		oGrid:SetIncMeter(1)
	Next nX
Return
//Exemplo de uso de sem Grid
User Function Testebc2(oGrid,lEnd)
	Local nX,nY
	oGrid:SetMaxMeter(4,1,"teste1")
	For nX := 1 To 4
		oGrid:SetMaxMeter(10,2,"teste2")
		For nY := 1 To 10
			oGrid:SetIncMeter(2)
			If lEnd
				Exit
			EndIf
			Sleep(1000)
		Next nY
		If lEnd
			Exit
		EndIf
		oGrid:SetIncMeter(1)
	Next nX
Return
User Function Testeba2(cParm,lErro)
	Sleep(10000)
Return(.T.)