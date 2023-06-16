# TMF CQL Schulung

## Start

### Install Blazectl

https://github.com/samply/blazectl

### Öffentlicher Server

```sh
export BASE="https://mii-agiop-polar.life.uni-leipzig.de/blaze"
export PASSWORD=<password>
```

### Lokaler Server

```sh
docker compose up -d
export BASE="http://localhost:8080/fhir"
blazectl --server "$BASE" upload data
```

## Alle Patienten

Unsere Population soll einfach alle Patienten enthalten.

### CQL Library

```cql
// CQL Library Header
library "everyone"
// wir nutzen das Datenmodell FHIR in der Version R4
using FHIR version '4.0.0'
// wir binden die CQL Bibliothek FHIRHelpers, die beim Arbeiten mit FHIR 
// praktisch immer gebraucht wird
include FHIRHelpers version '4.0.0'

// unsere CQL Expressions werden im Patient Context definiert,
// haben somit immer einen Patienten im Scope
context Patient

// InInitialPopulation ist unsere Expression, welche die Population bestimmt
// D.h. $evaluate-measure führt diese Expression pro Patient aus und erwartet
// einen Boolean Rückgabewert, welcher besagt, ob ein Patient Teil der Population
// sein soll.
define InInitialPopulation:
  true
```

### Vereinfachte Darstellung Library/Measure Ressourcen

Aus dieser YAML Datei erstellt `blazectl` eine [Measure][1] und eine [Library][2] Ressource. Die Library Ressource enthält den CQL Library Quelltext, wohingegen die Measure Ressource beschreibt, welche Populationen gerechnet werden sollen.

```yml
# Name der CQL Library Datei
library: everyone.cql
# Gruppen der Measure Ressource
group:
  # Wir bilden Patienten Populationen 
- type: Patient
  population:
    # Wir verwenden die InInitialPopulation Expression, um zu entscheiden, ob ein Patient
    # Teil der Population ist
  - expression: InInitialPopulation
```

### Ausführung

```sh
blazectl --server "$BASE" --user polar --password "$PASSWORD" evaluate-measure everyone.yml | jq -rf count.jq
```

### Ergebnis

```text
16982
```

### Als MeasureReport  (vereinfacht)

```json
{
  "resourceType": "MeasureReport",
  "status": "complete",
  "type": "summary",
  "measure": "urn:uuid:b5b9e154-fc7f-4d00-8860-44644f1d0132",
  "group": [
    {
      "population": [
        {
          "count": 16982
        }
      ]
    }
  ]
}
```

## Geschlecht

### CQL Library

```cql
library "geschlecht"
using FHIR version '4.0.0'
include FHIRHelpers version '4.0.0'

context Patient

// Wir können im Patientencontext per `Patient` auf den Patienten zugreifen
// Patient.gender ist vom Typ FHIR.code und wird implizit in einen String konvertiert
define InInitialPopulation:
  Patient.gender = 'female'
```

### Ausführung

```sh
blazectl --server "$BASE" --user polar --password "$PASSWORD" evaluate-measure geschlecht.yml | jq -rf count.jq
```

### Ergebnis

```text
8437
```

## Schädeldachfraktur

### CQL Library

```cql
library "schaedeldachfraktur"
using FHIR version '4.0.0'
include FHIRHelpers version '4.0.0'

// Wir definieren das ICD-10-GM Codesystem auf dem Identifier `icd10`
codesystem icd10: 'http://fhir.de/CodeSystem/bfarm/icd-10-gm'
// Wir definieren den Code `S02.0` aus dem ICD-10-GM Codesystem
// Der Identifier `Schädeldachfraktur` ist quoted und kann somit beliebige Zeichen enthalten 
code "Schädeldachfraktur": 'S02.0' from icd10

context Patient

// Wir verwenden hier eine Retrieve Expression mit der Synbtax [<Type>: <Terminology>]
// [Condition: "Schädeldachfraktur"] gibt eine Liste aller FHIR Condition Ressourcen mit
// dem Code `S02.0` aus ICD-10-GM des aktuell im Context befindlichen Patienten zurück.
// `exists` selektiert alle Patienten, die min. eine solche Diagnose haben.
define InInitialPopulation:
  exists [Condition: "Schädeldachfraktur"]
```

### Ausführung

```sh
blazectl --server "$BASE" --user polar --password "$PASSWORD" evaluate-measure schaedeldachfraktur.yml | jq -rf count.jq
```

### Ergebnis

```text
206
```

## Schädeldachfraktur aus 2020

### CQL Library

```cql
library "schaedeldachfraktur2020"
using FHIR version '4.0.0'
include FHIRHelpers version '4.0.0'

codesystem icd10: 'http://fhir.de/CodeSystem/bfarm/icd-10-gm'
code "Schädeldachfraktur": 'S02.0' from icd10

context Patient

define InInitialPopulation:
  exists "Schädeldachfraktur 2020"

// Wir definieren eine extra Expression für alle Schädeldachfrakturen aus 2020
// `from <list-expression> <alias> where <alias> ...` ist eine Query Expression
// mittels `year from C.recordedDate = 2020` schränken wir auf Diagnosen ein,
// welche in 2020 erfasst wurden. Das eigentlich relevantere `onset` ist in den
// Daten nicht vorhanden
define "Schädeldachfraktur 2020":
  from [Condition: "Schädeldachfraktur"] C
  where year from C.recordedDate = 2020
```

### Ausführung

```sh
blazectl --server "$BASE" --user polar --password "$PASSWORD" evaluate-measure schaedeldachfraktur2020.yml | jq -rf count.jq
```

### Ergebnis

```text
102
```

## Schädeldachfraktur mit zusätzlicher Stratifizierung nach Geburtsjahr

### CQL Library

```cql
library "schaedelfraktur-stratifier-birth-year"
using FHIR version '4.0.0'
include FHIRHelpers version '4.0.0'

codesystem icd10: 'http://fhir.de/CodeSystem/bfarm/icd-10-gm'
code "Schädeldachfraktur": 'S02.0' from icd10

context Patient

// Wir selektieren wieder die Patienten mit Schädeldachfraktur
define InInitialPopulation:
  exists [Condition: "Schädeldachfraktur"]

// Zusätzlich definieren wir eine Expression, die wir für die Stratifizierung
// der selektierten Patienten verwenden
define BirthYear:
  year from Patient.birthDate
```

### Vereinfachte Darstellung Library/Measure Ressourcen

```yml
library: schaedeldachfraktur-stratifier-birth-year.cql
group:
- type: Patient
  population:
  - expression: InInitialPopulation
  # zusätzlich zur Population können wir Stratifier definieren
  stratifier:
    # unter diesem Code sind die Stratum Werte im MeasureReport zu finden
  - code: birth-year
    # hier taucht der Expression Name aus unserer Bibliothek auf
    expression: BirthYear
```

### Ausführung

```sh
blazectl --server "$BASE" --user polar --password "$PASSWORD" evaluate-measure schaedeldachfraktur-stratifier-birth-year.yml | jq -rf stratifier-birth-year.jq
```

### Ergebnis

```text
"year","count"
"1950",104
"1995",102
```

### Jq Skript zur Verflachung

Dieses [Jq][4] Skript verflacht den MeasureReport mit den Stratum Werten in eine CSV Darstellung.

```text
["year", "count"],
(.group[0].stratifier[0].stratum[] | [.value.text, .population[0].count])
| @csv
```

## Kalium

### CQL Library

```cql
library "kalium"
using FHIR version '4.0.0'
include FHIRHelpers version '4.0.0'

codesystem loinc: 'http://loinc.org'
code "Kalium": '6298-4' from loinc

context Patient

define InInitialPopulation:
  exists "Kalium zwischen 2 mmol/L und 5 mmol/L" 
  
define "Kalium zwischen 2 mmol/L und 5 mmol/L":  
  from [Observation: "Kalium"] O
  where O.value between 2 'mmol/L' and 5 'mmol/L'
```

### Ausführung

```sh
blazectl --server "$BASE" --user polar --password "$PASSWORD" evaluate-measure kalium.yml | jq -rf count.jq
```

### Ergebnis

```text
43
```

## Kalium mit min. Zwei Werten

Wir wollen Patienten finden, die min. zwei Kalium Laborwerte haben.

### CQL Library

```cql
library "kalium"
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
```

### Ausführung

```sh
blazectl --server "$BASE" --user polar --password "$PASSWORD" evaluate-measure kalium-two-values.yml | jq -rf count.jq
```

### Ergebnis

```text
36
```

## Medication Enoxaparin

### CQL Library

```cql
library "medication-enoxaparin"
using FHIR version '4.0.0'
include FHIRHelpers version '4.0.0'

codesystem atc: 'http://fhir.de/CodeSystem/bfarm/atc'
code "Enoxaparin": 'B01AB05' from atc

context Unfiltered

// Diese Expression ist im Unfiltered Context definiert. D.h. von hier aus
// ist der Zugriff auf den kompletten Datenbestand und vor allem Ressourcen,
// welche nicht im Patient Compartment sind, aus möglich.
// Wir bilden hier die Referenz auf die Enoxaparin Medication.
define "Enoxaparin Ref":
  'Medication/' + singleton from (
    [Medication: "Enoxaparin"] M return FHIRHelpers.ToString(M.id))

context Patient

define InInitialPopulation:
  exists "Enoxaparin MedicationStatements"

define "Enoxaparin MedicationStatements":
    from [MedicationStatement] M
    where (M.medication as Reference).reference = "Enoxaparin Ref"
```

### Ausführung

```sh
blazectl --server "$BASE" --user polar --password "$PASSWORD" evaluate-measure medication-enoxaparin.yml | jq -rf count.jq
```

### Ergebnis

```text
21
```

### Gleiches Ergebnis mittels FHIR Search

#### Medication ID

```sh
curl -sH 'Accept: application/fhir+json' -u "polar:$PASSWORD" 'https://mii-agiop-polar.life.uni-leipzig.de/blaze/Medication?code=B01AB05'  | jq -r '.entry[].resource.id'
```

#### Download aller MedicationStatements und zählen aller uniqen Subject Referenzen

```sh
blazectl --server "$BASE" --user polar --password "$PASSWORD" download MedicationStatement -q 'medication=Medication--132846039' | jq -r '.subject.reference' | sort -u | wc -l
```

## Medication Enoxaparin mit Inpatient Encounters mit Admission diagnosis

```sh
blazectl --server "$BASE" --user polar --password "$PASSWORD" evaluate-measure medication-enoxaparin-near-condition.yml | jq -rf count.jq
```

## Statistics

### Encounter Classes

```sh
blazectl --server "$BASE" --user polar --password "$PASSWORD" evaluate-measure stratifier-encounter-class.yml | jq -rf stratifier-encounter-class.jq
```

### Laboratory Codes

```sh
blazectl --server "$BASE" --user polar --password "$PASSWORD" evaluate-measure stratifier-lab-code.yml | jq -rf stratifier-lab-code.jq
```

### Medication ATC Codes

```sh
blazectl --server "$BASE" --user polar --password "$PASSWORD" evaluate-measure stratifier-medication-statement-medication-code.yml | jq -rf stratifier-medication-atc.jq
```

## NT-proBNP Units

````sh
blazectl --server "$BASE" --user polar --password "$PASSWORD" evaluate-measure NT-proBNP-Unit.yml | jq -rf stratifier-unit.jq
````

[1]: <http://hl7.org/fhir/R4B/measure.html>
[2]: <http://hl7.org/fhir/R4B/library.html>
[3]: <http://hl7.org/fhir/R4B/measurereport.html>
[4]: <https://jqlang.github.io/jq/manual/>
