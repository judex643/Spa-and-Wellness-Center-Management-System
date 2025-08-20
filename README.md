# Spa and Wellness Center Management System

A comprehensive blockchain-based management system for spa and wellness centers built with Clarity smart contracts on the Stacks blockchain.

## Overview

This system provides a complete solution for managing spa and wellness center operations, including:

- **Client Management**: Secure handling of client health histories and treatment preferences
- **Therapist Certification**: Tracking and verification of therapist qualifications and certifications
- **Treatment Scheduling**: Efficient booking and scheduling system for treatments and appointments
- **Pricing & Packages**: Transparent pricing management and package deals
- **Outcome Tracking**: Customer satisfaction measurement and treatment outcome monitoring

## Architecture

The system consists of five interconnected Clarity smart contracts:

### 1. Client Management Contract (`client-management.clar`)
- Manages client profiles and health histories
- Stores treatment preferences and allergies
- Handles privacy and data protection
- Tracks client membership status

### 2. Therapist Certification Contract (`therapist-certification.clar`)
- Manages therapist profiles and qualifications
- Tracks certification status and expiration dates
- Handles skill specializations and ratings
- Manages availability schedules

### 3. Treatment Scheduling Contract (`treatment-scheduling.clar`)
- Handles appointment booking and cancellations
- Manages treatment room assignments
- Tracks appointment history
- Handles scheduling conflicts and availability

### 4. Pricing and Package Management Contract (`pricing-packages.clar`)
- Manages service pricing and package deals
- Handles membership discounts and promotions
- Tracks package usage and expiration
- Manages payment processing integration

### 5. Outcome Tracking Contract (`outcome-tracking.clar`)
- Records treatment outcomes and client feedback
- Tracks satisfaction ratings and reviews
- Manages follow-up scheduling
- Generates analytics and reports

## Key Features

### Security & Privacy
- Client health information is encrypted and access-controlled
- Role-based permissions for staff and management
- Audit trails for all sensitive operations
- HIPAA-compliant data handling practices

### Transparency
- Clear pricing structure with no hidden fees
- Public therapist certifications and ratings
- Treatment outcome statistics
- Service quality metrics

### Efficiency
- Automated scheduling and conflict resolution
- Package tracking and usage optimization
- Integrated payment processing
- Real-time availability updates

## Data Types

### Client Data
- Personal information (name, contact, emergency contacts)
- Health history and medical conditions
- Treatment preferences and allergies
- Membership status and package usage

### Therapist Data
- Professional qualifications and certifications
- Specialization areas and skill levels
- Availability schedules and preferences
- Performance ratings and client feedback

### Treatment Data
- Service descriptions and duration
- Pricing and package information
- Room and equipment requirements
- Outcome tracking and follow-up needs

## Smart Contract Functions

### Read Functions
- Get client profile and preferences
- Check therapist availability and certifications
- View pricing and package information
- Access treatment history and outcomes

### Write Functions
- Register new clients and therapists
- Book and manage appointments
- Process payments and package usage
- Record treatment outcomes and feedback

## Testing

The system includes comprehensive test coverage using Vitest:
- Unit tests for all contract functions
- Integration tests for cross-contract interactions
- Edge case testing for error handling
- Performance testing for scalability

## Deployment

Contracts are deployed on the Stacks blockchain and can be integrated with:
- Web applications for client and staff interfaces
- Mobile apps for on-the-go management
- Third-party payment processors
- Analytics and reporting tools

## Getting Started

1. Install dependencies: `npm install`
2. Run tests: `npm test`
3. Deploy contracts: `clarinet deploy`
4. Integrate with your frontend application

## License

This project is licensed under the MIT License - see the LICENSE file for details.
