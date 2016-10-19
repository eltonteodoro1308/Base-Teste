#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} COMP015_MVC
Exemplo de montagem da modelo e interface para um tabela em MVC
utilizando um MODEL e View ja existentes

@author Ernani Forastieri e Rodrigo Antonio Godinho
@since 05/10/2009
@version P10
/*/
//-------------------------------------------------------------------
User Function COMP015_MVC()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('ZA0')
oBrowse:SetDescription( 'Cadastro de Autor/Interprete' )
oBrowse:AddLegend( "ZA0_TIPO=='1'", "YELLOW", "Autor"       )
oBrowse:AddLegend( "ZA0_TIPO=='2'", "BLUE"  , "Interprete"  )
//oBrowse:DisableDetails()
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.COMP015_MVC' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.COMP015_MVC' OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.COMP015_MVC' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.COMP015_MVC' OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.COMP015_MVC' OPERATION 8 ACCESS 0
ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.COMP015_MVC' OPERATION 9 ACCESS 0
Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser acrescentada no Modelo de Dados
Local oStruZA6 := FWFormStruct( 1, 'ZA6', /*bAvalCampo*/,/*lViewUsado*/ )
// Inicia o Model com um Model ja existente
Local oModel   := FWLoadModel( 'COMP011_MVC' )

// Adiciona a nova FORMFIELD
oModel:AddFields( 'ZA6MASTER', 'ZA0MASTER', oStruZA6 )

// Faz relacionamento entre os compomentes do model
oModel:SetRelation( 'ZA6MASTER', { { 'ZA6_FILIAL', 'xFilial( "ZA6" )' }, { 'ZA6_CODIGO', 'ZA0_CODIGO' } }, ZA6->( IndexKey( 1 ) ) )

// Adiciona a descricao do novo componente
oModel:GetModel( 'ZA6MASTER' ):SetDescription( 'Complemento dos Dados de Autor/Interprete' )
//oModel:GetModel( 'ZA6MASTER' ):SetOptional( .T. )
Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'COMP015_MVC' )
// Cria a estrutura a ser acrescentada na View
Local oStruZA6 := FWFormStruct( 2, 'ZA6' )
// Inicia a View com uma View ja existente
Local oView    := FWLoadView( 'COMP011_MVC' )

// Altera o Modelo de dados quer será utilizado
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_ZA6', oStruZA6, 'ZA6MASTER' )

// É preciso criar sempre um box vertical dentro de um horizontal e vice-versa
// como na COMP011_MVC o box é horizontal, cria-se um vertical primeiro
oView:CreateVerticallBox(  'TELANOVA' , 100, 'TELA'     )
oView:CreateHorizontalBox( 'SUPERIOR' ,  50, 'TELANOVA' )
oView:CreateHorizontalBox( 'INFERIOR' ,  50, 'TELANOVA' )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_ZA0', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_ZA6', 'INFERIOR' )

// Liga a identificacao do componente
oView:EnableTitleView( 'VIEW_ZA0' )
oView:EnableTitleView( 'VIEW_ZA6' )

Return oView
