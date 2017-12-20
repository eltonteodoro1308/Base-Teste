#INCLUDE "PROTHEUS.CH"  

User Function ChartPie()

	Local oChart
	Local oDlg      

	DEFINE MSDIALOG oDlg PIXEL FROM 10,0 TO 400,400

	oChart := FWChartPie():New()
	oChart:init( oDlg, .t. ) 
	oChart:addSerie( "Votos PT", 50 )
	oChart:addSerie( "Votos PMDB", 30 )
	oChart:addSerie( "Votos PV", 20 ) 

	oChart:setLegend( CONTROL_ALIGN_LEFT ) 
	oChart:Build()

	ACTIVATE MSDIALOG oDlg

Return