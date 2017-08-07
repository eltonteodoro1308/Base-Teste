#Include 'Protheus.ch'
#Include 'birtdataset.ch'

USER_DATASET TESTE01  //Em ambiente sem chave de compilação utilizar o comando USER_DATASET no lugar de DATASET
TITLE "Teste de Dataset Protheus."
DESCRIPTION     "Este é um teste de um Dataset Protheus utilizando perguntas do SX1 que serve como exemplo para o desenvolvedor." + CRLF + ;
"Este Dataset solicita um conjunto de parâmetros do SX1 e grava na WorkTable os parâmetros digitados."
//PERGUNTE "TESTE01"

COLUMNS
DEFINE COLUMN CAMPO1 TYPE CHARACTER SIZE 10 LABEL "Campo 1"
DEFINE COLUMN CAMPO2 TYPE NUMERIC SIZE 6 DECIMALS 2 LABEL "Campo 2"
DEFINE COLUMN CAMPO3 TYPE CHARACTER SIZE 10 LABEL "Campo 3"
DEFINE COLUMN CAMPO4 TYPE CHARACTER SIZE 1 LABEL "Campo 4"
DEFINE COLUMN CAMPO5 TYPE CHARACTER SIZE 100 LABEL "Campo 5"

DEFINE QUERY "SELECT * FROM %WTable:1%"

PROCESS DATASET

Local cWTabAlias

//Private cField1 := self:execParamValue( "MV_PAR01" )
//Private cField2 := self:execParamValue( "MV_PAR02" )
//Private cField3 := self:execParamValue( "MV_PAR03" )
//Private cField4 := self:execParamValue( "MV_PAR04" )
//Private cField5 := self:execParamValue( "MV_PAR05" )

cWTabAlias := self:createWorkTable()

If self:isPreview()
	//utilize este método para verificar se esta em modo de preview
	//e assim evitar algum processamento, por exemplo atualização
	//em atributos das tabelas utilizadas durante o processamento
EndIf

RecLock( cWTabAlias, .T. )

( cWTabAlias )->CAMPO1 := 'cField1'
( cWTabAlias )->CAMPO2 := 'cField2'
( cWTabAlias )->CAMPO3 := 'DtoC(cField3)'
( cWTabAlias )->CAMPO4 := 'cField4'
( cWTabAlias )->CAMPO5 := 'cField5'

( cWTabAlias )->( MsUnlock() )

( cWTabAlias )->( DbCloseArea() )
Return .T.