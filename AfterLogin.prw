#Include 'TOTVS.CH'
#Define K_CTRL_D 04
#Define K_CTRL_P 16
#Define K_CTRL_R 18
#Define K_CTRL_V 22

User Function AfterLogin()
	
	//SetKey( K_CTRL_R,  {|| U_XTReport() } )
	//SetKey( K_CTRL_R,  {|| U_relat001() } )
	
	SetKey( K_CTRL_D,  {|| U_DicAdvpl() } )
	SetKey( K_CTRL_P,  {|| U_PrmBxTst() } )
	SetKey( K_CTRL_V,  {|| U_DrpTbl() } )
	
Return
