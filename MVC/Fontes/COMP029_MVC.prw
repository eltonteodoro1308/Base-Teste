#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} COMP029_MVC
Tela de consulta MVC

@author Ernani Forastieri e Rodrigo Antonio Godinho
@since 05/10/2009
@version P10
/*/
//-------------------------------------------------------------------
User Function COMP029_MVC()
FWExecView('Consulta Musicas',"COMP029_MVC", 3,, { || .T. } )
Return NIL


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruPar := FWFormModelStruct():New()
Local oStruZA1 := FWFormStruct( 1, 'ZA1' , { |x| ALLTRIM(x) $ 'ZA1_MUSICA, ZA1_TITULO'        } )
Local oStruZA2 := FWFormStruct( 1, 'ZA2' , { |x| ALLTRIM(x) $ 'ZA2_ITEM, ZA2_AUTOR, ZA2_NOME' } )
Local oModel

oStruPar:AddField( ;
"Musica"                       , ;               // [01] Titulo do campo
"Musica"                       , ;               // [02] ToolTip do campo
"MUSICA"                       , ;               // [03] Id do Field
"C"                            , ;               // [04] Tipo do campo
TamSX3('ZA1_MUSICA')[1]        , ;               // [05] Tamanho do campo
TamSX3('ZA1_MUSICA')[1]        , ;               // [06] Decimal do campo
FWBuildFeature( STRUCT_FEATURE_VALID, 'ExistCpo("ZA1",M->MUSICA,1)' ) , ;   // [07] Code-block de validação do campo
, ;                                              // [08] Code-block de validação When do campo
, ;                                              // [09] Lista de valores permitido do campo
.T.                            )                 // [10] Indica se o campo tem preenchimento obrigatório

oStruPar:AddField( ;
"Carregar"                     , ;               // [01] Titulo do campo
"Carregar"                     , ;               // [02] ToolTip do campo
'BOTAO'                        , ;               // [03] Id do Field
'BT'                           , ;               // [04] Tipo do campo
1                              , ;               // [05] Tamanho do campo
0                              , ;               // [06] Decimal do campo
{ |oMdl| Carrega( oMdl ), .T. }  )               // [07] Code-block de validação do campo


oStruZA1:SetProperty ( 'ZA1_MUSICA', MODEL_FIELD_VALID, FWBuildFeature( 1, '.T.' ) )
oStruZA1:SetProperty ( 'ZA1_MUSICA', MODEL_FIELD_INIT , NIL )

oModel := MPFormModel():New( 'MDTESTE' , , { | oMdl | NIL } )

oModel:AddFields( 'PARAMETROS', NIL, oStruPar )

oModel:AddGrid( 'ZA1DETAIL', 'PARAMETROS', oStruZA1 )

oModel:AddGrid( 'ZA2DETAIL', 'ZA1DETAIL', oStruZA2 )

oModel:AddCalc( 'CALCULOS', 'PARAMETROS', 'ZA1DETAIL', 'ZA1_MUSICA', 'ZA1__TOT01', 'COUNT', { | oFW | TOTAIS( oFW, .T. ) }, , "TOTAL 01" )
oModel:AddCalc( 'CALCULOS', 'PARAMETROS', 'ZA1DETAIL', 'ZA1_MUSICA', 'ZA1__TOT02', 'COUNT', { | oFW | TOTAIS( oFW, .F. ) }, , "TOTAL 02" )

//oModel:SetRelation( 'ZA2DETAIL', { { 'ZA2_FILIAL', 'xFilial( "ZA2" )' } , { 'ZA2_MUSICA', 'ZA1_MUSICA' } } , ZA2->( IndexKey( 1 ) ) )

oModel:GetModel( 'ZA2DETAIL' ):SetUniqueLine( { 'ZA2_AUTOR' } )

oModel:SetDescription( 'Modelo de Musicas' )
oModel:GetModel( 'PARAMETROS' ):SetDescription( 'PARAMETROS' )
oModel:GetModel( 'ZA1DETAIL' ):SetDescription( 'Dados da Musica' )
oModel:GetModel( 'ZA2DETAIL' ):SetDescription( 'Dados do Autor'  )

oModel:SetPrimaryKey( {} )

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria a estrutura a ser usada na View
Local oStruPar := FWFormViewStruct():New()
Local oStruZA1 := FWFormStruct( 2, 'ZA1' , { |x| ALLTRIM(x) $ 'ZA1_MUSICA, ZA1_TITULO' } )
Local oStruZA2 := FWFormStruct( 2, 'ZA2' , { |x| ALLTRIM(x) $ 'ZA2_ITEM, ZA2_AUTOR, ZA2_NOME' } )
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'COMP029_MVC' )
Local oView
Local oCalc1

oStruPar:AddField( ;
'MUSICA'         , ;             // [01] Campo
'ZZ'             , ;             // [02] Ordem
'Musica'         , ;             // [03] Titulo
'Musica'         , ;             // [04] Descricao
, ;                              // [05] Help
'G'              , ;             // [06] Tipo do campo   COMBO, Get ou CHECK
"@!"             , ;             // [07] Picture
, ;                              // [08] PictVar
'ZA1MVC'                     )               // [09] F3

oStruPar:AddField( ;
'BOTAO'          , ;             // [01] Campo
"ZZ"             , ;             // [02] Ordem
"Carregar"       , ;             // [03] Titulo
"Carregar"       , ;             // [04] Descricao
NIL              , ;             // [05] Help
'BT'             )               // [06] Tipo do campo   COMBO, Get ou CHECK

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_PAR' , oStruPar, 'PARAMETROS'   )
oView:AddGrid(  'VIEW_ZA1' , oStruZA1, 'ZA1DETAIL'    )
oView:AddGrid(  'VIEW_ZA2' , oStruZA2, 'ZA2DETAIL'    )

oCalc1 := FWCalcStruct( oModel:GetModel( 'CALCULOS') )
oView:AddField( 'VIEW_CALC', oCalc1, 'CALCULOS' )

oView:CreateHorizontalBox( "BOX1",  15 )
oView:CreateHorizontalBox( "BOX2",  30 )
oView:CreateHorizontalBox( "BOX3",  15 )
oView:CreateHorizontalBox( "BOX4",  40 )

oView:SetOwnerView( 'VIEW_PAR' , "BOX1" )
oView:SetOwnerView( 'VIEW_ZA1' , "BOX2" )
oView:SetOwnerView( 'VIEW_CALC', "BOX3" )
oView:SetOwnerView( 'VIEW_ZA2' , "BOX4" )

oView:EnableTitleView('VIEW_CALC','TOTAIS')

Return oView


//-------------------------------------------------------------------
Static Function TOTAIS( oFW, lPar )
Local lRet := .T.

If lPar
	lRet := ( Mod( Val( oFw:GetValue( 'ZA1DETAIL', 'ZA1_MUSICA' ) ) , 2 ) == 0 )
Else
	lRet := ( Mod( Val( oFw:GetValue( 'ZA1DETAIL', 'ZA1_MUSICA' ) ) , 2 ) <> 0 )
EndIf
Return lRet

//-------------------------------------------------------------------
Static Function Carrega( oMdl )
Local aArea      := GetArea()
Local cMusica    := ''
Local cTmp       := GetNextAlias()
Local cTmp2      := GetNextAlias()
Local nLinhaZA1  := 0
Local nLinhaZA2  := 0
Local oModel     := FWModelActive()
Local oModelZA1  := oModel:GetModel( 'ZA1DETAIL' )
Local oModelZA2  := oModel:GetModel( 'ZA2DETAIL' )

cMusica := oModel:GetValue( 'PARAMETROS', 'MUSICA' )

oModelZA1:DeActivate( .T. )
If !oModelZA1:Activate()
	Help( ,, 'Help',, 'Restricao de ativacao do Modelo', 1, 0 )
	Return NIL
EndIf	

BeginSql Alias cTmp
	
	SELECT ZA1_MUSICA, ZA1_TITULO
	
	FROM %table:ZA1% ZA1
	
	WHERE ZA1_FILIAL = %xFilial:ZA1%
	AND ZA1_MUSICA >= %Exp:cMusica%
	AND ZA1.%NotDel%
	
EndSql

nLinhaZA1 := 1

While !(cTmp)->( EOF() )
	
	If nLinhaZA1 > 1
		If oModelZA1:AddLine() <> nLinhaZA1
			Help( ,, 'HELP',, 'Nao incluiu linha ZA1' + CRLF + oModel:getErrorMessage()[6], 1, 0)   
			(cTmp)->( dbSkip() )
			Loop			
		EndIf
	EndIf
	
	oModelZA1:SetValue( 'ZA1_MUSICA',(cTmp)->ZA1_MUSICA )
	oModelZA1:SetValue( 'ZA1_TITULO',(cTmp)->ZA1_TITULO )
	
	nLinhaZA1++
	
	cMusica := (cTmp)->ZA1_MUSICA
	
	BeginSql Alias cTmp2
		
		SELECT ZA2_ITEM, ZA2_AUTOR, ZA2_MUSICA
		
		FROM %table:ZA2% ZA2
		
		WHERE ZA2_FILIAL = %xFilial:ZA2%
		AND ZA2_MUSICA = %Exp:cMusica%
		AND ZA2.%NotDel%
		
	EndSql
	
	
	nLinhaZA2 := 1
	
	While !(cTmp2)->( EOF() )  .AND. 	cMusica== (cTmp2)->ZA2_MUSICA
		
		If nLinhaZA2 > 1
			If oModelZA2:AddLine() <> nLinhaZA2
				Help( ,, 'HELP',, 'Nao incluiu linha ZA2' + CRLF + oModel:getErrorMessage()[6], 1, 0)
				(cTmp2)->( dbSkip() )
				Loop
			EndIf
		EndIf
		
		oModelZA2:SetValue( 'ZA2_AUTOR',(cTmp2)->ZA2_AUTOR )
		oModelZA2:SetValue( 'ZA2_ITEM', (cTmp2)->ZA2_ITEM )
		
		nLinhaZA2++
		
		(cTmp2)->( dbSkip() )
	End
	
	(cTmp2)->( dbCloseArea() )
	
	(cTmp)->( dbSkip() )
End

(cTmp)->( dbCloseArea() )

RestArea( aArea )

Return NIL
