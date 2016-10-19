#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} COMP042_MVC
Exemplo de montagem da modelo e interface para uma tabela em MVC
Utilizando NEW MODEL

@author Ernani Forastieri e Rodrigo Antonio Godinho
@since 05/10/2009
@version P10
/*/
//-------------------------------------------------------------------
User Function COMP042_MVC()
Local oBrowse

NEW MODEL ;
TYPE        	2    ;
DESCRIPTION 	"Teste Tabela Nao Normalizada" ;
BROWSE      	oBrowse          ;
SOURCE      	"COMP043_MVC"    ;
MODELID     	"MDCOMP043"      ;
MASTER      	"ZA2"            ;
HEADER      	{ 'ZA2_MUSICA', 'ZA2_ITEM' } ;
Relation      	{ { 'ZA2_FILIAL', 'xFilial( "ZA2" )' }, { 'ZA2_MUSICA', 'ZA2_MUSICA' } } ;  
UniqueLine		{ 'ZA2_AUTOR' } ;
OrderKey		ZA2->( IndexKey( 1 ) ) ;
AutoIncrement   'ZA2_ITEM'

Return 
