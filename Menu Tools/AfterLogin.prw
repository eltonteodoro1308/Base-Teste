#INCLUDE 'TOTVS.CH'
#DEFINE K_CTRL_E 5

User Function AfterLogin()

	SetKey( K_CTRL_E, { || U_EXECUTE() } )

Return

