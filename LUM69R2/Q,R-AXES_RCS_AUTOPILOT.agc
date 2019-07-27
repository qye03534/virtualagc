### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    Q,R-AXES_RCS_AUTOPILOT.agc
## Purpose:     A section of LUM69 revision 2.
##              It is part of the reconstructed source code for the flown
##              version of the flight software for the Lunar Module's (LM)
##              Apollo Guidance Computer (AGC) for Apollo 10. The code has
##              been recreated from a copy of Luminary revsion 069, using
##              changes present in Luminary 099 which were described in
##              Luminary memos 75 and 78. The code has been adapted such
##              that the resulting bugger words exactly match those specified
##              for LUM69 revision 2 in NASA drawing 2021152B, which gives
##              relatively high confidence that the reconstruction is correct.
## Reference:   pp. 1436-1453
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-07-27 MAS  Created from Luminary 69.

## Page 1436
                BANK    17
                SETLOC  DAPS2
                BANK

                EBANK=  CDUXD

                COUNT*  $$/DAPQR

CALLQERR        CA      BIT13           # CALCULATE Q,R ERRORS UNLESS THESE AXES
                EXTEND                  # ARE IN MANUAL RATE COMMAND.
                RAND    CHAN31
                CCS     A
                TCF     +5              # IN AUTO COMPUTE Q,R ERRORS
                CS      DAPBOOLS        # IN MANUAL RATE COMMAND?
                MASK    OURRCBIT
                EXTEND
                BZF     Q,RORGTS        # IF SO BYPASS CALCULATION OF ERRORS.
                TC      QERRCALC

Q,RORGTS        CCS     COTROLER        # CHOOSE CONTROL SYSTEM FOR THIS DAP PASS:
                TCF     GOTOGTS         #   GTS (ALTERNATES WITH RCS WHEN DOCKED)
                TCF     TRYGTS          #   GTS IF ALLOWED, OTHERWISE RCS
RCS             CAF     ZERO            #   RCS (TRYGTS MAY BRANCH TO HERE)
                TS      COTROLER

                DXCH    EDOTQ
                TC      ROT45DEG
                DXCH    OMEGAU

# X - TRANSLATION:
#
# INPUT:        BITS 7,8 OF CH31 (TRANSLATION CONTROLLER)
#               ULLAGER
#               APSFLAG, DRIFTBIT
#               ACC40R2X, ACRBTRAN
#
# OUTPUT:       NEXTU, NEXTV    CODES OF TRANSLATION FOR AFTER ROTATION
#               SENSETYP        TELL ROTATION DIRECTION AND DESIRE
#
# X-TRANS POLICIES ARE EITHER 4 JETS OR A DIAGONAL PAIR.  IN 2-JET TRANSLATION THE SYSTEM IS SPECIFIED.  A FAILURE
# WILL OVERRIDE THIS SPECIFICATION.  AN ALARM RESULTS WHEN NO POLICY IS AVAILABLE BECAUSE OF FAILURES.

SENSEGET        CA      BIT7            # INPUT BITS OVERRIDE THE INTERNAL BITS
                EXTEND                  # SENSETYP WILL NOT OPPOSE ANYTRANS
                RAND    CHAN31
                EXTEND
                BZF     +XORULGE
## Page 1437
                CA      BIT8
                EXTEND
                RAND    CHAN31
                EXTEND
                BZF     -XTRANS

                CA      ULLAGER
                MASK    DAPBOOLS
                CCS     A
                TCF     +XORULGE

                TS      NEXTU           # STORE NULL TRANSLATION POLICIES
                TS      NEXTV
                CS      DAPBOOLS        # BURNING OR DRIFTING?
                MASK    DRIFTBIT
                EXTEND
                BZF     TSENSE
                CA      FLGWRD10        # DPS (INCLUDING DOCKED) OR APS?
                MASK    APSFLBIT
                CCS     A
                CAF     TWO             # FAVOR +X JETS DURING AN APS BURN.
TSENSE          TS      SENSETYP
                TCF     QRCONTRL

+XORULGE        CAF     ONE
-XTRANS         AD      FOUR
                TS      ROTINDEX
                AD      NEG3
                TS      SENSETYP        # FAVOR APPROPRIATE JETS DURING TRANS.
                CA      DAPBOOLS
                MASK    ACC4OR2X
                CCS     A
                TCF     TRANS4

                CA      DAPBOOLS
                MASK    AORBTRAN
                CCS     A
                CA      ONE             # THREE FOR B
                AD      TWO             # TWO FOR A SYSTEM 2 JET X TRANS
TSNUMBRT        TS      NUMBERT

                TC      SELCTSUB

                CCS     POLYTEMP
                TCF     +3
                TC      ALARM
                OCT     02002
                CA      00314OCT
                MASK    POLYTEMP
TSNEXTS         TS      NEXTU
## Page 1438
                CS      00314OCT
                MASK    POLYTEMP
                TS      NEXTV

# Q,R-AXES RCS CONTROL MODE SELECTION
#       SWITCHES        INDICATION WHEN SET
#       BIT13/CHAN31    AUTO, GO TO ATTSTEER
#       PULSES          MINIMUM IMPULSE MODE
#       (OTHERWISE)     RATE COMMAND/ATTITUDE HOLD MODE

QRCONTRL        CA      BIT13           # CHECK MODE SELECT SWITCH.
                EXTEND
                RAND    CHAN31          # BITS INVERTED
                CCS     A
                TCF     ATTSTEER
CHKBIT10        CAF     PULSES          # PULSES = 1 FOR MIN IMP USE OF RHC
                MASK    DAPBOOLS
                EXTEND
                BZF     CHEKSTIK        # IN ATT-HOLD/RATE-COMMAND IF BIT10=0

# MINIMUM IMPULSE MODE

                INHINT
                TC      IBNKCALL
                CADR    ZATTEROR
                CA      ZERO
                TS      QERROR
                TS      RERROR          # FOR DISPLAYS
                RELINT

                EXTEND
                READ    CHAN31
                TS      TEMP31          # IS EQUAL TO DAPTEMP1
                CCS     OLDQRMIN
                TCF     CHECKIN

FIREQR          CA      TEMP31
                MASK    BIT1
                EXTEND
                BZF     +QMIN

                CA      TEMP31
                MASK    BIT2
                EXTEND
                BZF     -QMIN

                CA      TEMP31
                MASK    BIT5
## Page 1439
                EXTEND
                BZF     +RMIN

                CA      TEMP31
                MASK    BIT6
                EXTEND
                BZF     -RMIN

                TCF     XTRANS

CHECKIN         CS      TEMP31
                MASK    OCT63
                TS      OLDQRMIN
                TCF     XTRANS

+QMIN           CA      14MS
                TS      TJU
                CS      14MS
                TCF     MINQR
-QMIN           CS      14MS
                TS      TJU
                CA      14MS
                TCF     MINQR
+RMIN           CA      14MS
                TCF     +2
-RMIN           CS      14MS
                TS      TJU
MINQR           TS      TJV
                CA      MINADR
                TS      RETJADR
                CA      ONE
                TS      OLDQRMIN
MINRTN          TS      AXISCTR
                CA      DAPBOOLS
                MASK    AORBTRAN
                CCS     A
                CA      ONE
                AD      TWO
                TS      NUMBERT
                TCF     AFTERTJ

MINADR          GENADR  MINRTN
OCT63           OCT     63
14MS            =       +TJMINT6

TRANS4          CA      FOUR
                TCF     TSNUMBRT

# RATE COMMAND MODE:
## Page 1440
# DESCRIPTION (SAME AS P-AXIS)

CHEKSTIK        TS      INGTS           # NOT IN GTS WHEN IN ATT HOLD
                CS      ONE             # 1/ACCS WILL DO THE NULLING DRIVES
                TS      COTROLER        # COME BACK TO RCS NEXT TIME
                CA      BIT15
                MASK    CH31TEMP
                EXTEND
                BZF     RHCACTIV        # BRANCH IF OUT OF DETENT.
                CA      OURRCBIT        # ***********
                MASK    DAPBOOLS        # *IN DETENT*   CHECK FOR MANUAL CONTROL
                EXTEND                  # ***********   LAST TIME.
                BZF     STILLRCS
                CS      BIT9
                MASK    RCSFLAGS
                TS      RCSFLAGS        # BIT 9 IS 0.
                TCF     DAMPING
40CYCL          OCT     50
1/10S           OCT     1
LINRAT          DEC     46

# ================================

DAMPING         CA      ZERO
                TS      SAVEHAND
                TS      SAVEHAND +1
RHCACTIV        CCS     SAVEHAND        # *******************
                TCF     +3              # Q,R MANUAL CONTROL    WC = A*(B+|D|)*D
                TCF     +2              # *******************
                TCF     +1
                DOUBLE                  # WHERE
                DOUBLE                  #
                AD      LINRAT          #       WC  = COMMANDED ROTATIONAL RATE
                EXTEND                  #       A   = QUADRATIC SENSITIVITY FACTOR
                MP      SAVEHAND        #       B   = LINEAR/QUADRATIC SENSITIVITY
                CA      L               #       |D| = ABS. VALUE OF DEFLECTION
                EXTEND                  #       D   = HAND CONTROLLER DEFLECTION
                MP      STIKSENS
                XCH     QLAST           # COMMAND Q RATE     SCALED 45 DEG/SEC
                COM
                AD      QLAST
                TS      DAPTEMP3
                CCS     SAVEHAND +1
                TCF     +3
                TCF     +2
                TCF     +1
                DOUBLE
                DOUBLE
                AD      LINRAT
                EXTEND
                MP      SAVEHAND +1
                CA      L
## Page 1441
                EXTEND
                MP      STIKSENS
                XCH     RLAST
                COM
                AD      RLAST
                TS      DAPTEMP4
                CS      QLAST           # INTERVAL.
                AD      OMEGAQ
                TS      QRATEDIF
                CS      RLAST
                AD      OMEGAR
                TS      RRATEDIF
ENTERQR         DXCH    QRATEDIF        # TRANSFORM RATES FROM Q,R TO U,V AXES
                TC      ROT45DEG
                DXCH    URATEDIF
                CCS     DAPTEMP3        # CHECK IF Q COMMAND CHANGE EXCEEDS
                TC      +3              # BREAKOUT LEVEL.  IF NOT, CHECK R.
                TC      +2
                TC      +1
                AD      -RATEDB
                EXTEND
                BZMF    +2
                TCF     ENTERUV -2      # BREAKOUT LEVEL EXCEEDED.  DIRECT RATE.
                CCS     DAPTEMP4        # R COMMAND BREAKOUT CHECK.
                TC      +3
                TC      +2
                TC      +1
                AD      -RATEDB
                EXTEND
                BZMF    +2
                TCF     ENTERUV -2      # BREAKOUT LEVEL EXCEEDED.  DIRECT RATE.
                CA      RCSFLAGS        # BREAKOUT LEVEL NOT EXCEEDED.  CHECK FOR
                MASK    QRBIT           # DIRECT RATE CONTROL LAST TIME.
                EXTEND
                BZF     +2
                TCF     ENTERUV         # CONTINUE DIRECT RATE CONTROL.
                TCF     STILLRCS        # PSEUDO-AUTO CONTROL.
                CA      40CYCL
                TS      TCQR
ENTERUV         INHINT                  # DIRECT RATE CONTROL.
                TC      IBNKCALL
                FCADR   ZATTEROR
                RELINT
                CA      ZERO
                TS      DYERROR
                TS      DYERROR +1
                TS      DZERROR
                TS      DZERROR +1
                CCS     URATEDIF
                TCF     +3
## Page 1442
                TCF     +2
                TCF     +1
                AD      TARGETDB        # IF TARGET DB IS EXCEEDED, CONTINUE
                EXTEND                  # DIRECT RATE CONTROL.
                BZMF    VDB
                CCS     VRATEDIF
                TCF     +3
                TCF     +2
                TCF     +1
                AD      TARGETDB
                EXTEND
                BZMF    +2
                TCF     QRTIME
                CA      ZERO
                TS      VRATEDIF
                TCF     QRTIME
VDB             CCS     VRATEDIF
                TC      +3
                TC      +2
                TC      +1
                AD      TARGETDB        # IF TARGET DB IS EXCEEDED, CONTINUE
                EXTEND                  # DIRECT RATE CONTROL.  IF NOT, FIRE AND
                BZMF    TOPSEUDO        # SWITCH TO PSEUDO-AUTO CONTROL ON NEXT
                CA      ZERO            # PASS.
                TS      URATEDIF
QRTIME          CA      TCQR            # DIRECT RATE TIME CHECK.
                EXTEND
                BZMF    +5              # BRANCH IF TIME EXCEEDS 4 SEC.
                CS      RCSFLAGS
                MASK    QRBIT
                ADS     RCSFLAGS        # BIT 11 IS 1.
                TC      +4
TOPSEUDO        CS      QRBIT
                MASK    RCSFLAGS
                TS      RCSFLAGS        # BIT 11 IS 0.
                CA      HANDADR
                TS      RETJADR
                CA      ONE
BACKHAND        TS      AXISCTR

                CA      FOUR
                TS      NUMBERT

                INDEX   AXISCTR
                INDEX   SKIPU
                TCF     +1
                CA      FOUR
                INDEX   AXISCTR
                TS      SKIPU
                TCF     LOOPER
## Page 1443
                INDEX   AXISCTR
                CCS     URATEDIF        #       INDEX   AXIS    QUANITY
                CA      ZERO            #       0       -U      1/JETACC-AOSU
                TCF     +2              #       1       +U      1/JETACC+AOSU
                CA      ONE             #       16      -V      1/JETACC-AOSV
                INDEX   AXISCTR         #       17      +V      1/JETACC+AOSV
                AD      AXISDIFF        # JETACC = 2 JET ACCELERATION (1 FOR FAIL)

                INDEX   A
                CS      1/ANET2 +1
                EXTEND
                INDEX   AXISCTR         # URATEDIF IS SCALED AT PI/4 RAD/SEC
                MP      URATEDIF        #  JET TIME IN A      SCALED 32 SEC
                TS      Q
                DAS     A
                AD      Q
                TS      A               #  OVERFLOW SKIP
                TCF     +2
                CA      Q               # RIGHT SIGN AND BIGGER THAN 150MS
SETTIME         INDEX   AXISCTR
                TS      TJU             # SCALED AT 10.67 WHICH IS CLOSE TO 10.24
                TCF     AFTERTJ

ZEROTJ          CA      ZERO
                TCF     SETTIME

HANDADR         GENADR  BACKHAND

# GTS WILL BE TRIED IF
#       1. USEQRJTS= 0,
#       2. ALLOWGTS POS,
#       3. JETS ARE OFF (Q,R-AXES)

TRYGTS          CAF     USEQRJTS        # IS JET USE MANDATORY.         (AS LONG AS
                MASK    DAPBOOLS        # USEQRJTS BIT IS NOT BIT 15, CCS IS SAFE)
                CCS     A
                TCF     RCS
                CCS     ALLOWGTS        # NO.  DOES AOSTASK OK CONTROL FOR GTS?
                TCF     +2
                TCF     RCS
                EXTEND
                READ    CHAN5
                CCS     A
                TCF     CHKINGTS
GOTOGTS         EXTEND
                DCA     GTSCADR
                DTCB

CHKINGTS        CCS     INGTS           # WAS THE TRIM GIMBAL CONTROLLING
                TCF     +2              #       YES.  SET UP A DAMPED NULLING DRIVE.
                TCF     RCS             #       NO.  NULLING WAS SET UP BEFORE.  DO RCS
## Page 1444
                INHINT
                TC      IBNKCALL
                CADR    TIMEGMBL
                RELINT
                CAF     ZERO
                TS      INGTS
                TCF     RCS

                EBANK=  CDUXD
GTSCADR         2CADR   GTS

## Page 1445
# SUBROUTINE TO COMPUTE Q,R-AXES ATTITUDE ERRORS FOR USE IN THE RCS AND GTS CONTROL LAWS AND THE DISPLAYS.

QERRCALC        CAE     CDUY            # Q-ERROR CALCULATION
                EXTEND
                MSU     CDUYD           # CDU ANGLE - ANGLE DESIRED (Y-AXIS)
                TS      DAPTEMP1        # SAVE FOR RERRCALC
                EXTEND
                MP      M21             # (CDUY-CDUYD)*M21 SCALED AT PI RADIANS
                TS      E
                CAE     CDUZ            # SECOND TERM CALCULATION:
                EXTEND
                MSU     CDUZD           # CDU ANGLE -ANGLE DESIRED (Z-AXIS)
                TS      DAPTEMP2        # SAVE FOR RERRCALC
                EXTEND
                MP      M22             # (CDUZ-CDUZD)*M22 SCALED AT PI RADIANS
                AD      DELQEROR        # KALCMANU INERFACE ERROR
                AD      E
                XCH     QERROR          # SAVE Q-ERROR FOR EIGHT-BALL DISPLAY.

RERRCALC        CAE     DAPTEMP1        # R-ERROR CALCULATION:
                EXTEND                  # CDU ANGLE -ANGLE DESIRED (Y-AXIS)
                MP      M31             # (CDUY-CDUYD)*M31 SCALED AT PI RADIANS
                TS      E
                CAE     DAPTEMP2        # SECOND TERM CALCULATION:
                EXTEND                  # CDU ANGLE -ANGLE DESIRED (Z-AXIS)
                MP      M32             # (CDUZ-CDUZD)*M32 SCALED AT PI RADIANS
                AD      DELREROR        # KALCMANU INERFACE ERROR
                AD      E
                XCH     RERROR          # SAVE R-ERROR FOR EIGHT-BALL DISPLAY.
                TC      Q

## Page 1446
# "ATTSTEER" IS THE ENTRY POINT FOR Q,R-AXES (U,V-AXES) ATTITUDE CONTROL USING THE REACTION CONTROL SYSTEM

ATTSTEER        EQUALS  STILLRCS        # "STILLRCS" IS THE RCS EXIT FROM TRYGTS.

STILLRCS        CA      RERROR
                LXCH    A
                CA      QERROR
                TC      ROT45DEG
                DXCH    UERROR

# PREPARES CALL TO TJETLAW (OR SPSRCS(DOCKED))
# PREFORMS SKIP LOGIC ON U OR Y AXIS IF NEEDED.

TJLAW           CA      TJLAWADR
                TS      RETJADR
                CA      ONE
                TS      AXISCTR
                INDEX   AXISCTR
                INDEX   SKIPU
                TCF     +1
                CA      FOUR
                INDEX   AXISCTR
                TS      SKIPU
                TCF     LOOPER
                INDEX   AXISCTR
                CA      UERROR
                TS      E
                INDEX   AXISCTR
                CA      OMEGAU
                TS      EDOT
                CA      DAPBOOLS
                MASK    CSMDOCKD
                CCS     A
                TCF     +3
                TC      TJETLAW
                TCF     AFTERTJ
 +3             CS      DAPBOOLS        # DOCKED.  IF GIMBAL USABLE DO GTS CONTROL
                MASK    USEQRJTS        #  ON THE NEXT PASS.
                CCS     A               # USEQRJTS BIT MUST NOT BE BIT 15.
                TS      COTROLER        # GIMBAL USABLE.  STORE POSITIVE VALUE.
                TC      SPSRCS          # DETERMINE RCS CONTROL.
                CAF     FOUR            # ALWAYS CALL FOR 2-JET CONTROL ABOUT U,V.
                TS      NUMBERT         # FALL THROUGH TO JET SELECTION, ETC.

# Q,R-JET-SELECTION-LOGIC
#
# INPUT:        AXISCTR         0,1 FOR U,V
#               SNUFFBIT        ZERO TJETU,V AND TRANS. ONLY IF SET IN A DPS BURN
#               TJU,TJV         JET TIME SCALED 10.24 SEC.
#               NUMBERT         INDICATES NUMBER OF JETS AND TYPE OF POLICY
#               RETJADR         WHERE TO RETURN TO
## Page 1447
# OUTPUT:       NO.U(V)JETS     RATE DERIVATION FEEDBACK
#               CHANNEL 5
#               SKIPU,SKIRV     FOR LESS THAN 150MS FIRING
#
# NOTES:        IN CASE OF FAILURE IN DESIRED ROTATION POLICY, "ALL" UNFAILED
#               JETS OF THE DESIRED POLICY ARE SELECTED. SINCE THERE ARE ONLY
#               TWO JETS, THIS MEANS THE OTHER ONE OR NONE. THE ALARM IS SENT
#               IF NONE CAN BE FOUND.
#
#               TIMES LESS THAN 14 MSEC ARE TAKEN TO CALL FOR A SINGLE-JET
#               MINIMUM IMPULSE, WITH THE JET CHOSEN SEMI-RANDOMLY.

AFTERTJ         CA      FLAGWRD5        # IF SNUFFBIT SET DURING A DPS BURN GO TO
                MASK    SNUFFBIT        #  XTRANS; THAT IS, INHIBIT CONTROL.
                EXTEND
                BZF     DOROTAT
                CS      FLGWRD10
                MASK    APSFLBIT
                EXTEND
                BZF     DOROTAT
                CA      DAPBOOLS
                MASK    DRIFTBIT
                EXTEND
                BZF     XTRANS

DOROTAT         CAF     TWO
                TS      L
                INDEX   AXISCTR
                CCS     TJU
                TCF     +5
                TCF     NOROTAT
                TCF     +2
                TCF     NOROTAT
                ZL
                AD      ONE
                TS      ABSTJ

                CA      AXISCTR
                AD      L
                TS      ROTINDEX        # 0 1 2 3 = -U -V -+U +V

                CA      ABSTJ
                AD      -150MS
                EXTEND
                BZMF    DOSKIP

                TC      SELCTSUB

                INDEX   AXISCTR
                CA      INDEXES
## Page 1448
                TS      L

                CA      POLYTEMP
                INHINT
                INDEX   L
                TC      WRITEP

                RELINT
                TCF     FEEDBACK

NOROTAT         INDEX   AXISCTR
                CA      INDEXES
                INHINT
                INDEX   A
                TC      WRITEP  -1

                RELINT
LOOPER          CCS     AXISCTR
                TC      RETJADR
                TCF     CLOSEOUT
DOSKIP          CS      ABSTJ
                AD      +TJMINT6        # 14MS
                EXTEND
                BZMF    NOTMIN

                ADS     ABSTJ
                INDEX   AXISCTR
                CCS     TJU
                CA      +TJMINT6
                TCF     +2
                CS      +TJMINT6
                INDEX   AXISCTR
                TS      TJU

                CCS     SENSETYP        # ENSURE MIN-IMPULSE NOT AGAINST TRANS
                TCF     NOTMIN  -1
                EXTEND
                READ    LOSCALAR
                MASK    ONE
                TS      NUMBERT

NOTMIN          TC      SELCTSUB

                INDEX   AXISCTR
                CA      INDEXES
                INHINT
                TS      T6FURTHA +1
                CA      POLYTEMP
                INDEX   T6FURTHA +1
                TC      WRITEP
## Page 1449
                CA      ABSTJ
                TS      T6FURTHA
                TC      JTLST           # IN QR BANK BY NOW

                RELINT

                CA      ZERO
                INDEX   AXISCTR
                TS      SKIPU

FEEDBACK        CS      THREE
                AD      NUMBERT
                EXTEND
                BZMF    +3

                CA      TWO
                TCF     +2
                CA      ONE
                INDEX   AXISCTR
                TS      NO.UJETS
                TCF     LOOPER

XTRANS          CA      ZERO
                TS      TJU
                TS      TJV
                CA      FOUR
                INHINT
                XCH     SKIPU
                EXTEND
                BZF     +2
                TC      WRITEU  -1
                CA      FOUR
                XCH     SKIPV
                RELINT

                EXTEND
                BZF     CLOSEOUT
                INHINT
                TC      WRITEV  -1
                RELINT

                TCF     CLOSEOUT
INDEXES         DEC     4
                DEC     13
+TJMINT6        DEC     22
-150MS          DEC     -240
BIT8,9          OCT     00600
SCLNORM         OCT     266
TJLAWADR        GENADR  TJLAW   +3      # RETURN ADDRESS FOR RCS ATTITUDE CONTROL

## Page 1450
# THE JET LIST:
# THIS IS A WAITLIST FOR T6RUPTS.
#
# CALLED BY:
#               CA      TJ              TIME WHEN NEXT JETS WILL BE WRITTEN
#               TS      T6FURTHA
#               CA      INDEX           AXIS TO BE WIRTTEN AT TJ (FROM NOW)
#               TS      T6FURTHA +1
#               TC      JTLST
#
# EXAMPLE - U-AXIS AUTOPILOT WILL WRITE ITS ROTATION CODE OF
# JETS INTO CHANNEL 5.  IF IT DESIRES TO TURN OFF THIS POLICY WITHIN
# 150MS AND THEN FIRE NEXTU, A CALL TO JTLST IS MADE WITH T6FURTHA
# CONTAINING THE TIME TO TURN OFF THE POLICY, T6FURTHA +1 THE INDEX
# OF THE U-AXIS(4), AND NEXTU WILL CONTAIN THE "U-TRANS" POLICY OR ZERO.
#
# THE LIST IS EXACTLY 3 LONG.  (THIS LEADS TO SKIP LOGIC AND 150MS LIMIT)
# THE INPUT IS THE LAST MEMBER OF THE LIST
#
# RETURNS BY:
#       +       TC      Q
#
# DEFINITIONS:  (OUTPUT)
#       TIME6           TIME OF NEXT RUPT
#       T6NEXT          DELTA TIME TO NEXT RUPT
#       T6FURTHA        DELTA TIME FROM 2ND TO LAST RUPT
#       NXT6ADR         AXIS INDEX       Q - P-AXIS
#       T6NEXT +1       AXIS INDEX       4 - U-AXIS
#       T6FURTHA +1     AXIS INDEX      13 - V-AXIS

JTLST           CS      T6FURTHA
                AD      TIME6
                EXTEND
                BZMF    MIDORLST        # TIME6 - T IS IN A

                LXCH    NXT6ADR
                DXCH    T6NEXT
                DXCH    T6FURTHA
                TS      TIME6
                LXCH    NXT6ADR

TURNON          CA      BIT15
                EXTEND
                WOR     CHAN13
                TC      Q

MIDORLST        AD      T6NEXT
                EXTEND
                BZMF    LASTCHG         # TIME6 + T6NEXT - T IS IN A

                LXCH    T6NEXT  +1
## Page 1451
                DXCH    T6FURTHA
                EXTEND
                SU      TIME6
                DXCH    T6NEXT

                TC      Q

LASTCHG         CS      A
                AD      NEG0
                TS      T6FURTHA

                TC      Q

ROT45DEG        TS      ROTEMP1
                AD      L
                TS      ROTEMP2
                TCF     +6
                CCS     A
                CA      POSMAX
                TCF     +2
                CA      NEGMAX
                TS      ROTEMP2         # Q+R
                CS      ROTEMP1
                AD      L
                TS      ROTEMP1         # R-Q
                TCF     +4
                EXTEND
                MP      POSMAX
                CA      L
                EXTEND
                MP      .707
                XCH     ROTEMP2
                EXTEND
                MP      .707
                LXCH    ROTEMP2
                TC      Q

.707            DEC     .70711

SELCTSUB        INDEX   ROTINDEX
                CA      ALLJETS
                INDEX   NUMBERT
                MASK    TYPEPOLY
                TS      POLYTEMP

                MASK    CH5MASK
                CCS     A
                TCF     +2
## Page 1452
                TC      Q

                CA      THREE
FAILOOP         TS      NUMBERT
                INDEX   ROTINDEX
                CA      ALLJETS
                INDEX   NUMBERT
                MASK    TYPEPOLY
                TS      POLYTEMP
                MASK    CH5MASK
                EXTEND
                BZF     FAILOOP -2
                CCS     NUMBERT
                TCF     FAILOOP
                INDEX   AXISCTR
                TS      TJU
                TC      ALARM
                OCT     02004
                TCF     NOROTAT
ALLJETS         OCT     00110           #       -U      6 13
                OCT     00022           #       -V      2 9
                OCT     00204           #       +U      5 14
                OCT     00041           #       +V      1 10
TYPEPOLY        OCT     00125           #       -X      1 5 9 13
                OCT     00252           #       +X      2 6 10 14
                OCT     00146           #       A       2 5 10 13
                OCT     00231           #       B       1 6 9 14
                OCT     00377           #       ALL     1 2 5 6 9 10 13 14

# THE FOLLOWING SETS THE INTERRUPT FLIP-FLOP AS SOON AS POSSIBLE, WHICH PERMITS A RETURN TO THE INTERRUPTED JOB.

CLOSEOUT        CA      ADRRUPT
                TC      MAKERUPT

ADRRUPT         ADRES   ENDJASK

ENDJASK         DXCH    DAPARUPT
                DXCH    ARUPT
                DXCH    DAPBQRPT
                XCH     BRUPT
                LXCH    Q
                CAF     NEGMAX          # NEGATIVE DAPZRUPT SIGNALS JASK IS OVER.
                DXCH    DAPZRUPT
                DXCH    ZRUPT
                TCF     NOQRSM
                BLOCK   3
                SETLOC  FFTAG6
                BANK
## Page 1453
                COUNT*  $$/DAP

MAKERUPT        EXTEND
                EDRUPT  MAKERUPT

