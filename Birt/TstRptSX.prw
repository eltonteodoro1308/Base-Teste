#Include 'Protheus.ch'
#Include 'tdsBirt.ch'


user function TstRptSX()

	Local oReport

	DEFINE USER_REPORT oReport NAME TstRptSX TITLE "Teste de Report" //ASKPAR EXCLUSIVE

	ACTIVATE REPORT oReport LAYOUT TstRptSX FORMAT HTML

Return