Design Notes for the CUPS Sharing Server
========================================

Key Features:

- IPP System Service with IPP Print Service instances, Proxy support
- Identification, Authentication, and Authorization (IAA)
- Accounting
- Release Printing (PIN and/or other mechanisms)
- Print Policies (restricting who can print in color, print multiple copies,
  require release printing, etc.)
- DNS load balancing, replication, redundancy support
- Web interface


System Service:

- IPP System Service + IPP Shared Infrastructure Extensions implementation
- Local printers and job processing, shadow (remote) printers to support DNS
  load balancing


Three Kinds of Print Services:

- Direct/push printer (IPP Everywhere/AirPrint/Mopria)
- Release/pull printer (IPP Shared Infrastructure Extensions)
- Shadow printer (points to other servers, limited to basic status/description
  info)

Print services can also be linked to one or more incoming services (fan-in) that
also implement the Shared Infrastructure Extensions.

```
+----------+    +----------+    +----------+           +----------+
| Client A |    | Client B |    | Client C |    ...    | Client Z |
+----------+    +----------+    +----------+           +----------+
    /|\             /|\             /|\                    /|\
   v v v           v v v           v v v                  v v v
  1  2  N         1  2  N         1  2  N                1  2  N

        +----------+            +----------+           +----------+
        | System 1 |<---------->| System 2 |<---...--->| System N |
        +----------+            +----------+           +----------+
          |  |  |                 ^  ^   ^                   ^
          /  |   \                |  |   |                   |
         /   |    \              /   |    \          +----------------+
        /    |     \            /    |     \         | Backend System |
       /     |      \          /     |      \        +----------------+
      |      |       |        /      |       \         |     ^     |
      v      |       v       |       |       |         v     |     v
+---------+  |  +---------+  |  +---------+  |  +---------+  |  +---------+
| Printer |  |  | Printer |  |  | Release |  |  | Printer |  |  | Printer |
+---------+  |  +---------+  |  +---------+  |  +---------+  |  +---------+
             v               |               |               |
        +---------+     +---------+     +---------+     +---------+
        | Printer |     | Release |     | Release |     | Release |
        +---------+     +---------+     +---------+     +---------+
```


Identification, Authentication, and Authorization (IAA):

- HTTP Basic authentication using PAM
- OAuth 2.0 with OpenID-compliant providers (Google, others?)
- Access groups for printing, operator, admin stuff
- Printer visibility based on access groups


Accounting:

- Page counting w/details (B&W, color, blank, sides + pages)
- Page limit enforcement
- Transactions (pre-approval/reservation)
- Extension plug-in API (default plug-in to supply existing CUPS quota
  period/limit functionality)
- Reporting/billing plug-in API


Release Printing:

- "job-password" and/or IPP Shared Infrastructure Extensions pull configurations
- Configurable to require it (i.e. printer-mandatory-job-attributes with
  job-password or similar)
- INFRA configuration has a single user-visible queue with composite/configured
  capabilities.


Print Policies:

- Value/attribute deny filter based on user/group, e.g., don't allow color
  printing, copies, finishings, etc.
- Also required/requested attributes, policy page content


DNS Load Balancing:

- Support distributed printing via shadow printers - Clients can connect to a
  round-robin'd system/server, which points them at a particular server that
  handles traffic for a given printer.
- Systems replicate "shadow" printers for each of their peers so the Clients
  can see the full set of printers/state when connecting to an individual
  system (Get-Printers or Get-System-Attributes).
- Replication includes watchdog/heartbeat functionality to detect when a given
  system goes away.
- Clients still connect to a particular System when using a specific printer/
  print service.
- It is possible for multiple Systems to be front-end servers for a given
  release printer or backend system (for redundancy/load-balancing).
- TODO: hot backup support?


Web Interface:

- High-level dashboard to provide system-wide status/health
- Some level of configuration support (change location/contact info, for
  example)
