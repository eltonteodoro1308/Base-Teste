#include "totvs.ch"
user function exBGetKey()
	local oDlg := nil, oEdit := nil
	Local cTMultiget1 := "", cTGet1 := ""
	Local cCombo1
	DEFINE DIALOG oDlg TITLE "tSimpleEditor" FROM 180, 180 TO 640, 900 PIXEL
	oEdit := tSimpleEditor():New(0, 0, oDlg, 100, 100)
	oEdit:Load("TSimpleEditor")
	oEdit:bGetKey := {|self,cText,ckey|texto(self,cText,ckey,oDlg)}

	cTMultiget1 := "TMultiget"
	oMulti := TMultiget():New(100,00,{|u|if(Pcount()>0,cTMultiget1:=u,cTMultiget1)},oDlg,100,100,,,,,,.T.)
	oMulti:bGetKey := {|self,cText,nkey|texto(self,cText,nkey,oDlg)}

	cTGet1 := "TGet            "
	oTGet1 := TGet():New( 000,100,{|u|if(Pcount()>0,cTGet1:=u,cTGet1)},oDlg,096,009,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGet1,,,, )
	oTGet1:bGetKey := {|self,cText,nkey|texto(self,cText,nkey,oDlg)}

	oTButton1 := TButton():New( 200, 002, "Off SimpleEditor",oDlg,{||oEdit:bGetKey := {||} }, 30,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton2 := TButton():New( 200, 035, "Off Multiget",oDlg,{||oMulti:bGetKey := {||} }, 30,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton3 := TButton():New( 200, 068, "Off TGet",oDlg,{||oTGet1:bGetKey := {||} }, 30,10,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE DIALOG oDlg CENTERED
return

static function texto (objeto,ctext,nKey,oDlg)
	local realkey := nkey, tecla := ""
	// O exemplo abaixo serve para identificar qual tecla foi pressionada para um caso geral.
	//
	// Se for necessário apenas testar uma tecla específica, pode-se testar diretamente o nKey, por exemplo:
	// Necessário verificar se a tecla pressionada é a letra R, pode-se fazer o seguinte:
	// if nKey == 82 //0x52
	//   conout("tecla R pressionada")
	// endif
	//
	// Se precisa saber se a tecla CONTROL-R for pressionada presisa primeiramente realizar um OR entre o código da tecla R com o código do modifier CONTROL, por exemplo:
	// Local controlR := NOR(82, 67108864)
	// if nKey == controlR
	//   conout("tecla Control-R pressionada")
	// endif
	//
	// Se precisa saber se a tecla R for pressionada independente de modifier, deve-se fazer o seguinte:
	// Local realKey := NAND(nKey, 33554431) // Número utilizado para isolar os 25 bits da tecla sem os modifiers
	// if nKey == 82 //0x52
	//   conout("tecla R pressionada")
	// endif

	// Os valores abaixo foram retirados da tabela disponível em: http://doc.qt.io/qt-5/qt.html#KeyboardModifier-enum
	local kmodifiers := {33554432 /*Shift 0x02000000*/, 67108864 /*Control 0x04000000*/, 134217728 /*Alt 0x08000000*/, 268435456 /*Meta 0x10000000*/, 536870912 /*KeyPad 0x20000000*/, 1073741824 /*GroupSwitch 0x40000000*/}

	// O código em nKey se refere ao código da tecla pressianada com uma operação lógica OR com os modifiers pressionados (Control, Shift, etc)

	// A operação abaixo serve para saber se existe algum modifier pressionado
	isMod := NAND(nKey, NOR(kmodifiers[1],kmodifiers[2],kmodifiers[3],kmodifiers[4],kmodifiers[5],kmodifiers[6])) > 0

	if isMod
		// Para pegar a tecla real que foi pressionada (sem o modifier) é necessário isolar só os 25 bits menos signaficativos por isso é feito o AND abaixo
		realkey := NAND(nKey, 33554431) //Not de kmodifiers, para isolar a tecla sem o modifier

		// Aqui eu testo todos os modifiers para saber qual está pressionado
		iif(NAND(nKey, kmodifiers[1]) > 0,  tecla += "SHIFT-",)
		iif(NAND(nKey, kmodifiers[2]) > 0,  tecla += "CONTROL-",)
		iif(NAND(nKey, kmodifiers[3]) > 0,  tecla += "ALT-",)
		iif(NAND(nKey, kmodifiers[4]) > 0,  tecla += "META-",)
		iif(NAND(nKey, kmodifiers[5]) > 0,  tecla += "KP-",)
		iif(NAND(nKey, kmodifiers[6]) > 0,  tecla += "GW-",)
	endif

	// Os códigos abaixo de 255 são (em sua marioria) "printáveis", o resto é necessário verificar a tabela
	if realkey < 255
		tecla += chr(realkey)
	else
		// verificar tabela em: http://doc.qt.io/qt-5/qt.html#Key-enum
		tecla += "??"
	endif

	conout("Tecla - " + tecla)

	conout(ctext)

return .T.