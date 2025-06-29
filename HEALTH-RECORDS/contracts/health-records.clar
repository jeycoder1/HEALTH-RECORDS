;; Medical Records Management Contract
;; Patient-controlled health data with provider access

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u600))
(define-constant err-unauthorized (err u601))
(define-constant err-record-not-found (err u602))
(define-constant err-invalid-permission (err u603))
(define-constant err-emergency-only (err u604))

(define-data-var record-counter uint u0)
(define-data-var emergency-mode bool false)

(define-map patient-records uint {
  patient: principal,
  record-hash: (string-ascii 64),
  record-type: (string-ascii 50),
  provider: principal,
  timestamp: uint,
  emergency-accessible: bool,
  encrypted: bool
})

(define-map access-permissions {patient: principal, provider: principal} {
  read-access: bool,
  write-access: bool,
  expiry: uint,
  granted-at: uint
})

(define-map healthcare-providers principal {
  name: (string-ascii 100),
  license-number: (string-ascii 50),
  specialty: (string-ascii 50),
  verified: bool
})

(define-map patient-profiles principal {
  name: (string-ascii 100),
  date-of-birth: uint,
  emergency-contact: principal,
  blood-type: (string-ascii 10)
})

(define-read-only (get-patient-record (record-id uint))
  (map-get? patient-records record-id)
)

(define-read-only (get-access-permission (patient principal) (provider principal))
  (map-get? access-permissions {patient: patient, provider: provider})
)

(define-read-only (get-provider-info (provider principal))
  (map-get? healthcare-providers provider)
)

(define-read-only (get-patient-profile (patient principal))
  (map-get? patient-profiles patient)
)

(define-public (register-provider (name (string-ascii 100)) (license (string-ascii 50)) (specialty (string-ascii 50)))
  (map-set healthcare-providers tx-sender {
    name: name,
    license-number: license,
    specialty: specialty,
    verified: false
  })
  (ok true)
)

(define-public (verify-provider (provider principal))
  (asserts! (is-eq tx-sender contract-owner) err-owner-only)
  (let ((provider-info (unwrap! (get-provider-info provider) err-record-not-found)))
    (map-set healthcare-providers provider (merge provider-info {verified: true}))
    (ok true)
  )
)

(define-public (create-patient-profile (name (string-ascii 100)) (dob uint) (emergency-contact principal) (blood-type (string-ascii 10)))
  (map-set patient-profiles tx-sender {
    name: name,
    date-of-birth: dob,
    emergency-contact: emergency-contact,
    blood-type: blood-type
  })
  (ok true)
)

(define-public (add-medical-record (patient principal) (record-hash (string-ascii 64)) (record-type (string-ascii 50)) (emergency-access bool))
  (let ((provider-info (unwrap! (get-provider-info tx-sender) err-unauthorized))
        (permission (get-access-permission patient tx-sender))
        (record-id (+ (var-get record-counter) u1)))
    
    (asserts! (get verified provider-info) err-unauthorized)
    (asserts! (or (is-some permission)
                  (var-get emergency-mode)) err-unauthorized)
    
    (map-set patient-records record-id {
      patient: patient,
      record-hash: record-hash,
      record-type: record-type,
      provider: tx-sender,
      timestamp: block-height,
      emergency-accessible: emergency-access,
      encrypted: true
    })
    
    (var-set record-counter record-id)
    (ok record-id)
  )
)

(define-public (grant-access (provider principal) (read-access bool) (write-access bool) (duration uint))
  (let ((provider-info (unwrap! (get-provider-info provider) err-record-not-found)))
    (asserts! (get verified provider-info) err-unauthorized)
    (map-set access-permissions {patient: tx-sender, provider: provider} {
      read-access: read-access,
      write-access: write-access,
      expiry: (+ block-height duration),
      granted-at: block-height
    })
    (ok true)
  )
)

(define-public (revoke-access (provider principal))
  (map-delete access-permissions {patient: tx-sender, provider: provider})
  (ok true)
)

(define-public (emergency-access-record (record-id uint))
  (let ((record (unwrap! (get-patient-record record-id) err-record-not-found))
        (provider-info (unwrap! (get-provider-info tx-sender) err-unauthorized)))
    
    (asserts! (get verified provider-info) err-unauthorized)
    (asserts! (or (get emergency-accessible record)
                  (var-get emergency-mode)) err-emergency-only)
    
    (ok record)
  )
)

(define-public (set-emergency-mode (enabled bool))
  (asserts! (is-eq tx-sender contract-owner) err-owner-only)
  (var-set emergency-mode enabled)
  (ok true)
)

(define-public (update-record-access (record-id uint) (emergency-accessible bool))
  (let ((record (unwrap! (get-patient-record record-id) err-record-not-found)))
    (asserts! (is-eq tx-sender (get patient record)) err-unauthorized)
    (map-set patient-records record-id (merge record {emergency-accessible: emergency-accessible}))
    (ok true)
  )
)
