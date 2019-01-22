User Function aSort()

//    Local nX   := 0

    Private aLst := { 3, 5, 1, 2, 4 }

//    For nX := 1 To Len(aLst)
//    
//        aLst[ nX ] := Randomize( 1, 50 )
//    
//    Next nX

    aSort( aLst,,,{ | x, y | Sort( x, y ) } )

    VarInfo('aLst', aLst,,.F.,.T.)

Return

Static Function Sort( x, y )

    Local xRet := x > y

    VarInfo('aLst', aLst,,.F.,.T.)

    ConOut( 'x = ' + cValToChar( x ) )
    ConOut( 'y = ' + cValToChar( y ) )
    ConOut( 'x > y = ' + cValToChar( xRet ) )
    Replicate("-",50)

Return xRet