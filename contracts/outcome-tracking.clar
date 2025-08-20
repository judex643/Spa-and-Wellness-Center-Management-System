;; Outcome Tracking Contract
;; Records treatment outcomes, client feedback, and generates analytics

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u500))
(define-constant ERR-OUTCOME-NOT-FOUND (err u501))
(define-constant ERR-INVALID-RATING (err u502))
(define-constant ERR-APPOINTMENT-NOT-FOUND (err u503))
(define-constant ERR-FEEDBACK-EXISTS (err u504))
(define-constant ERR-INVALID-INPUT (err u505))
(define-constant ERR-FOLLOW-UP-NOT-FOUND (err u506))

;; Data Variables
(define-data-var next-outcome-id uint u1)
(define-data-var next-feedback-id uint u1)
(define-data-var next-follow-up-id uint u1)
(define-data-var next-survey-id uint u1)

;; Data Maps
(define-map treatment-outcomes
  { outcome-id: uint }
  {
    appointment-id: uint,
    client-id: uint,
    therapist-id: uint,
    treatment-id: uint,
    session-date: uint,
    pre-treatment-notes: (string-ascii 300),
    post-treatment-notes: (string-ascii 300),
    treatment-effectiveness: uint, ;; 1-10 scale
    client-comfort-level: uint, ;; 1-10 scale
    any-adverse-reactions: bool,
    adverse-reaction-details: (optional (string-ascii 200)),
    recommended-follow-up: bool,
    follow-up-timeframe: (optional uint),
    therapist-observations: (string-ascii 400),
    recorded-by: principal,
    recorded-date: uint
  }
)

(define-map client-feedback
  { feedback-id: uint }
  {
    appointment-id: uint,
    client-id: uint,
    therapist-id: uint,
    overall-satisfaction: uint, ;; 1-5 scale
    service-quality: uint, ;; 1-5 scale
    facility-cleanliness: uint, ;; 1-5 scale
    staff-professionalism: uint, ;; 1-5 scale
    value-for-money: uint, ;; 1-5 scale
    would-recommend: bool,
    written-feedback: (string-ascii 500),
    areas-for-improvement: (string-ascii 300),
    favorite-aspects: (string-ascii 300),
    feedback-date: uint,
    is-anonymous: bool
  }
)

(define-map follow-up-appointments
  { follow-up-id: uint }
  {
    original-appointment-id: uint,
    client-id: uint,
    therapist-id: uint,
    recommended-date: uint,
    scheduled-date: (optional uint),
    follow-up-type: (string-ascii 50),
    priority-level: uint, ;; 1-5 scale
    notes: (string-ascii 300),
    status: (string-ascii 20),
    created-date: uint,
    completed-date: (optional uint)
  }
)

(define-map client-progress-tracking
  { client-id: uint, tracking-period: uint }
  {
    period-start: uint,
    period-end: uint,
    total-appointments: uint,
    average-satisfaction: uint,
    improvement-areas: (string-ascii 300),
    goals-achieved: (string-ascii 300),
    recommended-treatments: (string-ascii 200),
    overall-progress: uint, ;; 1-10 scale
    next-review-date: uint
  }
)

(define-map therapist-performance-metrics
  { therapist-id: uint, period: uint }
  {
    period-start: uint,
    period-end: uint,
    total-treatments: uint,
    average-client-satisfaction: uint,
    average-treatment-effectiveness: uint,
    client-retention-rate: uint,
    adverse-reaction-rate: uint,
    follow-up-compliance: uint,
    professional-development-hours: uint,
    performance-score: uint
  }
)

(define-map satisfaction-surveys
  { survey-id: uint }
  {
    survey-name: (string-ascii 100),
    description: (string-ascii 300),
    questions: (string-ascii 1000),
    target-audience: (string-ascii 50),
    active-from: uint,
    active-until: uint,
    response-count: uint,
    is-active: bool,
    created-by: principal
  }
)

(define-map survey-responses
  { survey-id: uint, client-id: uint }
  {
    responses: (string-ascii 1000),
    completion-date: uint,
    response-time-minutes: uint,
    overall-score: uint
  }
)

(define-map quality-metrics
  { metric-date: uint }
  {
    total-appointments: uint,
    completed-appointments: uint,
    cancelled-appointments: uint,
    average-satisfaction: uint,
    complaint-count: uint,
    compliment-count: uint,
    repeat-client-percentage: uint,
    new-client-count: uint,
    revenue-per-appointment: uint
  }
)

;; Private Functions
(define-private (is-authorized-for-outcome (appointment-id uint) (caller principal))
  (or
    (is-eq caller CONTRACT-OWNER)
    ;; Would need to check if caller is the therapist for this appointment
    true
  )
)

(define-private (calculate-average-rating (ratings (list 10 uint)))
  (let
    (
      (total (fold + ratings u0))
      (count (len ratings))
    )
    (if (> count u0)
      (/ total count)
      u0
    )
  )
)

(define-private (is-valid-rating (rating uint) (max-rating uint))
  (and (> rating u0) (<= rating max-rating))
)

;; Public Functions

;; Record treatment outcome
(define-public (record-treatment-outcome
  (appointment-id uint)
  (client-id uint)
  (therapist-id uint)
  (treatment-id uint)
  (pre-treatment-notes (string-ascii 300))
  (post-treatment-notes (string-ascii 300))
  (treatment-effectiveness uint)
  (client-comfort-level uint)
  (any-adverse-reactions bool)
  (adverse-reaction-details (optional (string-ascii 200)))
  (recommended-follow-up bool)
  (follow-up-timeframe (optional uint))
  (therapist-observations (string-ascii 400)))
  (let
    (
      (outcome-id (var-get next-outcome-id))
    )
    (asserts! (is-authorized-for-outcome appointment-id tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-valid-rating treatment-effectiveness u10) ERR-INVALID-RATING)
    (asserts! (is-valid-rating client-comfort-level u10) ERR-INVALID-RATING)

    (map-set treatment-outcomes
      { outcome-id: outcome-id }
      {
        appointment-id: appointment-id,
        client-id: client-id,
        therapist-id: therapist-id,
        treatment-id: treatment-id,
        session-date: block-height,
        pre-treatment-notes: pre-treatment-notes,
        post-treatment-notes: post-treatment-notes,
        treatment-effectiveness: treatment-effectiveness,
        client-comfort-level: client-comfort-level,
        any-adverse-reactions: any-adverse-reactions,
        adverse-reaction-details: adverse-reaction-details,
        recommended-follow-up: recommended-follow-up,
        follow-up-timeframe: follow-up-timeframe,
        therapist-observations: therapist-observations,
        recorded-by: tx-sender,
        recorded-date: block-height
      }
    )

    (var-set next-outcome-id (+ outcome-id u1))
    (ok outcome-id)
  )
)

;; Submit client feedback
(define-public (submit-client-feedback
  (appointment-id uint)
  (client-id uint)
  (therapist-id uint)
  (overall-satisfaction uint)
  (service-quality uint)
  (facility-cleanliness uint)
  (staff-professionalism uint)
  (value-for-money uint)
  (would-recommend bool)
  (written-feedback (string-ascii 500))
  (areas-for-improvement (string-ascii 300))
  (favorite-aspects (string-ascii 300))
  (is-anonymous bool))
  (let
    (
      (feedback-id (var-get next-feedback-id))
    )
    (asserts! (is-valid-rating overall-satisfaction u5) ERR-INVALID-RATING)
    (asserts! (is-valid-rating service-quality u5) ERR-INVALID-RATING)
    (asserts! (is-valid-rating facility-cleanliness u5) ERR-INVALID-RATING)
    (asserts! (is-valid-rating staff-professionalism u5) ERR-INVALID-RATING)
    (asserts! (is-valid-rating value-for-money u5) ERR-INVALID-RATING)

    (map-set client-feedback
      { feedback-id: feedback-id }
      {
        appointment-id: appointment-id,
        client-id: client-id,
        therapist-id: therapist-id,
        overall-satisfaction: overall-satisfaction,
        service-quality: service-quality,
        facility-cleanliness: facility-cleanliness,
        staff-professionalism: staff-professionalism,
        value-for-money: value-for-money,
        would-recommend: would-recommend,
        written-feedback: written-feedback,
        areas-for-improvement: areas-for-improvement,
        favorite-aspects: favorite-aspects,
        feedback-date: block-height,
        is-anonymous: is-anonymous
      }
    )

    (var-set next-feedback-id (+ feedback-id u1))
    (ok feedback-id)
  )
)

;; Schedule follow-up appointment
(define-public (schedule-follow-up
  (original-appointment-id uint)
  (client-id uint)
  (therapist-id uint)
  (recommended-date uint)
  (follow-up-type (string-ascii 50))
  (priority-level uint)
  (notes (string-ascii 300)))
  (let
    (
      (follow-up-id (var-get next-follow-up-id))
    )
    (asserts! (is-authorized-for-outcome original-appointment-id tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-valid-rating priority-level u5) ERR-INVALID-RATING)
    (asserts! (> recommended-date block-height) ERR-INVALID-INPUT)

    (map-set follow-up-appointments
      { follow-up-id: follow-up-id }
      {
        original-appointment-id: original-appointment-id,
        client-id: client-id,
        therapist-id: therapist-id,
        recommended-date: recommended-date,
        scheduled-date: none,
        follow-up-type: follow-up-type,
        priority-level: priority-level,
        notes: notes,
        status: "pending",
        created-date: block-height,
        completed-date: none
      }
    )

    (var-set next-follow-up-id (+ follow-up-id u1))
    (ok follow-up-id)
  )
)

;; Update follow-up status
(define-public (update-follow-up-status (follow-up-id uint) (status (string-ascii 20)) (scheduled-date (optional uint)))
  (let
    (
      (follow-up (unwrap! (map-get? follow-up-appointments { follow-up-id: follow-up-id }) ERR-FOLLOW-UP-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)

    (map-set follow-up-appointments
      { follow-up-id: follow-up-id }
      (merge follow-up {
        status: status,
        scheduled-date: scheduled-date,
        completed-date: (if (is-eq status "completed") (some block-height) none)
      })
    )
    (ok true)
  )
)

;; Record client progress
(define-public (record-client-progress
  (client-id uint)
  (tracking-period uint)
  (period-start uint)
  (period-end uint)
  (total-appointments uint)
  (average-satisfaction uint)
  (improvement-areas (string-ascii 300))
  (goals-achieved (string-ascii 300))
  (recommended-treatments (string-ascii 200))
  (overall-progress uint)
  (next-review-date uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (< period-start period-end) ERR-INVALID-INPUT)
    (asserts! (is-valid-rating overall-progress u10) ERR-INVALID-RATING)
    (asserts! (> next-review-date period-end) ERR-INVALID-INPUT)

    (map-set client-progress-tracking
      { client-id: client-id, tracking-period: tracking-period }
      {
        period-start: period-start,
        period-end: period-end,
        total-appointments: total-appointments,
        average-satisfaction: average-satisfaction,
        improvement-areas: improvement-areas,
        goals-achieved: goals-achieved,
        recommended-treatments: recommended-treatments,
        overall-progress: overall-progress,
        next-review-date: next-review-date
      }
    )
    (ok true)
  )
)

;; Record therapist performance metrics
(define-public (record-therapist-performance
  (therapist-id uint)
  (period uint)
  (period-start uint)
  (period-end uint)
  (total-treatments uint)
  (average-client-satisfaction uint)
  (average-treatment-effectiveness uint)
  (client-retention-rate uint)
  (adverse-reaction-rate uint)
  (follow-up-compliance uint)
  (professional-development-hours uint))
  (let
    (
      (performance-score (/ (+ (+ (+ average-client-satisfaction average-treatment-effectiveness) client-retention-rate) follow-up-compliance) u4))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (< period-start period-end) ERR-INVALID-INPUT)
    (asserts! (<= client-retention-rate u100) ERR-INVALID-INPUT)
    (asserts! (<= adverse-reaction-rate u100) ERR-INVALID-INPUT)
    (asserts! (<= follow-up-compliance u100) ERR-INVALID-INPUT)

    (map-set therapist-performance-metrics
      { therapist-id: therapist-id, period: period }
      {
        period-start: period-start,
        period-end: period-end,
        total-treatments: total-treatments,
        average-client-satisfaction: average-client-satisfaction,
        average-treatment-effectiveness: average-treatment-effectiveness,
        client-retention-rate: client-retention-rate,
        adverse-reaction-rate: adverse-reaction-rate,
        follow-up-compliance: follow-up-compliance,
        professional-development-hours: professional-development-hours,
        performance-score: performance-score
      }
    )
    (ok true)
  )
)

;; Create satisfaction survey
(define-public (create-survey
  (survey-name (string-ascii 100))
  (description (string-ascii 300))
  (questions (string-ascii 1000))
  (target-audience (string-ascii 50))
  (active-from uint)
  (active-until uint))
  (let
    (
      (survey-id (var-get next-survey-id))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> (len survey-name) u0) ERR-INVALID-INPUT)
    (asserts! (< active-from active-until) ERR-INVALID-INPUT)

    (map-set satisfaction-surveys
      { survey-id: survey-id }
      {
        survey-name: survey-name,
        description: description,
        questions: questions,
        target-audience: target-audience,
        active-from: active-from,
        active-until: active-until,
        response-count: u0,
        is-active: true,
        created-by: tx-sender
      }
    )

    (var-set next-survey-id (+ survey-id u1))
    (ok survey-id)
  )
)

;; Submit survey response
(define-public (submit-survey-response
  (survey-id uint)
  (client-id uint)
  (responses (string-ascii 1000))
  (response-time-minutes uint)
  (overall-score uint))
  (let
    (
      (survey (unwrap! (map-get? satisfaction-surveys { survey-id: survey-id }) ERR-OUTCOME-NOT-FOUND))
    )
    (asserts! (get is-active survey) ERR-INVALID-INPUT)
    (asserts! (>= block-height (get active-from survey)) ERR-INVALID-INPUT)
    (asserts! (<= block-height (get active-until survey)) ERR-INVALID-INPUT)
    (asserts! (is-valid-rating overall-score u10) ERR-INVALID-RATING)

    (map-set survey-responses
      { survey-id: survey-id, client-id: client-id }
      {
        responses: responses,
        completion-date: block-height,
        response-time-minutes: response-time-minutes,
        overall-score: overall-score
      }
    )

    (map-set satisfaction-surveys
      { survey-id: survey-id }
      (merge survey { response-count: (+ (get response-count survey) u1) })
    )
    (ok true)
  )
)

;; Record daily quality metrics
(define-public (record-quality-metrics
  (metric-date uint)
  (total-appointments uint)
  (completed-appointments uint)
  (cancelled-appointments uint)
  (average-satisfaction uint)
  (complaint-count uint)
  (compliment-count uint)
  (repeat-client-percentage uint)
  (new-client-count uint)
  (revenue-per-appointment uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (<= completed-appointments total-appointments) ERR-INVALID-INPUT)
    (asserts! (<= cancelled-appointments total-appointments) ERR-INVALID-INPUT)
    (asserts! (<= repeat-client-percentage u100) ERR-INVALID-INPUT)

    (map-set quality-metrics
      { metric-date: metric-date }
      {
        total-appointments: total-appointments,
        completed-appointments: completed-appointments,
        cancelled-appointments: cancelled-appointments,
        average-satisfaction: average-satisfaction,
        complaint-count: complaint-count,
        compliment-count: compliment-count,
        repeat-client-percentage: repeat-client-percentage,
        new-client-count: new-client-count,
        revenue-per-appointment: revenue-per-appointment
      }
    )
    (ok true)
  )
)

;; Read-only Functions

;; Get treatment outcome
(define-read-only (get-treatment-outcome (outcome-id uint))
  (ok (map-get? treatment-outcomes { outcome-id: outcome-id }))
)

;; Get client feedback
(define-read-only (get-client-feedback (feedback-id uint))
  (ok (map-get? client-feedback { feedback-id: feedback-id }))
)

;; Get follow-up appointment
(define-read-only (get-follow-up-appointment (follow-up-id uint))
  (ok (map-get? follow-up-appointments { follow-up-id: follow-up-id }))
)

;; Get client progress
(define-read-only (get-client-progress (client-id uint) (tracking-period uint))
  (ok (map-get? client-progress-tracking { client-id: client-id, tracking-period: tracking-period }))
)

;; Get therapist performance
(define-read-only (get-therapist-performance (therapist-id uint) (period uint))
  (ok (map-get? therapist-performance-metrics { therapist-id: therapist-id, period: period }))
)

;; Get survey details
(define-read-only (get-survey (survey-id uint))
  (ok (map-get? satisfaction-surveys { survey-id: survey-id }))
)

;; Get survey response
(define-read-only (get-survey-response (survey-id uint) (client-id uint))
  (ok (map-get? survey-responses { survey-id: survey-id, client-id: client-id }))
)

;; Get quality metrics
(define-read-only (get-quality-metrics (metric-date uint))
  (ok (map-get? quality-metrics { metric-date: metric-date }))
)

;; Get next outcome ID
(define-read-only (get-next-outcome-id)
  (ok (var-get next-outcome-id))
)

;; Check if outcome exists
(define-read-only (outcome-exists (outcome-id uint))
  (is-some (map-get? treatment-outcomes { outcome-id: outcome-id }))
)
