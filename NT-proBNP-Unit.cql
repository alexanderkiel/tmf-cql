library "NT-proBNP-Unit"
using FHIR version '4.0.0'
include FHIRHelpers version '4.0.0'

codesystem loinc: 'http://loinc.org'
code "NT-proBNP": '33762-6' from loinc

context Patient

define "NT-proBNP Observations":
  [Observation: "NT-proBNP"]

define function Unit(observation FHIR.Observation):
  Coalesce(FHIRHelpers.ToString((observation.value as Quantity).code),
    (observation.value as Quantity).code.extension.where(url = 'http://terminology.hl7.org/CodeSystem/data-absent-reason').value)
