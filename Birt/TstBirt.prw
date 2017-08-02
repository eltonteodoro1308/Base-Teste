#Include 'Protheus.ch'
#Include 'tdsBirt.ch'

User Function TstBirt()

	Local oReport

	DEFINE USER_REPORT oReport NAME TSTBIRT TITLE "Teste de Report" //ASKPAR EXCLUSIVE

	ACTIVATE REPORT oReport LAYOUT TSTBIRT FORMAT HTML

Return

