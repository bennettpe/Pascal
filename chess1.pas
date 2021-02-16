program CHESS1 ( STELLUNG , OUTPUT ) ;

//****************************************************************
//                                                                
//$A+                                                             
//                                                                
// Versuch einer einfachen Schach-Engine mit New Stanford Pascal  
// -------------------------------------------------------------  
// Autor: Bernd Oppolzer - begonnen Anfang 2021                   
//                                                                
// Naechste Schritte (* = erledigt, % = derzeit nicht):           
//                                                                
// % Einlesen Stellung entsprechend FEN (spaeter)                 
// % d.h. ggf. Einlesen "am Zug" und Rochade (spaeter)            
//                                                                
// * alles Folgende: abh. von "am Zug"                            
// * Pruefung, ob Koenig im Schach steht                          
// * Ermittlung moegliche Zuege                                   
// * a) moegliche Felder je Figur bzw. Figurentyp ermitteln       
// * b) andere Figuren duerfen geschlagen werden                  
// * c) eigene Figuren begrenzen den Weg                          
// * d) Koenig darf nicht ins Schach laufen                       
// * e) Fesselung durch drohendes Schach implementieren           
// * Pruefen, ob neue Stellungen immer noch Schach sind           
// * Pruefung, ob Koenig matt ist (oder stalemate)                
// * bei Suche der Zuege neue Stellungen abspeichern in Liste     
// * fehlerhafte Koenigszuege eliminieren                         
// * Figuren schlagen bei Zuegen anzeigen                         
// * M0 implementieren, Test mit Check 02.01.2021                 
// * M1 implementieren, Test mit Loesung aus 30.01.2021           
// * M2 implementieren                                            
//                                                                
// Probleme beheben (CHESS1 und Pascal):                          
//                                                                
// * VM: Fehler beim Einlesen, siehe TESTCH01.PAS                 
// * VM: Fehler beim Abfragen der Dialogeingaben (ANTWORT = 'W')  
// * VM: letzteres siehe auch Fehler bei COMPERRD                 
// * VM: weitere Abweichung bei CHESS1 mit M2 - noch unklar       
// * Speicher-Allokation mit ALLOC/FREE gibt Probleme (?) bei M2  
// - Stellungen kopieren fuer Zuege ist zu heavy (Inkrement?)     
// - M2 ist insgesamt zu aufwendig (Algorithmus)                  
//                                                                
// weiter mit CHESS1:                                             
//                                                                
// - M3 implementieren                                            
// - en passant schlagen (Regeln usw.)                            
// - Rochade ermoeglichen                                         
// - (statische) Bewertung der Stellung (d.h. Anzahl Figuren)     
// - aus alledem: Bewertungszahl fuer Stellung ausrechnen         
//                                                                
//****************************************************************



const BI_MAX = 143 ;


type FARBE = ( NOCOL , WEISS , SCHWARZ ) ;
     ROCHADE_TYP = ( RO_KLEIN , RO_GROSS ) ;
     FIGUR = ( NOFIG , BAUER , SPRINGER , LAEUFER , TURM , DAME ,
             KOENIG ) ;
     FSTATUS = ( NOEX , OCCUP , XFREE ) ;
     SSTATUS = ( NORM , CHECK , STALEMATE , CHECKMATE ) ;
     FELD = record
              BELEGT : BOOLEAN ;
              WAS : FIGUR ;
              COL : FARBE ;
            end ;
     FELD_INTERN = record
                     STAT : FSTATUS ;
                     WAS : FIGUR ;
                     COL : FARBE ;
                   end ;
     BI_INDEX = 0 .. BI_MAX ;

     //**************************************************************
     // die Informationen, die eine Stellung beschreiben,            
     // stehen in der Struktur GLOBAL und werden nicht an die        
     // einzelnen Funktionen uebergeben, sondern global benutzt      
     //**************************************************************
     // meistens: with G do ...                                      
     //**************************************************************
     // BI = interne Darstellung des Bretts, eindimensional 12 * 12  
     // AM_ZUG = Farbe, die am ZUG ist                               
     // ROCHADE_GELAUFEN = gibt an, welche Rochaden moeglich sind    
     // dann ein paar Werte, die ermittelt werden:                   
     // Positionen des schwarzen und weissen Koenigs                 
     // aktueller Status der Stellung, z.B. Schach, Stalemate, Matt  
     // Anzahl moeglicher Zuege (alles abh. von AM_ZUG)              
     //**************************************************************

     ZUGPTR = -> ZUG ;
     GLOBAL = record
                BI : array [ BI_INDEX ] of FELD_INTERN ;
                AM_ZUG : FARBE ;
                ROCHADE_GELAUFEN : array [ FARBE , ROCHADE_TYP ] of
                                   BOOLEAN ;
                K_SCHWARZ_POS , K_WEISS_POS : INTEGER ;
                ST : SSTATUS ;
                ANZAHL_ZUEGE : INTEGER ;
                ZFIRST , ZLAST : ZUGPTR ;
              end ;
     ZUG = record
             POS_ALT : BI_INDEX ;
             POS_NEU : BI_INDEX ;
             ZSTRING : STRING ( 10 ) ;
             G_NEU : GLOBAL ;
             ALTERN : ZUGPTR ;
             NEXT : ZUGPTR ;
           end ;


var STELLUNG : TEXT ;

    //**************************************************************
    // BRETT = externe Darstellung des Schachbretts                 
    // alles weitere steht in der Variablen G : GLOBAL              
    //**************************************************************

    BRETT : array [ 'a' .. 'h' , '1' .. '8' ] of FELD ;
    G : GLOBAL ;
    ANTWORT : STRING ( 80 ) ;
    A : CHAR ;
    DUMMYB : BOOLEAN ;
    ZUG_RESERVE : ZUGPTR := NIL ;
    ALLOC_COUNT : INTEGER := 0 ;
    FREE_COUNT : INTEGER := 0 ;



procedure WRITE_COUNTS ;

   begin (* WRITE_COUNTS *)
     WRITELN ( 'Anzahl Allocs = ' , ALLOC_COUNT ) ;
     WRITELN ( 'Anzahl Frees  = ' , FREE_COUNT ) ;
   end (* WRITE_COUNTS *) ;



function ALLOC_ZUG : ZUGPTR ;

   var P : ZUGPTR ;

   begin (* ALLOC_ZUG *)
     ALLOC_COUNT := ALLOC_COUNT + 1 ;
     if ZUG_RESERVE = NIL then
       ALLOC_ZUG := ALLOC ( SIZEOF ( ZUG ) )
     else
       begin
         P := ZUG_RESERVE ;
         ZUG_RESERVE := ZUG_RESERVE -> . NEXT ;
         P -> . NEXT := NIL ;
         ALLOC_ZUG := P ;
       end (* else *) ;
   end (* ALLOC_ZUG *) ;



procedure FREE_ZUG ( X : ZUGPTR ) ;

   begin (* FREE_ZUG *)
     if FALSE then
       begin
         FREE_COUNT := FREE_COUNT + 1 ;
         X -> . NEXT := ZUG_RESERVE ;
         X -> . ALTERN := NIL ;
         ZUG_RESERVE := X
       end (* then *)
     else
       FREE ( X )
   end (* FREE_ZUG *) ;



procedure S_TOUPPER ( var S : STRING ) ;

   const KLEINBUCHST : set of CHAR =
         [ 'a' .. 'i' , 'j' .. 'r' , 's' .. 'z' ] ;

   var I : INTEGER ;

   begin (* S_TOUPPER *)
     for I := 1 to LENGTH ( S ) do
       if S [ I ] in KLEINBUCHST then
         S [ I ] := CHR ( ORD ( S [ I ] ) - ORD ( 'a' ) + ORD ( 'A' ) )
                    ;
   end (* S_TOUPPER *) ;



function IX_INT ( X : CHAR ; Y : CHAR ) : INTEGER ;

//**************************************************
// ermittle Index fuer internes Feld aus externem   
// ab Position 26 (3. zeile) werden die Felder      
// der 1. Zeile (a1, b1 bis h1) abgelegt.           
// ..xxxxxxxx....yyyyyyyy....zzzzzzzz....           
// das waeren also demnach die 1., 2. und 3. Zeile  
// ab interner Position 24                          
//**************************************************


   var I1 , I2 : INTEGER ;

   begin (* IX_INT *)
     I1 := ( ORD ( Y ) - ORD ( '1' ) ) * 12 ;
     I2 := ORD ( X ) - ORD ( 'a' ) ;
     IX_INT := I1 + I2 + 26 ;
   end (* IX_INT *) ;



function IX_EXT ( X : INTEGER ) : STRING ;

//*****************************************************
// Rueckgabe eines Strings aus zwei Buchstaben         
// z.B. a1 - oder Leerstring, wenn kein "echtes" Feld  
//*****************************************************


   const S1 = 'abcdefgh' ;
         S2 = '12345678' ;

   var S : STRING ( 2 ) ;
       I1 , I2 : INTEGER ;

   begin (* IX_EXT *)
     S := '' ;
     if X < 26 then
       begin
         IX_EXT := S ;
         return
       end (* then *) ;
     I1 := X MOD 12 - 1 ;
     I2 := X DIV 12 - 1 ;
     if ( I1 < 1 ) or ( I1 > 8 ) or ( I2 < 1 ) or ( I2 > 8 ) then
       return ;
     S := S1 [ I1 ] || S2 [ I2 ] ;
     IX_EXT := S ;
   end (* IX_EXT *) ;



procedure BRETT_LEEREN ;

   var X : CHAR ;
       Y : CHAR ;

   begin (* BRETT_LEEREN *)
     for X := 'a' to 'h' do
       for Y := '1' to '8' do
         begin
           BRETT [ X , Y ] . BELEGT := FALSE ;
           BRETT [ X , Y ] . WAS := NOFIG ;
           BRETT [ X , Y ] . COL := NOCOL ;
         end (* for *) ;
   end (* BRETT_LEEREN *) ;



procedure SETZE ( X : CHAR ; Y : CHAR ; F : FIGUR ; C : FARBE ) ;

   begin (* SETZE *)
     BRETT [ X , Y ] . BELEGT := TRUE ;
     BRETT [ X , Y ] . WAS := F ;
     BRETT [ X , Y ] . COL := C ;
   end (* SETZE *) ;



procedure STELLUNG_ANFANG ;

   var X : CHAR ;

   begin (* STELLUNG_ANFANG *)
     BRETT_LEEREN ;

     //********************************************
     // Defaults setzen fuer "am Zug" und Rochade  
     //********************************************

     with G do
       begin
         AM_ZUG := WEISS ;
         ROCHADE_GELAUFEN [ WEISS , RO_KLEIN ] := FALSE ;
         ROCHADE_GELAUFEN [ WEISS , RO_GROSS ] := FALSE ;
         ROCHADE_GELAUFEN [ SCHWARZ , RO_KLEIN ] := FALSE ;
         ROCHADE_GELAUFEN [ SCHWARZ , RO_GROSS ] := FALSE ;
       end (* with *) ;

     //*********************************
     // Figuren setzen Anfangsstellung  
     //*********************************

     SETZE ( 'a' , '1' , TURM , WEISS ) ;
     SETZE ( 'b' , '1' , SPRINGER , WEISS ) ;
     SETZE ( 'c' , '1' , LAEUFER , WEISS ) ;
     SETZE ( 'd' , '1' , DAME , WEISS ) ;
     SETZE ( 'e' , '1' , KOENIG , WEISS ) ;
     SETZE ( 'f' , '1' , LAEUFER , WEISS ) ;
     SETZE ( 'g' , '1' , SPRINGER , WEISS ) ;
     SETZE ( 'h' , '1' , TURM , WEISS ) ;
     for X := 'a' to 'h' do
       begin
         SETZE ( X , '2' , BAUER , WEISS ) ;
         SETZE ( X , '7' , BAUER , SCHWARZ ) ;
       end (* for *) ;
     SETZE ( 'a' , '8' , TURM , SCHWARZ ) ;
     SETZE ( 'b' , '8' , SPRINGER , SCHWARZ ) ;
     SETZE ( 'c' , '8' , LAEUFER , SCHWARZ ) ;
     SETZE ( 'd' , '8' , DAME , SCHWARZ ) ;
     SETZE ( 'e' , '8' , KOENIG , SCHWARZ ) ;
     SETZE ( 'f' , '8' , LAEUFER , SCHWARZ ) ;
     SETZE ( 'g' , '8' , SPRINGER , SCHWARZ ) ;
     SETZE ( 'h' , '8' , TURM , SCHWARZ ) ;
   end (* STELLUNG_ANFANG *) ;



function TO_FIGUR ( X : CHAR ) : FIGUR ;

   begin (* TO_FIGUR *)
     case X of
       'B' : TO_FIGUR := BAUER ;
       'S' : TO_FIGUR := SPRINGER ;
       'L' : TO_FIGUR := LAEUFER ;
       'T' : TO_FIGUR := TURM ;
       'D' : TO_FIGUR := DAME ;
       'K' : TO_FIGUR := KOENIG ;
       otherwise
         TO_FIGUR := NOFIG
     end (* case *) ;
   end (* TO_FIGUR *) ;



function FIGUR_TO_CHAR ( X : FIGUR ) : CHAR ;

   begin (* FIGUR_TO_CHAR *)
     case X of
       BAUER : FIGUR_TO_CHAR := 'B' ;
       SPRINGER :
         FIGUR_TO_CHAR := 'S' ;
       LAEUFER :
         FIGUR_TO_CHAR := 'L' ;
       TURM : FIGUR_TO_CHAR := 'T' ;
       DAME : FIGUR_TO_CHAR := 'D' ;
       KOENIG :
         FIGUR_TO_CHAR := 'K' ;
       otherwise
         FIGUR_TO_CHAR := ' '
     end (* case *) ;
   end (* FIGUR_TO_CHAR *) ;



procedure STELLUNG_EINLESEN ( var F : TEXT ) ;

   var Z : STRING ( 100 ) ;
       FIG : FIGUR ;
       COL : FARBE ;
       I : INTEGER ;
       C : CHAR ;
       OK : BOOLEAN ;
       X : CHAR ;
       Y : CHAR ;


   procedure PARSE_POSITION ;

      begin (* PARSE_POSITION *)
        OK := TRUE ;
        if I > LENGTH ( Z ) then
          begin
            OK := FALSE ;
            return
          end (* then *) ;
        X := Z [ I ] ;
        if not ( X in [ 'a' .. 'h' ] ) then
          begin
            OK := FALSE ;
            return
          end (* then *) ;
        I := I + 1 ;
        if I > LENGTH ( Z ) then
          begin
            OK := FALSE ;
            return
          end (* then *) ;
        Y := Z [ I ] ;
        if not ( Y in [ '1' .. '8' ] ) then
          begin
            OK := FALSE ;
            return
          end (* then *) ;
        I := I + 1 ;
      end (* PARSE_POSITION *) ;


   procedure SETZE_FIGUR ;

      begin (* SETZE_FIGUR *)
        SETZE ( X , Y , FIG , COL ) ;
      end (* SETZE_FIGUR *) ;


   begin (* STELLUNG_EINLESEN *)

     //*****************************
     // Brett zunaechst leermachen  
     //*****************************

     BRETT_LEEREN ;
     with G do
       begin

     //********************************************
     // Defaults setzen fuer "am Zug" und Rochade  
     //********************************************

         AM_ZUG := WEISS ;
         ROCHADE_GELAUFEN [ WEISS , RO_KLEIN ] := FALSE ;
         ROCHADE_GELAUFEN [ WEISS , RO_GROSS ] := FALSE ;
         ROCHADE_GELAUFEN [ SCHWARZ , RO_KLEIN ] := FALSE ;
         ROCHADE_GELAUFEN [ SCHWARZ , RO_GROSS ] := FALSE ;

     //*****************************************************
     // Positionen der Figuren einlesen und Figuren setzen  
     //*****************************************************

         RESET ( F ) ;
         COL := WEISS ;
         repeat
           READLN ( F , Z ) ;
           I := 1 ;
           while I <= LENGTH ( Z ) do
             begin
               C := Z [ I ] ;
               case C of
                 ' ' , ',' , ';' :
                   I := I + 1 ;
                 '-' : begin
                         COL := SCHWARZ ;
                         I := I + 1
                       end (* tag/ca *) ;
                 '*' : break ;
                 'B' , 'S' , 'L' , 'T' , 'D' , 'K' :
                   begin
                     FIG := TO_FIGUR ( C ) ;
                     I := I + 1 ;
                     PARSE_POSITION ;
                     if OK then
                       begin
                         if C = 'K' then
                           if COL = WEISS then
                             begin
                               if ( X <> 'e' ) or ( Y <> '1' ) then
                                 begin
                                   ROCHADE_GELAUFEN [ WEISS , RO_KLEIN
                                   ] := TRUE ;
                                   ROCHADE_GELAUFEN [ WEISS , RO_GROSS
                                   ] := TRUE ;
                                 end (* then *)
                             end (* then *)
                           else
                             begin
                               if ( X <> 'e' ) or ( Y <> '8' ) then
                                 begin
                                   ROCHADE_GELAUFEN [ SCHWARZ ,
                                   RO_KLEIN ] := TRUE ;
                                   ROCHADE_GELAUFEN [ SCHWARZ ,
                                   RO_GROSS ] := TRUE ;
                                 end (* then *)
                             end (* else *) ;
                         SETZE_FIGUR
                       end (* then *)
                   end (* tag/ca *) ;
                 'a' .. 'h' :
                   begin
                     PARSE_POSITION ;
                     if OK then
                       SETZE_FIGUR
                   end (* tag/ca *) ;
                 otherwise
                   begin
                     WRITELN ( '+++ Fehler beim Einlesen der Stellung'
                               ) ;
                     WRITELN ( '+++ fehlerhaftes Zeichen = ' , C ) ;
                   end (* otherw *)
               end (* case *)
             end (* while *)
         until EOF ( F ) ;
       end (* with *)
   end (* STELLUNG_EINLESEN *) ;



procedure STELLUNG_AUSGEBEN ;

   const L = '!==================================================!' ;
         L2 = '!                                                  !' ;

   var X : CHAR ;
       Y : CHAR ;

   begin (* STELLUNG_AUSGEBEN *)
     WRITELN ( 'Ausgabe externe Brett-Darstellung:' ) ;
     WRITELN ( L ) ;
     WRITELN ( L2 ) ;
     WRITELN ( L2 ) ;
     for Y := '8' DOWNTO '1' do
       begin
         WRITE ( '! ' ) ;
         for X := 'a' to 'h' do
           begin
             if BRETT [ X , Y ] . BELEGT then
               begin
                 WRITE ( '  ' , BRETT [ X , Y ] . WAS : 1 ) ;
                 if BRETT [ X , Y ] . COL = WEISS then
                   WRITE ( 'w  ' )
                 else
                   WRITE ( 's  ' )
               end (* then *)
             else
               begin
                 WRITE ( '  --  ' ) ;
               end (* else *)
           end (* for *) ;
         WRITE ( ' !' ) ;
         WRITELN ;
         WRITELN ( L2 ) ;
         WRITELN ( L2 ) ;
       end (* for *) ;
     WRITELN ( L ) ;
   end (* STELLUNG_AUSGEBEN *) ;



procedure STELLUNG_AUSG_INT ;

   var I : INTEGER ;

   begin (* STELLUNG_AUSG_INT *)
     with G do
       begin
         WRITELN ( 'Ausgabe internes Brett zum Test:' ) ;
         for I := 24 to 71 do
           with BI [ I ] do
             case STAT of
               NOEX : WRITE ( '.' ) ;
               XFREE : WRITE ( '-' ) ;
               OCCUP : WRITE ( WAS : 1 ) ;
             end (* case *) ;
         WRITELN ;
         for I := 72 to BI_MAX - 24 do
           with BI [ I ] do
             case STAT of
               NOEX : WRITE ( '.' ) ;
               XFREE : WRITE ( '-' ) ;
               OCCUP : WRITE ( WAS : 1 ) ;
             end (* case *) ;
         WRITELN ;
       end (* with *)
   end (* STELLUNG_AUSG_INT *) ;





//                                                       
//  procedure TEST1 ;                                    
//                                                       
//  //**************************************             
//  // testet Speicherabbildungsfunktionen               
//  //**************************************             
//                                                       
//                                                       
//     var IX : INTEGER ;                                
//         S : STRING ( 2 ) ;                            
//                                                       
//     begin (* TEST1 *)                                 
//       IX := IX_INT ( 'f' , '5' ) ;                    
//       WRITELN ( 'index intern = ' , IX ) ;            
//       S := IX_EXT ( IX ) ;                            
//       WRITELN ( 'extern ' , S , ' should be f5' ) ;   
//       IX := IX_INT ( 'a' , '1' ) ;                    
//       WRITELN ( 'index intern = ' , IX ) ;            
//       S := IX_EXT ( IX ) ;                            
//       WRITELN ( 'extern ' , S , ' should be a1' ) ;   
//       IX := IX_INT ( 'h' , '8' ) ;                    
//       WRITELN ( 'index intern = ' , IX ) ;            
//       S := IX_EXT ( IX ) ;                            
//       WRITELN ( 'extern ' , S , ' should be h8' ) ;   
//       S := IX_EXT ( 84 ) ;                            
//       WRITELN ( 'extern ' , S , ' should be empty' ) ;
//     end (* TEST1 *) ;                                 
//                                                       




procedure TRANSFER_TO_INTERN ;

//*******************************************************
// uebertraegt Stellung von externem Brett in            
// internes Brett (BI)                                   
//*******************************************************


   var I : INTEGER ;
       X : CHAR ;
       Y : CHAR ;

   begin (* TRANSFER_TO_INTERN *)
     with G do
       begin
         for I := 0 to BI_MAX do
           with BI [ I ] do
             begin
               if IX_EXT ( I ) <> '' then
                 STAT := XFREE
               else
                 STAT := NOEX ;
               WAS := NOFIG ;
               COL := NOCOL ;
             end (* with *) ;
         for X := 'a' to 'h' do
           for Y := '1' to '8' do
             if BRETT [ X , Y ] . BELEGT then
               begin
                 I := IX_INT ( X , Y ) ;
                 BI [ I ] . STAT := OCCUP ;
                 BI [ I ] . WAS := BRETT [ X , Y ] . WAS ;
                 BI [ I ] . COL := BRETT [ X , Y ] . COL ;
               end (* then *) ;
       end (* with *)
   end (* TRANSFER_TO_INTERN *) ;



procedure TRANSFER_TO_EXTERN ;

//*******************************************************
// uebertraegt Stellung von internem Brett (BI)          
// in externes Brett                                     
//*******************************************************


   var I : INTEGER ;
       S : STRING ( 2 ) ;
       X : CHAR ;
       Y : CHAR ;

   begin (* TRANSFER_TO_EXTERN *)
     with G do
       begin
         BRETT_LEEREN ;
         for I := 0 to BI_MAX do
           if BI [ I ] . STAT = OCCUP then
             begin
               S := IX_EXT ( I ) ;
               X := S [ 1 ] ;
               Y := S [ 2 ] ;
               BRETT [ X , Y ] . BELEGT := TRUE ;
               BRETT [ X , Y ] . WAS := BI [ I ] . WAS ;
               BRETT [ X , Y ] . COL := BI [ I ] . COL ;
             end (* then *) ;
       end (* with *)
   end (* TRANSFER_TO_EXTERN *) ;



function CHECK_REIHE_FREI ( POS1 , POS2 : INTEGER ; MODUS : INTEGER ) :
                          BOOLEAN ;

//**********************************************
// pruefen, ob bei Bedrohungen durch            
// Dame, Turm oder Laeufer (gleiche Reihe oder  
// Diagonale) zwischen der Figur auf Pos1       
// und der angegriffenen Figur auf Pos2         
// noch andere Figuren stehen                   
//**********************************************


   var INCR : INTEGER ;
       POSX : INTEGER ;

   begin (* CHECK_REIHE_FREI *)
     with G do
       begin
         case MODUS of
           1 : begin

     //*************************************
     // Diagonale nach links aufsteigend,   
     // Index um 11 rauf oder runter        
     //*************************************

                 INCR := 11 ;
                 if POS2 < POS1 then
                   INCR := - INCR ;
               end (* tag/ca *) ;
           2 : begin

     //************************************
     // Diagonale nach rechts aufsteigend, 
     // Index um 13 rauf oder runter       
     //************************************

                 INCR := 13 ;
                 if POS2 < POS1 then
                   INCR := - INCR ;
               end (* tag/ca *) ;
           3 : begin

     //*********************************************
     // gleiche Reihe, Index um 1 rauf oder runter  
     //*********************************************

                 INCR := 1 ;
                 if POS2 < POS1 then
                   INCR := - INCR ;
               end (* tag/ca *) ;
           4 : begin

     //***********************************************
     // gleiche Spalte, Index um 12 rauf oder runter  
     //***********************************************

                 INCR := 12 ;
                 if POS2 < POS1 then
                   INCR := - INCR ;
               end (* tag/ca *) ;
         end (* case *) ;

     //*******************************************
     // Felder zwischen pos1 und pos2 anschauen,  
     // ob sie belegt sind                        
     //*******************************************

         if INCR > 0 then
           begin
             POSX := POS1 + INCR ;
             while POSX < POS2 do
               if BI [ POSX ] . STAT = OCCUP then
                 begin
                   CHECK_REIHE_FREI := FALSE ;
                   return
                 end (* then *)
               else
                 POSX := POSX + INCR ;
           end (* then *)
         else
           begin
             POSX := POS1 + INCR ;
             while POSX > POS2 do
               if BI [ POSX ] . STAT = OCCUP then
                 begin
                   CHECK_REIHE_FREI := FALSE ;
                   return
                 end (* then *)
               else
                 POSX := POSX + INCR ;
           end (* else *) ;
       end (* with *) ;
     CHECK_REIHE_FREI := TRUE
   end (* CHECK_REIHE_FREI *) ;



function ERREICHBAR ( POS1 : INTEGER ; POS2 : INTEGER ; WAS : FIGUR ;
                    COL : FARBE ) : BOOLEAN ;

//**********************************************
// erreichbar gibt an, ob die Position pos2     
// von der Position pos1 aus (zum Schlagen)     
// erreichbar ist bei gegebener Figur           
// (die Figur steht auf pos1).                  
//**********************************************
// col is die Farbe der Figur bei pos1          
// sie spielt normalerweise keine Rolle,        
// nur bei Bauern                               
//**********************************************


   var DIFF : INTEGER ;
       R1 , R2 , C1 , C2 : BI_INDEX ;
       D11 , D12 , D21 , D22 : BI_INDEX ;
       ETEMP : BOOLEAN ;

   begin (* ERREICHBAR *)
     ERREICHBAR := FALSE ;
     case WAS of
       BAUER : begin
                 DIFF := POS2 - POS1 ;
                 if COL = SCHWARZ then
                   DIFF := - DIFF ;
                 ERREICHBAR := DIFF in [ 11 , 13 ]
               end (* tag/ca *) ;
       SPRINGER :
         begin
           DIFF := ABS ( POS2 - POS1 ) ;
           ERREICHBAR := DIFF in [ 10 , 14 , 23 , 25 ] ;
         end (* tag/ca *) ;
       LAEUFER :
         begin
           R1 := POS1 DIV 12 ;
           C1 := POS1 MOD 12 ;
           R2 := POS2 DIV 12 ;
           C2 := POS2 MOD 12 ;
           D11 := R1 + C1 ;
           D12 := 24 + R1 - C1 ;
           D21 := R2 + C2 ;
           D22 := 24 + R2 - C2 ;
           ETEMP := ( D11 = D21 ) or ( D12 = D22 ) ;
           if not ETEMP then
             begin
               ERREICHBAR := FALSE ;
               return
             end (* then *) ;
           if D11 = D21 then
             ERREICHBAR := CHECK_REIHE_FREI ( POS1 , POS2 , 1 )
           else
             ERREICHBAR := CHECK_REIHE_FREI ( POS1 , POS2 , 2 )
         end (* tag/ca *) ;
       TURM : begin
                R1 := POS1 DIV 12 ;
                R2 := POS2 DIV 12 ;
                C1 := POS1 MOD 12 ;
                C2 := POS2 MOD 12 ;
                ETEMP := ( R1 = R2 ) or ( C1 = C2 ) ;
                if not ETEMP then
                  begin
                    ERREICHBAR := FALSE ;
                    return
                  end (* then *) ;
                if R1 = R2 then
                  ERREICHBAR := CHECK_REIHE_FREI ( POS1 , POS2 , 3 )
                else
                  ERREICHBAR := CHECK_REIHE_FREI ( POS1 , POS2 , 4 )
              end (* tag/ca *) ;
       DAME : begin
                R1 := POS1 DIV 12 ;
                C1 := POS1 MOD 12 ;
                R2 := POS2 DIV 12 ;
                C2 := POS2 MOD 12 ;
                D11 := R1 + C1 ;
                D12 := 24 + R1 - C1 ;
                D21 := R2 + C2 ;
                D22 := 24 + R2 - C2 ;
                ETEMP := ( D11 = D21 ) or ( D12 = D22 ) or ( R1 = R2 )
                         or ( C1 = C2 ) ;
                if not ETEMP then
                  begin
                    ERREICHBAR := FALSE ;
                    return
                  end (* then *) ;
                if D11 = D21 then
                  ERREICHBAR := CHECK_REIHE_FREI ( POS1 , POS2 , 1 )
                else
                  if D12 = D22 then
                    ERREICHBAR := CHECK_REIHE_FREI ( POS1 , POS2 , 2 )
                  else
                    if R1 = R2 then
                      ERREICHBAR := CHECK_REIHE_FREI ( POS1 , POS2 , 3
                                    )
                    else
                      ERREICHBAR := CHECK_REIHE_FREI ( POS1 , POS2 , 4
                                    )
              end (* tag/ca *) ;
       KOENIG :
         begin
           DIFF := ABS ( POS2 - POS1 ) ;
           ERREICHBAR := DIFF in [ 1 , 11 , 12 , 13 ] ;
         end (* tag/ca *) ;
     end (* case *) ;
   end (* ERREICHBAR *) ;



function LEGALE_STELLUNG : BOOLEAN ;

//**********************************************
// interne Stellung anschauen                   
// legal bedeutet (derzeit):                    
// zwei Koenige                                 
// diese stehen nicht auf benachbarten Feldern  
//**********************************************


   var I : INTEGER ;

   begin (* LEGALE_STELLUNG *)
     with G do
       begin
         K_SCHWARZ_POS := - 1 ;
         K_WEISS_POS := - 1 ;
         for I := 0 to BI_MAX do
           if BI [ I ] . STAT = OCCUP then
             if BI [ I ] . WAS = KOENIG then
               if BI [ I ] . COL = WEISS then
                 begin
                   if K_WEISS_POS >= 0 then
                     begin
                       LEGALE_STELLUNG := FALSE ;
                       return
                     end (* then *)
                   else
                     K_WEISS_POS := I ;
                 end (* then *)
               else
                 begin
                   if K_SCHWARZ_POS >= 0 then
                     begin
                       LEGALE_STELLUNG := FALSE ;
                       return
                     end (* then *)
                   else
                     K_SCHWARZ_POS := I ;
                 end (* else *) ;
         if K_SCHWARZ_POS < 0 then
           begin
             LEGALE_STELLUNG := FALSE ;
             return
           end (* then *) ;
         if K_WEISS_POS < 0 then
           begin
             LEGALE_STELLUNG := FALSE ;
             return
           end (* then *) ;
         if ERREICHBAR ( K_WEISS_POS , K_SCHWARZ_POS , KOENIG , NOCOL )
         then
           begin
             LEGALE_STELLUNG := FALSE ;
             return
           end (* then *) ;
       end (* with *) ;
     LEGALE_STELLUNG := TRUE ;
   end (* LEGALE_STELLUNG *) ;



function IS_SCHACH : BOOLEAN ;

//**********************************************
// prueft, ob Koenig im Schach steht            
// das heisst im Prinzip:                       
// erreichbar zum Schlagen von irgendeiner      
// gegnerischen Figur ausser Koenig             
//**********************************************


   var KOENIG_POS : INTEGER ;
       F : FIGUR ;
       I : INTEGER ;

   begin (* IS_SCHACH *)
     with G do
       begin
         if AM_ZUG = SCHWARZ then
           KOENIG_POS := K_SCHWARZ_POS
         else
           KOENIG_POS := K_WEISS_POS ;
         for I := 0 to BI_MAX do
           if BI [ I ] . STAT = OCCUP then
             begin
               F := BI [ I ] . WAS ;
               if F <> KOENIG then
                 if BI [ I ] . COL <> AM_ZUG then
                   if ERREICHBAR ( I , KOENIG_POS , F , BI [ I ] . COL
                   ) then
                     begin
                       IS_SCHACH := TRUE ;
                       return
                     end (* then *)
             end (* then *) ;
       end (* with *) ;
     IS_SCHACH := FALSE
   end (* IS_SCHACH *) ;



procedure NEUER_ZUG ( POS , POSN : INTEGER ) ;

   var GSAVE : GLOBAL ;
       OK : BOOLEAN ;
       PZUG : ZUGPTR ;

   begin (* NEUER_ZUG *)

     //***************************
     // neuen Zug ausprobieren    
     //***************************

     GSAVE := G ;
     with G do
       begin
         BI [ POSN ] := BI [ POS ] ;
         BI [ POS ] . STAT := XFREE ;
         BI [ POS ] . WAS := NOFIG ;
         BI [ POS ] . COL := NOCOL ;
       end (* with *) ;
     OK := LEGALE_STELLUNG ;
     if OK then
       OK := not IS_SCHACH ;
     if OK then
       begin
         PZUG := ALLOC_ZUG ;
         with PZUG -> do
           begin
             POS_ALT := POS ;
             POS_NEU := POSN ;
             ZSTRING := 'X' ;
             ZSTRING [ 1 ] := FIGUR_TO_CHAR ( G . BI [ POSN ] . WAS ) ;
             ZSTRING := ZSTRING || IX_EXT ( POS ) || '-' ;
             if GSAVE . BI [ POSN ] . STAT = OCCUP then
               ZSTRING [ 4 ] := 'x' ;
             ZSTRING := ZSTRING || IX_EXT ( POSN ) ;
             G_NEU := G ;
             G_NEU . ZFIRST := NIL ;
             G_NEU . ZLAST := NIL ;
             if GSAVE . ZFIRST = NIL then
               begin
                 GSAVE . ZFIRST := PZUG ;
                 GSAVE . ZLAST := PZUG
               end (* then *)
             else
               begin
                 GSAVE . ZLAST -> . ALTERN := PZUG ;
                 GSAVE . ZLAST := PZUG
               end (* else *) ;
             ALTERN := NIL ;
           end (* with *) ;
       end (* then *) ;
     G := GSAVE ;
     if not OK then
       return ;
     with G do
       begin
         ANZAHL_ZUEGE := ANZAHL_ZUEGE + 1 ;
       end (* with *)
   end (* NEUER_ZUG *) ;



function ZUG_OK ( POS : INTEGER ; C : FARBE ) : BOOLEAN ;

//*************************************************
// passt fuer alle Figuren, aber nicht fuer Bauer  
//*************************************************


   begin (* ZUG_OK *)
     with G do
       ZUG_OK := ( BI [ POS ] . STAT = XFREE ) or ( ( BI [ POS ] . STAT
                 = OCCUP ) and ( BI [ POS ] . COL <> C ) )
   end (* ZUG_OK *) ;



procedure SUCHE_ZUEGE ( POS : INTEGER ; WAS : FIGUR ; C : FARBE ) ;

//**********************************************
// Suche alle Zuege fuer Figur an Position pos  
// was = die Figur, um die es hier geht         
// c = deren Farbe                              
// gefundene Zuege in Liste eintragen           
//**********************************************


   var POSN : INTEGER ;
       INCR : INTEGER ;

   begin (* SUCHE_ZUEGE *)
     with G do
       begin
         case WAS of
           BAUER : case C of
                     WEISS : begin
                               INCR := 12 ;
                               if POS < 48 then
                                 begin
                                   POSN := POS + INCR ;
                                   if BI [ POSN ] . STAT = XFREE then
                                     begin
                                       POSN := POSN + INCR ;
                                       if BI [ POSN ] . STAT = XFREE
                                       then
                                         NEUER_ZUG ( POS , POSN ) ;
                                     end (* then *)
                                 end (* then *) ;
                               POSN := POS + INCR ;
                               if BI [ POSN ] . STAT = XFREE then
                                 NEUER_ZUG ( POS , POSN ) ;
                               POSN := POSN - 1 ;
                               if ( BI [ POSN ] . STAT = OCCUP ) and (
                               BI [ POSN ] . COL <> C ) then
                                 NEUER_ZUG ( POS , POSN ) ;
                               POSN := POSN + 2 ;
                               if ( BI [ POSN ] . STAT = OCCUP ) and (
                               BI [ POSN ] . COL <> C ) then
                                 NEUER_ZUG ( POS , POSN ) ;
                             end (* tag/ca *) ;
                     SCHWARZ :
                       begin
                         INCR := 12 ;
                         if POS > 96 then
                           begin
                             POSN := POS - INCR ;
                             if BI [ POSN ] . STAT = XFREE then
                               begin
                                 POSN := POSN - INCR ;
                                 if BI [ POSN ] . STAT = XFREE then
                                   NEUER_ZUG ( POS , POSN ) ;
                               end (* then *)
                           end (* then *) ;
                         POSN := POS - INCR ;
                         if BI [ POSN ] . STAT = XFREE then
                           NEUER_ZUG ( POS , POSN ) ;
                         POSN := POSN - 1 ;
                         if ( BI [ POSN ] . STAT = OCCUP ) and ( BI [
                         POSN ] . COL <> C ) then
                           NEUER_ZUG ( POS , POSN ) ;
                         POSN := POSN + 2 ;
                         if ( BI [ POSN ] . STAT = OCCUP ) and ( BI [
                         POSN ] . COL <> C ) then
                           NEUER_ZUG ( POS , POSN ) ;
                       end (* tag/ca *) ;
                   end (* case *) ;
           SPRINGER :
             begin
               POSN := POS + 10 ;
               if ZUG_OK ( POSN , C ) then
                 NEUER_ZUG ( POS , POSN ) ;
               POSN := POS + 14 ;
               if ZUG_OK ( POSN , C ) then
                 NEUER_ZUG ( POS , POSN ) ;
               POSN := POS + 23 ;
               if ZUG_OK ( POSN , C ) then
                 NEUER_ZUG ( POS , POSN ) ;
               POSN := POS + 25 ;
               if ZUG_OK ( POSN , C ) then
                 NEUER_ZUG ( POS , POSN ) ;
               POSN := POS - 10 ;
               if ZUG_OK ( POSN , C ) then
                 NEUER_ZUG ( POS , POSN ) ;
               POSN := POS - 14 ;
               if ZUG_OK ( POSN , C ) then
                 NEUER_ZUG ( POS , POSN ) ;
               POSN := POS - 23 ;
               if ZUG_OK ( POSN , C ) then
                 NEUER_ZUG ( POS , POSN ) ;
               POSN := POS - 25 ;
               if ZUG_OK ( POSN , C ) then
                 NEUER_ZUG ( POS , POSN ) ;
             end (* tag/ca *) ;
           LAEUFER :
             begin
               POSN := POS ;
               repeat
                 POSN := POSN + 13 ;
                 if ZUG_OK ( POSN , C ) then
                   NEUER_ZUG ( POS , POSN ) ;
               until BI [ POSN ] . STAT <> XFREE ;
               POSN := POS ;
               repeat
                 POSN := POSN + 11 ;
                 if ZUG_OK ( POSN , C ) then
                   NEUER_ZUG ( POS , POSN ) ;
               until BI [ POSN ] . STAT <> XFREE ;
               POSN := POS ;
               repeat
                 POSN := POSN - 11 ;
                 if ZUG_OK ( POSN , C ) then
                   NEUER_ZUG ( POS , POSN ) ;
               until BI [ POSN ] . STAT <> XFREE ;
               POSN := POS ;
               repeat
                 POSN := POSN - 13 ;
                 if ZUG_OK ( POSN , C ) then
                   NEUER_ZUG ( POS , POSN ) ;
               until BI [ POSN ] . STAT <> XFREE ;
             end (* tag/ca *) ;
           TURM : begin
                    POSN := POS ;
                    repeat
                      POSN := POSN - 1 ;
                      if ZUG_OK ( POSN , C ) then
                        NEUER_ZUG ( POS , POSN ) ;
                    until BI [ POSN ] . STAT <> XFREE ;
                    POSN := POS ;
                    repeat
                      POSN := POSN + 1 ;
                      if ZUG_OK ( POSN , C ) then
                        NEUER_ZUG ( POS , POSN ) ;
                    until BI [ POSN ] . STAT <> XFREE ;
                    POSN := POS ;
                    repeat
                      POSN := POSN - 12 ;
                      if ZUG_OK ( POSN , C ) then
                        NEUER_ZUG ( POS , POSN ) ;
                    until BI [ POSN ] . STAT <> XFREE ;
                    POSN := POS ;
                    repeat
                      POSN := POSN + 12 ;
                      if ZUG_OK ( POSN , C ) then
                        NEUER_ZUG ( POS , POSN ) ;
                    until BI [ POSN ] . STAT <> XFREE ;
                  end (* tag/ca *) ;
           DAME : begin
                    POSN := POS ;
                    repeat
                      POSN := POSN + 13 ;
                      if ZUG_OK ( POSN , C ) then
                        NEUER_ZUG ( POS , POSN ) ;
                    until BI [ POSN ] . STAT <> XFREE ;
                    POSN := POS ;
                    repeat
                      POSN := POSN + 11 ;
                      if ZUG_OK ( POSN , C ) then
                        NEUER_ZUG ( POS , POSN ) ;
                    until BI [ POSN ] . STAT <> XFREE ;
                    POSN := POS ;
                    repeat
                      POSN := POSN - 11 ;
                      if ZUG_OK ( POSN , C ) then
                        NEUER_ZUG ( POS , POSN ) ;
                    until BI [ POSN ] . STAT <> XFREE ;
                    POSN := POS ;
                    repeat
                      POSN := POSN - 13 ;
                      if ZUG_OK ( POSN , C ) then
                        NEUER_ZUG ( POS , POSN ) ;
                    until BI [ POSN ] . STAT <> XFREE ;
                    POSN := POS ;
                    repeat
                      POSN := POSN - 1 ;
                      if ZUG_OK ( POSN , C ) then
                        NEUER_ZUG ( POS , POSN ) ;
                    until BI [ POSN ] . STAT <> XFREE ;
                    POSN := POS ;
                    repeat
                      POSN := POSN + 1 ;
                      if ZUG_OK ( POSN , C ) then
                        NEUER_ZUG ( POS , POSN ) ;
                    until BI [ POSN ] . STAT <> XFREE ;
                    POSN := POS ;
                    repeat
                      POSN := POSN - 12 ;
                      if ZUG_OK ( POSN , C ) then
                        NEUER_ZUG ( POS , POSN ) ;
                    until BI [ POSN ] . STAT <> XFREE ;
                    POSN := POS ;
                    repeat
                      POSN := POSN + 12 ;
                      if ZUG_OK ( POSN , C ) then
                        NEUER_ZUG ( POS , POSN ) ;
                    until BI [ POSN ] . STAT <> XFREE ;
                  end (* tag/ca *) ;
           KOENIG :
             begin
               POSN := POS + 1 ;
               if ZUG_OK ( POSN , C ) then
                 NEUER_ZUG ( POS , POSN ) ;
               POSN := POS - 1 ;
               if ZUG_OK ( POSN , C ) then
                 NEUER_ZUG ( POS , POSN ) ;
               for POSN := POS + 11 to POS + 13 do
                 if ZUG_OK ( POSN , C ) then
                   NEUER_ZUG ( POS , POSN ) ;
               for POSN := POS - 13 to POS - 11 do
                 if ZUG_OK ( POSN , C ) then
                   NEUER_ZUG ( POS , POSN ) ;
             end (* tag/ca *) ;
         end (* case *) ;
       end (* with *)
   end (* SUCHE_ZUEGE *) ;



procedure FREE_ZUEGE ( var G : GLOBAL ) ;

   var PX : ZUGPTR ;

   begin (* FREE_ZUEGE *)
     with G do
       while ZFIRST <> NIL do
         begin
           PX := ZFIRST ;
           ZFIRST := ZFIRST -> . ALTERN ;
           FREE_ZUG ( PX ) ;
         end (* while *) ;
   end (* FREE_ZUEGE *) ;



procedure SUCHE_ALLE_ZUEGE ;

//************************************************
// suche alle Zuege fuer alle Figuren der Farbe,  
// die am Zug ist                                 
//************************************************


   var I : INTEGER ;
       F : FIGUR ;

   begin (* SUCHE_ALLE_ZUEGE *)
     with G do
       begin
         ZFIRST := NIL ;
         ZLAST := NIL ;
         ANZAHL_ZUEGE := 0 ;
         for I := 0 to BI_MAX do
           if BI [ I ] . STAT = OCCUP then
             if BI [ I ] . COL = AM_ZUG then
               begin
                 F := BI [ I ] . WAS ;
                 SUCHE_ZUEGE ( I , F , AM_ZUG ) ;
               end (* then *) ;
       end (* with *)
   end (* SUCHE_ALLE_ZUEGE *) ;



function SPIELSTATUS : SSTATUS ;

   var XSCHACH : BOOLEAN ;

   begin (* SPIELSTATUS *)
     XSCHACH := IS_SCHACH ;
     if XSCHACH then
       begin
         SPIELSTATUS := CHECK ;
         SUCHE_ALLE_ZUEGE ;
         if G . ANZAHL_ZUEGE = 0 then
           SPIELSTATUS := CHECKMATE ;
       end (* then *)
     else
       begin
         SPIELSTATUS := NORM ;
         SUCHE_ALLE_ZUEGE ;
         if G . ANZAHL_ZUEGE = 0 then
           SPIELSTATUS := STALEMATE ;
       end (* else *)
   end (* SPIELSTATUS *) ;



procedure ZUEGE_ANZEIGEN ;

   var Z : INTEGER := 0 ;
       PZUG : ZUGPTR ;

   begin (* ZUEGE_ANZEIGEN *)
     with G do
       begin
         PZUG := G . ZFIRST ;
         while PZUG <> NIL do
           begin
             Z := Z + 1 ;
             WRITELN ( Z : 2 , '. Zug: ' , PZUG -> . ZSTRING ) ;
             PZUG := PZUG -> . ALTERN ;
           end (* while *)
       end (* with *)
   end (* ZUEGE_ANZEIGEN *) ;



function SUCHE_MATT_ZUEGE ( AUSG : BOOLEAN ; ZUGNUMMER : INTEGER ;
                          const ZUEGE : STRING ) : BOOLEAN ;

   var GEF : BOOLEAN := FALSE ;
       PZUG : ZUGPTR ;
       GSAVE : GLOBAL ;
       Z : INTEGER := 0 ;
       ZAUS : INTEGER := 0 ;

   begin (* SUCHE_MATT_ZUEGE *)
     with G do
       begin
         PZUG := G . ZFIRST ;
         while PZUG <> NIL do
           begin
             GSAVE := G ;
             G := PZUG -> . G_NEU ;
             if G . AM_ZUG = WEISS then
               G . AM_ZUG := SCHWARZ
             else
               G . AM_ZUG := WEISS ;
             if SPIELSTATUS = CHECKMATE then
               begin
                 Z := Z + 1 ;
                 if ZUGNUMMER <> 0 then
                   ZAUS := ZUGNUMMER
                 else
                   ZAUS := Z ;
                 if AUSG then
                   if ZUEGE = '' then
                     WRITELN ( ZAUS : 2 , '. Matt-Zug: ' , ZUEGE , ' '
                               , PZUG -> . ZSTRING )
                   else
                     WRITELN ( ZAUS : 2 , '. Zug: ' , ZUEGE , ' ' ,
                               PZUG -> . ZSTRING , ' - Matt' ) ;
                 GEF := TRUE
               end (* then *) ;
             FREE_ZUEGE ( G ) ;
             G := GSAVE ;
             PZUG := PZUG -> . ALTERN ;
           end (* while *)
       end (* with *) ;
     SUCHE_MATT_ZUEGE := GEF ;
   end (* SUCHE_MATT_ZUEGE *) ;



procedure WORK_M0 ;

   begin (* WORK_M0 *)

     //*******************************************************
     // moegliche Zuege sind bereits ermittelt                
     // alle moeglichen Zuege anschauen und pruefen           
     // ob die resultierende Stellung eine Matt-Stellung ist  
     //*******************************************************

     if not SUCHE_MATT_ZUEGE ( TRUE , 0 , '' ) then
       WRITELN ( '+++ kein Matt-Zug gefunden' ) ;
   end (* WORK_M0 *) ;



function WORK_M1 ( AUSG : BOOLEAN ; const ZUEGE : STRING ) : BOOLEAN ;

   var GEF : BOOLEAN := FALSE ;
       GEF2 : BOOLEAN := FALSE ;
       GSAVE : GLOBAL ;
       PZUG : ZUGPTR ;
       Z : INTEGER := 0 ;

   begin (* WORK_M1 *)

     //******************************************************
     // moegliche Zuege sind bereits ermittelt               
     // alle moeglichen Zuege anschauen und                  
     // 1.) pruefen, ob die resultierende Stellung           
     //     Matt oder Stalemate ist, dann Treffer            
     // 2.) wenn nicht, Farbe wechseln und erneut            
     //     ab dieser Stellung alle Zuege ausrechnen         
     // 3.) der gefundene Zug (vorne) ist dann interessant,  
     //     wenn es einen Zug gibt,                          
     //     der in 2.) nicht zu Matt fuehrt                  
     //******************************************************

     with G do
       begin
         PZUG := G . ZFIRST ;
         while PZUG <> NIL do
           begin
             GSAVE := G ;
             G := PZUG -> . G_NEU ;
             if G . AM_ZUG = WEISS then
               G . AM_ZUG := SCHWARZ
             else
               G . AM_ZUG := WEISS ;

     //*****************************************
     // pruefen Spielstatus nach aktuellem Zug  
     //*****************************************

             G . ST := SPIELSTATUS ;
             if G . ST = CHECKMATE then
               begin
                 if AUSG then
                   WRITELN ( 'Matt-Zug: ' , ZUEGE , ' ' , PZUG -> .
                             ZSTRING ) ;
                 break ;
               end (* then *) ;
             if G . ST = STALEMATE then
               begin
                 if AUSG then
                   WRITELN ( 'Kein Zug mehr - ' , ZUEGE , ' ' , PZUG ->
                             . ZSTRING ) ;
                 break ;
               end (* then *) ;

     //********************************************
     // pruefen, ob es gegnerische Mattzuege gibt  
     //********************************************

             Z := Z + 1 ;

     //*************************************
     // problem hier bei dieser verkettung  
     //*************************************

             GEF := SUCHE_MATT_ZUEGE ( AUSG , Z , ZUEGE || ' ' || PZUG
                    -> . ZSTRING ) ;
             FREE_ZUEGE ( G ) ;
             G := GSAVE ;
             if not GEF then
               begin
                 GEF2 := TRUE ;
                 if AUSG then
                   WRITELN ( 'Matt wird verhindert durch: ' , PZUG -> .
                             ZSTRING )
               end (* then *) ;
             PZUG := PZUG -> . ALTERN ;
           end (* while *)
       end (* with *) ;
     if not GEF2 then
       if AUSG then
         WRITELN ( 'Matt kann nicht mehr abgewehrt werden' ) ;
     WORK_M1 := GEF2
   end (* WORK_M1 *) ;



procedure WORK_M2 ;

   var GEF : BOOLEAN := FALSE ;
       GSAVE : GLOBAL ;
       PZUG : ZUGPTR ;

   begin (* WORK_M2 *)

     //********************************************************
     // moegliche Zuege sind bereits ermittelt                 
     // alle moeglichen Zuege der Reihe nach ausprobieren      
     // dann Farbe wechseln und im Prinzip die Logik von       
     // m1, d.h.: kann das matt im folgenden Zug noch          
     // abgewendet werden? Falls ja, ist der Zug keine         
     // Loesung. Falls nein, Loesung ausgeben.                 
     //********************************************************

     with G do
       begin
         PZUG := G . ZFIRST ;
         while PZUG <> NIL do
           begin
             if FALSE then
               WRITELN ( 'm2: check ' , PZUG -> . ZSTRING ) ;
             GSAVE := G ;
             G := PZUG -> . G_NEU ;
             if G . AM_ZUG = WEISS then
               G . AM_ZUG := SCHWARZ
             else
               G . AM_ZUG := WEISS ;

     //*****************************************
     // pruefen Spielstatus nach aktuellem Zug  
     //*****************************************

             G . ST := SPIELSTATUS ;
             if G . ST = CHECKMATE then
               WRITELN ( 'Matt-Zug: ' , PZUG -> . ZSTRING )
             else
               if G . ST = STALEMATE then
                 WRITELN ( 'Kein Zug mehr - ' , PZUG -> . ZSTRING )
               else
                 begin

     //*****************************************
     // jetzt Logik vom M1                      
     //*****************************************

                   GEF := WORK_M1 ( FALSE , '' ) ;

     //**************************************************
     // wenn nichts gefunden                             
     // M1 nochmal aufrufen, um Loesung auszugeben       
     //**************************************************

                   if not GEF then
                     begin
                       GEF := WORK_M1 ( TRUE , PZUG -> . ZSTRING ) ;
                     end (* then *)
                 end (* else *) ;
             FREE_ZUEGE ( G ) ;
             if FALSE then
               WRITE_COUNTS ;
             G := GSAVE ;
             PZUG := PZUG -> . ALTERN ;
           end (* while *)
       end (* with *)
   end (* WORK_M2 *) ;



begin (* HAUPTPROGRAMM *)
  TERMIN ( INPUT ) ;
  TERMOUT ( OUTPUT ) ;
  STELLUNG_ANFANG ;
  STELLUNG_EINLESEN ( STELLUNG ) ;
  TRANSFER_TO_INTERN ;
  WRITELN ;
  STELLUNG_AUSG_INT ;
  TRANSFER_TO_EXTERN ;
  WRITELN ;
  STELLUNG_AUSGEBEN ;
  if not LEGALE_STELLUNG then
    begin
      WRITELN ( '+++ illegale Stellung +++' ) ;
      EXIT ( 8 )
    end (* then *) ;

  //*************************************
  // User Dialog                         
  // zunaechst abfragen, wer am Zug ist  
  // und dann, was getan werden soll     
  //*************************************

  repeat
    repeat
      WRITELN ;
      WRITELN ( 'wer ist am Zug ? (W/S) - leere Eingabe = Ende' ) ;
      READLN ( ANTWORT ) ;
      WRITELN ( 'antwort = <' , ANTWORT , '>' ) ;
      ANTWORT := TRIM ( ANTWORT ) ;
      WRITELN ( 'antwort = <' , ANTWORT , '>' ) ;
      S_TOUPPER ( ANTWORT ) ;
      WRITELN ( 'antwort = <' , ANTWORT , '>' ) ;
    until ( ANTWORT = 'W' ) or ( ANTWORT = 'S' ) or ( ANTWORT = '' ) ;
    if ANTWORT = '' then
      break ;
    WRITELN ;
    STELLUNG_AUSGEBEN ;
    WRITELN ;
    A := ANTWORT [ 1 ] ;
    if A in [ 'w' , 'W' ] then
      begin
        G . AM_ZUG := WEISS ;
        WRITELN ( 'Analyse fuer Weiss am Zug:' ) ;
      end (* then *)
    else
      begin
        G . AM_ZUG := SCHWARZ ;
        WRITELN ( 'Analyse fuer Schwarz am Zug:' ) ;
      end (* else *) ;

  //*****************************************
  // Analyse Stellung auf Schach, Matt usw.  
  // Anzahl noch moegliche Zuege             
  //*****************************************

    G . ZFIRST := NIL ;
    G . ZLAST := NIL ;
    G . ST := SPIELSTATUS ;
    case G . ST of
      CHECK : WRITELN ( '+++ steht im Schach +++' ) ;
      STALEMATE :
        WRITELN ( '+++ hat keinen Zug mehr (REMIS) +++' ) ;
      CHECKMATE :
        WRITELN ( '+++ ist schachmatt +++' ) ;
      otherwise
        
    end (* case *) ;
    WRITELN ( 'Anzahl Zuege = ' , G . ANZAHL_ZUEGE : 1 ) ;

  //**********************************
  // Abfrage der gewuenschten Aktion  
  //**********************************

    WRITELN ;
    WRITELN ( 'E  = Ende' ) ;
    WRITELN ( 'M0 = Gibt es einen Matt-Zug ?' ) ;
    WRITELN ( 'M1 = Kann Matt noch abgewehrt werden ?' ) ;
    WRITELN ( 'M2 = Matt in zwei Zuegen' ) ;
    WRITELN ( 'M3 = Matt in drei Zuegen' ) ;
    WRITELN ( 'Z  = Zuege anzeigen' ) ;
    WRITELN ;
    WRITELN ( 'was ist zu tun ?' ) ;
    READLN ( ANTWORT ) ;
    ANTWORT := TRIM ( ANTWORT ) ;
    S_TOUPPER ( ANTWORT ) ;
    if ANTWORT = 'E' then
      break ;

  //****************************************
  // Verzweigen zu der gewuenschten Aktion  
  //****************************************

    ALLOC_COUNT := 0 ;
    FREE_COUNT := 0 ;
    if ANTWORT = 'Z' then
      begin
        ZUEGE_ANZEIGEN ;
        continue
      end (* then *) ;
    if ANTWORT = 'M0' then
      begin
        WORK_M0 ;
        WRITE_COUNTS ;
        continue
      end (* then *) ;
    if ANTWORT = 'M1' then
      begin
        DUMMYB := WORK_M1 ( TRUE , '' ) ;
        WRITE_COUNTS ;
        continue
      end (* then *) ;
    if ANTWORT = 'M2' then
      begin
        WORK_M2 ;
        WRITE_COUNTS ;
        continue
      end (* then *) ;
  until FALSE
end (* HAUPTPROGRAMM *) .
