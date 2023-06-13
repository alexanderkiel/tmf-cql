library "schaedelfraktur"
using FHIR version '4.0.0'
include FHIRHelpers version '4.0.0'

codesystem icd10: 'http://fhir.de/CodeSystem/bfarm/icd-10-gm'
code "Schädeldachfraktur": 'S02.0' from icd10
code "Schädelbasisfraktur": 'S02.1' from icd10

context Patient

define InInitialPopulation:
  exists [Condition: "Schädeldachfraktur"] or
  exists [Condition: "Schädelbasisfraktur"]
