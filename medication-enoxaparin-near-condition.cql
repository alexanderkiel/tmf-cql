library "medication-enoxaparin-near-condition"
using FHIR version '4.0.0'
include FHIRHelpers version '4.0.0'

codesystem atc: 'http://fhir.de/CodeSystem/bfarm/atc'
codesystem ActCode: 'http://terminology.hl7.org/CodeSystem/v3-ActCode'
codesystem DiagnosisRole: 'http://terminology.hl7.org/CodeSystem/diagnosis-role'

code "Enoxaparin": 'B01AB05' from atc
code "Inpatient Encounter": 'IMP' from ActCode
code "Admission diagnosis": 'AD' from DiagnosisRole

context Unfiltered

define "Enoxaparin Ref":
  'Medication/' + singleton from (
    [Medication: "Enoxaparin"] M return FHIRHelpers.ToString(M.id))

context Patient

define InInitialPopulation:
  exists
    from [MedicationStatement] M
    with "Inpatient Encounters with Admission diagnosis" E
      such that M.context.reference = 'Encounter/' + E.id
    where (M.medication as Reference).reference = "Enoxaparin Ref"

define "Inpatient Encounters with Admission diagnosis":
  from [Encounter] E
  where E.class = "Inpatient Encounter" and E.diagnosis.use.coding contains "Admission diagnosis"
