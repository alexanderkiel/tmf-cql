library "stratifier-medication-statement-medication-code"
using FHIR version '4.0.0'
include FHIRHelpers version '4.0.0'

context Unfiltered

define function MedicationCode1(medicationId System.String):
  singleton from (from [Medication] M
    where M.id = medicationId
    return singleton from (M.code.coding.where(system = 'http://fhir.de/CodeSystem/bfarm/atc').code))

context Patient

define InInitialPopulation:
  [MedicationStatement]

define function MedicationCode(medicationStatement FHIR.MedicationStatement):
  MedicationCode1(Id((medicationStatement.medication as Reference).reference))

define function Id(reference System.String):
  Split(reference, '/')[1]
