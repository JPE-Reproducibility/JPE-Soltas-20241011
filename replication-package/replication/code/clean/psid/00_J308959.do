#delimit ;
*  PSID DATA CENTER *****************************************************
   JOBID            : 308959                            
   DATA_DOMAIN      : CDS                               
   USER_WHERE       : NULL                              
   FILE_TYPE        : CDS Kids Only                     
   OUTPUT_DATA_TYPE : ASCII                             
   STATEMENTS       : do                                
   CODEBOOK_TYPE    : HTML                              
   N_OF_VARIABLES   : 43                                
   N_OF_OBSERVATIONS: 10169                             
   MAX_REC_LENGTH   : 87                                
   DATE & TIME      : July 12, 2022 @ 15:10:50
*************************************************************************
;

infix
      KIDS                 1 - 1           KID97                2 - 4           KID02                5 - 7     
      KID07                8 - 10          KID14               11 - 13          KID19               14 - 16    
      ER30001             17 - 20          ER30002             21 - 23          ER33401             24 - 28    
      ER33402             29 - 30          ER33403             31 - 32          PCGCHREL97          33 - 33    
      Q1A26A              34 - 34          Q1A26B              35 - 35          Q1A26C              36 - 36    
      ER33601             37 - 40          ER33602             41 - 42          ER33603             43 - 44    
      CHREL               45 - 45          Q21A9A              46 - 46          Q21A9B              47 - 47    
      Q21A9C              48 - 48          ER33901             49 - 53          ER33902             54 - 55    
      ER33903             56 - 57          PCHREL07            58 - 58          Q31A9A              59 - 59    
      Q31A9B              60 - 60          Q31A9C              61 - 61          ER34201             62 - 66    
      ER34202             67 - 68          ER34203             69 - 70          P14REL              71 - 71    
      P14A17              72 - 72          P14A18              73 - 73          P14A19              74 - 74    
      ER34701             75 - 79          ER34702             80 - 81          ER34703             82 - 83    
      P19REL              84 - 84          P19A17              85 - 85          P19A18              86 - 86    
      P19A19              87 - 87    
using "$dir/data/psid/J308959.txt", clear 
;
label variable KIDS            "Sum of All KID Flags"                     ;
label variable KID97           "KID1997 = 1 if exists, else missing"      ;
label variable KID02           "KID2002 = 1 if exists, else missing"      ;
label variable KID07           "KID2007 = 1 if exists, else missing"      ;
label variable KID14           "KID2014 = 1 if exists, else missing"      ;
label variable KID19           "KID2019 = 1 if exists, else missing"      ;
label variable ER30001         "1968 INTERVIEW NUMBER"                    ;
label variable ER30002         "PERSON NUMBER                         68" ;
label variable ER33401         "1997 INTERVIEW NUMBER"                    ;
label variable ER33402         "SEQUENCE NUMBER                       97" ;
label variable ER33403         "RELATION TO HEAD                      97" ;
label variable PCGCHREL97      "PCG CHILD FILE RELEASE NUMBER 97"         ;
label variable Q1A26A          "LIMIT ON ATHLETICS 97"                    ;
label variable Q1A26B          "LIMIT ON SCH ATTEND 97"                   ;
label variable Q1A26C          "LIMIT ON SCH WK 97"                       ;
label variable ER33601         "2001 INTERVIEW NUMBER"                    ;
label variable ER33602         "SEQUENCE NUMBER                       01" ;
label variable ER33603         "RELATION TO HEAD                      01" ;
label variable CHREL           "PCG CHILD FILE RELEASE NUMBER 02"         ;
label variable Q21A9A          "LIMIT ON ATHLETICS 02"                    ;
label variable Q21A9B          "LIMIT ON SCH ATTEND 02"                   ;
label variable Q21A9C          "LIMIT ON SCH WK 02"                       ;
label variable ER33901         "2007 INTERVIEW NUMBER"                    ;
label variable ER33902         "SEQUENCE NUMBER                       07" ;
label variable ER33903         "RELATION TO HEAD                      07" ;
label variable PCHREL07        "PCG CHILD FILE RELEASE NUMBER 07"         ;
label variable Q31A9A          "LIMIT ON ATHLETICS 07"                    ;
label variable Q31A9B          "LIMIT ON SCHOOL ATTENDANCE 07"            ;
label variable Q31A9C          "LIMIT ON SCHOOL WORK 07"                  ;
label variable ER34201         "2013 INTERVIEW NUMBER"                    ;
label variable ER34202         "SEQUENCE NUMBER                       13" ;
label variable ER34203         "RELATION TO HEAD                      13" ;
label variable P14REL          "PCG CHILD RELEASE NUMBER 14"              ;
label variable P14A17          "LIMIT ON ATHLETICS 14"                    ;
label variable P14A18          "LIMIT ON SCHOOL ATTENDANCE 14"            ;
label variable P14A19          "LIMIT ON SCHOOL WORK 14"                  ;
label variable ER34701         "2019 INTERVIEW NUMBER"                    ;
label variable ER34702         "SEQUENCE NUMBER                       19" ;
label variable ER34703         "RELATION TO REFERENCE PERSON          19" ;
label variable P19REL          "PCG CHILD RELEASE NUMBER 19"              ;
label variable P19A17          "LIMIT ON ATHLETICS 19"                    ;
label variable P19A18          "LIMIT ON SCHOOL ATTENDANCE 19"            ;
label variable P19A19          "LIMIT ON SCHOOL WORK 19"                  ;
