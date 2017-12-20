#INCLUDE "PROTHEUS.CH"  

User Function ChartLine()

	Local oChart
	Local oDlg      

	DEFINE MSDIALOG oDlg PIXEL FROM 10,0 TO 600,600

	oChart := FWChartLine():New()
	oChart:init( oDlg, .t. ) 
	oChart:addSerie( "Votos PT", { {"Jan",50}, {"Fev",55}, {"Mar",60} })
	oChart:addSerie( "Votos PMDB", { {"Jan",30}, {"Fev",35}, {"Mar",40} } )
	oChart:addSerie( "Votos PV", { {"Jan",20}, {"Fev",10}, {"Mar",10} } ) 
	oChart:setLegend( CONTROL_ALIGN_LEFT ) 
	oChart:Build()
	ACTIVATE MSDIALOG oDlg

Return