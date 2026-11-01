<!-- Rapider Official App SOW & Specification | App #152: Medical Practice Management (medical-practice-management) | Domain: HLT -->
# #152 Medical Practice Management (`medical-practice-management`) — Scope of Work (SOW)

- **App Number:** `#152`
- **App Key:** `medical-practice-management`
- **Suite / Domain:** Healthcare & Wellness (`HLT` — `Hlt*`)
- **Representative Benchmark (`P1`):** AdvancedMD Practice Management
- **Combined Feature Set Reference:** [../combined-features/152-medical-practice-management-features.md](../combined-features/152-medical-practice-management-features.md)
- **Status:** Official Architecture & Implementation Specification

---

## 1. Executive Outcome & Target Audience

**Rapider Medical Practice Management (`medical-practice-management`)** eliminates front-desk registration bottlenecks, double-booked exam rooms, day-of-surgery prior authorization surprises, preventable eligibility-related claim rejections, and uncollected point-of-service copays. Acting as the operational backbone of the `HLT` suite, it orchestrates provider/facility capacity, multi-resource scheduling, primary/secondary/tertiary insurance verification (`X12 270/271`), prior authorizations (`278` / Da Vinci CRD), live exam-room flow, closed-loop referrals, and HIPAA-safe PHI-free copay handoff to `payments`.

### SME Fast-Path vs. Enterprise Progressive Disclosure
- **SME Fast-Path Defaults (1–15 Provider Outpatient, Dental/Vision, PT & Behavioral Clinics):** Configure provider profiles (`HltProviderProfile`) and exam rooms (`HltClinicFacilityRoom`), manage daily/weekly multi-provider calendars and recurring therapy series (`HltAppointment`), run automated 72-hour pre-visit eligibility checks (`HltEligibilityVerification`), check in arriving patients in under 60 seconds (`HltFrontDeskCheckIn`), drag cards across the live clinic rooming `<rapider-kanban>` board, and collect copays cleanly via tokenized `FinPaymentIntent` handoff.
- **Enterprise Progressive Disclosure (Multi-Site Specialty Networks, Ambulatory Surgery Centers & Access Centers):** Progressively unlock coupled multi-resource scheduling rules (Surgeon + Procedure Suite + C-Arm Modality), primary/secondary/tertiary Coordination of Benefits (COB), Da Vinci CRD / `X12 278` prior authorization visit countdown gates, centralized referral conversion workqueues (`HltReferralOrder`), provider state-license/DEA expiration governance, and predictive no-show slot optimization.

### Measurable Business & Operational Outcomes
1. **<= 60-Second Front-Desk Patient Check-In** and **>= 92% Point-of-Service Copay Collection Rate** via pre-verified eligibility breakdowns and tokenized one-click payment capture.
2. **>= 80% Reduction in Front-End Eligibility & Authorization Denials** through automated 72-hour batch `X12 270/271` verification and mandatory prior-authorization visit counter checks prior to rooming.
3. **>= 15% Improvement in Provider Slot Utilization** by pairing cancellation release rules with smart waitlist and `STAT` referral slot matching.
4. **Zero Clinical PHI Leakage into General Financial Ledgers** by passing strictly opaque `POS-CHK-{uuid}` settlement tokens to `payments` (`FinPaymentIntent`).

### Top 6 Global Benchmark Summary (`P1`–`P6`)
Synthesizes **AdvancedMD (`P1`)** unified multi-provider scheduling, secondary/tertiary batch eEligibility, and sub-minute check-in; **Epic Cadence & Prelude (`P2`)** multi-resource decision-tree booking, COB rigor, and Da Vinci CRD prior authorization; **ModMed (`P3`)** specialty rooming flow boards and authorized visit countdowns; **athenaOne PM (`P4`)** pre-visit network registration rule edits; **Salesforce Health Cloud (`P5`)** provider network credentialing and referral conversion; and **Microsoft Cloud for Healthcare (`P6`)** multi-facility care access and Copilot capacity insights.

---

## 2. In-Scope, Out-of-Scope & Suite Ownership Boundaries

### In-Scope (`medical-practice-management`)
- Provider directory, NPI-1/taxonomy, state medical license/DEA expiration tracking, on-call coverage, and accepted payer networks (`HltProviderProfile`).
- Clinic facilities (NPI-2, Place of Service codes), exam rooms, and bookable diagnostic equipment (`HltClinicFacilityRoom`), plus provider slot templates (`HltAppointmentSlot`).
- Multi-resource and recurring-series appointment booking, cancellations, no-shows, and smart waitlist ranking (`HltAppointment`).
- Primary, secondary, and tertiary insurance policies (`HltPatientCoverage`), automated batch/real-time `X12 270/271` eligibility, and `X12 278` prior authorization visit counters (`HltEligibilityVerification`).
- Sub-minute front-desk arrival check-in, live exam-room flow board, tokenized copay collection handoff (`HltFrontDeskCheckIn`), and inbound/outbound specialty referral loop closure (`HltReferralOrder`).

### Out-of-Scope (Delegated to Peer Rapider Apps)
- Authoring SOAP clinical notes, recording problems/allergies, prescribing medications, or signing lab results (owned by `#151 electronic-health-records-ehr`, which also owns canonical `HltPatient` MPI).
- Hosting live encrypted WebRTC video consult media streams and continuous RPM wearable telemetry (owned by `#153 telemedicine-and-virtual-care`).
- Payer fee schedules, `837P`/`837I` claim scrubbing/submission, `835` ERA remittance posting, denial appeals, and post-visit patient statements (owned by `#154 medical-billing-and-claims-management`).
- Patient-facing SMS/email reminder cadences, mobile digital intake forms, secure portal messaging, and population recall campaigns (owned by `#155 patient-engagement-and-communication`).
- Raw card/ACH acquiring rails (`payments`) and General Ledger accounting (`acc`).

### Cross-Suite Ownership Contract

| Domain / App | Owns Canonical Models | Integration Contract with `medical-practice-management` |
| :--- | :--- | :--- |
| **`medical-practice-management` (`#152` — This App)** | `HltProviderProfile`, `HltClinicFacilityRoom`, `HltAppointmentSlot`, `HltAppointment`, `HltPatientCoverage`, `HltEligibilityVerification`, `HltFrontDeskCheckIn`, `HltReferralOrder` | Publishes appointment lifecycle, verified coverage/auth references, tokenized copay settlements, and closed-loop referral events across `HLT`. |
| **`electronic-health-records-ehr` (`#151`)** | `HltPatient`, `HltEncounterNote`, `HltProblemCondition`, `HltDiagnosticOrderResult` | `#152` references and updates administrative contact fields on canonical `HltPatient`; transitioning an `HltAppointment` to `ROOMED` emits `hlt.pm.appointment.checkedIn` so `#151` opens/preps `HltEncounterNote`. |
| **`telemedicine-and-virtual-care` (`#153`)** | `HltTelehealthSession`, `HltVirtualWaitingRoom` | Booking or converting an `HltAppointment` with `modality == TELEHEALTH` (`POS 02`/`10`) triggers `#153` to provision an encrypted `HltTelehealthSession` room. |
| **`medical-billing-and-claims-management` (`#154`)** | `HltChargeSuperbill`, `HltClaim837`, `HltPatientStatementPlan` | `#154` consumes `HltPatientCoverage` COB order, `HltEligibilityVerification` prior-auth number (`Box 23`), facility `POS` code, and collected `HltFrontDeskCheckIn.copayCollectedAmount` (`Decimal128`) to calculate net claim/patient balances. |
| **`patient-engagement-and-communication` (`#155`)** | `HltAppointmentCadenceReminder`, `HltDigitalIntakePacket` | `#155` listens to `HltAppointment` bookings/cancellations to send reminders/waitlist slot offers and pushes completed pre-visit `HltDigitalIntakePacket` status into `HltFrontDeskCheckIn`. |
| **`employees` & `hrs` (`HR` Suite)** | `HrEmployee`, `HrDepartment`, `HrLocation`, `HrTimeOffRequest` | `HltProviderProfile.employeeId` references `HrEmployee`; approved clinician `HrTimeOffRequest`s automatically block corresponding `HltAppointmentSlot` availability. |
| **`payments` (`FIN` Suite)** | `FinPaymentIntent` | Front-desk copay capture creates a `FinPaymentIntent` carrying ONLY `externalRef: "POS-CHK-{uuid}"` and `Decimal128` amount/currency—zero patient name, MRN, or clinical metadata. |

---

## 3. Primary Web Pages & Sidebar Navigation Architecture (12 Pages)

All visible sidebar groups strictly enforce the **Minimum 3 Items per Section Rule** (`Scheduling & Flow`: 3 items, `Access & Clearance`: 3 items, `Resources & Operations`: 3 items = 9 visible items; 3 detail/drawer routes hidden with `displayOnMenu: false`).

| # | Route | Page Title | Sidebar Section | Menu Visible | Key Components & UX |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | `practice-command` | Practice Operations Command | `Scheduling & Flow` | `true` (Order 1) | Daily arrivals KPI, Lobby/Room wait-time SLA gauges, Unverified Eligibility count, POS Copay Collected (`Decimal128`), No-Show rate, and provider utilization bars. |
| 2 | `schedule-calendar` | Multi-Resource Calendar | `Scheduling & Flow` | `true` (Order 2) | Multi-provider / room / equipment schedule grid (`HltAppointment`, `HltAppointmentSlot`), recurring series indicator, eligibility badge overlay, `#activeFilterTagsBar`. |
| 3 | `clinic-flow-board` | Check-In & Rooming Flow Board | `Scheduling & Flow` | `true` (Order 3) | Real-time `<rapider-kanban>` + table of today's `HltAppointment` / `HltFrontDeskCheckIn` cards (`SCHEDULED` -> `CHECKED_IN` -> `ROOMED` -> `IN_CONSULT` -> `CHECKED_OUT`), exam-room assignment & wait timers. |
| 4 | `eligibility-clearance` | Eligibility & Prior Auth Queue | `Access & Clearance` | `true` (Order 4) | Pre-visit financial clearance worklist (`HltEligibilityVerification`), batch `270/271` trigger, inactive coverage alerts, `278` prior-auth status & remaining visit counters. |
| 5 | `patient-coverages` | Insurance Coverages (COB) | `Access & Clearance` | `true` (Order 5) | Searchable `HltPatientCoverage` registry (Primary / Secondary / Tertiary COB rank, Payer, Member ID, Copay/Deductible `Decimal128`), OCR card verification status. |
| 6 | `referrals-waitlist` | Referrals & Smart Waitlist | `Access & Clearance` | `true` (Order 6) | Tabbed `HltReferralOrder` (`STAT`/`URGENT`/`ROUTINE` inbound & outbound loop status) and Smart Waitlist queue with 1-click slot match & `#155` offer trigger. |
| 7 | `provider-directory` | Providers & Credentialing | `Resources & Operations` | `true` (Order 7) | `HltProviderProfile` directory (NPI-1, Taxonomy, State License/DEA expiry badges, accepted payers, on-call toggle, `<rapider-phone-input>` on-call pager/mobile). |
| 8 | `facilities-rooms` | Clinics, Rooms & Modalities | `Resources & Operations` | `true` (Order 8) | `HltClinicFacilityRoom` & `HltAppointmentSlot` template manager (NPI-2, POS `11`/`22`/`02`/`10`, exam rooms, imaging suites, `<rapider-phone-input>` clinic front desk). |
| 9 | `access-analytics` | Utilization & No-Show Analytics | `Resources & Operations` | `true` (Order 9) | 3rd-Next-Available Appointment (TNAA) trend, cancellation/no-show breakdown by specialty, referral leakage metrics, and front-desk copay collection scorecards. |
| 10 | `appointment-detail` | Appointment & Clearance 360 | *(None)* | `false` | Complete visit dossier: `HltPatient` summary link (`#151`), coupled room/modality, `270/271` benefit breakdown, prior-auth visit counter, copay receipt token, and `projectChannelMessage` clearance thread. |
| 11 | `booking-drawer` | Book / Reschedule Appointment | *(None)* | `false` | Sliding drawer for single or recurring series booking, conflict & credential check, telehealth toggle, `<rapider-phone-input>` callback verification, `finally` button reset, auto-close on Save/Cancel. |
| 12 | `checkin-copay-drawer` | Rapid Check-In & Copay Drawer | *(None)* | `false` | Sub-60s arrival verification drawer (`HltFrontDeskCheckIn`), COB check, prior-auth decrement confirmation, tokenized `FinPaymentIntent` copay capture, and room assignment. |

### Rapider UI & QA Standards Enforced Across All 12 Pages
- **SWR Read Standard:** Every page loads initial records via `window.rapiderApi.findSWR(entityName, filter)` and `countSWR(entityName, where)` with zero redundant `isDeleted` filter clauses and defensive client filtering (`items = raw.filter(i => i && i.isDeleted !== true)`).
- **Table Actions & Navigation:** Primary identifiers (Appointment Ref, Eligibility Ref, Member Policy Ref, Referral Ref, Provider NPI/Name) render as `font-semibold text-primary hover:underline cursor-pointer` navigating to `#/appointment-detail` or opening the detail view. Zero standalone "View" buttons in `Actions`; Edit uses icon + text (`<i class="fas fa-edit mr-1"></i><span>Edit</span>`); Delete uses icon-only (`<i class="fas fa-trash-alt"></i>` with `title="Delete" aria-label="Delete"`).
- **Search & `#activeFilterTagsBar`:** Synchronous in-memory search on daily schedules/flow boards and debounced `skip: 0` API queries on paginated historical appointments/coverages, paired with HTML-escaped filter chips and `[Clear all]`.
- **Contrast & Dialog Ban:** Primary and danger actions enforce `!text-white text-white` and `style="color: #ffffff !important;"`. Zero `window.alert`, `window.confirm`, or `window.prompt` calls.

---

## 4. Canonical Data Models (`Hlt*` — 8 Models)

All models omit `projectId`, use platform UUID `id` (`00000000-xxxx-xxxx-xxxx-xxxxxxxxxxxx` for synthetic sample seeds), store monetary benefit/copay figures as `Decimal128`, and enforce optimistic concurrency via `version: Integer`.

| Model Name | Key Fields & Types | Relationships & External Refs | Invariants & Lifecycle |
| :--- | :--- | :--- | :--- |
| **`HltProviderProfile`** | `npiNumber: String(10)`, `taxonomyCode: String`, `displayName: String`, `credentialSuffix: String`, `specialty: String`, `licensedStates: Array<{stateCode, licenseNumber, expiresAt: Date}>`, `deaRegistrationExpiresAt: Date?`, `requiresSupervisingCosign: Boolean`, `acceptedPayerCodes: Array<String>`, `onCallPhone: String`, `isOnCallActive: Boolean`, `status: Enum(PENDING_CREDENTIALING, ACTIVE, SUSPENDED, INACTIVE)`, `version: Int` | `employeeId -> HrEmployee` (`employees`), `defaultSupervisorId -> HltProviderProfile?`, `primaryFacilityId -> HltClinicFacilityRoom` | Unique 10-digit Luhn-valid `npiNumber`; cannot book clinical appointments for a facility whose `stateCode` license is missing or expired (`expiresAt < appointmentDate`). |
| **`HltClinicFacilityRoom`** | `facilityCode: String`, `facilityName: String`, `organizationNpi2: String(10)`, `placeOfServiceCode: Enum(POS_11_OFFICE, POS_22_OUTPATIENT_HOSP, POS_20_URGENT_CARE, POS_02_TELEHEALTH_OTHER, POS_10_TELEHEALTH_HOME)`, `stateCode: String(2)`, `frontDeskPhone: String`, `resourceKind: Enum(CLINIC_SITE, EXAM_ROOM, PROCEDURE_SUITE, DIAGNOSTIC_MODALITY)`, `roomCode: String?`, `status: Enum(ACTIVE, SANITIZING, MAINTENANCE, INACTIVE)`, `version: Int` | `parentFacilityId -> HltClinicFacilityRoom?`, `hrLocationId -> HrLocation?` (`hrs`) | Exam rooms and diagnostic modalities cannot be double-booked across overlapping `HltAppointment` time windows. |
| **`HltAppointmentSlot`** | `templateName: String`, `slotDate: Date`, `startTimeUtc: DateTime`, `endTimeUtc: DateTime`, `durationMinutes: Int`, `allowedVisitType: Enum(NEW_PATIENT, ESTABLISHED_FOLLOWUP, SAME_DAY_ACUTE, PROCEDURE, TELEHEALTH, ANY)`, `maxBookings: Int`, `bookedCount: Int`, `isBlockedTimeOff: Boolean`, `blockReason: String?`, `version: Int` | `providerId -> HltProviderProfile`, `facilityId -> HltClinicFacilityRoom`, `coupledModalityRoomId -> HltClinicFacilityRoom?` | `bookedCount <= maxBookings`; `isBlockedTimeOff == true` blocks new bookings automatically when synced from `HrTimeOffRequest`. |
| **`HltAppointment`** | `appointmentRef: String`, `visitType: Enum(NEW_PATIENT, ESTABLISHED_FOLLOWUP, SAME_DAY_ACUTE, PROCEDURE, TELEHEALTH, RECURRING_THERAPY)`, `modality: Enum(IN_PERSON, TELEHEALTH)`, `scheduledStartUtc: DateTime`, `scheduledEndUtc: DateTime`, `seriesGroupId: UUID?`, `reasonForVisit: String`, `noShowRiskScore: Decimal128`, `isWaitlistCandidate: Boolean`, `cancellationReason: String?`, `status: Enum(WAITLISTED, SCHEDULED, CONFIRMED, CHECKED_IN, ROOMED, IN_CONSULT, READY_FOR_CHECKOUT, CHECKED_OUT, CANCELLED, NO_SHOW)`, `version: Int` | `patientId -> HltPatient` (`#151`), `providerId -> HltProviderProfile`, `facilityId -> HltClinicFacilityRoom`, `assignedExamRoomId -> HltClinicFacilityRoom?`, `slotId -> HltAppointmentSlot?`, `referralOrderId -> HltReferralOrder?`, `telehealthSessionId -> HltTelehealthSession?` (`#153`) | Transitioning to `CANCELLED` atomically decrements `HltAppointmentSlot.bookedCount`; transitioning to `ROOMED` requires `assignedExamRoomId` (for `IN_PERSON`) and emits encounter-prep event to `#151`. |
| **`HltPatientCoverage`** | `policyRef: String`, `cobPriority: Enum(PRIMARY, SECONDARY, TERTIARY, SELF_PAY_ONLY)`, `payerCode: String`, `payerName: String`, `planType: Enum(COMMERCIAL, MEDICARE, MEDICAID, TRICARE, WORKERS_COMP, SELF_PAY)`, `memberId: String`, `groupNumber: String?`, `subscriberRelationship: Enum(SELF, SPOUSE, CHILD, OTHER)`, `subscriberFullName: String`, `subscriberDob: Date`, `effectiveStartDate: Date`, `effectiveEndDate: Date?`, `status: Enum(ACTIVE, INACTIVE_TERMINATED, PENDING_VERIFICATION)`, `version: Int` | `patientId -> HltPatient` (`#151`), `cardFrontFileId -> DriveFile?`, `cardBackFileId -> DriveFile?` | At most one `ACTIVE` coverage per `(patientId, cobPriority)` rank at a given service date. |
| **`HltEligibilityVerification`** | `verificationRef: String`, `transactionKind: Enum(X12_270_271_ELIGIBILITY, X12_278_PRIOR_AUTH, DAVINCI_CRD_CHECK)`, `verifiedAt: DateTime`, `coverageStatusResult: Enum(ACTIVE_COVERED, INACTIVE, OUT_OF_NETWORK, AUTH_REQUIRED, AUTH_APPROVED, AUTH_DENIED, ERROR_NEEDS_REVIEW)`, `currency: String(3)`, `copayAmount: Decimal128`, `coinsurancePct: Decimal128`, `deductibleTotal: Decimal128`, `deductibleRemaining: Decimal128`, `oopMaxRemaining: Decimal128`, `priorAuthNumber: String?`, `approvedVisits: Int?`, `usedVisits: Int?`, `authExpiresAt: Date?`, `version: Int` | `patientId -> HltPatient`, `coverageId -> HltPatientCoverage`, `appointmentId -> HltAppointment?`, `exceptionWorkItemId -> WorkItem?` | For `AUTH_APPROVED` visit-limited authorizations, `usedVisits <= approvedVisits`; `INACTIVE` or `AUTH_DENIED` auto-generates a financial-clearance Home `WorkItem`. |
| **`HltFrontDeskCheckIn`** | `checkInRef: String`, `arrivedAt: DateTime`, `roomedAt: DateTime?`, `checkedOutAt: DateTime?`, `photoIdVerified: Boolean`, `hipaaNoticeSigned: Boolean`, `demographicsConfirmed: Boolean`, `currency: String(3)`, `estimatedPatientDue: Decimal128`, `copayCollectedAmount: Decimal128`, `posPaymentToken: String?`, `paymentStatus: Enum(NONE_DUE, COLLECTED, DEFERRED_TO_BILLING, WAIVED_HARDSHIP)`, `waiverReason: String?`, `version: Int` | `appointmentId -> HltAppointment`, `patientId -> HltPatient`, `assignedRoomId -> HltClinicFacilityRoom?`, `paymentIntentId -> FinPaymentIntent?` (`payments`), `intakePacketId -> HltDigitalIntakePacket?` (`#155`) | **Zero-PHI Payment Invariant:** `posPaymentToken` (`POS-CHK-{uuid}`) is the sole identifier sent to `FinPaymentIntent`; `WAIVED_HARDSHIP` requires authorized supervisor role and `waiverReason`. |
| **`HltReferralOrder`** | `referralRef: String`, `direction: Enum(INBOUND_TO_CLINIC, OUTBOUND_EXTERNAL, INTERNAL_SPECIALTY)`, `urgency: Enum(ROUTINE, URGENT, STAT)`, `targetSpecialty: String`, `reasonIcd10Code: String`, `clinicalSummaryNote: String`, `externalProviderName: String?`, `externalProviderNpi: String?`, `externalProviderPhone: String?`, `consultReportSentAt: DateTime?`, `status: Enum(NEW_UNSCHEDULED, AUTH_PENDING, SCHEDULED, CONSULT_COMPLETED, LOOP_CLOSED, EXPIRED, CANCELLED)`, `version: Int` | `patientId -> HltPatient`, `referringProviderId -> HltProviderProfile?`, `receivingProviderId -> HltProviderProfile?`, `sourceEncounterId -> HltEncounterNote?` (`#151`), `bookedAppointmentId -> HltAppointment?` | `STAT` referrals unscheduled beyond 24 hours auto-escalate via Home `WorkItem`; `LOOP_CLOSED` requires `consultReportSentAt != null`. |

---

## 5. Core End-to-End User Journeys

### Journey 1: 72-Hour Automated Batch Eligibility & Pre-Visit Financial Clearance
1. Three days before clinic day, `pm-batch-270-271-eligibility` runs automatically across all scheduled `HltAppointment`s, creating `HltEligibilityVerification` records for primary, secondary, and tertiary `HltPatientCoverage`s.
2. Out of 64 appointments, 61 return `ACTIVE_COVERED` with exact `Decimal128` copay (`\$30.00` PCP / `\$50.00` Specialist) and remaining deductible figures; 3 return `INACTIVE` or `AUTH_REQUIRED`, generating Rapider Home `WorkItem`s.
3. Patient Access Specialist opens `#/eligibility-clearance`, filters by `Result: "INACTIVE"` (`#activeFilterTagsBar`), calls the patient via `#155` or phone, updates the new employer BlueCross policy in `HltPatientCoverage`, re-runs real-time `270/271` to `ACTIVE_COVERED`, and resolves the Home `WorkItem` 48 hours before arrival.

### Journey 2: Sub-60-Second Front-Desk Check-In, PHI-Free Copay Capture & Live Exam-Room Flow
1. Patient arrives at the front desk; Receptionist opens `#/clinic-flow-board` and clicks **Check In** on the `09:30 AM` card, sliding open `#/checkin-copay-drawer`.
2. Pre-visit intake (`#155`) shows `hipaaNoticeSigned: true` and `demographicsConfirmed: true`; verified eligibility displays a `\$35.00` specialist copay and `4 of 6` authorized physical therapy visits remaining.
3. Receptionist collects `\$35.00`—`medical-practice-management` generates opaque token `POS-CHK-8f92...` and dispatches `FinPaymentIntent` to `payments` with zero patient name or clinical data. Upon settlement callback, `copayCollectedAmount` updates to `35.00`, authorized visit counter increments (`5 of 6`), and Receptionist assigns `Exam Room 3` (`ROOMED`).
4. Drawer resets button state in `finally`, clears SWR cache, auto-closes, moves the card to `ROOMED` on `<rapider-kanban>` optimistically, and emits `hlt.pm.appointment.checkedIn` so `#151` stages the provider's `HltEncounterNote`.

### Journey 3: Multi-Resource Coupled Booking & Expired State License Guardrail
1. Scheduler opens `#/schedule-calendar` and launches `#/booking-drawer` to schedule a `45-minute Vascular Ultrasound + Consult`.
2. Scheduler selects `Dr. Gomez` + `Vascular Suite B`; the slot engine verifies both resources are simultaneously free and checks `HltProviderProfile.licensedStates` against the clinic's state (`NY`) and accepted payer network—confirming active credentials before committing `HltAppointment`.

### Journey 4: Cancellation Release & Smart Waitlist Backfill Handoff to `#155`
1. An afternoon dermatology slot cancels (`status: CANCELLED`); `HltAppointmentSlot.bookedCount` decrements immediately.
2. `#/referrals-waitlist` highlights 3 matching waitlisted patients and 1 `URGENT` inbound `HltReferralOrder` with verified insurance; Scheduler clicks **Offer Slot via Patient Engagement**, emitting `hlt.pm.waitlist.slotOffered` so `#155` texts the top candidate to self-confirm.

### Journey 5: Closed-Loop Specialty Referral Tracking
1. `#151` clinician signs an encounter ordering an `URGENT` Cardiology referral; `#152` creates `HltReferralOrder` (`NEW_UNSCHEDULED`).
2. Referral Coordinator attaches `X12 278` `priorAuthNumber`, books the cardiology `HltAppointment` (`SCHEDULED`), and once the cardiologist signs the consult note in `#151`, dispatches the consult summary back to the referring PCP (`LOOP_CLOSED`).

### Journey 6: List-to-Detail Click-Through & Filter State Restoration
1. Practice Manager filters `#/eligibility-clearance` by `Status: "AUTH_REQUIRED"` and searches `"Aetna"`, rendering chips `Status: "AUTH_REQUIRED" ✕` and `Search: "Aetna" ✕` in `#activeFilterTagsBar`.
2. Manager clicks `ELIG-2026-0419` -> transitions cleanly to `#/appointment-detail?id=...` to review Da Vinci CRD clinical requirements, then clicks `#btnGoBack` returning to `#/eligibility-clearance` with active filters and scroll position intact.

---

## 6. Consolidated Feature Priorities & Work Packages

### `P0` Foundation (MVP Release — Mandatory)
- **WP-P0-1: Providers, Facilities & Slot Templates (`MPM-001`, `MPM-002`, `MPM-003`, `MPM-022`):** `HltProviderProfile` (NPI/license guardrails), `HltClinicFacilityRoom` (clinics, rooms, modalities), `HltAppointmentSlot` templates, and SME vs. Enterprise mode.
- **WP-P0-2: Multi-Resource Scheduling, Recurring Series & Waitlist (`MPM-005`, `MPM-006`, `MPM-007`):** `HltAppointment` conflict-free booking, recurring therapy series, cancellation slot release, and ranked waitlist queue.
- **WP-P0-3: Insurance COB & X12 270/271 Eligibility (`MPM-009`, `MPM-010`, `MPM-011`):** `HltPatientCoverage` primary/secondary/tertiary COB, batch/on-demand `HltEligibilityVerification`, and pre-visit exception `WorkItem`s.
- **WP-P0-4: Sub-Minute Check-In, Clinic Flow Board & PHI-Free Copay (`MPM-014`, `MPM-015`, `MPM-016`):** `HltFrontDeskCheckIn` rapid arrival drawer, `<rapider-kanban>` rooming board, `#151` encounter trigger, and tokenized `FinPaymentIntent` copay capture.
- **WP-P0-5: Closed-Loop Specialty Referrals (`MPM-018`):** `HltReferralOrder` intake, scheduling linkage, `STAT` SLA escalation, and consult-report loop closure.

### `P1` Scale & Enterprise Access Governance
- **WP-P1-1: Credential Escalations, On-Call & Hybrid Telehealth (`MPM-004`, `MPM-008`, `MPM-020`, `MPM-021`):** License/DEA expiry Home `WorkItem`s, booking prerequisite rules, on-call routing, and 1-click `#153` telehealth conversion.
- **WP-P1-2: Prior Authorizations (`278` / CRD), GFE & Check-Out Recalls (`MPM-012`, `MPM-013`, `MPM-017`):** Authorized visit countdowns, Good Faith Estimate triggers for `SELF_PAY`, and check-out follow-up booking prompts.
- **WP-P1-3: Utilization Analytics & Access Audit (`MPM-019`, `MPM-028`):** TNAA access lag, room turnaround, no-show analytics, and append-only waiver/override audit logs.

### `P2` Grounded Practice Operations AI
- **WP-P2-1: No-Show Risk, OCR Insurance Staging & Smart Slot Match (`MPM-023`, `MPM-024`, `MPM-026`):** Transparent HTI-1 no-show scoring, human-verified insurance card OCR staging, and automated waitlist candidate ranking.
- **WP-P2-2: AI Prior-Auth Assembler & Operations Copilot (`MPM-025`, `MPM-027`):** Specialist-reviewed prior-auth medical necessity packet drafting and `projectChannelMessage` Practice Operations Copilot.

---

## 7. Roles, Permissions & Field-Level Governance

| Role | Permitted Actions | Restricted / Field-Level Boundaries |
| :--- | :--- | :--- |
| **Front-Desk / Patient Access Representative (`hlt.pm.front_desk`)** | Book/reschedule/cancel `HltAppointment`s; update `HltPatientCoverage`; run `270/271` eligibility; execute `HltFrontDeskCheckIn`; assign exam rooms; collect tokenized copays. | **Cannot** waive copays (`WAIVED_HARDSHIP`), override expired provider licenses, view `#151` clinical SOAP narratives/lab results (minimum-necessary HIPAA boundary!), or edit `HltProviderProfile` credentials. |
| **Financial Clearance & Prior-Auth Specialist (`hlt.pm.clearance_specialist`)** | Manage `HltEligibilityVerification` queues, submit/update `X12 278` prior authorizations, attach minimum-necessary `#151` clinical docs for payer medical necessity, manage `HltReferralOrder` auths. | **Cannot** alter clinical notes in `#151` or modify provider NPI/DEA records. |
| **Practice Manager / Access Supervisor (`hlt.pm.manager`)** | Configure `HltClinicFacilityRoom`, `HltAppointmentSlot` templates, overbooking caps, on-call schedules; approve hardship copay waivers; resolve escalations; view utilization KPIs. | **Cannot** bypass state licensure expiration blocks or inject PHI into `FinPaymentIntent` payloads. |
| **Credentialing Administrator (`hlt.pm.credentialing`)** | Create/maintain `HltProviderProfile` NPI, taxonomy, state licenses, DEA dates, and accepted payer enrollments. | Read-only on patient appointments; zero clinical chart access. |
| **Clinician / Nurse (`hlt.ehr.physician` / `hlt.ehr.clinical_support`)** | View own/facility schedule and `<rapider-kanban>` rooming board; update room status (`IN_CONSULT`, `READY_FOR_CHECKOUT`); initiate internal/outbound `HltReferralOrder`s. | Cannot modify insurance COB rules or provider credential records. |

---

## 8. Technical APIs, Guarded Commands, Events & `requiredWorkflows`

### Guarded Idempotent Commands
All mutating endpoints require `idempotencyKey`, `correlationId`, and `expectedVersion`:
- `hlt.pm.appointment.book` / `hlt.pm.appointment.reschedule` / `hlt.pm.appointment.cancel` — Atomically checks provider active license for facility state, coupled room/modality availability, and slot capacity before committing.
- `hlt.pm.eligibility.verify` — Executes clearinghouse `X12 270/271` or Da Vinci CRD check and creates Home `WorkItem` on `INACTIVE` / `AUTH_REQUIRED`.
- `hlt.pm.checkin.complete` — Verifies arrival flags, decrements `HltEligibilityVerification` remaining authorized visits if applicable, and dispatches PHI-free `FinPaymentIntent` (`POS-CHK-{uuid}`) when `copayCollectedAmount > 0`.
- `hlt.pm.flow.transitionStatus` — Advances `HltAppointment` (`CHECKED_IN` -> `ROOMED` -> `IN_CONSULT` -> `CHECKED_OUT`), recording SLA timestamps and notifying `#151`.
- `hlt.pm.referral.closeLoop` — Records consult report transmission to referring provider (`LOOP_CLOSED`).

### Domain Events (Kafka)
- **Published:** `hlt.pm.appointment.booked`, `hlt.pm.appointment.cancelled`, `hlt.pm.appointment.checkedIn`, `hlt.pm.appointment.checkedOut`, `hlt.pm.eligibility.failed`, `hlt.pm.waitlist.slotOffered`, `hlt.pm.copay.collected`, `hlt.pm.referral.loopClosed`, `hlt.pm.provider.credentialExpiring`.
- **Consumed:** `hlt.ehr.encounter.signed` (`#151` — follow-up & referral orders), `hlt.engage.appointment.confirmedByPatient` (`#155`), `hlt.engage.intakePacket.submitted` (`#155`), `hr.timeoff.request.approved` (`timeoff`), `fin.payments.intent.settled` (`payments`).

### `requiredWorkflows` in `app.manifest.json`
1. `pm-batch-270-271-eligibility` (Runs scheduled 72-hour and 24-hour pre-visit clearinghouse eligibility checks across primary/secondary/tertiary coverages via vault-injected credentials).
2. `pm-davinci-278-prior-auth-sync` (Submits and polls `X12 278` / FHIR Da Vinci PAS prior authorization statuses and updates remaining visit counters).
3. `pm-provider-credential-expiry-monitor` (Daily check emitting 90/60/30-day Home `WorkItem`s for expiring state licenses and DEA registrations).
4. `pm-stat-referral-sla-escalator` (Monitors `STAT` and `URGENT` `HltReferralOrder`s and escalates unbooked referrals to Practice Managers).

### Grounded AI Safety Contract
Practice AI tools (no-show risk scoring, insurance card OCR staging, prior-auth packet drafting, and `projectChannelMessage` Operations Copilot) respect HIPAA minimum-necessary RBAC, cite exact `HltAppointment.id`, `HltAppointmentSlot.id`, and `HltEligibilityVerification.id` records, and **never** auto-cancel patient appointments, submit payer prior authorizations, or overwrite `HltPatientCoverage` policies without explicit staff confirmation.

---

## 9. Security, Privacy, Compliance & Non-Functional Requirements

- **HIPAA Minimum-Necessary Front-Office Separation:** Front-desk and scheduling roles access administrative demographics (`HltPatient`), appointment reason summaries, and insurance coverage (`HltPatientCoverage`), while clinical SOAP notes, sensitive behavioral diagnoses, and lab results in `#151` remain strictly blocked.
- **Zero PHI in `FIN` Payment Rails:** `HltFrontDeskCheckIn` stores the mapping between `appointmentId` and `posPaymentToken` (`POS-CHK-{uuid}`) inside the HIPAA-governed `HLT` boundary; `payments` (`FinPaymentIntent`) and `acc` (`FinJournalEntry`) receive only the opaque token, facility cost-center code, and `Decimal128` amount (e.g., `\$35.00`).
- **CMS Interoperability & No Surprises Act Readiness:** Supports ANSI X12 `5010` `270/271` & `278`, HL7 FHIR R4 `Appointment` / `Schedule` / `Slot` / `Coverage`, and automated Good Faith Estimate triggers for uninsured/`SELF_PAY` bookings.
- **Zero Hardcoded Credentials & Responsive Accessibility:** Clearinghouse API keys reside solely in `process.env` / secret vaults; WCAG 2.2 AA compliance, `#ffffff !important` button contrast, and responsive layouts across `390px` (mobile provider schedule), `768px` (tablet check-in desk), and `1440px` (multi-column access center calendar) in Light and Dark themes.

---

## 10. Deterministic Acceptance Criteria

1. **Sidebar Section Threshold:** `app.manifest.json` exposes 3 visible sidebar groups (`Scheduling & Flow`: 3 items, `Access & Clearance`: 3 items, `Resources & Operations`: 3 items) with zero 1-item or 2-item micro-headers; `#/appointment-detail`, `#/booking-drawer`, and `#/checkin-copay-drawer` set `displayOnMenu: false`.
2. **SWR & Clean Query Compliance:** All 12 pages load initial data via `findSWR` / `countSWR` without manual `isDeleted` filter clauses in API payloads and defensively filter `item.isDeleted !== true` in memory.
3. **Expired License & Resource Conflict Guardrails:** Calling `hlt.pm.appointment.book` for a provider whose state license is expired for the clinic's `stateCode` fails with `422 PROVIDER_LICENSE_EXPIRED`; booking an already occupied `HltClinicFacilityRoom` exam room or modality fails with `409 RESOURCE_CONFLICT`.
4. **Zero-PHI `FinPaymentIntent` Handoff:** Collecting a `\$40.00` copay in `#/checkin-copay-drawer` dispatches a `FinPaymentIntent` payload containing `POS-CHK-{uuid}` and `Decimal128("40.00")`—verified by E2E payload assertion to contain zero patient name, DOB, MRN, or ICD/CPT strings.
5. **Prior Authorization Visit Counter Gate:** Attempting to check in a visit-limited procedure when `usedVisits >= approvedVisits` blocks standard check-in and requires either an updated `AUTH_APPROVED` record or documented supervisor financial waiver.
6. **Batch Eligibility Exception `WorkItem`:** Receiving an `INACTIVE` or `AUTH_DENIED` `HltEligibilityVerification` automatically creates a linked Rapider Home `WorkItem` without duplicating an isolated inbox app.
7. **Decimal128 Benefit & Copay Precision:** Copay, coinsurance %, total/remaining deductible, and POS collected totals use `Decimal128` with zero floating-point rounding drift.
8. **Rooming Event Handoff to `#151`:** Dragging or transitioning an `HltAppointment` to `ROOMED` on `<rapider-kanban>` updates the UI optimistically, clears SWR cache, and emits `hlt.pm.appointment.checkedIn` with `patientId` and `appointmentId`.
9. **Drawer Lifecycle & `finally` Reset:** Saving or cancelling `#/booking-drawer` and `#/checkin-copay-drawer` resets submit buttons inside a `finally` block and closes the drawer automatically.
10. **Optimistic CRUD & Rollback:** Editing appointments, coverages, or room statuses immediately updates tables and `<rapider-kanban>`, invalidates `swr_find_` / `swr_count_` keys, and rolls back cleanly on simulated API failure.
11. **Search, `#activeFilterTagsBar` & Clear All:** Filtering calendars, eligibility queues, or referrals displays HTML-escaped chips in `#activeFilterTagsBar`; clicking `✕` removes a single chip and `[Clear all]` restores the full dataset synchronously.
12. **Table Actions, Custom Elements & Dialog Ban:** Tables contain zero "View" buttons in `Actions`, navigate via clickable primary identifiers, render icon+text `Edit` and icon-only `Delete`, use `<rapider-kanban>` for clinic rooming flow and `<rapider-phone-input>` for clinic/provider/patient phones, enforce `#ffffff !important` on primary/danger buttons, and use zero `alert()`/`confirm()`/`prompt()` calls.
13. **Click-Through & Back State Restoration:** Clicking an eligibility or appointment identifier transitions cleanly to `#/appointment-detail?id=...` without `<base href>` URL hijacking, and clicking `#btnGoBack` restores prior filter chips and list state across Light and Dark themes.
