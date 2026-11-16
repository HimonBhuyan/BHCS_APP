# Blue Hour HQ — Agency Operating System (Mobile + Backend)

**Blue Hour HQ** is the flagship mobile business management, CRM, real-time team communication, project delivery, and financial intelligence platform built for **Blue Hour Creative Studios**.

> **One Business. One Team. One Workspace.**

---

## Repository Structure

```text
BHCS_APP/
├── mobile_app/          # Flutter (Android & iOS) mobile application
├── backend/             # Laravel REST API, Reverb WebSockets, Queues & PostgreSQL DDL
├── documentation/       # Architecture, Normalized Schema & Design System specs
├── deployment/          # Docker Compose, Nginx & Production VPS deployment configs
└── README.md
```

---

## Key Capabilities

1. **Executive Founder Dashboard**: Real-time agency KPIs (Total Leads, Conversion Rate, Monthly Revenue in INR, Active Clients/Projects, Pending Follow-ups), interactive revenue & conversion analytics (`fl_chart`), service-wise breakdown, and AI Business Assistant.
2. **Agency CRM & 8-Stage Lead Pipeline**: Toggle between Kanban Pipeline (`New Lead` → `Contacted` → `Meeting Scheduled` → `Requirement Gathering` → `Proposal Sent` → `Negotiation` → `Converted` / `Lost`) and filtered list views, one-tap Call/WhatsApp/Email actions, follow-up reminder scheduling, and instant Lead-to-Client conversion.
3. **Internal Real-Time Chat (Reverb WebSockets)**: Department & project channels (`#general`, `#management`, `#sales-leads`, `#development`, `#design-team`, `#social-media`, `#client-projects`, `#announcements`), 1-on-1 DMs, voice notes, file attachments, reactions, read receipts, and presence indicators.
4. **Project & Task Delivery Engine**: Agency service categories, milestone tracking, subtasks, dependencies, logged hours, and workload monitoring.
5. **Meeting & Calendar Management**: Daily/monthly interactive calendar, online meeting deep links, participant invites, and automated multi-interval push reminders (`1d`, `1h`, `15m`, `0m`).
6. **Proposals, Quotations & INR Finance**: GST-ready proposals and invoices (`CGST`/`SGST`/`IGST`), advance payment tracking, expense management, and role-restricted financial analytics.
7. **Central Notification Centre & Daily Founder Briefing**: Categorized notification feed, quiet hours, granular preferences, and configurable morning executive summary.

---

## Running the Flutter Mobile App

```bash
cd mobile_app
flutter pub get
flutter run
```

