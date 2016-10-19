#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} COMP041_MVC
Exemplo de montagem da modelo e interface para uma tabela em MVC
Utilizando NEW MODEL e MENUDEF

@author Ernani Forastieri e Rodrigo Antonio Godinho
@since 05/10/2009
@version P10
/*/
//-------------------------------------------------------------------
User Function COMP044_MVC()
Local oBrowse

NEW MODEL ;
TYPE        1    ;
DESCRIPTION "Cadastro de Autor/Interprete" ;
BROWSE      oBrowse         ;
SOURCE      "COMP044_MVC"   ;
MENUDEF     "COMP044_MVC"   ;
MODELID     "MDCOMP044"     ;
FILTER      "ZA0_TIPO=='1'" ;
MASTER      "ZA0"

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.COMP044_MVC' OPERATION 2 ACCESS 0

Return aRotina