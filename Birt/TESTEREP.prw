
#Include 'Protheus.ch'
#Include 'tdsBirt.ch'
 
User Function TESTEREP()
 
Local oReport
 
DEFINE REPORT oReport NAME TstRpt TITLE "Teste de Report" //ASKPAR EXCLUSIVE
 
ACTIVATE REPORT oReport LAYOUT TstRpt FORMAT HTML
 
Return		