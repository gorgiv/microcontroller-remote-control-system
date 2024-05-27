'****************************************************************
'*  Name    : code.BAS                                          *
'*  Author  : Gjorgji Velkovski                                 *
'*  Notice  : Copyright (c) 2014 SMSkontroler                   *
'*          : All Rights Reserved                               *
'*  Date    : 24.12.2014                                        *
'*  Version : 1.0                                               *
'*  Notes   :                                                   *
'*          :                                                   *
'****************************************************************

Device 18F8722
XTAL 24 

Declare HSERIAL_BAUD = 9600     ' Brzina na seriska komunikacija

TRISB = 0                       ' definiranje izlezni za LCD
         	
LCD_DTPIN = PORTB.4	            ' Podesuvanje na LCD
LCD_RSPIN = PORTB.0
LCD_ENPIN = PORTB.2
LCD_INTERFACE = 4		
LCD_LINES = 2
LCD_TYPE = 0

Symbol ADON = ADCON0.0          ' ADCON0: A/D control register 0
Symbol GODONE = ADCON0.1        ' status bit na A/D konverzijata 
Symbol CHS0 = ADCON0.2
Symbol CHS1 = ADCON0.3
Symbol CHS2 = ADCON0.4
Symbol CHS3 = ADCON0.5

Symbol PCFG0 = ADCON1.0         ' ADCON1: A/D control register 1
Symbol PCFG1 = ADCON1.1
Symbol PCFG2 = ADCON1.2
Symbol PCFG3 = ADCON1.3
Symbol VCFG0 = ADCON1.4
Symbol VCFG1 = ADCON1.5

Symbol ADCS0 = ADCON2.0         ' ADCON2: A/D control register 2
Symbol ADCS1 = ADCON2.1
Symbol ADCS2 = ADCON2.2
Symbol ACQT0 = ADCON2.3
Symbol ACQT1 = ADCON2.4
Symbol ACQT2 = ADCON2.5
Symbol ADFM = ADCON2.7

TRISA = %00001101               ' definiranje vlezni i izlezni [A/D konverzija]

CHS0 = 0                        ' selektiranje bitovi za analogen kanal (RA0/AN0) na koj e povrzan Temp.senzor
CHS1 = 0
CHS2 = 0
CHS3 = 0

PCFG0 = 0                       ' konfiguracija na kontrolni bitovi (analogen vlez)    
PCFG1 = 0
PCFG2 = 0
PCFG3 = 0                        
VCFG0 = 1                       ' nadvoresen Vref+ (1V)
VCFG1 = 1                       ' nadvoresen Vref- (0V)                           
                            
ADCS0 = 0                       ' selektiranje bitovi za taktot na A/D konverzija (Fosc/2)
ADCS1 = 0
ADCS2 = 0
ACQT0 = 1                       ' selektiranje bitovi za dobivanje vreme pred A/D konverzija (2 Tad)
ACQT1 = 0
ACQT2 = 0
ADFM = 1                        ' desno podreduvanje na rezultatot od A/D konverzijata

ADON = 1                        ' modulot za A/D konverzija e ovozmozen (1 - A/D konvertorot raboti ; 0 - A/D konvertorot ne raboti)

Symbol RD = EECON1.0            ' kontrolen bit za citanje od EEPROM
Symbol WR = EECON1.1            ' kontrolen bit za zapisuvanje vo EEPROM
Symbol WREN = EECON1.2          ' Data EEPROM Write Enable bit
Symbol CFGS = EECON1.6          ' CFGS = 1 (Access Configuration registers), CFGS = 0 (Access Flash program or data EEPROM memory)
Symbol EEPGD = EECON1.7         ' EEPGD = 1 (Access Flash program memory), EEPGD = 0 (Access data EEPROM memory)
Symbol GIE = INTCON.7             ' Globalen interrupt
Symbol EEIF = PIR2.4            ' EEPROM Interrupt Flag bit (EEIF = 1 koga e zavrseno zapisuvanjeto vo EEPROM)				

TRISC.3 = 0                     ' izlezen pin za Zelenata dioda
TRISH.0 = 0                     ' izlezen pin za Zholtata dioda 
TRISH.1 = 0                     ' izlezen pin za Sinata dioda
TRISH.2 = 0                     ' izlezen pin za Crvenata dioda
TRISG.4 = 1                     ' vlezen pin za tasterot (Senzor za Dvizenje)  
Symbol LED_Z = PORTC.3          ' Zelena dioda      (oznacuva deka PIC-ot raboti) 
Symbol LED_Zh = PORTH.0         ' Zholta dioda      (oznacuva sostojba na Grealka)
Symbol LED_S = PORTH.1          ' Sina dioda        (oznacuva sostojba na Bojler)
Symbol LED_C = PORTH.2          ' Crvena dioda      (oznacuva sostojba na Sistem)
Symbol sen_Dv = PORTG.4         ' taster    (oznacuva prisustvo registrirano od Senzorot za Dvizenje)                                                              
LED_Z = 1                       ' vklucena Zelena dioda                    
LED_Zh = 0                      ' isklucena Zholta dioda
LED_S = 0                       ' isklucena Sina dioda
LED_C = 0                       ' isklucena Crvena dioda 

Dim jMax As Byte                ' max adresi vo EEPROM
Dim primenBroj As String * 15   ' treba da se proveri tocno kolku cifri sodrzi tel.br. i da se izdvojat samo tie, poradi razlicen prefiks od razlicna drzava (vk.max=15, a za RM e 11)
Dim telBr As String * 15        ' tel.br. na toj sto pratil SMS     (string promenliva moze da se koristi samo kaj 16-bit PIC)
Dim tbAdmin As String * 15      ' tel.br. na Administratorot koj ke gi prima site SMS sto ke gi vrakja PIC-ot (eden Admin vazi se dodeka ne bide smenet so "AD01" vo SMS)
Dim tBroj As String * 15        ' tel.br. na Admin ili tel.br. na Korisnik
Dim i As Byte                   ' pomosna za menuvanje tel.br.
Dim tipAdresa As Byte           ' tip na adresa (tel.br.), 145 - internacionalen broj (so +389...), 129 - nacionalen broj (bez +389...)       
Dim primenaSMS As String * 12   ' sodrzina na textot od primenata SMS
Dim proveriSMS As String * 12   ' pomosna za proverka na sodrzinata na primenata SMS
Dim textSMS As String * 35      ' del od textot vo SMS sto se prakja do korisnikot
Dim Od As String * 4            ' svrznik "od" vo textot vo SMS sto se prakja do Admin
Dim sodrzinaSMS As String * 54  ' cela sodrzina na textot vo SMS sto se prakja do Admin ili Korisnik
Dim Bo As String * 5            ' sostojba na Bojler
Dim Gr As String * 6            ' sostojba na Grealka
Dim Si As String * 5            ' sostojba na Sistem
Dim Te As String * 7            ' sostojba na senzorot za Temperatura
Dim Po As String * 6            ' sostojba na alarm za Pozar (dali bila resetirana sostojbata so odgovor ALARM OK)
Dim Dv As String * 6            ' sostojba na alarm za Dvizenje (dali bila resetirana sostojbata so odgovor ALARM OK)
Dim start As Byte               ' prvo izvrsuvanje na programata pri startuvanje na PIC-ot (1 = da, 0 = ne)
Dim index As Byte               ' index na SMS sto se sodrzi vo memorija na mob.tel. (za citanje i brisenje na konkretna SMS)
Dim Inbox As Byte               ' dali e prazen Inbox-ot (1 = poln, 0 = prazen)
Dim naredba As Byte             ' dali e zadadena naredba spored usvoeniot format (1 - da, 0 - ne)
Dim dvizenje As Byte            ' dali Senzorot za Dvizenje registriral dvizenje (1 - da, 0 - ne)
Dim pozar As Byte               ' dali Senzorot za Temperatura registriral pozar, Tmom > Tmax (1 - da, 0 - ne)
Dim odrzuvaT As Byte            ' dali Grealkata ja odrzuva Tref vo prostorijata (1 - da, 0 - ne) 
Dim vratiSMS As Byte            ' dali PIC-ot da prati povratna SMS (1 = da, 0 = ne)
Dim j As Byte                   ' pomosna za menuvanje na adresa vo EEADR registarot
Dim Tmom As Float               ' momentalna temperatura registrirana od senzorot
Dim Tzad As Byte                ' zadadena temperatura od primenata SMS
Dim Tref As Byte                ' referentna temperatura do koja e potrebno da se zagree prostorijata
Dim Tmax As Byte                ' max dozvolena temperatura pred da nastane pozar vo prostorijata
Dim rezBIT As Word              ' 16-bit rezultat [A/D konverzija]
Dim k As Byte                   ' koeficient za prodolzuvanje na Delay

Symbol nav = 34                 ' ASCII broj za navodnici (")
Symbol zap = 44                 ' ASCII broj za zapirka (,)

primenBroj = ""
Od = " od "                     ' svrznik vo sodrzinaSMS
tipAdresa = 145                 ' za prakjanje na internacionalen tel.br. (so +389...)
start = 1                       ' na pocetok e prvo izvrsuvanje na programata
Inbox = 1                       ' za prviot pat da proveri zaostanati SMS vo Inbox
Tmom = 0
Tzad = 0
Tref = 0
Tmax = 50                       ' 50 C, za opasnost od pozar
index = 0                       ' da ne dobiva default vr od pocetok pri izvrsuvanje na programata sto bi predizvikalo obid za citanje na nepostoecka SMS                           
dvizenje = 0
pozar = 0
odrzuvaT = 0

PORTB.1 = 0
PORTB.3 = 1

k = 1                   

DelayMS	150*k		 		        ' vreme na prilagoduvanje, za da se vkluci LCD i se ostanato


Main:
        
    STKPTR = 00000                              ' resetiranje Stack (Stack-ot se prepolnuva koga nekoja Podprograma ne zavrsuva so Return tuku so GoTo Main) STKPTR = 5-bit Stack Pointer
     
    If start = 1 Then
        Cls                                     ' Clear Screen [LCD]
        DelayMS 10
        Print At 1, 1, "Podesuvanje..."
        GoSub ProcitajOd_EEPROM                                         
        GoSub Proveri_EEPROM
        GoSub Proveri_Komunikacija
        DelayMS 20*k
        GoSub Eliminiraj_Eho
        DelayMS 20*k
        GoSub TextMode_SMS
        DelayMS 20*k
        GoSub Izberi_Memorija
        DelayMS 20*k
        start = 0        
    EndIf
    
    If Inbox = 1 Then
        GoSub Index_staraSMS                    ' proveruva da ne zaostanala nekoja procitana SMS sto ne e izbrisana ili ne e izvrsena nejzinata naredba
        DelayMS 200*k                           ' moze da se sluci da imalo problem vo GSM mrezata i po nekoe vreme da pristignat povekje SMS, koi so edno REC UNREAD ke se smetaat za REC READ
    ElseIf Inbox = 0 Then
        GoSub Index_novaSMS                     ' ja proveruva sekoja pristignata nova SMS
        DelayMS 200*k
        Inbox = 1
    EndIf
    
    If index > 0 Then  
        GoSub Procitaj_SMS                      ' cita SMS so index od pristignata staraSMS ili novaSMS
        DelayMS 500*k
        GoSub Proveri_TelBroj
        GoSub Izbrisi_SMS
        DelayMS 200*k
        GoSub Izvrsi_Naredba
    EndIf
    
    GoSub AD_Konverzija    
    GoSub Proveri_Sostojbi   
    DelayMS 500*k

GoTo Main


Greska:
    start = 1                                   ' da se obide povotorno so Podesuvanje od pocetok vo Main
    LED_Z = 0
    Cls
    DelayMS 10
    Print At 2, 1, "refresh"
    DelayMS 250*k
    LED_Z = 1
GoTo Main

Prazen_Inbox:
    Inbox = 0
    Cls
    DelayMS 10
    Print At 2, 1, "Prazen Inbox"
GoTo Main                                       ' se vrakja vo Main da proveri Index_novaSMS

Nema_SMS:
    Cls
    DelayMS 10
    Print At 2, 1, "Nema SMS"                   
Return

Nepoznat_TelBr:
    Cls
    DelayMS 10
    Print At 2, 1, "Nepoznat tel.br."                   
Return

Pogresna_Shifra:
    Cls
    DelayMS 10
    Print At 2, 1, "Gresna shifra"
Return

Proveri_Komunikacija:      
    HRSOut "ATQ0", 13                           ' mob. zadolzitelno da vrakja odgovor na zadadenite AT komandi !!!
    HRSin {1000, Greska}, Wait("OK")                             
Return

Eliminiraj_Eho:      
    HRSOut "ATE0", 13                           ' mob. da ne gi vrakja istite komandni linii sto gi prima so AT komandite !!!
    HRSin {1000, Greska}, Wait("OK")                             
Return

TextMode_SMS:                                   ' da raboti so SMS vo text format, a ne vo PDU !!!
    HRSOut "AT+CMGF=1", 13                      ' 13 - ASCII broj za Carriage Return (poc. na nov red) =  kako pritisnat Enter na tastatura                      
    HRSin {1000, Greska}, Wait("OK")            ' ako vo rok od 1000ms ne primi "OK" vleguva vo f-jata Greska (ke javi Error ako ne e staven SIM vo mob)                     
Return

Izberi_Memorija:
    HRSOut "AT+CPMS=", nav, "ME", nav, 13                   ' da raboti so SMS od vnatresna memorija (ne od SIM) !!!
    HRSin {1000, Greska}, Wait("OK")
Return

Index_staraSMS:
    HRSOut "AT+CMGL=", nav, "REC READ", nav, 13             ' Lista procitani SMS !!!   
    HRSin {1000, Prazen_Inbox}, Wait("CMGL: "), Dec index       ' go prima indexot na starata SMS, vo slucaj da ne bila izbrisana ili bila zaostanata od prethodno
    HRSin {1000, Greska}, Wait("OK")                        ' ceka OK pa zapira seriskata komunikacija (za prethodno da se dozvoli da pomine celosnata niza na znaci od SMS sodrzinata ili ako nema nova SMS samo ke prekine)
Return

Index_novaSMS:
    HRSOut "AT+CMGL=", nav, "REC UNREAD", nav, 13           ' Lista neprocitani SMS !!!   
    HRSin {1000, Nema_SMS}, Wait("CMGL: "), Dec index       ' go prima indexot na novata SMS
    HRSin {1000, Greska}, Wait("OK")                        ' ceka OK pa zapira seriskata komunikacija (za prethodno da se dozvoli da pomine celosnata niza na znaci od SMS sodrzinata ili ako nema nova SMS samo ke prekine)
Return

Procitaj_SMS:                                               
    HRSOut "AT+CMGR=", Dec index, 13                     ' Cita SMS !!!         
    HRSin {1000, Nepoznat_TelBr}, Wait(nav, "+"), Str primenBroj\15      ' prima telefonski broj (ako vo rok od 1000ms ne doceka "+ ke vleze vo Nepoznat_TelBr a od tuka ke se vrati vo Main na narednata linija pod GoSub Procitaj_SMS)  
    HRSin {1000, Pogresna_Shifra}, Wait("14MK "), Str primenaSMS\12      ' mora da se definira konecen broj na primeni znaci (vo slucajov 12) za posle niv da moze da prekine seriskata komunikacija
Return

Izbrisi_SMS:
    HRSOut "AT+CMGD=", Dec index, 13                         ' Brise SMS !!!
    HRSin {1000, Greska}, Wait("OK")
    DelayMS 20*k
    index = 0
Return

Prati_SMS:                                                   ' Prakja SMS !!!
    HRSOut "AT+CMGS=", nav, tBroj, nav, zap, Dec tipAdresa, 13             ' go vnesuva tel.br. i preogja vo nov red za vnesuvanje sodrzina na SMS
    HRSin {1000, Greska}, Wait("> ")             
    DelayMS 20*k
    HRSOut sodrzinaSMS, 26                              ' 26 - ASCII broj za Ctrl+Z pritisnati na tastatura, komanda za da izvrsi i prati SMS
    HRSin {8000, Greska}, Wait("OK")                    ' ceka 8000ms bidejki treba da prati SMS i potoa da primi odgovor +CMGS: xx, prazen red i na kraj OK
Return          

Izvrsi_Naredba:                                             ' Proveruva (Izvrsuva) naredba i Vrakja SMS !!!
    vratiSMS = 1
    If primenaSMS <> "" Then                        ' Proverka za kakva naredba e zadadena i uslovno izvrsuvanje na istata:
        proveriSMS = Left$(primenaSMS, 4)
            If proveriSMS = "AD01" Then                     ' Promena (Proverka) na administratorskiot tel.br.
                GoSub ZapisiVo_EEPROM
'                tbAdmin = telBr                   
                GoSub ProcitajOd_EEPROM         ' namesto  tbAdmin = telBr
                Cls                                     
                DelayMS 10                              
                Print At 1, 1, "Pisuva vo EEPROM"       
                Print At 2, 1, Dec jMax-1, " ", tbAdmin                  
                DelayMS 1000*k                            ' ako se trgne Print na display, nema potreba od Delay 
                textSMS = "Admin OK"
                naredba = 1       
            EndIf                 
        proveriSMS = Left$(primenaSMS, 8)
            If proveriSMS = "ALARM OK" Then
                If dvizenje = 1 Then
                    dvizenje = 0
                    vratiSMS = 0                            ' PIC-ot da ne prakja povratna SMS
                    naredba = 1
                    Cls
                    DelayMS 10
                    Print At 1, 1, "Dvizenje primenaSMS:"
                    Print At 2, 1, "ALARM OK"
                    DelayMS 500*k                         ' ako se trgne Print na display, nema potreba od Delay
                EndIf
                If pozar = 1 Then
                    pozar = 0
                    vratiSMS = 0                            ' PIC-ot da ne prakja povratna SMS
                    naredba = 1
                    Cls
                    DelayMS 10
                    Print At 1, 1, "Pozar primenaSMS:"
                    Print At 2, 1, "ALARM OK"
                    DelayMS 500*k                         ' ako se trgne Print na display, nema potreba od Delay                        
                EndIf
            ElseIf proveriSMS = "SOSTOJBI" Then    
                If LED_S = 1 Then
                    Bo = " Bo-V"                 
                Else
                    Bo = " Bo-I"
                EndIf
                If LED_Zh = 1 Then
                    Gr = " Gr-V"                 
                ElseIf LED_Zh = 0 Then
                    If odrzuvaT = 1 Then
                        Gr = " Gr-iO"                       ' Grealkata e isklucena vo momentot, no ja odrzuva Tref
                    ElseIf odrzuvaT = 0 Then
                        Gr = " Gr-I"
                    EndIf
                EndIf
                If LED_C = 1 Then
                    Si = " Si-V"                 
                Else
                    Si = " Si-I"
                EndIf
                If pozar = 1 Then
                    Po = " Po-al"                   ' oznacuva deka alarmot e seuste aktiven dodeka ne se resetira so ALARM OK
                Else
                    Po = " Po-ne"
                EndIf
                If dvizenje = 1 Then
                    Dv = " Dv-al"                   ' oznacuva deka alarmot e seuste aktiven dodeka ne se resetira so ALARM OK
                Else
                    Dv = " Dv-ne"
                EndIf
                textSMS = Te + Bo + Gr + Si + Po + Dv
                naredba = 1
            ElseIf proveriSMS = "BOJLER V" Then
                LED_S = 1 
                textSMS = "Bo-V"                            ' "Bojlerot e vklucen"
                naredba = 1            
            ElseIf proveriSMS = "BOJLER I" Then
                LED_S = 0
                textSMS = "Bo-I"                            ' "Bojlerot e isklucen"
                naredba = 1
            ElseIf proveriSMS = "SISTEM V" Then
                LED_C = 1
                textSMS = "Si-V"                            ' "Sistemot e vklucen"
                naredba = 1
            ElseIf proveriSMS = "SISTEM I" Then
                LED_C = 0
                textSMS = "Si-I"                            ' "Sistemot e isklucen"
                naredba = 1
            EndIf
        proveriSMS = Left$(primenaSMS, 9)
            If proveriSMS = "GREALKA V" Then                ' treba da sodrzi "GREALKA V xx", kade sto xx e zadadenata temperatura
                If primenaSMS[10] <> "" And primenaSMS[11] <> "" Then
                    proveriSMS = Right$(primenaSMS,2)
                    Tzad = Val(proveriSMS,Dec)
                    If Tzad > Tmom And Tzad < Tmax Then
                        Tref = Tzad                        
                        LED_Zh = 1
                        odrzuvaT = 1
                        textSMS = "Gr-V"                    ' "Grealkata e vklucena"
                        naredba = 1
                        Cls
                        DelayMS 10
                        Print At 2, 1, "Tref = ", Dec Tref, " C"
                        DelayMS 1000*k
                    EndIf
                EndIf
            ElseIf proveriSMS = "GREALKA I" Then
                LED_Zh = 0
                odrzuvaT = 0
                textSMS = "Gr-I"                            ' "Grealkata e isklucena"
                Tref = 0
                naredba = 1
            EndIf        
        If naredba = 0 Then
            textSMS = "Pogresna naredba"
        EndIf
        If vratiSMS = 1 Then
            For i = 0 To 1                          ' Prakjanje na povratna SMS do Admin (i do korisnik ako toj zadal naredba):
                If i = 0 Then
                    tBroj = tbAdmin                  
                    If telBr = tbAdmin Then
                        sodrzinaSMS = textSMS
                    ElseIf telBr <> tbAdmin Then
                        sodrzinaSMS = textSMS + Od + telBr         ' vo SMS do Admin da sodrzi od koj tel.br. e zadadena naredbata
                    EndIf
                ElseIf i = 1 Then
                    tBroj = telBr
                    sodrzinaSMS = textSMS
                EndIf
                Cls
                DelayMS 10
                Print At 1, 1, nav, tBroj, nav
                Print At 2, 1, sodrzinaSMS
                GoSub Prati_SMS
                DelayMS 1000*k                                ' ako se trgne Print na display, dovolno e samo DelayMS 200
                If telBr = tbAdmin Then Break
            Next
            Clear textSMS
            Clear sodrzinaSMS
        EndIf
        Clear primenaSMS
        Clear proveriSMS
        naredba = 0
    EndIf
Return

ZapisiVo_EEPROM:
    jMax = Len(telBr)               
    jMax = jMax + 1                 ' ostava mesto za +1 adresa za zapis za kolkava e vk dolzina na cifri vo tbAdmin
    For j = 1 To jMax               ' go zapisuva cifra po cifra telBr vo EEPROM
        EEADR = j                   ' definira adresa vo koja ke se zapisuva vo EEPROM cifrata od telBr
        If j = 1 Then
            EEDATA = Len(telBr)         ' prima podatok za kolkava ke bide vk dolzina na cifri vo tbAdmin
        Else                    
            EEDATA = telBr[j-1]         ' go prima podatokot (cifrata) koja ke se zapisuva vo EEPROM na pogore definiranata adresa
        EndIf
        EEPGD = 0                   ' ovozmozuva pristap do EEPROM memorija
        CFGS = 0                    ' ovozmozuva so EEPGD da se odredi pristap do EEPROM memorijata
        WREN = 1                    ' ovozmozuva zapisuvanje vo EEPROM
        GIE = 0                     ' gi onevozmozuva site interapti
        EECON2=$55                  ' Write 55h
        EECON2=$0AA                 ' Write 0AAh
        WR = 1                      ' pottiknuva (zapocnuva) zapisuvanje vo EEPROM    
        DelayMS 100*k
        GIE = 1                     ' gi ovozmozuva site interapti, za da moze so EEIF da oznaci koga zavrsilo zapisuvanjeto vo EEPROM
        WREN = 0
        EEIF = 0                    ' mora interaptot da se spusti softverski bidejki sam se kreva koga ke zavrsi zapisuvanjeto vo EEPROM  
    Next              
Return

ProcitajOd_EEPROM:
    If jMax = 0 Then
        jMax = 2                    ' kolku da vleze vo For ciklusot, a potoa od prvata adresa ke si ja primi realnata vrednost
    EndIf        
    For j = 1 To jMax                 ' go cita cifra po cifra telBr od EEPROM
        EEADR = j                   ' definira adresa od koja ke se cita od EEPROM cifrata od telBr                    
        EEPGD = 0                   ' ovozmozuva pristap do EEPROM memorija
        CFGS = 0                    ' ovozmozuva so EEPGD da se odredi pristap do EEPROM memorijata
        RD = 1                      ' pottiknuva (zapocnuva) citanje od EEPROM
        If j = 1 Then
            jMax = EEDATA               ' prima podatok za kolkava e vk dolzina na cifri vo tbAdmin
            jMax = jMax + 1             ' go zgolemuva za +1 za For da moze da gi svrti site adresi so cifri
        Else 
            tbAdmin[j-1] = EEDATA       ' go prima podatokot (cifrata) koja se naogja na pogore definiranata adresa vo EEPROM
        EndIf
        DelayMS 20*k
    Next    
Return

Proveri_EEPROM:                                 ' Proveruva dali vo EEPROM navistina imalo zapisan tbAdmin !!!
    If tbAdmin[0] <> "0" And tbAdmin[0] <> "1" And tbAdmin[0] <> "2" And tbAdmin[0] <> "3" And tbAdmin[0] <> "4" Then         ' dovolna e proverka samo spored prvata cifra
        If tbAdmin[0] <> "5" And tbAdmin[0] <> "6" And tbAdmin[0] <> "7" And tbAdmin[0] <> "8" And tbAdmin[0] <> "9" Then     ' bidejki ne sobira vo eden red, uste eden If ...     
            tbAdmin = "38970123456"     ' go prima ovoj broj ako nemalo zapis vo EEPROM
        EndIf
    EndIf
Return

Proveri_TelBroj:                                ' Proveruva dolzina na cifri i gi izdvojuva samo niv kako telBr !!!
    If primenBroj <> "" Then
        telBr = primenBroj                                  ' vo slucaj site 15 karakteri od stringot da bile cifri od tel.br.
        For j = 15 To 1 Step -1                             ' ako nekoi od karakterite ne bile cifri ke gi otstrani ovde                         
            If primenBroj[j-1] <> "0" And primenBroj[j-1] <> "1" And primenBroj[j-1] <> "2" And primenBroj[j-1] <> "3" And primenBroj[j-1] <> "4" Then         ' bidejki ne sobira vo eden red, uste eden If ...
                If primenBroj[j-1] <> "5" And primenBroj[j-1] <> "6" And primenBroj[j-1] <> "7" And primenBroj[j-1] <> "8" And primenBroj[j-1] <> "9" Then     
                    telBr = Left$(primenBroj, j-1)             
                EndIf
            EndIf
        Next
        Clear primenBroj
    EndIf
Return

Proveri_Sostojbi:
    If sen_Dv = 1 And dvizenje = 0 Then
        tBroj = tbAdmin
        sodrzinaSMS = "Alarm DVIZENJE"
        Cls
        DelayMS 10
        Print At 1, 1, nav, tBroj, nav
        Print At 2, 1, sodrzinaSMS
        GoSub Prati_SMS
        DelayMS 100*k
        Clear sodrzinaSMS
        dvizenje = 1                    ' za da ne bombardira so prakjanje SMS celo vreme dodeka trae alarmot                                
    EndIf
    If Tmom > Tmax And pozar = 0 Then
        tBroj = tbAdmin
        sodrzinaSMS = "Alarm POZAR"
        Cls
        DelayMS 10
        Print At 1, 1, nav, tBroj, nav
        Print At 2, 1, sodrzinaSMS
        GoSub Prati_SMS
        DelayMS 100*k
        Clear sodrzinaSMS
        pozar = 1                       ' za da ne bombardira so prakjanje SMS celo vreme dodeka trae alarmot
    EndIf
    If Tref <> 0 Then
        If Tmom = Tref Or Tmom > Tref Then          ' ne ja resetira Tref tuku ja odrzava taa temperatura dodeka ne primi SMS za isklucuvanje Grealka
            LED_Zh = 0                              
        ElseIf Tmom < Tref Then
            LED_Zh = 1
        EndIf        
    EndIf            
Return

AD_Konverzija:
    GODONE = 1                              ' start A/D conversion
        While GODONE = 1                    ' ceka da se smeni statusot na GODONE (da zavrsi A/D konverzijata) pa da prodolzi podolu
        Wend
    rezBIT = (ADRESH * 256) + ADRESL        ' ADRESL 8-bit, ADRESH 8-bit ; 2^8 = 256 ; A/D rezultatot e 10-bit ; 2^10 = 1024
    DelayMS 50*k                            ' desno podreduvanje => 8-Bit(ADRESL) + posledni 2-bit(ADRESH) = 10-bit => rezBIT.max = 1024
    Tmom = (rezBIT / 1023) * 100            ' Tmom = (rezBit / 1023) * (Vref / r)     ,   Vref=1000mV   ,   r=10mV/C (rezolucija na temp.senzor),  =>  Tmom[C]
    Te = "T=" + Str$(DEC1 Tmom) + "C"       ' za potrebite na textSMS pri odgovor na SOSTOJBI
    Cls
    DelayMS 10
    Print At 2, 1, "Tmom = ",DEC1 Tmom, " C"    ' DEC1 za da prikazuva samo edna decimala posle zapirkata
    DelayMS 250*k   
Return
