# HEALTH-RECORDS

A blockchain-based medical record management system providing patients with full control over their health data while enabling secure provider access.

## Overview

HEALTH-RECORDS creates a patient-centric health data ecosystem where individuals own and control access to their medical information, ensuring privacy while enabling quality healthcare delivery.

## Features

- **Patient Ownership**: Complete control over medical record access and sharing
- **Provider Verification**: Licensed healthcare provider registration and verification
- **Granular Permissions**: Fine-grained read/write access control with expiration
- **Emergency Access**: Critical situation protocols for immediate care
- **Audit Trail**: Immutable record of all data access and modifications
- **Privacy Protection**: Encrypted storage with consent-based sharing

## Contract Functions

### Public Functions

- `register-provider(name, license, specialty)` - Register as healthcare provider
- `verify-provider(provider)` - Admin function to verify provider credentials
- `create-patient-profile(name, dob, emergency-contact, blood-type)` - Create patient profile
- `add-medical-record(patient, record-hash, record-type, emergency-access)` - Add medical record
- `grant-access(provider, read-access, write-access, duration)` - Grant provider access
- `revoke-access(provider)` - Revoke provider access permissions
- `emergency-access-record(record-id)` - Emergency access to critical records
- `set-emergency-mode(enabled)` - Admin function for system-wide emergency access
- `update-record-access(record-id, emergency-accessible)` - Update emergency access settings

### Read-Only Functions

- `get-patient-record(record-id)` - Retrieve medical record details
- `get-access-permission(patient, provider)` - Check provider access permissions
- `get-provider-info(provider)` - Get healthcare provider information
- `get-patient-profile(patient)` - Get patient profile information

## Usage

### For Patients
1. Create profile with `create-patient-profile`
2. Grant access to providers using `grant-access`
3. Monitor and revoke access as needed
4. Control emergency access settings per record

### For Healthcare Providers
1. Register with `register-provider`
2. Wait for admin verification
3. Request access from patients
4. Add records with appropriate permissions
5. Use emergency access only when necessary

## Security & Privacy

- **Encrypted Storage**: All records stored with encryption
- **Time-limited Access**: Provider permissions automatically expire
- **Emergency Protocols**: Critical care access without delays
- **Audit Logging**: Complete access history tracking
- **Patient Consent**: All access requires explicit patient permission

## Compliance

- Designed with HIPAA principles in mind
- Patient-controlled data sharing
- Immutable audit trails for compliance reporting
- Emergency access protocols for critical care
- Provider verification and licensing tracking
