#include 'totvs.ch'

User Function A010TOK()

	Local lRet       := .T.
	Local oProcess   := Nil
	Local cAcao      := ''
	Local cCodigo    := M->B1_COD
	Local cDescricao := M->B1_DESC

	oProcess := TWFProcess():New( '000001' )

	If INCLUI

		MyConOut( cAcao := 'Produto Incluído.' )

	ElseIf ALTERA

		MyConOut( cAcao := 'Produto Alterado.' )

	End If

	oProcess:NewTask( 'Notificação de ' + cAcao, '\WorkFlow\Notificacao.Html' )

	oProcess:cSubject := cAcao
	oProcess:cTo      := 'HTML'//EnviaPara()

	oProcess:oHTML:ValByName( 'cAcao'     , cAcao      )
	oProcess:oHTML:ValByName( 'cCodigo'   , cCodigo    )
	oProcess:oHTML:ValByName( 'cDescricao', cDescricao )

	MyConOut( 'Processo ' + oProcess:Start( /*'\web\'*/ ) + ' Criado. ')

	MyConOut( 'Processo: ' + oProcess:fProcessID )
	MyConOut( 'Processo: ' + oProcess:fTaskID    )

	oProcess:Finish()

Return lRet

Static Function MyConOut( cMsg )

	Local   cMsgAux := ''
	Default cMsg    := ''

	cMsgAux += ' [ '
	cMsgAux += ' A010TOK'
	cMsgAux += ' - '
	cMsgAux += PadL( Day  ( Date() ), 2, '0' )
	cMsgAux += '/'
	cMsgAux += PadL( Month( Date() ), 2, '0' )
	cMsgAux += '/'
	cMsgAux += PadL( Year ( Date() ), 4, '0' )
	cMsgAux += ' - '
	cMsgAux += Time()
	cMsgAux += ' ] '
	cMsgAux += cMsg

	ConOut( cMsgAux )

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