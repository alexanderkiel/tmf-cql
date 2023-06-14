library "stratifier-encounter-class"
using FHIR version '4.0.0'
include FHIRHelpers version '4.0.0'

context Patient

define InInitialPopulation:
  [Encounter]

define function Class(encounter FHIR.Encounter):
  encounter.class.code
