library "medication-enoxaparin"
using FHIR version '4.0.0'
include FHIRHelpers version '4.0.0'

codesystem atc: 'http://fhir.de/CodeSystem/bfarm/atc'
code "Enoxaparin": 'B01AB05' from atc

context Unfiltered

define "Enoxaparin Ref":
  'Medication/' + singleton from (
    [Medication: "Enoxaparin"] M return FHIRHelpers.ToString(M.id))

context Patient

define InInitialPopulation:
  exists "Enoxaparin MedicationStatements"

define "Enoxaparin MedicationStatements":
    from [MedicationStatement] M
    where (M.medication as Reference).reference = "Enoxaparin Ref"
