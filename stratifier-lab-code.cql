library "stratifier-lab-code"
using FHIR version '4.0.0'
include FHIRHelpers version '4.0.0'

codesystem category: 'http://terminology.hl7.org/CodeSystem/observation-category'
code laboratory: 'laboratory' from category

context Patient

define InInitialPopulation:
  [Observation: category in laboratory]

define function Code(observation FHIR.Observation):
  observation.code
