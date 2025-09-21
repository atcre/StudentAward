
;; title: StudentAward
;; version: 1.0.0
;; summary: A transparent evaluation system for academic achievement recognition and grant distribution
;; description: This contract manages student awards, evaluations, and grant distributions on the Stacks blockchain

;; traits
;;

;; token definitions
;;

;; constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_STUDENT_NOT_FOUND (err u101))
(define-constant ERR_INVALID_SCORE (err u102))
(define-constant ERR_AWARD_NOT_FOUND (err u103))
(define-constant ERR_INSUFFICIENT_FUNDS (err u104))
(define-constant ERR_ALREADY_EVALUATED (err u105))
(define-constant ERR_INVALID_AWARD_TYPE (err u106))

;; Award types
(define-constant AWARD_EXCELLENCE u1)
(define-constant AWARD_ACHIEVEMENT u2)
(define-constant AWARD_MERIT u3)

;; data vars
(define-data-var total-students uint u0)
(define-data-var total-awards uint u0)
(define-data-var contract-balance uint u0)

;; data maps
;; Student registry
(define-map students
  { student-id: uint }
  {
    name: (string-ascii 50),
    wallet: principal,
    total-score: uint,
    evaluation-count: uint,
    awards-received: uint,
    registered-at: uint
  }
)

;; Evaluations
(define-map evaluations
  { student-id: uint, evaluation-id: uint }
  {
    evaluator: principal,
    subject: (string-ascii 30),
    score: uint,
    comments: (string-ascii 200),
    timestamp: uint
  }
)

;; Awards
(define-map awards
  { award-id: uint }
  {
    student-id: uint,
    award-type: uint,
    amount: uint,
    reason: (string-ascii 100),
    awarded-by: principal,
    awarded-at: uint,
    claimed: bool
  }
)

;; Student lookup by wallet
(define-map student-by-wallet
  { wallet: principal }
  { student-id: uint }
)

;; Evaluator permissions
(define-map evaluators
  { evaluator: principal }
  { authorized: bool }
)

;; public functions

;; Register a new student
(define-public (register-student (name (string-ascii 50)) (wallet principal))
  (let ((student-id (+ (var-get total-students) u1)))
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (map-set students
      { student-id: student-id }
      {
        name: name,
        wallet: wallet,
        total-score: u0,
        evaluation-count: u0,
        awards-received: u0,
        registered-at: block-height
      }
    )
    (map-set student-by-wallet { wallet: wallet } { student-id: student-id })
    (var-set total-students student-id)
    (ok student-id)
  )
)

;; Authorize an evaluator
(define-public (authorize-evaluator (evaluator principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (map-set evaluators { evaluator: evaluator } { authorized: true })
    (ok true)
  )
)

;; Submit an evaluation for a student
(define-public (submit-evaluation
  (student-id uint)
  (subject (string-ascii 30))
  (score uint)
  (comments (string-ascii 200)))
  (let (
    (student (unwrap! (map-get? students { student-id: student-id }) ERR_STUDENT_NOT_FOUND))
    (evaluator-authorized (default-to false (get authorized (map-get? evaluators { evaluator: tx-sender }))))
    (evaluation-id (+ (get evaluation-count student) u1))
  )
    (asserts! (or (is-eq tx-sender CONTRACT_OWNER) evaluator-authorized) ERR_UNAUTHORIZED)
    (asserts! (<= score u100) ERR_INVALID_SCORE)

    ;; Record the evaluation
    (map-set evaluations
      { student-id: student-id, evaluation-id: evaluation-id }
      {
        evaluator: tx-sender,
        subject: subject,
        score: score,
        comments: comments,
        timestamp: block-height
      }
    )

    ;; Update student record
    (map-set students
      { student-id: student-id }
      (merge student {
        total-score: (+ (get total-score student) score),
        evaluation-count: evaluation-id
      })
    )

    (ok evaluation-id)
  )
)

;; Create an award for a student
(define-public (create-award
  (student-id uint)
  (award-type uint)
  (amount uint)
  (reason (string-ascii 100)))
  (let (
    (student (unwrap! (map-get? students { student-id: student-id }) ERR_STUDENT_NOT_FOUND))
    (award-id (+ (var-get total-awards) u1))
  )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (and (>= award-type AWARD_EXCELLENCE) (<= award-type AWARD_MERIT)) ERR_INVALID_AWARD_TYPE)

    (map-set awards
      { award-id: award-id }
      {
        student-id: student-id,
        award-type: award-type,
        amount: amount,
        reason: reason,
        awarded-by: tx-sender,
        awarded-at: block-height,
        claimed: false
      }
    )

    ;; Update student awards count
    (map-set students
      { student-id: student-id }
      (merge student {
        awards-received: (+ (get awards-received student) u1)
      })
    )

    (var-set total-awards award-id)
    (ok award-id)
  )
)

;; Claim an award
(define-public (claim-award (award-id uint))
  (let (
    (award (unwrap! (map-get? awards { award-id: award-id }) ERR_AWARD_NOT_FOUND))
    (student (unwrap! (map-get? students { student-id: (get student-id award) }) ERR_STUDENT_NOT_FOUND))
  )
    (asserts! (is-eq tx-sender (get wallet student)) ERR_UNAUTHORIZED)
    (asserts! (not (get claimed award)) ERR_AWARD_NOT_FOUND)
    (asserts! (>= (var-get contract-balance) (get amount award)) ERR_INSUFFICIENT_FUNDS)

    ;; Mark award as claimed
    (map-set awards
      { award-id: award-id }
      (merge award { claimed: true })
    )

    ;; Transfer funds
    (var-set contract-balance (- (var-get contract-balance) (get amount award)))
    (unwrap! (stx-transfer? (get amount award) (as-contract tx-sender) (get wallet student)) ERR_INSUFFICIENT_FUNDS)

    (ok true)
  )
)

;; Deposit funds to the contract
(define-public (deposit-funds (amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (unwrap! (stx-transfer? amount tx-sender (as-contract tx-sender)) ERR_INSUFFICIENT_FUNDS)
    (var-set contract-balance (+ (var-get contract-balance) amount))
    (ok true)
  )
)

;; read only functions

;; Get student information
(define-read-only (get-student (student-id uint))
  (map-get? students { student-id: student-id })
)

;; Get student by wallet
(define-read-only (get-student-by-wallet (wallet principal))
  (match (map-get? student-by-wallet { wallet: wallet })
    student-lookup (map-get? students { student-id: (get student-id student-lookup) })
    none
  )
)

;; Get evaluation
(define-read-only (get-evaluation (student-id uint) (evaluation-id uint))
  (map-get? evaluations { student-id: student-id, evaluation-id: evaluation-id })
)

;; Get award
(define-read-only (get-award (award-id uint))
  (map-get? awards { award-id: award-id })
)

;; Calculate average score for a student
(define-read-only (get-average-score (student-id uint))
  (match (map-get? students { student-id: student-id })
    student (if (> (get evaluation-count student) u0)
              (some (/ (get total-score student) (get evaluation-count student)))
              (some u0))
    none
  )
)

;; Get contract statistics
(define-read-only (get-contract-stats)
  {
    total-students: (var-get total-students),
    total-awards: (var-get total-awards),
    contract-balance: (var-get contract-balance)
  }
)

;; Check if principal is authorized evaluator
(define-read-only (is-evaluator (evaluator principal))
  (default-to false (get authorized (map-get? evaluators { evaluator: evaluator })))
)

;; private functions

;; Get award type name
(define-read-only (get-award-type-name (award-type uint))
  (if (is-eq award-type AWARD_EXCELLENCE)
    "Excellence Award"
    (if (is-eq award-type AWARD_ACHIEVEMENT)
      "Achievement Award"
      (if (is-eq award-type AWARD_MERIT)
        "Merit Award"
        "Unknown Award"
      )
    )
  )
)
