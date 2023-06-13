library "stratifier-medication-statement-medication-code"
using FHIR version '4.0.0'
include FHIRHelpers version '4.0.0'

context Unfiltered

define function MedicationCode(medicationId string):
  from [Medication] M
  where M.id = medicationId
  return M.code

context Patient

define InInitialPopulation:
  [MedicationStatement]

define function MedicationCode(medicationStatement FHIR.MedicationStatement):
  Split((medicationStatement.medication as Reference).reference, '/')[1]
