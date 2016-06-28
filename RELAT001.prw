#Include 'Protheus.ch'
#Include 'Protheus.ch'
#INCLUDE 'TOPCONN.CH'

User Function relat001()
	Local oReport := nil
	Local cPerg:= Padr("RELAT001",10)
	
	//Incluo/Altero as perguntas na tabela SX1
	AjustaSX1(cPerg)
	//gero a pergunta de modo oculto, ficando dispon�vel no bot�o a��es relacionadas
	Pergunte(cPerg,.F.)
	
	oReport := RptDef(cPerg)
	oReport:PrintDialog()
Return

Static Function RptDef(cNome)
	Local oReport := Nil
	Local oSection1:= Nil
	Local oSection2:= Nil
	Local oBreak
	Local oFunction
	
	/*Sintaxe: TReport():New(cNome,cTitulo,cPerguntas,bBlocoCodigo,cDescricao)*/
	oReport := TReport():New(cNome,"Relat�rio NCM x Cadastro Produtos",cNome,{|oReport| ReportPrint(oReport)},"Descri��o do meu relat�rio")
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	
	//Monstando a primeira se��o
	//Neste exemplo, a primeira se��o ser� composta por duas colunas, c�digo da NCM e sua descri��o
	//Iremos disponibilizar para esta se��o apenas a tabela SYD, pois quando voc� for em personalizar
	//e entrar na primeira se��o, voc� ter� todos os outros campos dispon�veis, com isso, ser�
	//permitido a inser��o dos outros campos
	//Neste exemplo, tamb�m, j� deixarei definido o nome dos campos, mascara e tamanho, mas voc�
	//ter� toda a liberdade de modific�-los via relatorio.
	oSection1:= TRSection():New(oReport, "NCM", {"SYD"}, , .F., .T.)
	TRCell():New(oSection1,"YD_TEC"		,"TRBNCM","NCM"  		,"@!",40)
	TRCell():New(oSection1,"YD_DESC_P"  ,"TRBNCM","DESCRICAO"	,"@!",200)
	
	//A segunda se��o, ser� apresentado os produtos, neste exemplo, estarei disponibilizando apenas a tabela
	//SB1,poderia ter deixado tamb�m a tabela de NCM, com isso, voc� poderia incluir os campos da tabela
	//SYD.Semelhante a se��o 1, defino o titulo e tamanho das colunas
	oSection2:= TRSection():New(oReport, "Produtos", {"SB1"}, NIL, .F., .T.)
	TRCell():New(oSection2,"B1_COD"   	,"TRBNCM","Produto"		,"@!",30)
	TRCell():New(oSection2,"B1_DESC"  	,"TRBNCM","Descri��o"	,"@!",100)
	TRCell():New(oSection2,"B1_LOCPAD"	,"TRBNCM","Arm.Padrao"	,"@!",20)
	TRCell():New(oSection2,"B1_POSIPI"	,"TRBNCM","NCM"			,"@!",30)
	
	TRFunction():New(oSection2:Cell("B1_COD"),NIL,"COUNT",,,,,.F.,.T.)
	
	oReport:SetTotalInLine(.F.)
	
	//Aqui, farei uma quebra  por se��o
	oSection1:SetPageBreak(.T.)
	oSection1:SetTotalText(" ")
Return(oReport)

Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local cQuery    := ""
	Local cNcm      := ""
	Local lPrim 	:= .T.
	
	//Monto minha consulta conforme parametros passado
	cQuery := "	SELECT YD_TEC,YD_DESC_P,B1_COD,B1_DESC,B1_LOCPAD,B1_POSIPI,B1_IPI,YD_PER_IPI "
	cQuery += "	FROM "+RETSQLNAME("SYD")+" SYD "
	cQuery += "	LEFT JOIN "+RETSQLNAME("SB1")+" SB1 ON SB1.D_E_L_E_T_='' AND B1_FILIAL='"+xFilial("SB1")+"' AND B1_POSIPI=YD_TEC "
	cQuery += "	WHERE SYD.D_E_L_E_T_=' ' "
	cQuery += "	AND YD_FILIAL='"+xFilial("SYD")+"' "
	cQuery += " AND YD_TEC BETWEEN '"+mv_par01+"' AND '"+mv_par02+"'"
	cQuery += "	ORDER BY YD_TEC,B1_COD "
	
	//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
	IF Select("TRBNCM") <> 0
		DbSelectArea("TRBNCM")
		DbCloseArea()
	ENDIF
	
	//crio o novo alias
	TCQUERY cQuery NEW ALIAS "TRBNCM"
	
	dbSelectArea("TRBNCM")
	TRBNCM->(dbGoTop())
	
	oReport:SetMeter(TRBNCM->(LastRec()))
	
	//Irei percorrer todos os meus registros
	While !Eof()
		
		If oReport:Cancel()
			Exit
		EndIf
		
		//inicializo a primeira se��o
		oSection1:Init()
		
		oReport:IncMeter()
		
		cNcm 	:= TRBNCM->YD_TEC
		IncProc("Imprimindo NCM "+alltrim(TRBNCM->YD_TEC))
		
		//imprimo a primeira se��o
		oSection1:Cell("YD_TEC"):SetValue(TRBNCM->YD_TEC)
		oSection1:Cell("YD_DESC_P"):SetValue(TRBNCM->YD_DESC_P)
		oSection1:Printline()
		
		//inicializo a segunda se��o
		oSection2:init()
		
		//verifico se o codigo da NCM � mesmo, se sim, imprimo o produto
		While TRBNCM->YD_TEC == cNcm
			oReport:IncMeter()
			
			IncProc("Imprimindo produto "+alltrim(TRBNCM->B1_COD))
			oSection2:Cell("B1_COD"):SetValue(TRBNCM->B1_COD)
			oSection2:Cell("B1_DESC"):SetValue(TRBNCM->B1_DESC)
			oSection2:Cell("B1_LOCPAD"):SetValue(TRBNCM->B1_LOCPAD)
			oSection2:Cell("B1_POSIPI"):SetValue(TRBNCM->B1_POSIPI)
			oSection2:Printline()
			
			TRBNCM->(dbSkip())
		EndDo
		//finalizo a segunda se��o para que seja reiniciada para o proximo registro
		oSection2:Finish()
		//imprimo uma linha para separar uma NCM de outra
		oReport:ThinLine()
		//finalizo a primeira se��o
		oSection1:Finish()
	Enddo
Return

static function ajustaSx1(cPerg)
	//Aqui utilizo a fun��o putSx1, ela cria a pergunta na tabela de perguntas
	putSx1(cPerg, "01", "NCM DE ?"	  , "", "", "mv_ch1", "C", tamSx3("B1_POSIPI")[1], 0, 0, "G", "", "SYD", "", "", "mv_par01")
	putSx1(cPerg, "02", "NCM ATE?"	  , "", "", "mv_ch2", "C", tamSx3("B1_POSIPI")[1], 0, 0, "G", "", "SYD", "", "", "mv_par02")
return
