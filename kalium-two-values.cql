library "kalium-two-values"
using FHIR version '4.0.0'
include FHIRHelpers version '4.0.0'

codesystem loinc: 'http://loinc.org'
code "Kalium": '6298-4' from loinc

context Patient

define InInitialPopulation:
  Length("Kalium zwischen 2 mmol/L und 5 mmol/L") > 1

define "Kalium zwischen 2 mmol/L und 5 mmol/L":
  from [Observation: "Kalium"] O
  where O.value between 2 'mmol/L' and 5 'mmol/L'
