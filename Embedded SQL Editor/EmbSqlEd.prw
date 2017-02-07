#INCLUDE 'TOTVS.CH'
#Define K_CTRL_E 05

User Function EmbSqlEd()

	Local oDlg  := Nil
	Local oEdit := Nil
	Local cTxt  := "Novo texto <b>Negrito</b>" + ;
	"<font color=red> Texto em Vermelho</font>" + ;
	"<font size=14> Texto com tamanho grande</font>"

	SetKey( K_CTRL_E,  {|| oEdit:Load(cTxt) } )

	Define Dialog oDlg Title "TSimpleEditor" From 180, 180 To 550, 700 Pixel

	oEdit := TSimpleEditor():New(0, 0, oDlg, 260, 184)


	oEdit:Load( "Novo texto <b>Negrito</b>" + ;
	"<font color=red> Texto em Vermelho</font>" + ;
	"<font size=14> Texto com tamanho grande</font>")

	Activate Dialog oDlg Centered

Return