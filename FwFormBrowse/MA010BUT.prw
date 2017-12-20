//#INCLUDE "FIVEWIN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "PROTHEUS.CH"

Static lTipMark	:= .T.

user function MTA010MNU()

	aAdd( aRotina, { 'Teste Browse', 'U_BROWSE', 0, 2, 0, nil } )

return

User Function BROWSE()

	Local oDlg
	Local oBrowse
	Local aCampos 	:= {}
	Local aRetQry		:= {}
	Local cAliasRC1 	:= "SB1TRB"
	Local aSize 		:= FwGetDialogSize(oMainWnd)
	Local cTitulo 	:= "Selecione os produtos"

	aRetQry := FCRIATRB()


	oDlg := MsDialog():New(aSize[1]/2, aSize[2]/2, aSize[3]/2, aSize[4]/2, cTitulo,,,,,,,, oMainWnd, .T.)
	oBrowse := FwFormBrowse():New()
	oBrowse:SetOwner(oDlg)
	oBrowse:SetDescription("Seleção de Produtos")
	oBrowse:AddMarkColumns( {|| If((cAliasRC1)->B1_OK == 1,"LBOk", "LBNO") },{ |oBrowse| MarkOne(@oBrowse) },{ |oBrowse| MarkAll(@oBrowse) } )
	oBrowse:SetDataQuery(.T.)
	oBrowse:SetQuery(aRetQry[1])
	oBrowse:SetAlias(cAliasRC1)
	oBrowse:SetColumns(aRetQry[2])
	oBrowse:DisableConfig()
	oBrowse:DisableReport()
	oBrowse:DisableDetails()
	oBrowse:AddButton("Confirmar",{|| /*GeraMail(cAliasRC1),*/ oDlg:End()},,,,.F.,2)
	oBrowse:AddButton("Cancelar",{|| oDlg:End()},,,,.F.,2)
	oBrowse:aColumns[1]:bHeaderClick := {|oBrowse| MarkAll(@oBrowse)}
	oBrowse:SetDoubleClick({|oBrowse| MarkOne(@oBrowse)})
	oBrowse:SetNoBrowse( .F. )
	oBrowse:Activate()


	oDlg:Activate( ,,,.T.,,, )

Return

Static Function FCRIATRB(lSelected)

	Local aArea		:= GetArea()
	Local aAreaX3		:= ""
	Local cQuery 		:= ""
	Local nI			:= 0
	Local nJ			:= 0
	Local aRet			:= {}
	Local aCampos		:= {}
	Local aColumns	:= {}
	Local aNoFields	:= {}

	Default lSelected := .F.
	//Array com campos para Grid
	AADD(aCampos,'B1_COD')
	AADD(aCampos,'B1_DESC')

	//Campo não visualizado na Grid
//	AADD(aNoFields,'RC1_OK')
	AADD(aNoFields,'RC1_RECNO')

	cQuery := "SELECT "
	//Carrega os campos da consulta
	For nI := 1 To Len(aCampos)
		If( nI > 1 )
			cQuery += ", "
		Endif
		cQuery += aCampos[nI]
	Next nI

	If lSelected
		cQuery += ", 1 AS B1_OK"
	Else
		cQuery += ", 0 AS B1_OK"
	Endif
	cQuery += ", R_E_C_N_O_ AS B1_RECNO"
	cQuery += " FROM "+RetSqlName("SB1")+" SB1"
	cQuery += " WHERE SB1.D_E_L_E_T_ = ' ' "

	//Cria estrutura da Grid
	AADD(aCampos,'B1_OK')

	nJ := 1

	For nI := 1 To Len(aCampos)

		If( Ascan(aNoFields, aCampos[nI]) == 0)

			Aadd( aColumns, FWBrwColumn():New() )
			aColumns[nJ]:SetData( &("{||" +aCampos[nI]+ "}") )
			dbSelectArea('SX3')
			aAreaX3 := GetArea('SX3')
			SX3->( dbSetOrder(2) )
			SX3->( dbSeek( aCampos[nI] ) )
			aColumns[nJ]:SetTitle(Alltrim(X3titulo(aCampos[nI])))
			aColumns[nJ]:SetSize(TamSx3(aCampos[nI])[1])
			aColumns[nJ]:SetDecimal(TamSx3(aCampos[nI])[2])
			aColumns[nJ]:SetPicture(Alltrim(X3Picture(aCampos[nI])))

			nJ++
		Endif
		RestArea(aAreaX3)
	Next nI

	Aadd( aRet, cQuery )
	Aadd( aRet, aColumns )

	RestArea( aArea )

Return aRet

Static Function MarkAll(oObjMark)

Local cMarkRC1 := ''
Local nTipMark := If( lTipMark, 1,0 )

Default oObjMark := Nil

If oObjMark <> Nil
	cMarkRC1 := oObjMark:cAlias

	dbSelectArea(cMarkRC1)
	aAreaRC1 := (cMarkRC1)->( GetArea() )
   (cMarkRC1)->(DbGoTop())
	While (cMarkRC1)->(!EOF())
		RecLock( (cMarkRC1), .F. )
			REPLACE (cMarkRC1)->B1_OK  WITH IIf( (cMarkRC1)->B1_OK == 1, 0, 1 )
		MsUnlock()
		(cMarkRC1)->(DbSkip())
	End
	(cMarkRC1)->( DbGotop() )
	RestArea( aAreaRC1 )
	oObjMark:GoBottom()
	oObjMark:GoTop()
Endif

Return

Static Function MarkOne(oObjMark)

Local cMarkRC1 := ''

Default oObjMark := Nil

If oObjMark <> Nil
	cMarkRC1 := oObjMark:cAlias

	If (cMarkRC1)->B1_OK == 1
		 (cMarkRC1)->B1_OK := 0
	Else
		 (cMarkRC1)->B1_OK := 1
	Endif
Endif

Return