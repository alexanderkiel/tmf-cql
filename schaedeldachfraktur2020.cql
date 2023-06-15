library "schaedeldachfraktur2020"
using FHIR version '4.0.0'
include FHIRHelpers version '4.0.0'

codesystem icd10: 'http://fhir.de/CodeSystem/bfarm/icd-10-gm'
code "Schädeldachfraktur": 'S02.0' from icd10

context Patient

define InInitialPopulation:
  exists "Schädeldachfraktur 2020"

define "Schädeldachfraktur 2020":
  from [Condition: "Schädeldachfraktur"] C
  where year from C.recordedDate = 2020
