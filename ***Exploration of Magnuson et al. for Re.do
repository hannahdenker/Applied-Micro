***Exploration of Magnuson et al. for Replication Project
***Working through variables present in Table 1
**Tab Flags for Math and Reading Scores to see missing
tab C1MTHFLG C4MTHFLG, mi
tab C1RDGFLG C4RDGFLG, mi

**See if these variables are missing in PUF
browse C1R4MSCL C1R4MTSC C4R4MTSC C4R4MSCL // math fall kinder and spring 1st
browse  C1R4RSCL C1R4RTSC C4R4RSCL C4R4RTSC // rdg fall kinder and spring 1st


**Not sure which of these would be considered the self-control outcome (fall kinder and spring 1st)
browse P4CONTRO P1CONTRO, mi
browse T1CONTRO T4CONTRO, mi

**I think this is the "externalizing behaviors" outcome
browse T1EXTERN T4EXTERN


***Kindergarten retention
tab S2KNDRGT, mi

**Child Races used in paper: Black, Asian, Hispanic (and I assume white as reference)
desc B1RACE2 B1RACE3 B1HISP  B1RACE5
tab  B1RACE2 B1HISP , mi // hispanic not mutually exclusive with other races. 
// is there another variable to use? 

**Male
tab GENDER, mi
**age
tab R2_KAGE R1_KAGE, mi
**income-to-needs ratio
// cna't find this variable. 
***ECE care type
desc P1RPREK P1NPREK P1HSPREK P1CPREK P2RPREK P2NPREK P2HSPREK P2CPREK P3RPREK P3NPREK P3HSPREK P3CPREK P1PRIMPK WKCAREPK
// not sure which of these is the right "child care arrangements the year prior to kindergarten"

tab P1PRIMPK, mi
tab P1RPREK, mi
tab WKCAREPK, mi

