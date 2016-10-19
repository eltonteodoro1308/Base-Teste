#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} COMP041_MVC
Exemplo de montagem da modelo e interface para uma tabela em MVC
Utilizando NEW MODEL

@author Ernani Forastieri e Rodrigo Antonio Godinho
@since 05/10/2009
@version P10
/*/
//-------------------------------------------------------------------
User Function COMP041_MVC()
Local oBrowse
            
NEW MODEL ;
TYPE        1    ;
DESCRIPTION "Cadastro de Autor/Interprete" ;
BROWSE      oBrowse         ;  
SOURCE      "COMP041_MVC"   ; 
MODELID     "MDCOMP041"     ;  
FILTER      "ZA0_TIPO=='1'" ; 
MASTER      "ZA0"           ;    
AFTER       { |oMdl| COMP041POS( oMdl ) } ;
COMMIT      { |oMdl| COMP041CMM( oMdl ) } 
          
Return NIL                       

//-------------------------------------------------------------------
Static Function COMP041POS( oModel )
Help( ,, 'Help',, 'Acionou a COMP041POS', 1, 0 )
Return .T.

//-------------------------------------------------------------------
Static Function COMP041CMM( oModel )
FWFormCommit( oModel )
Return NIL
