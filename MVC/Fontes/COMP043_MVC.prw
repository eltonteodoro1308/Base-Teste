#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} COMP043_MVC
Exemplo de montagem da modelo e interface para uma estrutura
pai/filho em MVC
Utilizando NEW MODEL

@author Ernani Forastieri e Rodrigo Antonio Godinho
@since 05/10/2009
@version P10
/*/
//-------------------------------------------------------------------
User Function COMP043_MVC()

Local oBrowse

New Model ;
Type 		    3               ;
Description 	"Musicas"       ;
Browse      	oBrowse         ;
Source      	"COMP043_MVC"   ;
ModelID     	"MDCOMP043"     ;
Master      	"ZA1"           ;
Detail      	"ZA2"           ;
Relation    	{ { 'ZA2_FILIAL', 'xFilial( "ZA2" )' }, { 'ZA2_MUSICA', 'ZA1_MUSICA' } } ;
UniqueLine		{ 'ZA2_AUTOR' } ;
OrderKey		ZA2->( IndexKey( 1 ) ) ;
AutoIncrement   'ZA2_ITEM'


Return NIL
