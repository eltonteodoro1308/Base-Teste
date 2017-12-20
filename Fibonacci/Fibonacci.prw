#INCLUDE 'TOTVS.CH'

User Function Fibonacci( n )

	Local a := 0
	Local b := 1
	Local c := a + b

	Default n := 0
	
	n := Val( n )  

	If n >= 0

		ConOut( cValToChar( a ) )

	End If

	If n >= 1

		ConOut( cValToChar( b ) )

	End If

	Do While c < n

		ConOut( cValToChar( c ) )

		a := b

		b := c

		c := a + b

	End Do

Return