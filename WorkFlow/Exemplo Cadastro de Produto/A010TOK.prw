#include 'totvs.ch'

user function A010TOK()

	Local oProcess := TWFProcess():New( '000001' )
	Local cHostWF  := 'http://spon4944:10002/workflow/task/'
	Local cMailId  := ''

	oProcess:NewTask( 'FORMULARIO', '\workflow\html\model\WFAprovProd.html' )

	oProcess:oHTML:ValByName( 'B1_COD' , SB1->B1_COD  )
	oProcess:oHTML:ValByName( 'B1_DESC', SB1->B1_DESC )

	oProcess:bReturn  := 'U_WFPRDAPR'

	cMailId := oProcess:Start( '\workflow\html\task\')

	//RecLock( 'SB1', .F.)

	//SB1->B1_WFID := oProcess:fProcessID

	//SB1->(MsUnlock())

	oProcess:NewTask( 'LINK', '\workflow\html\model\WFAprovProdLink.html' )

	oProcess:oHtml:ValByName( 'LINK', cHostWF + '/' + cMailId + ".htm")

	oProcess:cSubject := 'Aprovação do Cadastro de Produto'
	oProcess:cTo      := EnviaPara()

	oProcess:Start()

return

User Function WFPRDAPR( oProcess )

	Local cCod   := AllTrim( oProcess:oHtml:RetByName( 'B1_COD'   ) )
	Local cDesc  := AllTrim( oProcess:oHtml:RetByName( 'B1_DESC'  ) )
	Local cAprov := AllTrim( oProcess:oHtml:RetByName( 'APROVADO' ) )

	DbSelectArea( 'SB1' )
	DbSetOrder( 1 )

	If DbSeek( xFilial() + cCod  )

		RecLock( 'SB1', .F. )

		If cAprov == 'S'

			SB1->B1_MSBLQL := '2'

		Else

			SB1->B1_MSBLQL := '1'

		EndIf

		MsUnlock()

	End If

	ConOut( PadC( '', 100, '=' ) )
	ConOut( cCod + ' - ' + cDesc + ' - ' + If( cAprov == 'S', 'Aprovado', 'Reprovado' ) )
	ConOut( PadC( '', 100, '=' ) )

Return

Static Function EnviaPara()

	Local oButton
	Local oGet
	Local cGet := PadR( MemoRead( '\system\bufexec.txt' ), 50 )
	Local oSay
	Local oDlg

	DEFINE MSDIALOG oDlg TITLE "Envio de Notificação" FROM 000, 000  TO 100, 400 COLORS 0, 16777215 PIXEL

	@ 035, 156 BUTTON oButton PROMPT 'Enviar' SIZE 037, 012 OF oDlg ACTION oDlg:End() PIXEL
	@ 017, 003 MSGET oGet VAR cGet SIZE 190, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 002, 002 SAY oSay PROMPT "Email:" SIZE 025, 010 OF oDlg COLORS 0, 16777215 PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

	MemoWrite( '\system\bufexec.txt', cGet )

Return cGet