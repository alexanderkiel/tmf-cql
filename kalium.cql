library "kalium"
using FHIR version '4.0.0'
include FHIRHelpers version '4.0.0'

codesystem loinc: 'http://loinc.org'
code "Kalium": '6298-4' from loinc

context Patient

define InInitialPopulation:
  exists [Observation: "Kalium"] O
  where O.value between 2 'mmol/L' and 5 'mmol/L'
